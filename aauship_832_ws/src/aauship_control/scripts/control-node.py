#!/usr/bin/env python2

import roslib; roslib.load_manifest('aauship')

import rospy
from std_msgs.msg import String, Float64MultiArray, Header
from geometry_msgs.msg import Point, Quaternion, PoseStamped, Pose
from aauship.msg import *
from nav_msgs.msg import Path
import scipy.io as sio
import scipy.linalg as linalg
import numpy as np
from math import pi, sqrt, atan2, acos, sin, fmod
import time
import os 
import tf

## This is the control node
class Control(object):
    def __init__(self):
        self.k = 0        
        self.n = 1 # used for wp gen logic

        rospy.init_node('control_node')
        self.sub = rospy.Subscriber('kf_statesnew', Float64MultiArray, self.callback, queue_size=1)
        #self.sub = rospy.Subscriber('kf_states', Float64MultiArray, self.callback, queue_size=1)
        self.pub = rospy.Publisher('lli_input', LLIinput, queue_size=4, latch=True)

        # Initilaze parameters for the simple PID heading contorller
        self.error = []
        self.integral = []
        self.integral.append(0)
        self.derivative = []
        self.derivative.append(0)
        self.thrustdiff =[]
        self.thrustdiff.append(0)
        
        # PID tuning parameters for the simple heading controller
        '''
        self.Kp = 0.1
        self.Ki = 0.0
        self.Kd = 0.0
        '''
        '''
        self.Kp = 3.0
        self.Ki = 0.0
        self.Kd = 35.0
        '''
	''' 
        self.Kp = 3.0
        self.Ki = 0.0
        self.Kd = 60.0
        '''
        self.Kp = 2.0
        self.Ki = 0.0
        self.Kd = 70.0

        # Create path object in rviz
        self.pubpath = rospy.Publisher('path', Path, queue_size=3, latch=True)

        # Create the struct to be printed
        self.pathmsg = Path()

        # Assign frame
        self.pathmsg.header.frame_id = "ned"
        h = Header()
        q = Quaternion(0,0,0,1)

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

        # Load the lawnmower generated path
        # Original track
        #self.path = sio.loadmat('../../../../../matlab/2mmargintrack.mat')
        # Original track, just smaller
        #self.path = sio.loadmat('../../../../../matlab/lawnmoversmall.mat')
        # Only a line segment in the middle
        #self.path = sio.loadmat('../../../../../matlab/linesegment.mat')
        # Just a simple triangle wp
        #self.path = sio.loadmat('../../../../../matlab/triangletrack.mat')
        # Just a small line segment in the cornor
        #self.path = sio.loadmat('../../../../../matlab/verysmalllinesegment.mat')
        # FJORDEN zig-zag
        #self.path = sio.loadmat('../../../../../matlab/fjordtriangle.mat')
        # FJORDEN one long line segment
        self.path = sio.loadmat('../../../../../matlab/fjordlinesegment.mat')
        # FJORDEN one half long line segment
        #self.path = sio.loadmat('../../../../../matlab/fjordsmalllinesegment.mat')
        # FJORDEN long track with many waypoints
        #self.path = sio.loadmat('../../../../../matlab/fjordlargepath.mat')
        self.path['track'] = self.path['track'] - np.array([+3,0])  # offset of the map
        
        # Fill in the path on the rviz path
        for i in self.path['track']:
            p = Point(i[0],i[1],0)
            self.pathmsg.poses.append(PoseStamped(h, Pose(p, q)))
        self.pubpath.publish(self.pathmsg)

    # Angle in rad to the interval (-pi pi]
    def rad2pipi(self, rad):
        r = fmod((rad+np.sign(rad)*pi) , 2*pi) # remainder
        s = np.sign(np.sign(rad) + 2*(np.sign(abs( fmod((rad+pi), (2*pi)) /(2*pi)))-1));
        pipi = r - s*pi;
        return pipi

    def callback(self, data):
        # Publish data to lli_input
        print "Control callback " + str(time.time())

        # Send tf for the robot model visualisation
        ns = rospy.get_namespace()
        br = tf.TransformBroadcaster()
        br.sendTransform((data.data[0],data.data[1], 0),
                         tf.transformations.quaternion_from_euler(data.data[4], data.data[5], data.data[6]),
                         rospy.Time.now(),
                         ns + "boat_link",
                         "ned")

        # First time we get a state estimate
        if self.k == 0:
            # Include initial point to path once
            self.path['track'] = np.append([[data.data[0],data.data[1]]], self.path['track'], axis=0)
            #rospy.signal_shutdown("testing")

        # GNC
        (headingdesired, wp_reached, cte) = self.wp_gen(self.path['track'][self.n-1],self.path['track'][self.n],np.array([data.data[0],data.data[1]])); # WP Gen
        nopid = 0
        if (wp_reached == 1):
            self.n = self.n+1;
            if self.n >= len(self.path['track']):
                #es = k;
                print('Finished path')
                exit()
                #self.n = 1


        # PID
        self.error.append(self.rad2pipi(headingdesired  - data.data[6]))
        self.integral.append(self.integral[self.k] + self.error[self.k])
        if self.k!=1:
            self.derivative.append(self.error[self.k] - self.error[self.k-1])
        self.thrustdiff.append(self.Kp*self.error[self.k] + self.Ki*self.integral[self.k] + self.Kd*self.derivative[self.k])

        # Desired control forces
        self.tau = np.array([80,0,0,0,self.thrustdiff[self.k]])

        # Calculation of input vector from desired control forces    
        pinvT = np.asmatrix( linalg.pinv(self.T) )
        self.u = linalg.inv(self.K).dot( linalg.pinv(self.T).dot(self.tau) )
    
        # Saturation in inputs (shoudl probably be in the simulaiton model instead)
        
        threshold = 45
        '''
        if -threshold < self.u[0]:
            self.u[0] = self.u[0] -40
        if threshold < self.u[0]:
            self.u[0] = self.u[0] +40
        if -threshold < self.u[1]:
            self.u[1] = self.u[1] -40
        if threshold < self.u[1]:
            self.u[1] = self.u[1] +40
        '''
        
        if self.u[0] > 0:
            self.u[0] = self.u[0] + threshold
        if self.u[0] < 0:
            self.u[0] = self.u[0] - threshold
        if self.u[1] > 0:
            self.u[1] = self.u[1] + threshold
        if self.u[1] < 0:
            self.u[1] = self.u[1] - threshold
        
        maksimal = 260
        if self.u[0] > maksimal:
            self.u[0] = maksimal
        elif self.u[0] < -maksimal:
            self.u[0] = -maksimal
        if self.u[1] > maksimal:
            self.u[1] = maksimal
        elif self.u[1] < -maksimal:
            self.u[1] = -maksimal

        print((int(self.u[0]), int(self.u[1])))

        # (-100% = -500 to +100% = 500)
        # right thruster, devid 10, msgid 3
        # left thruster, devid 10, msgid 5
        self.pubmsg = LLIinput()

        self.pubmsg.DevID = 10
        self.pubmsg.MsgID = 5
        self.pubmsg.Data  = self.u[1] # Reducing our thrust allocation to only ues the main propellers
        self.pub.publish(self.pubmsg)
        
        self.pubmsg.DevID = 10
        self.pubmsg.MsgID = 3
        self.pubmsg.Data  = self.u[0] # Reducing our thrust allocation to only ues the main propellers
        self.pub.publish(self.pubmsg)

        # Increment loop counter
        self.k = self.k+1


    # This calculates reference points for the path follower
    def wp_gen(self, wps, wpe, now):
        
        #P_c = [now, 0]; # [x y angle]
        P_c = now; # [x y]
        wp_r = 2; # Waypoint Radius
        wp_reached = 0; # Waypoint not reached
        v_i_len = 2; # length of intermediate vector
        
        ## Initial calculations
        #track = [wps;wpe];

        ## Track-frame projected point
        v_i = ( (wpe-wps)/linalg.norm(wpe-wps) )*v_i_len; # Intermediate vector

        #P_i = [P_c[0]+v_i[0], P_c[1]+v_i[1]]; # Intermediate projected parallel point
        P_i = P_c+v_i

        ## Calculate projected point onto the track
        A = P_i - wps;
        B = wpe - wps;
        r_p = ((A.dot(B))/((linalg.norm(B)**2)))*B; # Projection of vector on vector
        P_p = r_p + wps;

        ## The vessels predicted position
        v_d = P_p - P_c[0:2];
        v_ref = v_d/linalg.norm(v_d); # normaliserer
        v_ref = v_ref * v_i_len;
        P_ref = v_ref + now;
        # plot(P_ref(2),P_ref(1),'*')

        ## Calculate if waypoint is reached
        dist = sqrt((P_c[0]-wpe[0])**2+(P_c[1]-wpe[1])**2);
        if dist < wp_r:
            wp_reached = 1

        ## Calculate heading
        # heading = 2*pi-asin(( P_ref(1)-P_c[0] ) / sqrt( (P_ref(1)-P_c[0])  ^2 + (P_ref(2)-P_c[1])^2 ));
        # heading = mod(atan2(v_ref(2),v_ref(1))+pi,2*pi)-pi;
        heading = self.rad2pipi(atan2(v_ref[1],v_ref[0]))

        ## CrossTrackError % MOD = HYP*SIN(A) => crosstrack = (pos-wps) * sin(vinkel mellem (pos-wps) og (pos-wps))
        a = linalg.norm(now-wps);
        b = linalg.norm(wpe-wps);
        vinkel = (acos((now-wps).dot((wpe-wps).T)/(a*b))); #ValueError: math domain error
        # vinkeligrader = vinkel*180/pi;
        cte = a*sin(vinkel);

        #return {'heading':heading, 'wp_reached':wp_reached, 'cte':cte}
        return (heading, wp_reached, cte)

    def run(self):
        BUFSIZE = 1024
        #self.ctllog = open(os.getcwd() + "/../meas/ctl.log",'w')
        ##self.ctllog = open("logs/ctl.log",'w',BUFSIZE)
        ##print(self.ctllog.name)
        
        rospy.spin() # Keeps the node running untill stopped
        print("\nClosing log file")
        ##self.ctllog.close()
        print("Exiting the control node")
        exit()

if __name__ == '__main__':
    w = Control()
    w.run()

