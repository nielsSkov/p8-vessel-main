import struct
import csv
import Queue
import numpy
from pynmea import nmea
from math import pi, atan
import gpsfunctions
import time

## Packet Parser
#
# This parses the packets to identify messages and decodes them for the logs
class packetParser():
    def __init__(self,accelfile,gpsfile,measstate,fulllog,plog):
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
        self.accellog = accelfile
        self.fulllog = fulllog
        self.plog = plog
    #    self.accelwriter = csv.writer(self.accellog)
        self.prevtime = 0
        self.excount = 0
        #self.accelburst = 0
        self.gpspacket = 0
        self.measureddata = measstate
        self.n_rec = 0
        
        self.gpsdata = [0,0,0,0,0,0,0,0]
        #Time of fix, Latitude, Longitude, Speed over ground, Course Made Good True, Date of Fix, Magnetic Variation, local timestamp
        self.gpslog = gpsfile
    #    self.writer = csv.writer(self.accellog)
        #self.gpswriter = csv.writer(self.gpslog)
        #print "Stdsqewarted!"
        self.state = numpy.zeros((9,2))
        self.mergedata = False
        
        self.centerlat = 57.02175678643284*pi/180
        self.centerlon = 9.97691237031843*pi/180;
        self.rot = gpsfunctions.get_rot_matrix(self.centerlat,self.centerlon)
        
        self.gpsinvalid = 0
        self.accconst = 0.003333333333333
        self.gyroconst = 0.05*pi/180
        
        pass
            
    def parse(self,packet):
        #print packet
        try:
            if(ord(packet['DevID']) == 20):
                if(ord(packet['MsgID']) == 14):
                    #self.accelburst = self.accelburst + 1
                    #print "IMU: " + str(self.accelburst)
                    print "BOB"
                    
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
                                self.accellog.write(str(val[0]) + ", ")
                                self.fulllog.write(str(val[0]) + ", ")
                                measurements.append(val[0])
                                #print val[0]
                        #print measurements[5]
                        #print measurements
                        self.accellog.write(str(time.time()) + "\r\n")
                        self.fulllog.write(str(time.time()) + "\r\n")
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
                            print self.measureddata
                            self.state[:,1] = 0
                            
                    except Exception as e:
                        print e
                    print "exception"
                    
                    #print "IMU BURST!"
                    pass
                elif(ord(packet['MsgID']) == 13):
                    tmeasurements = []
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
                            self.accellog.write(str(val[0]) + ", ")
                            self.fulllog.write(str(val[0]) + ", ")
                            tmeasurements.append(val[0])
                            #print val[0]
                    #print measurements[5]
		    #HK - ACTUAL IMU DATA
		    #print tmeasurements
                    '''
                    [0] Supply
                    [1] X Gyro
                    [2] Y Gyro
                    [3] Z Gyro
                    [4] X
                    [5] Y
                    [6] Z Acc
                    [7] X
                    [8] Y
                    [9] Z Mag
                    [10] Temp
                    [11] ADC
                    
                    What we want:
                    
                    Zgyro
                    X acc
                    Y acc
                    X Mag
                    Y Mag
                    ADC
                    
                    '''
                    
                    #print 
                    #print "READY"
                    measurements.append(tmeasurements[3])
                    measurements.append(tmeasurements[4])
                    measurements.append(tmeasurements[5])
                    measurements.append(tmeasurements[7])
                    measurements.append(tmeasurements[8])
                    measurements.append(tmeasurements[11])
                    #print measurements
                    self.accellog.write(str(time.time()) + "\r\n")
                    self.fulllog.write(str(time.time()) + "\r\n")
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
                        gyroz = measurements[0] * self.gyroconst
                        
                        
                        
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
                        self.state = numpy.zeros((9,2))
                            
                elif(ord(packet['MsgID']) == 15): # Reduced ADIS data
		    print "Reduced ADIS data"
                    self.n_rec += 1
                    msgnr = ord(packet['Data'][0])
                    #print msgnr
                    self.plog.write(str(self.n_rec) + ", ")
                    self.plog.write(str(msgnr))
                    self.plog.write(", 0\n")
                        
                        
            elif (ord(packet['DevID']) == 30): # GPS data
                #print "GPS!"
                #time.sleep(1)
                if(ord(packet['MsgID']) == 6):
                    #print str("".join(packet['Data']))
                    content = "".join(packet['Data']).split(',')
		    
                    if content[0] == "$GPRMC" and content[2] == 'A':
                    	print content
                        #print ",".join("".join(packet['Data']).split(',')[1:8])
                        content = content[1:8]
                    # The GPRMC packet contain the following information:
                    # [0] Timestamp
                    # [1] A for valid, V for invalid (only valid packets gets send)
                    # [2] Latitude
                    # [3] N or S (N)
                    # [4] Longitude
                    # [5] E or W (E)
                    # [6] Speed over ground
                    #print content[6]
                    '''
                    if content[1] == 'A' :
                        self.gpsinvalid += 1
                    
                    if 42 <= self.gpsinvalid <= 67:
                        content[1] = 'V'
                        print "Gps invalid!"
                    '''
                    if content[1] == 'A' :
                    
                        self.gpslog.write(",".join(content) + ", " + str(time.time()) + "\r\n")
                        self.fulllog.write(",".join(content) + ", " + str(time.time()) + "\r\n")
                        #print content
                        speed = float(content[6]) * 0.514444444 #* 0 + 100
                        #print str(speed) + " m/s"
                        [latdec, londec] = (gpsfunctions.nmea2decimal(float(content[2]),content[3],float(content[4]),content[5]))
                        latdec = latdec*pi/180
                        londec = londec*pi/180
                        if self.centerlat == 0 and self.centerlon == 0:
                            self.rot=gpsfunctions.get_rot_matrix(float(latdec),float(londec))
                            self.centerlat = float(latdec)
                            self.centerlon = float(londec)
                        
                        
                        pos = self.rot * (gpsfunctions.wgs842ecef(float(latdec),float(londec))-gpsfunctions.wgs842ecef(float(self.centerlat),float(self.centerlon)))
                        #print pos
                        #print pos
                        
                        
                        self.state[0] = [float(pos[0,0]),        1]
                        #self.state[0] = [10,1]
                        self.state[1] = [speed, 1]
                        self.state[3] = [float(pos[1,0]),     1]
                        #self.state[3] = [5,1]
                        
                elif(ord(packet['MsgID']) == 31):
                    self.n_rec += 1
                    msgnr = ord(packet['Data'][0])
                    self.plog.write(str(self.n_rec) + ", ")
                    self.plog.write("0, ")
                    self.plog.write(str(msgnr))
                    self.plog.write("\n")


            elif (ord(packet['DevID']) == 0): # LLI data
                print "LLI IS COMMING TO TOWN**************************"
            else:
                #print packet
                print "gfoo"
        except Exception as e:
            self.excount += 1
            print " "+ str(self.excount)
            print e,

