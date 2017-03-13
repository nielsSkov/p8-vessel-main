#!/usr/bin/env python2

import roslib; roslib.load_manifest('aauship_control')

import rospy
from std_msgs.msg import String
from aauship_control.msg import *
from rospy.numpy_msg import numpy_msg

import time
import os 

import fapsParse
import numpy
from math import atan2,sqrt,cos,sin

## This is the estimator and sensor node
#
#  It takes the raw data published from the LLI node and interprets
#  them with the fapsParse.packetParser.parser(). 
class Estimator(object):
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
        #self.magnbias = {'x':0.25825, 'y':0.1225, 'z':-0.686}
        #self.magnbias = {'x':0.28, 'y':0.15, 'z':-0.18}
        #self.magnbias = {'x':0, 'y':0, 'z':0}
        self.magnbias = {'x':0.29, 'y':0.15, 'z':-0.15} # magnetometertest-lab7, in hands swinging


	## Commented out by 17gr832
    # def pitchroll(self,ax,ay,az):
        # x2 = ax**2
        # y2 = ay**2
        # z2 = az**2
        # sxy = sqrt(x2+z2)
        # syz = sqrt(y2+z2)

        # roll = atan2(ay,sxy)

        # pitch = -atan2(ax,syz)

        # return {'roll':roll, 'pitch':pitch}

    # def yaw(self,mx,my,mz,pitch,roll):
        # xhead = mx*cos(-pitch) + my*sin(-roll)*sin(-pitch) - mz*cos(-roll)*sin(-pitch)
        # yhead = my*cos(-roll) + mz*sin(-roll)
        # heading = -atan2(yhead, xhead)

        # return heading


    def callback(self, data):
        #rospy.loginfo(rospy.get_caller_id()+" I heard %s",data.Data)

        self.stat = self.stat + 1 # Used for callback debugging
        if self.stat > 1:     
            print("WARNING: This could be bad; Estimator gets a callback before it has finished the last one.")
            print("self.stat = " + str(self.stat))

        #print "Running parser"
        ### if IMU device ###
        tmp = {'DevID':str(data.DevID), 'MsgID':str(data.MsgID),'Data': (data.Data)}
        self.parser.parse(tmp)
        self.imu['supply'] = numpy.asscalar(self.samples[0,0])*0.002418
        self.imu['xgyro'] = numpy.asscalar(self.samples[1,0])*0.05
        self.imu['ygyro'] = numpy.asscalar(self.samples[2,0])*0.05
        self.imu['zgyro'] = numpy.asscalar(self.samples[3,0])*0.05
        self.imu['xaccl'] = numpy.asscalar(self.samples[4,0])*9.82*0.00333
        self.imu['yaccl'] = numpy.asscalar(self.samples[5,0])*9.82*0.00333
        self.imu['zaccl'] = numpy.asscalar(self.samples[6,0])*9.82*0.00333
        self.imu['xmagn'] = numpy.asscalar(self.samples[7,0])*0.0005-self.magnbias['x']
        self.imu['ymagn'] = numpy.asscalar(self.samples[8,0])*0.0005-self.magnbias['y']
        self.imu['zmagn'] = numpy.asscalar(self.samples[9,0])*0.0005-self.magnbias['z']
        self.imu['temp'] = numpy.asscalar(self.samples[10,0])*0.14
        self.imu['adc'] = numpy.asscalar(self.samples[11,0])*0.806

        # Wildpoint detection on IMU samples
        # We can use  the value of the ADC on the IMU to detect wildpoints. It is tied to ground.
        if self.imu['adc'] < 1.0:
            self.pub_imu.publish(
                self.imu['supply'],
                self.imu['xgyro'],self.imu['ygyro'],self.imu['zgyro'],
                self.imu['xaccl'],self.imu['yaccl'],self.imu['zaccl'],
                self.imu['xmagn'],self.imu['ymagn'],self.imu['zmagn'],
                self.imu['temp'],self.imu['adc'])
        else:
            rospy.logwarn("Wildpoint detected")
        
		## Commented out by 17gr832
        #pr = self.pitchroll(self.imu['xaccl'],self.imu['yaccl'],self.imu['zaccl'])
        #head = self.yaw(self.imu['xmagn'],self.imu['ymagn'],self.imu['zmagn'],pr['pitch'],pr['roll'])
		
		
		
        ### if GPS device ###
        # publish GPS topic here

        #self.pub_attitude.publish(pr['pitch'],pr['roll'],head) # We use the cpp ahrs methods insted

        self.stat = 0 # Used for callback debugging


    def run(self):
        self.stat = 0 # Used for callback debugging
        BUFSIZE = 1024
		## Uncomment below if you log the data
        #self.imulog   = open("imu.log",'w',BUFSIZE)   # was acclog
        #self.mixedlog = open("mixed.log",'w',BUFSIZE) # was recieved
        #self.gps1log   = open("gps1.log",'w',BUFSIZE)  # was gpslog
        #self.plog     = open("p.log",'w',BUFSIZE)     # was plog

        #self.echolog = open("logs/echo.log",'w',BUFSIZE)  # Currently logged in lli-node.py
        #self.gps2log = open("logs/gps2.log",'wb',BUFSIZE) # Currently logged in lli-node.py
	
	self.gps1sample = GPS()

        # TODO use the rotlat and rotlat from sio.loadmat('klingenberg.mat')
        # to determine the rotatoin point for GPS positions to the NED frame.
        # GPS1 = LLI GPS
        # GPS2 = u-blox GPS	

        self.samples = numpy.zeros((12,2))
        self.parser = fapsParse.packetParser(
                #self.imulog,
                #self.gps1log,
                self.gps1sample,
                self.samples)
                #self.mixedlog,
                #self.plog
				##) Uncomment the fields necessary to log the data

        #print(self.imulog.name)

        rospy.init_node('sensor_decode_node')
        rospy.Subscriber('samples', Faps, self.callback)
        self.pub_imu = rospy.Publisher('imu', ADIS16405, queue_size=10)
        #self.pub_attitude = rospy.Publisher('attitude',Attitude, queue_size=10) # We use the cpp ahrs methods insted
        rospy.spin() # Keeps the node running untill stopped
        #print("\nClosing log files")
		
		## Uncomment below if you log the data
        #self.imulog.close()
        #self.mixedlog.close()
        #self.gps1log.close()
        #self.plog.close()
        
		#print("Exiting")
        exit()

if __name__ == '__main__':
    w = Estimator()
    w.run()
