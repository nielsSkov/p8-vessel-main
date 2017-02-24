#!/usr/bin/env python2

import rospy
import serial
import gpsfunctions

from aauship.msg import *

class GPS2():
    '''
    NMEA data format:
    
    For GPGGA:
      0: $GPGGA
      1: Time
      2: Latitude
      3: N or S
      4: Longitude
      5: E or W
      6: Fix (1 = good)
      7: No. sats
      8: Horizontal Dilution of Precision (HDOP)
      9: Altitude (ASML)
      10: Height of geoid above WGS84 ellipsoid
      12: Time since last DGPS update
      13: DGPS reference station id
      14: Checksum

    For GPRMC:
      0: $GPRMC
      1: time
      2: A or V (A = valid, V = invalid)
      3: Latitude
      4: N or S
      5: Longitude
      6: E or W
      7: Speed in knots
      8: True course 
      9: Date 
      10: Variation
      11: E or W
      12: Checksum
    '''

    def __init__(self, log_file):
        self.gps2 = serial.Serial("/dev/gps2",115200,timeout=0.04)
        #self.gps2 = open("gps2.data")
        self.log_file = open(log_file, 'w')
        self.pub = rospy.Publisher('gps2', GPS, queue_size=10)
        self.lli = rospy.Publisher('lli_input', LLIinput, queue_size=10)

	rospy.init_node('gps2node')

    def run(self):
        GPGGA_received = False
        GPRMC_received = False
        gps_msg = GPS()
        
        while not rospy.is_shutdown():
            try:
                line = self.gps2.readline()
                if line:
                    line = line.rstrip()                    
                    data_arr = line.split(',')
                    
                if data_arr[0] == "$GPGGA":
                    self.log_file.write(line + '\n')
                    GPGGA_received = True
                    #print data_arr[1]
                    gps_msg.time = int(float(data_arr[1]))
                    #print "time:", int(float(data_arr[1]))
                    lat, lng = gpsfunctions.nmea2decimal(float(data_arr[2]), data_arr[3], float(data_arr[4]), data_arr[5])
                    gps_msg.latitude = lat
                    gps_msg.longitude = lng
                    #print "long:", float(data_arr[4])
                    gps_msg.fix = int(data_arr[6])
                    #print "fix:", int(data_arr[6])
                    gps_msg.sats = int(data_arr[7])
                    #print "sats:", int(data_arr[7])
                    gps_msg.HDOP = float(data_arr[8])
                    #print "HDOP:", float(data_arr[8])
                    gps_msg.altitude = float(data_arr[9])
                    #print "AMSL:", float(data_arr[9])
                    gps_msg.height = float(data_arr[11])


                elif data_arr[0] == "$GPRMC":
                    self.log_file.write(line + '\n')
                    GPRMC_received = True
                    gps_msg.SOG = float(data_arr[7])
                    gps_msg.track_angle = float(data_arr[8])
                    gps_msg.date = int(data_arr[9])
                    
                
                if GPGGA_received and GPRMC_received:
                    # send packet
                    print "GPS_MSG:", gps_msg
                    self.pub.publish(gps_msg)
                    gps_msg = GPS()
                    GPGGA_received = False
                    GPGGA_received = False
            except:
                pass

        self.log_file.close()

if __name__ == '__main__':
    gps = GPS2('logs/gps2.log')
    gps.run()    
