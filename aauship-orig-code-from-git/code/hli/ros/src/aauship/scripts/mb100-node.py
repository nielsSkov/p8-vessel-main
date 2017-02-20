#!/usr/bin/env python2

# This is the LLI node

import roslib; roslib.load_manifest('aauship')

import rospy
from std_msgs.msg import String
from aauship.msg import *

from std_msgs.msg import Float64MultiArray, Header
from geometry_msgs.msg import Point, Quaternion, PoseStamped, Pose
from nav_msgs.msg import Path
import tf

import serial
import struct
import time
from math import pi
import numpy as np
import scipy.io as sio

import Queue
import gpsfunctions as geo

class MB100(object):
    def __init__(self):
        # Open the file descriptors
        BUFSIZE = 1024
        self.mb100log = open("logs/mb100.log",'wb',BUFSIZE)
        self.mb100rcv = serial.Serial("/dev/mb100rover",115200,timeout=0.04)

        # Static rotation matrix
        self.klingen = sio.loadmat('klingenberg.mat')
        self.klingen = sio.loadmat('fjorden.mat')
        self.Rn2e = geo.RNED2ECEF(self.klingen['rotlon'], self.klingen['rotlat'])
        self.Re2n = self.Rn2e.T
        self.pos_of_ned_in_ecef = geo.wgs842ecef(self.klingen['rotlat'], self.klingen['rotlon'])

        # Create objects for the kftrack stuff
        self.kftrackpath = rospy.Publisher('kftrack', Path, queue_size=3)
        self.kftrackmsg = Path()
        self.kftrackmsg.header.frame_id = "ned"

        # Initialise pose for the graphic path segment for rviz
        h = Header()
        p = Point(0,0,0)
        q = Quaternion(0,0,0,1)
        self.kftrackmsg.poses.append(PoseStamped(h, Pose(p, q)))
        self.kftrackmsg.poses.append(PoseStamped(h, Pose(p, q)))
        
        self.x_hat = np.zeros(17)


    def parse(self,line):
        self.mb100log.write(line + ',' + str(time.time()) + "\r\n")
        line = line.split(',')

        # Make sure that there is no empty strings, which will make
        # the float() and int() conversions fail, which in turn will
        # make the parsing except silently, because of the try
        # catching in the self.run().
        for k in range(len(line)):
            if line[k] == '':
                line[k] = 0
                rospy.logwarn("Empty element sin the $PASHR,POS message, do not sail.")
        # Note that is might not be the best idea to set it to zero
        # only. We might need to handle this downstream, such that we
        # don't change them maybe.

        if line[0] == "$PASHR" and line[1] == "POS":
            mb100 = {}
            mb100['posmode'] = int(line[2])
            mb100['sats'] = int(line[3])
            mb100['utctime'] = float(line[4])
            [latdec, londec] = (geo.nmea2decimal(float(line[5]),line[6],float(line[7]),line[8]))
            mb100['lat'] = latdec*pi/180.0
            mb100['lon'] = londec*pi/180.0
            mb100['alt'] = float(line[9])
            #TODO Fix this, when the the float() gets and empty stirng, it will fail the try in the self.run()
            #print(line[9])
            #print("woo")
            #print(type(line[10]))
            #mb100['ageofdiff'] = float(line[10])
            #print(line[10])
            mb100['cog'] = float(line[11])*pi/180.0
            mb100['sog'] = float(line[12])*0.514444444
            mb100['verticalvel'] = float(line[13])
            mb100['pdop'] = float(line[14])
            mb100['hdop'] = float(line[15])
            mb100['vdop'] = float(line[16])
            mb100['tdop'] = float(line[17])
            mb100['crc'] = line[18]
            return mb100
        elif line[0] == "RomBOOT":  # TODO the string the gps sends when booting
            rospy.logwarn("It seems like the MB100 has restarted. Is the powersupply ok?")
            return None
        else:
            return None

    def run(self):
        # Example of data
        #line = "$PASHR,POS,1,10,134035.35,5700.8745400,N,00959.1551112,E,059.318,10.4,077.3,000.459,+000.069,1.7,0.9,1.4,0.9,Hp23*30"
        #print(self.parse(line))

        pub = rospy.Publisher('kf_statesnew', Float64MultiArray, queue_size=1)
        rospy.init_node('mb100')
        r = rospy.Rate(200)

        # Do the publishing of the mission boundary path and keeoput
        # zone
        self.refpath = rospy.Publisher('refpath', Path, queue_size=3, latch=True)
        self.keepoutpath = rospy.Publisher('keepout', Path, queue_size=3, latch=True)

        # Define the path poses for the map to display in rviz
        self.refmsg = Path()
        self.refmsg.header.frame_id = "ned"
        self.keepoutmsg = Path()
        self.keepoutmsg.header.frame_id = "ned"
        q = Quaternion(0,0,0,1)
        h = Header()

        offset = 3
        for i in self.klingen['outer']:
            p = Point(i[0]-offset,i[1],0)
            self.refmsg.poses.append(PoseStamped(h, Pose(p, q)))
        for i in self.klingen['inner']:
            p = Point(i[0]-offset,i[1],0)
            self.keepoutmsg.poses.append(PoseStamped(h, Pose(p, q)))
        for i in self.fjorden['all']:
            p = Point(i[0]-offset,i[1],0)
            self.keepoutmsg.poses.append(PoseStamped(h, Pose(p, q)))


        self.refpath.publish(self.refmsg)
        self.keepoutpath.publish(self.keepoutmsg)

        modecount = 0

        while not rospy.is_shutdown():
            # Grabbing the data
            try:
                data = self.mb100rcv.readline()
                if data != "":
                    data = data.rstrip()
                    parsed = self.parse(data)
                    
                    self.pubmsg = Float64MultiArray()
                    
                    # Headpoint of trail track
                    p = Point(self.x_hat[0],self.x_hat[1],0.0)
                    q = Quaternion(0,0,0,1)
                    self.kftrackmsg.poses[0] = PoseStamped(Header(), Pose(p, q))

                    # Positoin in NED
                    pos_ecef = geo.wgs842ecef(parsed['lat'], parsed['lon'], 0.0)
                    pos_ned = self.Re2n.dot( pos_ecef - self.pos_of_ned_in_ecef )
                    self.x_hat[0:2] = np.squeeze( pos_ned[0:2] )

                    #TODO Not exactly the heading, should probably use the heading from
                    #     the AHRS filter.
                    self.x_hat[6]   = parsed['cog'] 

                    #TODO When implementing for multi control, e.g. the duckling, then
                    #     it is probably of interest to calculate the u and v speeds
                    #     also.

                    # Fill in the message to be published in ROS
                    for a in self.x_hat:
                        self.pubmsg.data.append(a)
                    pub.publish(self.pubmsg)

                    # Endpoint of trail track
                    p = Point(self.x_hat[0],self.x_hat[1],0.0)
                    self.kftrackmsg.poses[1] = PoseStamped(Header(), Pose(p, q))
                    self.kftrackpath.publish(self.kftrackmsg)
                    if modecount >= 20:
                        modecount = 0
                        print("Position mode from MB100: " + str(parsed['posmode']))
                    modecount = modecount + 1
            except Exception:
                pass

            # End of loop, wait to keep the rate
            r.sleep()
        
        print("Closing MB100 node")
        self.mb100log.close()
        self.mb100rcv.close()

        
if __name__ == '__main__':
    w = MB100()
    w.run()
