#!/usr/bin/env python
import roslib; roslib.load_manifest('aauship_control')
import rospy
from aauship_control.msg import *
from geometry_msgs.msg import Twist

import sys, select, termios, tty



def getKey():
	tty.setraw(sys.stdin.fileno())
	select.select([sys.stdin], [], [], 0)
	key = sys.stdin.read(1)
	termios.tcsetattr(sys.stdin, termios.TCSADRAIN, settings)
	return key

vel_now = 0
vel_left = 0
vel_right = 0
count = 0
state = 0

if __name__=="__main__":
    	settings = termios.tcgetattr(sys.stdin)
	
	#pub = rospy.Publisher('cmd_vel', Twist, queue_size = 1)
	pub = rospy.Publisher('lli_input', LLIinput, queue_size=1000)
	rospy.init_node('keyboard_teleop_node')

	SAT_UP = 200
	SAT_DOWN = -200
	DEBOUNCE_COUNT = 1
	STOP_MODE = 0
	ON_MODE = 1

	pub_msg = LLIinput()


#	try:
	while(1):
		key = getKey()
		print key

		if(state == ON_MODE):
		# Step operation: Cross-up to increase speed by 10 and cross-down to decrease it
			if ((key == 'w') and count>=DEBOUNCE_COUNT):
				count=0
				vel_now += 10
			if ((key == 's') and count>=DEBOUNCE_COUNT):
				count=0
				vel_now-=10
			count=count+1
			vel_left=vel_now
			vel_right=vel_now
	
			# To turn keep pressing cross left/right button.
			if (key == 'd'):
				vel_right = -100
			if (key == 'a'):
				vel_left = -100

			# If the square bottom is pressed, a high PWM is set to both motors
			if (key == 'h'):
				vel_right = 200
				vel_left = 200

			# If the cross bottom is pressed, a high PWM is set to one motor and half to the other one
			if (key == 't'):
				vel_right = 150
				vel_left = -100

			# Check for saturation
			if (vel_left>SAT_UP):
		 		vel_left=SAT_UP
			if (vel_left<SAT_DOWN):
		 		vel_left=SAT_DOWN
			if (vel_right>SAT_UP):
		 		vel_right=SAT_UP
			if (vel_right<SAT_DOWN):
		 		vel_right=SAT_DOWN
		else: #if(state == ON_MODE):
		# To start the boat, press the triangle
			if (key == '1'):
				state=ON_MODE
				vel_now=80

		# Emergency Stop: Press the circle
		if (key == '0'):
			vel_now=0
			vel_left=0
			vel_right=0
			state=STOP_MODE
			count=0
			
		#rospy.rosinfo("[%f, %f, %f]", vel_left, vel_right, vel_now)
		pub_msg.DevID = int(10)
		pub_msg.MsgID = int(5)
		pub_msg.Data = int(vel_left)
		pub_msg.Time = 0
		pub.publish(pub_msg)

		pub_msg.DevID = int(10)
		pub_msg.MsgID = int(3)
		pub_msg.Data = int(vel_right)
		pub_msg.Time = 0
		pub.publish(pub_msg)

		if (key == '\x03'):
			break
				# twist.linear.x = x*speed twist.linear.y = y*speed twist.linear.z = z*speed
				# twist.angular.x = 0 twist.angular.y = 0 twist.angular.z = th*turn
				# pub.publish(pub_msg)

#	except:
#		print 'e'
#
#	finally:
#		pub_msg = LLIinput()
#		pub.publish(pub_msg)
#
#    		termios.tcsetattr(sys.stdin, termios.TCSADRAIN, settings)


