#include "ros/ros.h"
#include "sensor_msgs/Joy.h"
#include "aauship/Faps.h"
#include "aauship/LLIinput.h"
#include <std_msgs/Float32.h>

#include <sstream>
#include <stdint.h>
#include <string>
//#include <cstdint>

// note on plain values:
// buttons are either 0 or 1
// button axes go from 0 to -1
// stick axes go from 0 to +/-1

#define PS3_BUTTON_SELECT            0
#define PS3_BUTTON_STICK_LEFT        1
#define PS3_BUTTON_STICK_RIGHT       2
#define PS3_BUTTON_START             3
#define PS3_BUTTON_CROSS_UP          4
#define PS3_BUTTON_CROSS_RIGHT       5
#define PS3_BUTTON_CROSS_DOWN        6
#define PS3_BUTTON_CROSS_LEFT        7
#define PS3_BUTTON_REAR_LEFT_2       8
#define PS3_BUTTON_REAR_RIGHT_2      9
#define PS3_BUTTON_REAR_LEFT_1       10
#define PS3_BUTTON_REAR_RIGHT_1      11
#define PS3_BUTTON_ACTION_TRIANGLE   12
#define PS3_BUTTON_ACTION_CIRCLE     13
#define PS3_BUTTON_ACTION_CROSS      14
#define PS3_BUTTON_ACTION_SQUARE     15
#define PS3_BUTTON_PAIRING           16

#define PS3_AXIS_STICK_LEFT_LEFTWARDS    0
#define PS3_AXIS_STICK_LEFT_UPWARDS      1
#define PS3_AXIS_STICK_RIGHT_LEFTWARDS   2
#define PS3_AXIS_STICK_RIGHT_UPWARDS     3
#define PS3_AXIS_BUTTON_CROSS_UP         4
#define PS3_AXIS_BUTTON_CROSS_RIGHT      5
#define PS3_AXIS_BUTTON_CROSS_DOWN       6
#define PS3_AXIS_BUTTON_CROSS_LEFT       7
#define PS3_AXIS_BUTTON_REAR_LEFT_2      8
#define PS3_AXIS_BUTTON_REAR_RIGHT_2     9
#define PS3_AXIS_BUTTON_REAR_LEFT_1      10
#define PS3_AXIS_BUTTON_REAR_RIGHT_1     11
#define PS3_AXIS_BUTTON_ACTION_TRIANGLE  12
#define PS3_AXIS_BUTTON_ACTION_CIRCLE    13
#define PS3_AXIS_BUTTON_ACTION_CROSS     14
#define PS3_AXIS_BUTTON_ACTION_SQUARE    15
#define PS3_AXIS_ACCELEROMETER_LEFT      16
#define PS3_AXIS_ACCELEROMETER_FORWARD   17
#define PS3_AXIS_ACCELEROMETER_UP        18
#define PS3_AXIS_GYRO_YAW                19


#define AXIS_REAR_LEFT_2 12
#define AXIS_REAR_RIGHT_2 13
#define BUTTON_REAR_LEFT_1 10
#define BUTTON_REAR_RIGHT_1 11
#define BUTTON_SELECT 0
#define BUTTON_CROSS_UP        4
#define BUTTON_CROSS_DOWN        6
/**
 * This is the joy tele operation node
 */

class JoyTeleOperation
{
public:


  JoyTeleOperation()
  {
    pub = n.advertise<aauship::LLIinput>("lli_input", 1000);
    sub = n.subscribe("joy", 1000, &JoyTeleOperation::chatterCallback, this);

  }

  void chatterCallback(const sensor_msgs::Joy::ConstPtr& msg)
  {

    aauship::LLIinput msg2;
    float vel_left;
    float vel_right;
    int16_t val;

    int16_t thrust_diff = 5;
    int16_t thrust_step = 10;

    vel_left = ((-msg->axes[AXIS_REAR_LEFT_2]+1)/2*100)*3;
    vel_right = ((-msg->axes[AXIS_REAR_RIGHT_2]+1)/2*100)*3;
    if (msg->buttons[BUTTON_REAR_LEFT_1])
      vel_left = vel_left*-1;
    if (msg->buttons[BUTTON_REAR_RIGHT_1])
      vel_right = vel_right*-1;
    ROS_INFO("[%f, %f]", vel_left, vel_right);

//    if (msg->buttons[BUTTON_CROSS_UP]);
//    if (msg->buttons[BUTTON_CROSS_DOWN]);
      
    val = (int16_t)(vel_left);

    msg2.DevID = 10;
    msg2.MsgID = 5;
    msg2.Data = val;
    msg2.Time = msg->buttons[BUTTON_CROSS_DOWN];
    pub.publish(msg2);

    val = (int16_t)(vel_right);
    msg2.DevID = 10;
    msg2.MsgID = 3;
    msg2.Data = val;
    msg2.Time = msg->buttons[BUTTON_CROSS_DOWN];
    pub.publish(msg2);
  }

private:
  ros::NodeHandle n;
  ros::Publisher pub;
  ros::Subscriber sub;

}; // End of class JoyTeleOperation

int main(int argc, char **argv)
{
  ros::init(argc, argv, "teleop_node");
  //Create an object of class JoyTeleOperation that will take care of everything
  JoyTeleOperation JTOObject;
  ros::spin();

  return 0;
}

