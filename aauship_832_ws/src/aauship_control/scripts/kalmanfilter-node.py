#!/usr/bin/env python2
# Kalman filter example demo in Python

import roslib; roslib.load_manifest('aauship_control')

import rospy
from std_msgs.msg import String
from aauship_control.msg import *
from std_msgs.msg import Float64MultiArray, Header
from geometry_msgs.msg import Point, Quaternion, PoseStamped, Pose
import tf
from math import sin, cos
import kalmanfilterfoo as kfoo # temporary implementation for the simulation
from nav_msgs.msg import Path

import numpy as np
import scipy.io as sio
import scipy.linalg as linalg
from math import pi, fmod
import gpsfunctions as geo

class KF(object):
    def __init__(self):
        # Load discretised model constants
        self.ssmat = sio.loadmat('ssaauship.mat')

        self.tau = np.zeros(5) # input vector
        self.x = np.zeros(17) # state vector
        self.x[0] = 20
        self.x_hat = self.x
        self.x_hat[0] = -40
        self.x_hat[1] = -50

        # Measurement noise vector and covarince matrix
        self.v = np.array([0.1,0.1,13.5969e-006,0.2,0.2,0.033,0.033])#Measurement,noise
        self.P_plus = np.zeros([17,17])
        self.R = np.diag(self.v)
        self.R_i = np.diag(self.v)

        # Initialisation of thruster input variables
        self.rightthruster = 0
        self.leftthruster = 0

        # Construct kalmanfilterfoo, because it contains the aaushipsimmodel function
        self.f = kfoo.KF()

        # Process noise vector and covariance matrix
        self.w = np.array([0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.01, 0.01, 0.01, 0.01, 0.01, 0.033, 0.033, 0.033, 0.033, 0.033])
        self.Q = np.diag(self.w)
        self.no_of_states = 17

        # Measurement vector
        self.z = np.zeros(7)
        self.z[0] = 20

        self.kftrackpath = rospy.Publisher('kftrack', Path, queue_size=3)
        self.kftrackmsg = Path()
        self.kftrackmsg.header.frame_id = "ned"

        # Static rotation matrix
        self.klingen = sio.loadmat('klingenberg.mat')
        self.Rn2e = geo.RNED2ECEF(self.klingen['rotlon'], self.klingen['rotlat'])
        self.Re2n = self.Rn2e.T
        self.pos_of_ned_in_ecef = geo.wgs842ecef(self.klingen['rotlat'], self.klingen['rotlon'])
        self.fjorden = sio.loadmat('fjorden.mat')

        # Define the path poses for the map to display in rviz
        self.refmsg = Path()
        self.refmsg.header.frame_id = "ned"
        self.keepoutmsg = Path()
        self.keepoutmsg.header.frame_id = "ned"
        q = Quaternion(0,0,0,1)
        h = Header()

        offset = 3
        for i in self.klingen['outer']:
            p = Point(i[0]-offset,i[1],0)
            self.refmsg.poses.append(PoseStamped(h, Pose(p, q)))
        for i in self.klingen['inner']:
            p = Point(i[0]-offset,i[1],0)
            self.keepoutmsg.poses.append(PoseStamped(h, Pose(p, q)))
        for i in self.fjorden['all']:
            p = Point(i[0]-offset,i[1],0)
            self.keepoutmsg.poses.append(PoseStamped(h, Pose(p, q)))

        # Topics
        self.subgps1 = rospy.Subscriber('gps1', GPS, self.gps1cb)
        self.subgps2 = rospy.Subscriber('gps2', GPS, self.gps2cb)
        self.subimu  = rospy.Subscriber('imu', ADIS16405, self.imucb)
        self.subahrs = rospy.Subscriber('attitude', Quaternion, self.ahrscb)
        self.sub = rospy.Subscriber('lli_input', LLIinput, self.llicb)
        self.pub = rospy.Publisher('kf_statesnew', KFStates, queue_size=1)
        self.refpath = rospy.Publisher('refpath', Path, queue_size=3, latch=True)
        self.keepoutpath = rospy.Publisher('keepout', Path, queue_size=3, latch=True)
        
        # Initialise pose for the graphic path segment for rviz
        h = Header()
        p = Point(0,0,0)
        q = Quaternion(0,0,0,1)
        self.kftrackmsg.poses.append(PoseStamped(h, Pose(p, q)))
        self.kftrackmsg.poses.append(PoseStamped(h, Pose(p, q)))

        # Initialize common variables
        self.roll = 0
        self.pitch = 0
        self.yaw = 0
        self.rightthruster = 0
        self.leftthruster = 0

        rospy.init_node('kalmanfilter_node')


    # /lli_input callback (same as in the simulation node) TODO move to another file?
    def llicb(self, data):
        #print('/lli_input callback')
        if data.MsgID == 5:
            self.rightthruster = data.Data

        if data.MsgID == 3:
            self.leftthruster = data.Data
        

        if self.rightthruster > 0:
            self.rightthruster = self.rightthruster -40
        if self.rightthruster < 0:
            self.rightthruster = self.rightthruster +40

        if self.leftthruster > 0:
            self.leftthruster = self.leftthruster -40
        if self.leftthruster < 0:
            self.leftthruster = self.leftthruster +40


        #print(self.leftthruster, self.rightthruster)

        # Thust allocation matrix from calcTforthrustalloc.m
        self.T = np.matrix([[      0,         0,    0.9946,    0.9946],
                            [ 1.0000,    1.0000,         0,         0],
                            [-0.0500,   -0.0500,    0.0052,   -0.0052],
                            [      0,         0,    0.0995,    0.0995],
                            [ 0.4100,   -0.1800,   -0.0497,    0.0497]])

        self.T = self.T[:,2:4] # Reducing our thrust allocation to only ues the main propellers

        # Thust coefficient matrix
        #self.K = np.eye(4)
        self.K = np.eye(2) # Reducing our thrust allocation to only ues the main propellers
        self.K[0,0] = 0.26565
        self.K[1,1] = 0.26565

        # Calculation of forces from the input vector
        #self.u = np.array([0,0,self.rightthruster,self.leftthruster]) 
        self.u = np.array([self.rightthruster,self.leftthruster]) # Reducing our thrust allocation to only ues the main propellers
        self.tau = np.squeeze( np.asarray( self.T.dot(self.K.dot(self.u)) ) )

        # inv(K)*pinv(T)*tau
        #print(self.tau)


    # GPS1 callback
    def gps1cb(self, data):
        #z = [N E psi u v udot vdot]

        # Positoin in NED
        # This seems to only be approximate
        pos_ecef = geo.wgs842ecef(data.latitude, data.longitude, 0.0)
        pos_ned = self.Re2n.dot( pos_ecef - self.pos_of_ned_in_ecef )
        self.z[0:2] =  np.squeeze( pos_ned[0:2] )
        #print((self.z[0], self.z[1]))        

        # Body velocities
        #print('')
        #print('track angle: ' + str(data.track_angle))
        #print('heading ang: ' + str(self.z[2]))
        beta = data.track_angle - self.z[2] # sideslip angle = track_angle - heading
        #print(beta)
        U_b = np.array([cos(beta), sin(beta)]) * data.SOG
        self.z[3:5] = np.squeeze( U_b )
        #print(self.z[3:5])
        #print('GPS recieved')

        self.R[0,0] = self.R_i[0,0]
        self.R[1,1] = self.R_i[1,1]
        self.R[3,3] = self.R_i[3,3]
        self.R[4,4] = self.R_i[4,4]

    # GPS2 callback
    def gps2cb(self, data):
        print('GPS2 is not implemented yet')

    # IMU callback
    # We just use the IMU callback to call the Kalman filter, becaue
    # it is easier, and it has a much higher sample rate than the
    # kalman filter. We should make sure we only use a GPS measurement
    # from a GPS only once. We can do that by checking the sequence
    # number of the GPS header.
    def imucb(self, data):
        #self.KalmanF()
        #print(data)

        # TODO calculate the measurement vector z and compare this constructed z with the one from the simulation node
        Rn2b = geo.RNED2BODY(self.roll, self.pitch, self.yaw)
        a_imu = np.array([data.xaccl, data.yaccl, data.zaccl])
        gravity = Rn2b.dot(np.array([0,0,9.82]))
        #print('gravity ' + str(gravity))
        a_b = a_imu - gravity
        #print('a_xb ' + str(a_b[0,0]))
        #print('a_yb ' + str(a_b[0,1]))
        #print('a_zb ' + str(a_b[0,2]))
        #print(a_b)
        #print('')
        self.z[5:7] = np.array([a_b[0,0], a_b[0,1]]) # TODO is the entirely correct? Maybe the sign is opposite?
        #print(str(self.z[2]) + "kal")
        #print('Kalmanfilter node')
        #print('N:   ' + str(self.z[0]))
        #print('E:   ' + str(self.z[1]))
        #print('psi: ' + str(self.z[2]))
        #print('u:   ' + str(self.z[3]))
        #print('v:   ' + str(self.z[4]))
        #print('du:  ' + str(self.z[5]))
        #print('dv:  ' + str(self.z[6]))
        #print('')

        # TODO move the KF stuff from the simulation node in here, now it should still work
        ### move to kalmanfilter-node start ###
        
        # Headpoint of trail track
        p = Point(self.x_hat[0],self.x_hat[1],0.0)
        q = Quaternion(0,0,0,1)
        self.kftrackmsg.poses[0] = PoseStamped(Header(), Pose(p, q))

        (self.x_hat,self.P_plus) = self.f.KalmanF(self.x_hat, self.tau, self.z, self.P_plus, self.R)
        
        self.R[0,0] = 10*10**10;
        self.R[1,1] = 10*10**10;
        self.R[3,3] = 10*10**10;
        self.R[4,4] = 10*10**10;

        # Endpoint of trail track
        p = Point(self.x_hat[0],self.x_hat[1],0.0)
        q = Quaternion(0,0,0,1)
        self.kftrackmsg.poses[1] = PoseStamped(Header(), Pose(p, q))
        self.kftrackpath.publish(self.kftrackmsg)


        self.pubmsg = KFStates()
        #print "x_hat: "
        #print self.x_hat

        self.pubmsg.x = self.x_hat[0]
        self.pubmsg.y = self.x_hat[1]
        self.pubmsg.psi = self.x_hat[6]

        #ALTERATION 20/03/17

        self.pubmsg.phi = self.x_hat[4]
        self.pubmsg.theta = self.x_hat[5]
        self.pubmsg.u = self.x_hat[7]
        self.pubmsg.v = self.x_hat[8]
        self.pubmsg.p = self.x_hat[9]
        self.pubmsg.q = self.x_hat[10]
        self.pubmsg.r = self.x_hat[11]

        #ALTERATION END

        self.pub.publish(self.pubmsg)
        #print(self.pubmsg)
   
        ### move to kalmanfilter-node end ###


        # This transformation seesm to not be nessesary, this will make the
        # kalmanfilter-node estimate dead reckon in the wrong direction. Looks
        # mirrored around the North axis.
        '''
        v = tf.transformations.quaternion_from_euler(0,0,0)
        imuq = tf.transformations.quaternion_from_euler(self.roll,self.pitch,self.yaw)
        vimuq = tf.transformations.quaternion_multiply(v,imuq)
        neweuler = tf.transformations.euler_from_quaternion(vimuq)

        self.x_hat[4] = neweuler[0]
        self.x_hat[5] = neweuler[1]
        self.x_hat[6] = neweuler[2]
        '''
        '''
        self.x_hat[4] = self.roll
        self.x_hat[5] = self.pitch
        self.x_hat[6] = self.yaw
        '''

        # Send tf for the robot model visualisation
        '''
        br = tf.TransformBroadcaster()
        br.sendTransform((self.x_hat[0],self.x_hat[1], 0),
                         tf.transformations.quaternion_from_euler(self.x_hat[4], self.x_hat[5], self.x_hat[6]),
                         #tf.transformations.quaternion_from_euler(self.roll, self.pitch, self.yaw),
                         rospy.Time.now(),
                         "boat_link",
                         "ned")
        '''
        pass

    def ahrscb(self, data):
        (self.roll, self.pitch, self.yaw) = tf.transformations.euler_from_quaternion([data.x, data.y, data.z, data.w])

        #print('attitude before: ' + str((self.roll, self.pitch, self.yaw)))
        #Rm2n  = geo.RNED2BODY(pi/2, 0, pi )
        #att = Rm2n.dot(np.array([self.roll, self.pitch, self.yaw]))
        #print(att)
        #print( (self.roll, self.pitch, self.yaw))

        self.yaw = fmod( self.yaw+2*pi+pi/2+pi/2, 2*pi)
        self.z[2] = self.yaw
        #print('attitude after: ' + str((self.roll, self.pitch, self.yaw)))
        #print('')

    def run(self):
        '''
        # Testing code for the KF
        x = np.array([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]) # state vector
        u = np.array([8,0,0,0,0]) # input vector
        z = np.array([1,1,1,1,1,1,1]) # measurement vector

        self.P_plus = np.zeros([17,17])
        R = np.diag([3.0, 3.0, 13.5969, 0.1, 0.1, 0.0524, 0.0524])
        (xest,self.P_plus) = self.KalmanF(x, u, z, self.P_plus, R)
        print(self.P_plus)
        '''
        # Do the publishing of the mission boundary path and keeoput
        # zone
        self.refpath.publish(self.refmsg)
        self.keepoutpath.publish(self.keepoutmsg)
        
        rospy.spin()

        print("Exiting kalmanfilter node")
        exit()



if __name__ == '__main__':
    w = KF()
    w.run()
