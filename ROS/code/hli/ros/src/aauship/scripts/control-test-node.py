#!/usr/bin/env python

import roslib; roslib.load_manifest('aauship')

import rospy
from std_msgs.msg import String
from aauship.msg import *

import time
import os 

## This is the control node
#  Its sole purpose is to be the simple PID controller implementation
#  that should be used for model verification. That is that we see
#  similar performance with the real boat with the same PID parameters
#  as we do with the matlab model.
#
#  This node gets input from the rqt_mypkg node, which sets reference
#  setpoints and PID coefficients to the controllers, from here it is
#  also possible to select the respective controller.
#
#  This is divided into two topics, one for the setpoints
#  (aauship/testSetpoints.msg) and one for the PID coefficients
#  (aauship/PID.msg).
class Control(object):
    ## Reference callback to update variables
    def ref_cb(self, data):
        print(data)
        pass

    ## PID callback to update variables
    def pid_cb(self, data):
        print(data)
        pass

        pid_u = self.pid_controller_update()

    ## PID controller to calculate actuator input
    def pid_controller_update(self, Kp, Ki, Kd, desired, currentstate):
        error = desired - currentstate
        integral = integral + error
        derivative = error - prev_error
        actuatorinput = Kp*error + Ki*integral + Kd*derivative
        prev_error = error
        return actuatorinput
        #sleep(dt)
        pass

    def run(self):
        BUFSIZE = 1024
        self.ctllog = open(str(os.environ['ROS_TEST_RESULTS_DIR']) + "/../../src/aauship/scripts/logs/ctl.log",'w',BUFSIZE)
        print(self.ctllog.name)

        prev_error = 0
        

        subref = rospy.Subscriber('ref_input', testSetpoints, self.pid_cb, queue_size=1)
        subpid = rospy.Subscriber('pid_input', PID, self.ref_cb, queue_size=1)
        pub = rospy.Publisher('lli_input', LLIinput, queue_size=1)

        rospy.init_node('control_test_node')
        r = rospy.Rate(0.5) # Hz
        #rospy.spin() # Keeps the node running untill stopped
        while not rospy.is_shutdown():
            #pub.publish("control signals should be sent here")
            print("\nHusk at logge motor inputs")
            r.sleep()
        print("\nClosing log file")
        self.ctllog.close()
        print("Exiting")
        exit()

if __name__ == '__main__':
    w = Control()
    w.run()
