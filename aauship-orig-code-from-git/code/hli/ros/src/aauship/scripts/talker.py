#!/usr/bin/env python

import roslib; roslib.load_manifest('aauship')

import rospy
from std_msgs.msg import *

import struct
import time

def talker():
    print('Running time debugging talker node')
    pub = rospy.Publisher('chatter', Float64)
    rospy.init_node('talker', anonymous=True)
    r = rospy.Rate(1) # sleep time
    while not rospy.is_shutdown():
        print 'time.time()' , time.time()
        data = rospy.get_time()
        print 'rospy.get_time()' , data
        pub.publish(data)
        r.sleep()
        
if __name__ == '__main__':
    try:
        talker()
    except rospy.ROSInterruptException: pass
