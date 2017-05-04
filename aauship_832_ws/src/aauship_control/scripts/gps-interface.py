#!/usr/bin/env python
import sys
import socket 
import os 
import time
from threading import Thread 
from SocketServer import ThreadingMixIn 
import serial
import math
import binascii
from aauship_control.msg import *

import rospy

#IP and port number of RTK base server
HOST = '192.38.55.85'
PORT = 5500
#Baudrate can be changed in reachview
BAUD_RATE= 115200
DEVICE = '/dev/rtk_gps' 

class SerialReader(Thread):
     
    def __init__(self):
        Thread.__init__(self)
        self.Start_lat_rads = self.deg_to_radians(57.0147061)
        self.Start_log_rads = self.deg_to_radians(9.9859129)
        self.gps_pub= rospy.Publisher('gps_pos',RTKGPS,queue_size=1)
        self.pub_msg = RTKGPS()
         

    def run(self):#Run this when start() is called
        global ser
        global NMEA_MSG
        while not rospy.is_shutdown(): 
          NMEA_MSG = ser.readline()
          # print NMEA_MSG
          gpsfix = 0;
          if len(NMEA_MSG)>0:
              if NMEA_MSG.startswith('$GPGGA'):
                  if gpsfix == 0:
                    print "GPS FIX"
                  gpsfix = 1
                  self.pub_msg.timestamp= NMEA_MSG[7:16]
                  lat_start = 17
                  # Lattitude
                  lat_deg = float(NMEA_MSG[lat_start:lat_start+2])
                  lat_min = float(NMEA_MSG[lat_start+2:lat_start+12])
                  lat_deg = lat_deg+(lat_min/60)
                  # Longitude 
                  log_start = 32
                  log_deg = float(NMEA_MSG[log_start:log_start+3])
                  log_min = float(NMEA_MSG[log_start+3:log_start+12])
                  log_deg = log_deg+(log_min/60)
                  [self.pub_msg.delx,self.pub_msg.dely] = self.compute_distance(lat_deg,log_deg)
                  self.pub_msg.longitude = log_deg
                  self.pub_msg.latitude = lat_deg
                  self.gps_pub.publish(self.pub_msg)
                else:
                  if gpsfix == 1:
                    print "No GPS"
                  gpsfix = 0
              # else:
              #     self.pub_msg.timestamp = "0"
              #     self.pub_msg.delx = 0
              #     self.pub_msg.dely = 0
              #     self.pub_msg.longitude = 0
              #     self.pub_msg.latitude = 0
              #     self.gps_pub.publish(self.pub_msg)

    def deg_to_radians(self,deg):
        return deg*math.pi/180

    def compute_distance(self,lat,log):
        R = 6363128 #6371000

        #Convert to radians
        lat_rads = self.deg_to_radians(lat)
        log_rads = self.deg_to_radians(log)

        #Compute distance in lattitude and longitude
        del_lat = lat_rads - self.Start_lat_rads
        del_log = log_rads - self.Start_log_rads

        #Compute trigonomtric functions
        cos_lat1 = math.cos(lat_rads)
        sin_lat1 = math.sin(lat_rads)
        cos_log1 = math.cos(log_rads)
        sin_log1 = math.sin(log_rads)
        cos_lat0 = math.cos(self.Start_lat_rads)
        sin_lat0 = math.sin(self.Start_lat_rads)
        cos_log0 = math.cos(self.Start_log_rads)
        sin_log0 = math.sin(self.Start_log_rads)
        sin_lat10 = math.sin((del_lat)/2)

        #Compute distance in xn directions
        dx=R*2*math.atan2(math.sqrt(sin_lat10*sin_lat10),math.sqrt(1-sin_lat10*sin_lat10))

        #Compute total distance to the origin in NED frame
        x1 = R * cos_lat1 * cos_log1;
        y1 = R * cos_lat1 * sin_log1;
        z1 = R * sin_lat1;

        x0 = R * cos_lat0 * cos_log0;
        y0 = R * cos_lat0 * sin_log0;
        z0 = R * sin_lat0;

        xd = x1 - x0;
        yd = y1 - y0;
        zd = z1 - z0;

        d = math.sqrt(xd * xd + yd * yd + zd * zd)

        #Compute distance in yn directions
        dy = math.sqrt(d * d - dx * dx)

        #Put the correct sign
        if del_lat < 0:
       	  dx = -dx
        if del_log < 0:
       	  dy = -dy

        #Return calculated values
        return [dx,dy]
 
class CorrectionDataClient(Thread):
    def __init__(self,Host,Port):
        Thread.__init__(self)
        self.Host = Host
        self.Port = Port

    def run(self):#Run this when start() is called
        #establish connection to RTK Base server 
        RTKBaseServer = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 
        global ser
        try:
            RTKBaseServer.connect((HOST,PORT))
            print "Successfully connected to: " + HOST
        except:
            print "Connection to server failed"
        RTCM3Data = []
        while not rospy.is_shutdown(): 
            while True:
                tmp = RTKBaseServer.recv(1) 
                if hex(ord(tmp))[2:]=='d3':#Look for startchar (d3)
                    break

            header = tmp+RTKBaseServer.recv(2) #When startchar is located next two bytes is header
            msgLength = int(binascii.hexlify(header),16)&0x3FF#extract message length from header
            # print "Message Length",
            # print msgLength+6
            msg = RTKBaseServer.recv(msgLength+3) #message length + checksum
            RTCM3Data = header+msg#Put header back on checksum
            # print "RTCM3 Length",
            # print len(RTCM3Data)
            # print "Sanity Check!: "
            # print ' '.join(hex(ord(x))[2:] for x in RTCM3Data)
            # print "#####################################"

            if len(RTCM3Data)>0:
                ser.write(str(RTCM3Data))
                RTCM3Data = []
                

if __name__ == '__main__':
  #contains currently running threads
  threads = []
  rospy.init_node('gps_node')
  print("######GPS NODE RUNNING######")
  #Run RTK-reader Threads
  global ser
  while not rospy.is_shutdown():
      try:
          ser = serial.Serial(DEVICE,BAUD_RATE)
          print "Sucessfully connected to RTK."
          break
      except:
          print "Cannot access RTK. Retrying in 1s."
          time.sleep(1)

  ser.flushInput()
  RTK_Reader = SerialReader()
  RTK_Reader.deamon=True
  RTK_Reader.start()

  RTK_Base_client = CorrectionDataClient(HOST,PORT)
  RTK_Base_client.deamon=True
  RTK_Base_client.start()
