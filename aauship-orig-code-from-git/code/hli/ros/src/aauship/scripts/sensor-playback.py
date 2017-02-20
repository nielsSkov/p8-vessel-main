#!/usr/bin/env python2

import roslib; roslib.load_manifest('aauship')

from aauship.msg import *
import rospy
from std_msgs.msg import Float64MultiArray, Header
from nav_msgs.msg import Path
from geometry_msgs.msg import Point, Quaternion, PoseStamped, Pose
from aauship.msg import *
import tf
import numpy as np
from math import pi, sqrt, atan2, acos, sin, fmod, cos
import scipy.io as sio
import scipy.linalg as linalg
import time
import os


# This file is supposed to replay measurement data from a real
# seatrail as it is presented to ROS. So this should act as a fake
# sensor-decode-node.py (publishes IMU through the /imu topic) and
# the lli-node.py (publishes GPS data thorugh the /gps1 topic).
# 
# You need to run process.m first to save the test data to a mat file
# that is to be read by this script for the playback.
class Playback(object):
    def __init__(self):
        rospy.init_node('playback_node')
        self.r = rospy.Rate(50) # Hz
        
        # Define the topics
        self.pub_imu = rospy.Publisher('imu', ADIS16405, queue_size=1)
        self.pub_gps = rospy.Publisher('gps1', GPS, queue_size=1)
        
        # Open the data file
        self.mat = sio.loadmat('../../../../../matlab/log-viewer/processdotm.mat')

        self.gpsmsg = GPS()
        

    def run(self):
        # Iterator initialization
        i = 0 # IMU iterator
        g = 0 # GPS iterator

        imulength = len(self.mat['imudata'])
        gpslength = len(self.mat['nmealat'])
        print('Number of IMU samples: ' + str(imulength))
        print('Number of GPS samples: ' + str(gpslength))
        print('Simulation time is:    ' + str(self.r.sleep_dur.to_sec()*imulength))

        # Main loop
        while not rospy.is_shutdown():
            # Call AHRS node either Mahony or Madgwick
            # Publish the calculated measurements for /imu
            self.pub_imu.publish(
                  self.mat['supply'][i][0],
                  self.mat['gyro'][i][0],
                  -self.mat['gyro'][i][1],
                  -self.mat['gyro'][i][2],
                  self.mat['accl'][i][0],
                  -self.mat['accl'][i][1],
                  -self.mat['accl'][i][2],
                  self.mat['magn'][i][0],
                  -self.mat['magn'][i][1],
                  -self.mat['magn'][i][2],
                  self.mat['temp'][i][0],
                  self.mat['aux_adc'][i][0])

            # Handle GPS
            # CAUTION this does not make sure that IMU and GPS data 
            # are synchronized! This should be fixed before any real
            # use.
            # WARNING magic number here
            if i%20 !=0:
                # Do not send GPS data
                pass
            else:
                # Send GPS data
                self.gpsmsg.time = self.mat['time'][g][0]
                self.gpsmsg.latitude = self.mat['lat'][0][g]*pi/180.0
                self.gpsmsg.longitude = self.mat['lon'][0][g]*pi/180.0
                self.gpsmsg.track_angle = self.mat['nmea_track_angle'][g][0]*pi/180.0
                self.gpsmsg.date = int(self.mat['nmeadate'][g][0])
                self.gpsmsg.SOG = self.mat['nmeaspeed'][g][0]*0.514444444
                self.pub_gps.publish(self.gpsmsg)
                print(g)
                g = g + 1
                if g == gpslength:
                    i = 0
                    g = 0
                print('GPS')
            
            # Handle iterator
            i = i + 1
            if i == imulength:
                i = 0
                g = 0
                print('Resetting playback iterator')
            
            # Sleep the rest of the time to keep the node rate
            self.r.sleep()
        
        print("Exiting node")
        exit()

if __name__ == '__main__':
    w = Playback()
    w.run()

