import rospy
import time

from aauship.msg import *

msg = LLIinput()
lli = rospy.Publisher('lli_input', LLIinput, queue_size=10)

def constant(thrust_r, thrust_l):
    while not rospy.is_shutdown():
        msg.DevID = 10
        msg.MsgID = 3
        msg.Data = thrust_r
        lli.publish(msg)
        
        print msg
        
        msg.DevID = 10
        msg.MsgID = 5
        msg.Data = thrust_l
        lli.publish(msg)

        print msg

        time.sleep(1)

def alternating(t1, t2):
    while not rospy.is_shutdown():
        msg.DevID = 10
        msg.MsgID = 3
        msg.Data = t1
        lli.publish(msg)
        
        msg.DevID = 10
        msg.MsgID = 5
        msg.Data = t2
        lli.publish(msg)

        tmp = t1
        t1 = t2
        t2 = tmp
        time.sleep(1)

    

if __name__ == '__main__':
    # (-100% = -500 to +100% = 500)
    # right thruster, devid 10, msgid 3
    # left thruster, devid 10, msgid 5
    rospy.init_node("step")
    if sys.argv[1] == 'c':
        constant(int(sys.argv[2]), int(sys.argv[3]))
    else:
        alternating(int(sys.argv[2]), int(sys.argv[3]))
