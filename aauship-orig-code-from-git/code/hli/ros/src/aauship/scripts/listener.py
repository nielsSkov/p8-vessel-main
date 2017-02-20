#!/usr/bin/env python

PKG = 'aauship' # this package name
import roslib; roslib.load_manifest(PKG)

import rospy
from std_msgs.msg import *

import time

log = open("logs/listener.log", "w", 1)

def callback(data):
    print("%.9f" % data.data)
    line = str("%.9f" % data.data) + ";" + str("%.9f" % rospy.get_time()) + "\n"
    log.write(line)

def listener():
    print('Running time debugging listener node')
    rospy.init_node('listener', anonymous=True)
    rospy.Subscriber("chatter", Float64, callback)
    rospy.spin()
    log.close()
        
if __name__ == '__main__':
    listener()
