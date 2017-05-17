#!/usr/bin/env python2
# Simulation model

import roslib; roslib.load_manifest('aauship_control')

import rospy
from std_msgs.msg import String
from aauship_control.msg import *
from std_msgs.msg import Float64MultiArray, Header
import tf
# import scipy.io as sio
# import kalmanfilterfoo as kfoo # temporary implementation for the simulation
# import gpsfunctions as geo
import numpy as np
from math import pi, sqrt, atan2, acos, sin, fmod, cos
# import scipy.linalg as linalg
import time
import os

class modelSim(object):
    """docstring for modelSim"""
    def __init__(self):
        self.n = 3 # number of states
        self.p = 2 # number of inputs, also outputs
        self.Ts = 0.05 # sampling time
        # init ss matrices
        self.A = np.matrix([[ 1, 0.0497, 0],
            [ 0, 0.9882, 0],
            [ 0, 0, 0.9891]])
        self.B = np.matrix([[0.0001, -0.0001],
            [0.0022, -0.0022],
            [0.0038, 0.0038]])
        # init states
        self.x = np.zeros([self.n])
        self.x_old = self.x
        # position in NED
        self.pos = np.zeros([2])
        self.pos_old = self.pos
        # components of the rotaton matrix
        self.a = np.zeros([2])
        # 
        self.sub = rospy.Subscriber('lli_input', LLIinput, self.llicb,queue_size=1000)
        self.pubatt = rospy.Publisher('kf_attitude', AttitudeStates, queue_size=1000)
        self.pubpos = rospy.Publisher('kf_position', PositionStates, queue_size=1000)
        self.pubattmsg = AttitudeStates()
        self.pubposmsg = PositionStates()

        # variables to convert PWM2force
        # self.m = 0.26565
        # self.c = 24.835

        self.mpos = 6.6044 #0.26565
        self.npos = 70.0168 #24.835
        self.mneg = 8.5706 #0.26565
        self.nneg = 91.9358 #24.835

        # Variables for the thrusters
        self.leftthruster = 0.0
        self.rightthruster = 0.0

        rospy.init_node('model_node')
        rate = rospy.Rate(20)
        before = 0;
        while not rospy.is_shutdown():
            # print after - before
            # Calculates new states
            # print self.x
            self.x_old = self.x
            for i in range(0,self.n):
                # Check this implementation in LQR-node   
                self.x[i] = (self.A[i,0]*self.x_old[0] + self.A[i,1]*self.x_old[1] + self.A[i,2]*self.x_old[2]) \
                    + (self.B[i,0]*self.leftthruster + self.B[i,1]*self.rightthruster)
            # self.pubmsg.r = rospy.get_time()
            # Convert yaw to range [-pi,pi]
            self.x[0] = (self.x[0] % (2 * pi))
            if self.x[0] > pi:
            	self.x[0] = self.x[0] - 2 * pi
            # Calculate new position
            self.a[0] = cos(self.x[0])
            self.a[1] = sin(self.x[0])
            self.pos_old = self.pos
            for i in range(0,2):
            	self.pos[i] = self.Ts / 2 * self.a[i] * (self.x_old[2] + self.x[2]) + self.pos_old[i]
            # Publish
            self.pubattmsg.yaw = self.x[0]
            self.pubattmsg.yawd = self.x[1]
            self.pubposmsg.xbd = self.x[2]
            self.pubposmsg.xn = self.pos[0]
            self.pubposmsg.yn = self.pos[1]
            self.pubatt.publish(self.pubattmsg)
            self.pubpos.publish(self.pubposmsg)
            # print "XnModel", self.pos[0]
            # print "YnModel", self.pos[1]
            rate.sleep()
            # before = after

    def llicb(self, data):
        # Get inputs from controller
        if data.MsgID == 3:
            if float(data.Data) > 70:
                self.rightthruster = (float(data.Data)-self.npos)/self.mpos
            elif float(data.Data) < -70:
                self.rightthruster = (float(data.Data)+self.nneg)/self.mneg
            else:
                self.rightthruster = 0

            # print "F2Model", self.rightthruster
        if data.MsgID == 5:
            if float(data.Data) > 70:
                self.leftthruster = (float(data.Data)-self.npos)/self.mpos
            elif float(data.Data) < -70:
                self.leftthruster = (float(data.Data)+self.nneg)/self.mneg
            else:
                self.leftthruster = 0
            # print "F1Model", self.leftthruster
        #print "Data: ", float(data.Data)
        #print "Left Thruster: ", self.leftthruster, " Right Thruster: ", self.rightthruster
        #print self.leftthruster
        #print self.rightthruster

        # Limits for motors
        # if self.rightthruster > 40:
        #     self.rightthruster = 40
        # elif self.rightthruster < -25:
        #     self.rightthruster = -25

        # if self.leftthruster > 40:
        #     self.leftthruster = 40
        # elif self.leftthruster < -25:
        #     self.leftthruster = -25

        # self.pubmsg.psi = self.x[0]
        # self.pubmsg.p = self.x[1]
        # self.pubmsg.u = self.x[2]

        #print "Yaw: ", self.x[0]," YawDot: ", self.x[1], " Xdot: ", self.x[2]
        #print self.x[2]
        #self.pub.publish(self.pubmsg)

    def run(self):
        #cself.sub.subscribe(self.sub)
        rospy.spin()

        print("Exiting model node")
        exit()



if __name__ == '__main__':
    w = modelSim()
    w.run()
