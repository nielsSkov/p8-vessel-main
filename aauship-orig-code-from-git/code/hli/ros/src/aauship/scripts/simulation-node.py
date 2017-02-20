#!/usr/bin/env python2

import roslib; roslib.load_manifest('aauship')

import rospy
from std_msgs.msg import Float64MultiArray, Header
from nav_msgs.msg import Path
from geometry_msgs.msg import Point, Quaternion, PoseStamped, Pose
from aauship.msg import *
import tf
import scipy.io as sio
import kalmanfilterfoo as kfoo # temporary implementation for the simulation
import gpsfunctions as geo
import numpy as np
from math import pi, sqrt, atan2, acos, sin, fmod, cos
import scipy.linalg as linalg
import time
import os

# GPS frequencey counter
jj = 0

# Counter for figuring out when to add the GPS sample
k = 0



## This is the simulaiton node, basically kind of the same as simaauship.m
class Simulator(object):
    def __init__(self):
        self.thrustdiff = 0
        self.tau = np.zeros(5) # input vector
        self.x = np.zeros(17) # state vector
        self.x[0] = -40
        self.x[1] = -50

        self.x_hat = self.x
        self.v = np.array([0.1,0.1,13.5969e-006,0.2,0.2,0.00033,0.00033])#Measurement,noise
        self.z = np.zeros(7)
        
        self.P_plus = np.zeros([17,17])
        self.R = np.diag(self.v)
        self.R_i = np.diag(self.v)
        
        self.old_z = np.ones(7) # Used for calculation of speed over ground and track angle for the GPS

        # Construct kalmanfilterfoo, because it contains the aaushipsimmodel function
        self.f = kfoo.KF()

        self.roll = 0
        self.pitch = 0
        self.yaw = 0
        self.rightthruster = 0
        self.leftthruster = 0
        
        rospy.init_node('simulation_node')
        self.r = rospy.Rate(20) # Hz

        self.sub = rospy.Subscriber('lli_input', LLIinput, self.llicb)
        self.pub = rospy.Publisher('kf_states', Float64MultiArray, queue_size=1) # This should eventually be removed when the kf-node is tested against this
        self.subahrs = rospy.Subscriber('attitude', Quaternion, self.ahrscb) # Should be removed from here when the kf-node is tested against this
        self.pubimu = rospy.Publisher('imu', ADIS16405, queue_size=1, latch=True)
        self.trackpath = rospy.Publisher('track', Path, queue_size=3)
        self.pubgps1 = rospy.Publisher('gps1', GPS, queue_size=1, latch=False)

        # Construct variables for messages
        self.imumsg = ADIS16405()
        self.pubmsg = Float64MultiArray()
        self.trackmsg = Path()
        self.trackmsg.header.frame_id = "ned"
        self.gpsmsg = GPS()

        # Load external staitc map and path data
        self.klingen = sio.loadmat('klingenberg.mat')
        self.path = sio.loadmat('../../../../../matlab/2mmargintrack.mat')
        
        # Static rotation matrix
        self.Rn2e = geo.RNED2ECEF(self.klingen['rotlon'], self.klingen['rotlat'])
        self.pos_of_ned_in_ecef = geo.wgs842ecef(self.klingen['rotlat'], self.klingen['rotlon'])

        # Variables for the thrusters
        self.leftthruster = 0.0
        self.rightthruster = 0.0

        h = Header()
        q = Quaternion(0,0,0,1)

    # /lli_input callback (same as in the kalmanfilter node) TODO move to another file?
    def llicb(self, data):
        #print('/lli_input callback')
        if data.MsgID == 3:
            self.rightthruster = data.Data

        if data.MsgID == 5:
            self.leftthruster = data.Data

        # Saturation in inputs
        threshold = 40


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

	
    # /attidude callback
    def ahrscb(self, data):
        #print(data.data[0])

        global k
        global jj

        # Generate noise vector data from IMU
        ###self.z[2]   = fmod(self.x[6]+2*pi, 2*pi) #+ self.v[2]*np.random.randn(1,1)
        (self.roll, self.pitch, self.yaw) = tf.transformations.euler_from_quaternion([data.x, data.y, data.z, data.w])
        self.yaw = fmod( self.yaw+2*pi+pi/2+pi/2, 2*pi)
        self.z[2] = self.yaw

        self.z[3:5] = self.x[7:9] #+ np.array([self.v[3],self.v[4]])*np.random.randn(1,2)


        # Simulating that GPS is only once a second
        # WARNING magic number here
        if k%20 != 0:
            self.R[0,0] = 10*10**10;
            self.R[1,1] = 10*10**10;
            self.R[3,3] = 10*10**10;
            self.R[4,4] = 10*10**10;
        else:
            self.R[0,0] = self.R_i[0,0]
            self.R[1,1] = self.R_i[1,1]
            self.R[3,3] = self.R_i[3,3]
            self.R[4,4] = self.R_i[4,4]
            jj = jj+1;

            # Generate noise vector data from GPS
            self.z[0:2] = self.x[0:2] #+ np.array([self.v[0],self.v[1]])*np.random.randn(1,2)
            self.z[5:7] = self.x[12:14] #+ np.array([self.v[5],self.v[6]])*np.random.randn(1,2)

            print('Setting self.z GPS')
            # NED to ECEF
            pos_ecef = self.Rn2e.dot( np.matrix([[self.x[0]], [self.x[1]], [0]]) ) + self.pos_of_ned_in_ecef

            # ECEF to WGS84
            pos_wgs84 = geo.ecef2wgs82(pos_ecef[0], pos_ecef[1], pos_ecef[2])

            self.gpsmsg.latitude = pos_wgs84['lat']
            self.gpsmsg.longitude = pos_wgs84['lon']

            self.gpsmsg.SOG = sqrt( (self.old_z[0]-self.z[0])**2 + (self.old_z[1]-self.z[1])**2 )

            self.gpsmsg.track_angle = fmod(atan2(self.z[1]-self.old_z[1] , self.z[0]-self.old_z[0])+2*pi, 2*pi) # angle between new and last GPS position
            #print(self.gpsmsg.track_angle)
            self.pubgps1.publish(self.gpsmsg)
            print('Publishing GPS')

            #print(self.z[0:2])
            self.old_z = self.z.copy() # used to calculate SOG and track_angles

        #print(self.old_z)
        #print(str(self.z[2]) + "sim")
        print('Simulation node')
        print('N:   ' + str(self.z[0]))
        print('E:   ' + str(self.z[1]))
        print('psi: ' + str(self.z[2]))
        print('u:   ' + str(self.z[3]))
        print('v:   ' + str(self.z[4]))
        print('du:  ' + str(self.z[5]))
        print('dv:  ' + str(self.z[6]))
        print('')
        
        ### move to kalmanfilter-node start ###
        (self.x_hat,self.P_plus) = self.f.KalmanF(self.x_hat, self.tau, self.z, self.P_plus, self.R)
        
        self.pubmsg = Float64MultiArray()
        for a in self.x_hat:
            self.pubmsg.data.append(a)
            #print(a)
        self.pub.publish(self.pubmsg)
        #print(self.pubmsg)

        ### move to kalmanfilter-node end ###

        # Send tf for the robot model visualisation
        '''
        br = tf.TransformBroadcaster()
        br.sendTransform((self.x[0],self.x[1], 0),
                         tf.transformations.quaternion_from_euler(self.x[4], self.x[5], self.x[6]),
                         rospy.Time.now(),
                         "boat_link",
                         "ned")
        '''

        # Endpoint of trail track
        #p = Point(self.x[0],self.x[1],0.0)
        p = Point(self.x_hat[0],self.x_hat[1],0.0)
        q = Quaternion(0,0,0,1)
        self.trackmsg.poses[1] = PoseStamped(Header(), Pose(p, q))
        self.trackpath.publish(self.trackmsg)

        k = k+1

    def run(self):
        # Initialize an poses array for the trackmsg
        h = Header()
        p = Point(0,0,0)
        q = Quaternion(0,0,0,1)
        self.trackmsg.poses.append(PoseStamped(h, Pose(p, q)))
        self.trackmsg.poses.append(PoseStamped(h, Pose(p, q)))


        self.x_hat = self.x
        self.path['track'] = np.append([[self.x[0],self.x[1]]], self.path['track'], axis=0)
        # Main loop
        while not rospy.is_shutdown():
            # Headpoint of trail track
            #p = Point(self.x[0],self.x[1],0.0)
            p = Point(self.x_hat[0],self.x_hat[1],0.0)
            q = Quaternion(0,0,0,1)
            self.trackmsg.poses[0] = PoseStamped(h, Pose(p, q))

            # Her skal u subscripe til lli input
            ##self.tau = np.array([8,0,0,0,self.thrustdiff])

            # Simulation
            self.x = self.f.aaushipsimmodel(self.x,self.tau)
            #self.pubmsg.data = self.x
            
            # Calculate the IMU measurements from the aaushipsimmodel
            Rn2b = geo.RNED2BODY(self.x[4],self.x[5],self.x[6])
            accelbody = np.array([self.x[12], self.x[13], 0])
            gravity = Rn2b.dot(np.array([0,0,9.82]))
            #print('gravity ' + str(gravity))
            accelimu = accelbody + gravity

            declination = 2.1667*pi/180 # angle from north
            inclination = 70.883*pi/180 # angle from north-east plane
            magnimu = geo.RNED2BODY(self.x[4],self.x[5],self.x[6]).T.dot(np.array([0,inclination,declination]))

            self.imumsg.xgyro = self.x[14] # dot_p
            self.imumsg.ygyro = self.x[15] # dot_q
            self.imumsg.zgyro = self.x[16] # dot_r
            self.imumsg.xaccl = accelimu.item(0)
            self.imumsg.yaccl = accelimu.item(1)
            self.imumsg.zaccl = accelimu.item(2)
            self.imumsg.xmagn = magnimu.item(0)
            self.imumsg.ymagn = magnimu.item(1)
            self.imumsg.zmagn = magnimu.item(2)

            # Call AHRS node either Mahony or Madgwick
            # Publish the calculated measurements for /imu
            self.pubimu.publish(self.imumsg)

            # This part is basically waiting for the arhs node to publish to the /attitude topic
            # Idle loop untill the /ahrs_* publishses to /attitude
            before = time.time()
            #print("waiting for topic")
            rospy.wait_for_message('attitude', Quaternion, timeout=1)
            #print("recieved topic " + str(time.time()-before))

            #rospy.signal_shutdown("testing")

            #print(time.time())

            self.r.sleep()
        
        print("Exiting simulation node")
        exit()

if __name__ == '__main__':
    w = Simulator()
    w.run()

