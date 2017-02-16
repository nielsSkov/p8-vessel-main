#!/usr/bin/env python2

# This is the LLI node

import roslib; roslib.load_manifest('aauship')

import rospy
from std_msgs.msg import String
from aauship.msg import *

import serial
import struct
import time

import Queue
import fapsPacket # fork of packetHandler

class LLI(object):
    def __init__(self):
        self.ctllog = open("logs/ctl.log",'w',256)

    def callback(self, data):
        # write data to serial
        tmp = []
        tmp = struct.pack('>h', data.Data )

        #if data.DevID == 10: # Actuators
            #self.ctllog.write(str(ord(data.MsgID)) + ',' + str(data.Data) + ',' + str(time.time()) + "\r\n")

        self.packet.lli_send(self.packet.package(tmp,data.DevID,data.MsgID))
        print("packet sent")

    def run(self):
        self.qu = Queue.Queue()
        self.packet = fapsPacket.Handler('/dev/lli', 57600, 0.02, self.qu)
#        self.packet = fapsPacket.Handler('/dev/lli', 115200, 0.02, self.qu)
        # GPS2 and Echo sounder should be opened here, or maybe implemented in the fapsPacket.Handler thread
#        gps2rcv = serial.Serial("/dev/gps2",115200,timeout=0.04)
        echorcv = serial.Serial("/dev/echosounder",4800,timeout=0.04)

        BUFSIZE = 1024
        echolog = open("logs/echo.log",'w',BUFSIZE)
        #gps2log = open("logs/gps2.log",'wb',BUFSIZE)

        time.sleep(5)
        self.packet.start()
        pub = rospy.Publisher('samples', Faps, queue_size=10)
        sub = rospy.Subscriber('lli_input', LLIinput, self.callback)
        rospy.init_node('lli')
        r = rospy.Rate(100) # Rate in Hz, maybe try a faster rate than
        # 100 to fix the buffering issue

        while not rospy.is_shutdown():
            try:
                data = self.qu.get(False)
#                print("Queue size:" + str(self.qu.qsize()) + "\r\n")
                pub.publish(data['DevID'],
                            data['MsgID'],
                            (data['Data']),
                            rospy.get_time())
            except Queue.Empty:
                pass


            # Grabbing the GPS2 data (tempory implementation)
            '''
            try:
                gps2 = gps2rcv.readline()
                if gps2 != "":
                    gps2 = gps2.rstrip()
                    gps2log.write(gps2 + ',' +str(time.time()) + "\r\n")
            except Exception:
                pass
            '''

            # Grabbing the echosounder data (tempory implementation)
            try:
                echosounder = echorcv.readline()
                echosounder = echosounder.rstrip()
                if echosounder != "":
                    echolog.write(echosounder + ',' + str(time.time()) + "\r\n")
            except Exception:
                pass


            # End of loop, wait to keep the rate
            r.sleep()

        echolog.close()
        #gps2log.close()
        self.ctllog.close()
        self.packet.close()
        self.packet.join()
        
if __name__ == '__main__':
    w = LLI()
    w.run()
