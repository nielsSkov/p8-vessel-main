#!/usr/bin/env python

import roslib; roslib.load_manifest('aauship_control')

import rospy
from std_msgs.msg import String
from sensor_msgs.msg import Joy

import time
import os 

## This is the joy tele operation node
class Joy(object):
    def callback(self, data):
        #print data.buttons
        print time.time()
        #pub.publish("control signals should be sent here")
        pass

    def run(self):

        #pub = rospy.Publisher('lli_input', String)
        sub = rospy.Subscriber('joy', Joy, self.callback)
        rospy.init_node('joy_teleop')

        rospy.spin() # Keeps the node running untill stopped
        exit()

if __name__ == '__main__':
    w = Joy()
    w.run()
