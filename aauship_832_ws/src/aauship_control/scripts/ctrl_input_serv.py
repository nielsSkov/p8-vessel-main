#!/usr/bin/env python
import sys
import socket
import time 
import rospy
from aauship_control.msg import LLIinput

HOST = ''
PORT = 9000
inputLength=22

inpServ=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
inpServ.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1)
inpServ.bind((HOST,PORT))
rospy.init_node('control_input_node')
publisher=rospy.Publisher('lli_input',LLIinput,queue_size=10)
lli_data_R = LLIinput()
lli_data_R.DevID = 10
lli_data_R.MsgID =5
lli_data_R.Time=0
lli_data_L = LLIinput()
lli_data_L.DevID = 10
lli_data_L.MsgID = 3
lli_data_L.Time=0





#while True:
#
#    inpServ.listen(10)
#    print "waiting for incoming traffic"
#    (conn,(ip,port)) = inpServ.accept()
#    print "accepted connection from: ",
#    while True:
#        try:
#            data = conn.recv(inputLength)
#        except e: 
#            err=e.args[0]
#            print err
#        if data.startswith('$'):
#            print data
#            X1 = ord(data[1])
#            Y1 = ord(data[2])
#            X2 = ord(data[3])
#            Y2 = ord(data[4])

while True:

    inpServ.listen(10)
    print "waiting for incoming traffic"
    (conn,(ip,port)) = inpServ.accept()
    print "accepted connection from: ",
    print ip
    while True:
        try:
            data = conn.recv(inputLength)
        except: 
            print "Connection err thingy"
        if data.startswith('$') and len(data) == inputLength:
            X1  = ord(data[1])
            Y1  = ord(data[2])
            X2  = ord(data[3])
            Y2  = ord(data[4])
            du  = ord(data[5])
            dd  = ord(data[6])
            dl  = ord(data[7])
            dr  = ord(data[8])
            se  = ord(data[9])
            ps  = ord(data[10])
            st  = ord(data[11])
            L3  = ord(data[12])
            R3  = ord(data[13])
            tri = ord(data[14])
            o   = ord(data[15])
            x   = ord(data[16])
            squ = ord(data[17])
            L1  = ord(data[18])
            R1  = ord(data[19])
            L2  = ord(data[20])
            R2  = ord(data[21])
            speed_max = 200

            if L1>10:
                speed= int(speed_max*(128-Y1)/128)
                turn=128-X2
                if speed < 80:
                    speed = 0
                    speed_l=0
                    speed_r=0
                else:
                    speed_l=max(min(speed-turn,300),80)
                    speed_r=max(min(speed+turn,300),80)

                lli_data_R.Data=int(speed_r)
                lli_data_L.Data=int(speed_l)
                print "Values:"
                print Y1,X2
                print "Speeds:" 
                print speed_l,speed_r
                print "Turn:"
                print turn

            elif R1>10:
                speed=max(int((du-155)*speed_max/100),0)
                turn_l=max(int((dl-155)*speed_max/100),0)
                turn_r=max(int((dr-155)*speed_max/100),0)
                if speed < 80:
                    speed = 0
                    speed_l=0
                    speed_r=0
                else:
                    speed_l=max(min(speed-turn_l+turn_r,300),80)
                    speed_r=max(min(speed-turn_r+turn_l,300),80)

                lli_data_R.Data=int(speed_r)
                lli_data_L.Data=int(speed_l)
                print "Values:"
                print Y1,X2
                print "Speeds:" 
                print speed_l,speed_r
                print "Turn:"
                print dl,dr
                print turn_l,turn_r

            else:
                lli_data_R.Data=0
                lli_data_L.Data=0
            
            

                            
            publisher.publish(lli_data_R)
            publisher.publish(lli_data_L)
            

        if not data: 
            print "lost connection"
            lli_data_R.Data = 0
            lli_data_L.Data = 0
            publisher.publish(lli_data_R)
            publisher.publish(lli_data_L)
            conn.close
            break

