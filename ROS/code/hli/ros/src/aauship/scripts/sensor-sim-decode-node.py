#!/usr/bin/env python2

import roslib; roslib.load_manifest('aauship')

import rospy
from std_msgs.msg import Float64MultiArray
from aauship.msg import *

import time
import os 

import numpy
from math import sin,cos,tan

## This is the node that takes the simulation model's state vector and
#  converts it to the sensor topics /imu, /gps1 and /gps2
class Sensor(object):
    def __init__(self):
        self.imu = {'supply':0.0,
                    'xgyro':0.0,
                    'ygyro':0.0,
                    'zgyro':0.0,
                    'xaccl':0.0,
                    'yaccl':0.0,
                    'zaccl':0.0,
                    'xmagn':0.0,
                    'ymagn':0.0,
                    'zmagn':0.0,
                    'temp':0.0,
                    'adc':0.0}
        self.magnbias = {'x':0, 'y':0, 'z':0}

    def callback(self, data):
        print(data.data[6])

        self.stat = self.stat + 1 # Used for callback debugging
        if self.stat > 1:     
            print("WARNING: This could be bad; Estimator gets a callback before it has finished the last one.")
            print("self.stat = " + str(self.stat))


        self.imu['supply'] = 0.0
        self.imu['xgyro']  = data.data[9]
        self.imu['ygyro']  = data.data[10]
        self.imu['zgyro']  = data.data[11]
        self.imu['xaccl']  = data.data[12]
        self.imu['yaccl']  = data.data[13]
        self.imu['zaccl']  = 9.82
        self.imu['xmagn']  = cos(data.data[6])
        self.imu['ymagn']  = sin(data.data[6])
        self.imu['zmagn']  = 0.0
        self.imu['temp']   = 0.0
        self.imu['adc']    = 0.0

        self.pub_imu.publish(                                               
            self.imu['supply'],                                             
            self.imu['xgyro'],self.imu['ygyro'],self.imu['zgyro'],          
            self.imu['xaccl'],self.imu['yaccl'],self.imu['zaccl'],          
            self.imu['xmagn'],self.imu['ymagn'],self.imu['zmagn'],          
            self.imu['temp'],self.imu['adc']) 

        self.stat = 0 # Used for callback debugging


    def run(self):
        self.stat = 0 # Used for callback debugging
        BUFSIZE = 1024

        rospy.init_node('sensor_sim_decode_node')
        rospy.Subscriber('simstate', Float64MultiArray, self.callback)
        self.pub_imu = rospy.Publisher('imu', ADIS16405, queue_size=10)
        rospy.spin() # Keeps the node running untill stopped
        print("Exiting")
        exit()

if __name__ == '__main__':
    w = Sensor()
    w.run()
