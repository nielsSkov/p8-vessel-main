#!/usr/bin/env python2

import roslib; roslib.load_manifest('aauship_control')

import rospy
from std_msgs.msg import String, Float64MultiArray, Header
from geometry_msgs.msg import Point, Quaternion, PoseStamped, Pose
from aauship_control.msg import *
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
	#self.ref = np.array([0 0 0 0 0 0])

        rospy.init_node('controller_node')
	self.subref = rospy.Subscriber('states_reference', Float64MultiArray, self.callbackref, queue_size=1)
        self.sub = rospy.Subscriber('kf_statesnew', Float64MultiArray, self.callback, queue_size=1)
        self.pub = rospy.Publisher('lli_input', LLIinput, queue_size=4, latch=True)

    # Angle in rad to the interval (-pi pi]
    def rad2pipi(self, rad):
        r = fmod((rad+np.sign(rad)*pi) , 2*pi) # remainder
        s = np.sign(np.sign(rad) + 2*(np.sign(abs( fmod((rad+pi), (2*pi)) /(2*pi)))-1));
        pipi = r - s*pi;
        return pipi

    def callback(self, data):
        # Publish data to lli_input
        print "Control callback " + str(time.time())

        # # PID
        # self.error.append(self.rad2pipi(self.ref[2]  - data.data[6]))
        # self.integral.append(self.integral[self.k] + self.error[self.k])
        # if self.k!=1:
            # self.derivative.append(self.error[self.k] - self.error[self.k-1])
        # self.thrustdiff.append(self.Kp*self.error[self.k] + self.Ki*self.integral[self.k] + self.Kd*self.derivative[self.k])

        # Desired control forces
        # self.tau = np.array([80,0,0,0,self.thrustdiff[self.k]])

        # # Calculation of input vector from desired control forces    
        # pinvT = np.asmatrix( linalg.pinv(self.T) )
        # self.u = linalg.inv(self.K).dot( linalg.pinv(self.T).dot(self.tau) )
    
        # # Saturation in inputs
        
        # threshold = 45
        
        # if self.u[0] > 0:
            # self.u[0] = self.u[0] + threshold
        # if self.u[0] < 0:
            # self.u[0] = self.u[0] - threshold
        # if self.u[1] > 0:
            # self.u[1] = self.u[1] + threshold
        # if self.u[1] < 0:
            # self.u[1] = self.u[1] - threshold
        
        # maksimal = 260
        # if self.u[0] > maksimal:
            # self.u[0] = maksimal
        # elif self.u[0] < -maksimal:
            # self.u[0] = -maksimal
        # if self.u[1] > maksimal:
            # self.u[1] = maksimal
        # elif self.u[1] < -maksimal:
            # self.u[1] = -maksimal

        # print((int(self.u[0]), int(self.u[1])))

        self.pubmsg = LLIinput()

        self.pubmsg.DevID = 10
        self.pubmsg.MsgID = 5
        self.pubmsg.Data  = 0 #self.u[1] # Reducing our thrust allocation to only ues the main propellers
        self.pub.publish(self.pubmsg)
        
        self.pubmsg.DevID = 10
        self.pubmsg.MsgID = 3
        self.pubmsg.Data  = 0 #self.u[0] # Reducing our thrust allocation to only ues the main propellers
        self.pub.publish(self.pubmsg)

        # Increment loop counter
        self.k = self.k+1

    def callbackref(self,data):
	self.ref = data.Data
		
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

