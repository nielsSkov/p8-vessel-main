/*
 * This node subscribes to a geometry_msgs/Transform topic from a matlab node
 * such that it can send a transform to be interpreted by rviz, this just
 * because I have no idea of sending the transforms directly from matabl, with
 * the ROS I/O toolbox for matlab.
 */

#include "ros/ros.h"
#include <tf/transform_broadcaster.h>
#include <visualization_msgs/Marker.h>


void adisCallback(const geometry_msgs::Transform::ConstPtr& msg)
{
  /* AHRS debug output */
//  ROS_INFO("Quaternions: [%.3f, %.3f, %.3f, %0.3f]", u.getQuaternions(1), u.getQuaternions(2), u.getQuaternions(3), u.getQuaternions(0));
//  ROS_INFO("getTuning: [%.3f, %.3f]", u.getTuning(0), u.getTuning(1));
//  ROS_INFO("sampleFreq: [%.3f]", u.getSampleFreq());
  ROS_INFO("foo: [%.3f]", msg->rotation.x);
  /* Publish rviz information */
  static tf::TransformBroadcaster tfbc;
  tf::Transform transform;
  transform.setOrigin( tf::Vector3(msg->translation.x,msg->translation.y,msg->translation.z) );
  tf::Quaternion q(msg->rotation.w,msg->rotation.x,msg->rotation.y,msg->rotation.z);
//  tf::Quaternion q;
//  q.setRPY(u.getEulerAngles(0), u.getEulerAngles(1), u.getEulerAngles(2));
  transform.setRotation(q);
  tfbc.sendTransform( tf::StampedTransform(transform, ros::Time::now(), "map", "boat_link"));
}


int main(int argc, char **argv)
{
  ros::init(argc, argv, "matlab_ahrs_helper_node");
  ros::NodeHandle adis;
  ros::Subscriber adissub = adis.subscribe("test", 2, adisCallback);
  ros::spin();

  return 0;
}
