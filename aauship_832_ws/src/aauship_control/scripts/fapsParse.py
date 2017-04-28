import struct
import csv
import Queue
import numpy
from pynmea import nmea
from math import pi, atan
import gpsfunctions
import time

import rospy
from aauship_control.msg import *

## Packet Parser
#
# This parses the packets to identify messages and decodes them for the logs
class packetParser():
    #def __init__(self,accelfile,gpsfile,gpsstate,measstate,fulllog,plog): ## USE IF YOU WANT TO LOG DATA
    #def __init__(self,accelfile,gpsfile,fulllog,plog):	
    def __init__(self,gpsstate,measstate): ## 17gr832 USE IF YOU DON'T WANT TO LOG DATA
    	self.GPS = {0: 'Latitude',
        	1: 'Longtitude',
        	2: 'Velocity'}
    	self.IMU = {0: 'AccelerationX',
        	1: 'AccelerationY',
                2: 'AccelerationZ',
                3: 'GyroscopeX',
                4: 'GyroscopeY',
                5: 'GyroscopeZ',
                6: 'MagnetometerX',
                7: 'MagnetometerY',
                8: 'MagnetometerZ',
                9: 'Temperature'}
        self.MsgID = {0: self.GPS, 1: self.IMU}
        self.DevID = {0: 'GPS', 1: 'IMU'}
        self.accelburst = [0,0,0,0,0,0,0]
	## Uncomment below if you log the data
        #self.accellog = accelfile
        #self.fulllog = fulllog
        #self.plog = plog

        self.prevtime = 0
        self.excount = 0
        #self.accelburst = 0
        self.gpspacket = 0
        self.gps = gpsstate
        self.measureddata = measstate
        self.n_rec = 0
        
        self.gpsdata = [0,0,0,0,0,0,0,0]
        #Time of fix, Latitude, Longitude, Speed over ground, Course Made Good True, Date of Fix, Magnetic Variation, local timestamp
        ## Uncomment below if you log the data
		#self.gpslog = gpsfile

        self.state = numpy.zeros((12,2))
        self.mergedata = False
        
        self.centerlat = 57.02175678643284*pi/180
        self.centerlon = 9.97691237031843*pi/180;
        self.rot = gpsfunctions.get_rot_matrix(self.centerlat,self.centerlon)
        
        self.gpsinvalid = 0
        self.accconst = 0.003333333333333
        self.gyroconst = 0.05*pi/180

        self.pub_bm = rospy.Publisher('bm', BatteryMonitor, queue_size=1)
        self.pub_gps = rospy.Publisher('gps1', GPS, queue_size=1)

        self.gpsmsg = GPS()
        
        self.bank1 = [0.0, 0.0, 0.0, 0.0]
        self.bank2 = [0.0, 0.0, 0.0, 0.0]
        pass
            
    def parse(self,packet):
        #print packet
        try:
            if(ord(packet['DevID']) == 0): # LLI data
                if(ord(packet['MsgID']) == 13): # Battery monitor sample
                    print("BANK1:\t")
                    self.bank1[0] = (ord(packet['Data'][0]) << 8 | ord(packet['Data'][1]))*(0.25*3.0/1.43)
                    self.bank1[1] = (ord(packet['Data'][2]) << 8 | ord(packet['Data'][3]))*(0.25*3.0/1.43)
                    self.bank1[2] = (ord(packet['Data'][4]) << 8 | ord(packet['Data'][5]))*(0.25*3.0/1.43)
                    self.bank1[3] = (ord(packet['Data'][6]) << 8 | ord(packet['Data'][7]))*(0.25*3.0/1.43)
                    print(self.bank1)

                    print("BANK2:\t")
                    self.bank2[0] = (ord(packet['Data'][8]) << 8 | ord(packet['Data'][9]))*(0.25*3.0/1.43)
                    self.bank2[1] = (ord(packet['Data'][10]) << 8 | ord(packet['Data'][11]))*(0.25*3.0/1.43)
                    self.bank2[2] = (ord(packet['Data'][12]) << 8 | ord(packet['Data'][13]))*(0.25*3.0/1.43)
                    self.bank2[3] = (ord(packet['Data'][14]) << 8 | ord(packet['Data'][15]))*(0.25*3.0/1.43)
                    print(self.bank2)


                    # Measured offsets
                    self.bank1[0] = self.bank1[0]+97.33
                    self.bank1[1] = self.bank1[1]+143.67
                    self.bank1[2] = self.bank1[2]+138.67
                    self.bank1[3] = self.bank1[3]+124.33

                    self.bank2[0] = self.bank2[0]+111.33
                    self.bank2[1] = self.bank2[1]+130.67
                    self.bank2[2] = self.bank2[2]+143.67
                    self.bank2[3] = self.bank2[3]+111.33
					
					# if min(self.bank1) < 3600.0:
                        # self.bank1 = [3600.0, 3600.0, 3600.0, 3600.0]

                    # if min(self.bank2) < 3600.0:
                        # self.bank2 = [3600.0, 3600.0, 3600.0, 3600.0]

                    # if max(self.bank1) > 4200.0:
                        # self.bank1 = [4200.0, 4200.0, 4200.0, 4200.0]

                    # if max(self.bank2) > 4200.0:
                        # self.bank2 = [4200.0, 4200.0, 4200.0, 4200.0]
                    
                    if not rospy.is_shutdown():
                        self.pub_bm.publish(self.bank1,self.bank2)


            if(ord(packet['DevID']) == 20): # IMU data
                if(ord(packet['MsgID']) == 14): # Burst read reduced
                    #self.accelburst = self.accelburst + 1
                    #print "IMU: " + str(self.accelburst)
                    
                    
                    #print "IMU"
                    meas = numpy.zeros((9,2))
                    accelnr = 0
                    order = [7,1,4,6,6]
                    if self.mergedata:
                        pass
                    self.mergedata = False
                    #print "IMU!"
                    try:
                        #print "IMU"
                        '''The structure of the packet is 
                        Zgyro
                        X acc
                        Y acc
                        X Mag
                        Y Mag
                        ADC
                        '''
                        #types = ['ADC','Ymag', 'Xmag', 'Yacc', 'Xacc', 'Zgyro']
                        #self.accellog.write("".join(packet['Data']) + "\r\n")
                        measurements = []
                        for i in range(len(packet['Data'])):
                            if ((i & 1) == 1):
                                tempval = packet['Data'][i-1:i+1]
                                tempval.reverse()
                                val = 0
                                try:
                                    val = struct.unpack('h', "".join(tempval))
                                except:
                                    pass
								## Uncomment below if you log the data
                                #self.accellog.write(str(val[0]) + ", ")
                                #self.fulllog.write(str(val[0]) + ", ")
                                measurements.append(val[0])
                                #print val[0]
                        #print measurements[5]
                        #print measurements
						## Uncomment below if you log the data
                        #self.accellog.write(str(time.time()) + "\r\n")
                        #self.fulllog.write(str(time.time()) + "\r\n")
                        if abs(measurements[5]) < 10: #Check that the grounded ADC doesn't return a high value
                            #Calculate heading from magnetometer:
                            
                            heading = 0
                            if -measurements[3] > 0:
                                heading = (90 - atan(float(-measurements[4])/float(-measurements[3]))*180/pi)*pi/180
                            elif -measurements[3] < 0:
                                heading = (270 - atan(float(-measurements[4])/float(-measurements[3]))*180/pi)*pi/180
                            else:
                                if -measurements[4] < 0:
                                    heading = pi
                                else:
                                    heading = 0
                                    
                            #heading = -(2*pi-heading-pi/2)
                            heading = -heading
                            #print chr(27) + "[2J"
                            #print "[" + str(measurements[4]) + ", " + str(measurements[3]) + "]\t Theta: " + str(heading) + "\t Time:" + str(time.time())
                            
                            accx = -measurements[2] * self.accconst
                            accy = -measurements[1] * self.accconst
                            gyroz = -measurements[0] * self.gyroconst
                            
                            self.state[2] = [accx,        1]
                            self.state[5] = [accy,        1]
                            self.state[6] = [heading,    1]
                            self.state[7] = [gyroz,        1]
                            #print self.state
                            for i in range(numpy.size(self.state,0)):
                                for j in range(numpy.size(self.state,1)):
                                    self.measureddata[i,j] = self.state[i,j]
                            #measstate = self.state
                            
                            #print chr(27) + "[2J"
                            #print self.measureddata
                            self.state[:,1] = 0
                            
                    except Exception as e:
                        print e
                    print "exception"
                    
                    #print "IMU BURST!"
                    pass
                elif(ord(packet['MsgID']) == 13): # Burst read
#                    print "Burst read"
                    measurements = []
                    for i in range(len(packet['Data'])):
                        if ((i & 1) == 1):
                            tempval = packet['Data'][i-1:i+1]
                            tempval.reverse()
                            val = 0
                            try:
                                val = struct.unpack('h', "".join(tempval))
                            except:
                                pass
                            ##Uncomment below if you log the data
							#self.accellog.write(str(val[0]) + ", ")
                            #self.fulllog.write(str(val[0]) + ", ")
                            measurements.append(val[0])
					##Uncomment below if you log the data
                    #self.accellog.write(str(time.time()) + "\r\n")
                    #self.fulllog.write(str(time.time()) + "\r\n")

                    self.state[0] = [measurements[0], 1] #supply
                    self.state[1] = [measurements[1], 1] #xacc
                    self.state[2] = [measurements[2], 1] #yacc
                    self.state[3] = [measurements[3], 1] #zacc
                    self.state[4] = [measurements[4], 1] #xgyro
                    self.state[5] = [measurements[5], 1] #ygyro
                    self.state[6] = [measurements[6], 1] #zgyro
                    self.state[7] = [measurements[7], 1] #xmag
                    self.state[8] = [measurements[8], 1] #ymag
                    self.state[9] = [measurements[9], 1] #zmag
                    self.state[10] = [measurements[10], 1] #temp
                    self.state[11] = [measurements[11], 1] #adc

                    # Writing to our "output" object measureddata
                    for i in range(numpy.size(self.state,0)):
                        for j in range(numpy.size(self.state,1)):
                            self.measureddata[i,j] = self.state[i,j]

                    self.state = numpy.zeros((12,2))
                            
                elif(ord(packet['MsgID']) == 15): # Reduced ADIS data, RF test
                    self.n_rec += 1
                    msgnr = ord(packet['Data'][0])
                    #print msgnr
					##Uncomment below if you log the data
                    #self.plog.write(str(self.n_rec) + ", ")
                    #self.plog.write(str(msgnr))
                    #self.plog.write(", 0\n")
                        
                        
            elif (ord(packet['DevID']) == 30): # GPS1 data
                #print "GPS!"
                #time.sleep(1)
                if(ord(packet['MsgID']) == 6): # This is what the LII sends for the moment
                    #['$GPGGA', '133635.000', '5700.8791', 'N', '00959.1707', 'E', '1', '7', '1.23', '42.0', 'M', '42.5', 'M', '', '*6E\r\n']
                    #['$GPRMC', '133635.000', 'A', '5700.8791', 'N', '00959.1707', 'E', '0.20', '263.57', '040914', '', '', 'A*61\r\n']

                    # We expect to get both GPGGA and GPRMC at every GPS sample. This is in two messages.
                    # The GPRMC message is the plast one, so we publish our hybrid GPS message in that if.

                    #print str("".join(packet['Data']))
                    content = "".join(packet['Data']).split(',')
                    # print(content)

                    if content[0] == "$GPGGA":
                        # The GPGGA packet contain the following information:
                        # [0] Message type ($GPGGA)
                        # [1] Time
                        # [2] Latitude
                        # [3] N or S (N)
                        # [4] Longitude
                        # [5] E or W (E)
                        # [6] Fix quality (expect 1 = GPS fix single)
                        # [7] Number of satellites being tracked
                        # [8] HDOP
                        # [9] Altitude, above mean sea level
                        # [10] Unit for altitude M = meters
                        # [11] Height of geoid (mean sea level) above WGS84 ellipsoid
                        # [12] Unit of heigt M = meters
                        # [13] DGPS stuff, ignore
                        # [14] DGPS stuff, ignore
                        # [15] Checksum
                        # print("GGA")
                        if content[11] == '':
                            print('GGA parsing, no fix')
                        else:
                            self.gpsmsg.fix = int(content[6])
                            self.gpsmsg.sats = int(content[7])
                            self.gpsmsg.HDOP = float(content[8])
                            self.gpsmsg.altitude = float(content[9])
                            self.gpsmsg.height = float(content[11])


                    if content[0] == "$GPRMC" and content[2] == 'A':
                        #print ",".join("".join(packet['Data']).split(',')[1:8])
                        # print("RMC")
                        # The GPRMC packet contain the following information:
                        # [0] Message type ($GPRMC)
                        # [1] Timestamp
                        # [2] A for valid, V for invalid (only valid packets gets send)
                        # [3] Latitude
                        # [4] N or S (N)
                        # [5] Longitude
                        # [6] E or W (E)
                        # [7] Speed over ground
                        # [8] Track angle
                        # [9] Date
                        # [10] Magnetic variation value [not existant on this cheap GPS]
                        # [11] Magnetic variation direction [not existant on this cheap GPS]

                        if content[2] == 'A' :
                            # print("Wee, we have a valid $GPRMC fix")
							## Uncomment below if you log the data
                            #self.gpslog.write(",".join(content) + ", " + str(time.time()) + "\r\n")
                            #self.fulllog.write(",".join(content) + ", " + str(time.time()) + "\r\n")
                            #print content
                            speed = float(content[7]) * 0.514444444 #* 0 + 100
                            #print str(speed) + " m/s"
                            
                            # Caculate decimal degrees
                            [latdec, londec] = (gpsfunctions.nmea2decimal(float(content[3]),content[4],float(content[5]),content[6]))
                            # print(latdec,londec)
                            latdec = latdec*pi/180
                            londec = londec*pi/180

                            # Old code for rotating the position into the local NED frame
                            if self.centerlat == 0 and self.centerlon == 0:
                                self.rot=gpsfunctions.get_rot_matrix(float(latdec),float(londec))
                                self.centerlat = float(latdec)
                                self.centerlon = float(londec)
                            pos = self.rot * (gpsfunctions.wgs842ecef(float(latdec),float(londec))-gpsfunctions.wgs842ecef(float(self.centerlat),float(self.centerlon)))
                            #print pos
                            
                            # Legacy stuff
                            self.state[0] = [float(pos[0,0]), 1]
                            #self.state[0] = [10,1]
                            self.state[1] = [speed, 1]
                            self.state[3] = [float(pos[1,0]), 1]
                            #self.state[3] = [5,1]

                            # With [0:6] we ignore ".000" in the NMEA string.
                            # It is always zero for GPS1 anyways.
                            self.gpsmsg.time = int(content[1][0:6]) 
                            self.gpsmsg.latitude = latdec
                            self.gpsmsg.longitude = londec
                            self.gpsmsg.track_angle = float(content[8])
                            self.gpsmsg.date = int(content[9])
                            self.gpsmsg.SOG = speed

                            self.pub_gps.publish(self.gpsmsg)
                            
                        
                elif(ord(packet['MsgID']) == 31):
                    self.n_rec += 1
                    msgnr = ord(packet['Data'][0])
					## Uncomment below if you log the data
                    #self.plog.write(str(self.n_rec) + ", ")
                    #self.plog.write("0, ")
                    #self.plog.write(str(msgnr))
                    #self.plog.write("\n")

            else:
                #print packet
                print "gfoo"
        except Exception as e:
            self.excount += 1
            # print " "+ str(self.excount)
            # print e

