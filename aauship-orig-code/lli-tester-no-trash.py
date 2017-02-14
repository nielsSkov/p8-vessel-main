import packetHandler
import packetparser
import Queue
import time
import csv
import numpy
import os
from math import pi
import serial

import struct

##Open relevant files
'''LOGGING FOR BOTH'''
receivinglog = open("meas/received.txt",'w')
acclog = open("meas/acc.txt",'w')
gpslog = open("meas/gps.txt",'w')
plog = open("meas/plog.txt",'w')
inclog = open("meas/inclog.txt",'w')
echolog = open("meas/echolog.txt",'w')
gps2log = open("meas/gps2log.txt",'wb')


qu = Queue.Queue()
kalqueue = Queue.Queue()
to = 0.1665
#receiver = packetHandler.packetHandler("/dev/tty.SLAB_USBtoUART",38400,0.02,qu,inclog)
# Using the udev rules file 42-aauship.rules 
#receiver = packetHandler.packetHandler("/dev/lli",115200,0.02,qu,inclog) # This runs its own thread
receiver = packetHandler.packetHandler("/dev/lli",57600,0.02,qu,inclog) # This runs its own thread
#echorcv = serial.Serial("/dev/echosounder",4800,timeout=0.04)
#gps2rcv = serial.Serial("/dev/gps2",115200,timeout=0.04)

receiver.start()

measuredstates = numpy.zeros((9,2))
tempm = measuredstates
parser = packetparser.packetParser(acclog,gpslog,measuredstates,receivinglog,plog)
bla = True
timeout = 1000
p = receiver.constructPacket("",0,9)
print "Packet:", p
count = 0
motor = numpy.matrix([[0],[0]])
motor2 = numpy.matrix([[0],[0]])
sendControl = 0
running = True
sign = 1
p = {'DevID': chr(255) , 'MsgID': 0,'Data': 0, 'Time': time.time()}
p2 = {'DevID': chr(255) , 'MsgID': 0,'Data': 0, 'Time': time.time()}
GPSFIX = True

#receiver.

try:
    while running == True:
            p = receiver.constructPacket("",0,9)
            #receiver.sendPacket(p)

            if(receiver.isOpen()):
                try:

                    p = qu.get(False)
                    if ord(p['DevID']) != 255:
                        pass

                    # If current is GPS and previous was [I DON'T KNOW]
                    if ord(p['DevID']) == 30 and ord(p2['DevID']) == 255:
                        GPSFIX = True
                        print "Handling GPS Data!1"
                        p2 = p
                        n = 0
                        while n < 3:
                            try:
                                p = qu.get(False)
                            except Queue.Empty:
                                time.sleep(0.0001)
                                pass
                            n += 1
                        parser.parse(p2)
                        parser.parse(p)
                        tempm = measuredstates
                        sendControl += 1
                    
                    # If previous packet was IMU and current is GPS
                    elif ord(p2['DevID']) == 20 and ord(p['DevID']) == 30: 
                        GPSFIX = True
                        #print "Handling GPS Data!2"
                        #print p
                        parser.parse(p)
                        parser.parse(p2)
                        tempm = measuredstates
                        print "printing temp: "
                        print tempm
                        #print measuredstates[0]
                        sendControl += 1
                        #print measuredstates
                        #tempm = measuredstates
                    
                    # If both packets are IMU
                    elif ord(p2['DevID']) == 20 and ord(p['DevID']) == 20:
                        parser.parse(p2)
                        #print measuredstates[0]
                        sendControl += 1
                    
                    # If previous is IMU and current is [I DON'T KNOW]
                    elif ord(p2['DevID']) == 20 and ord(p['DevID']) == 255:
                        parser.parse(p2)
                        sendControl += 1
                    
                    # If both are [I DON'T KNOW] and sendControl > 0
                    if ord(p2['DevID']) == 255 and ord(p['DevID']) == 255 and sendControl > 0:
                        #print measuredstates[0][1]
                        if measuredstates[0][1] == 1:
			     print "hello"
                            #print measuredstates
                        
                        
                        #if GPSFIX == True:
                            #print "GPS FIX!"
                            #AAUSHIP2.ReadStates(tempm,motor)
                        GPSFIX = False
                        #print sendControl
                        sendControl = 0
                        #print sendControl
                        #print str(count)
                        count += 1
                        
                    p2 = p
                    
#                    elif ord(p['DevID']) == 20 and ord(p2['DevID']) == 30:
#                        parser.parse(p2)
#                        parser.parse(p)
#                    elif ord(p2['DevID']) == 20:
#                        parse(p2)
                except Queue.Empty:
                    pass

                # Grabbing the echosounder data
                try:
                    echosounder = echorcv.readline()
                    echosounder = echosounder.rstrip()
                    if echosounder != "":
                        #print echosounder
                        echolog.write(echosounder + ',' + str(time.time()) + "\r\n")
                except Exception:
                    pass
                
                # Grabbing the GPS2 data
                try:
                    gps2 = gps2rcv.readline()
                    if gps2 != "":
                        gps2 = gps2.rstrip()
                        gps2log.write(gps2 + ',' +str(time.time()) + "\r\n")
                        #print gps2
#                        if gps[0:3]=='$GP':
#                            print "nullermand" + gps2
#                            gps2 = gps2.rstrip()
#                            gps2log.write(gps2 + ',' + str(time.time()) + "\r\n")
#                        else:
#                            gps2log.write(gps2)
                except Exception:
                    pass

except KeyboardInterrupt:
    print "Interrupted by keyboard"
    receiver.close()
    receiver.join()
                

receivinglog.close()
#echorcv.close()

acclog.close()
gpslog.close()
echolog.close()
gps2log.close()


plog.close()
inclog.close()

print "done"

quit()    
