#include <stdlib.h>
#include <iostream>
#include <math.h>

#include "ros/ros.h"
#include "sensor_msgs/Joy.h"
#include "aauship_control/Faps.h"
#include "aauship_control/LLIinput.h"
#include <std_msgs/Float32.h>
#include "aauship_control/KFStates.h"
#include "aauship_control/ref.h"

#define _USE_MATH_DEFINES //Ensures compatibility with math library
#define WAYPOINT_RADIUS 5 //[m]
#define BOAT_RADIUS 5 //[m]
#define PATH_FOLLOWING_FREQUENCY 2 //[hz]
#define ENABLE_LOOP true
#define SPEED 1 //[m/s]

struct point{
  float x;
  float y;
}prev_wpt,next_wpt;

float heading = 1;
point current_position;
//point next_wpt, old_wpt;

void KF_callback(const aauship_control::KFStates::ConstPtr& KFStates)
  {
  heading =  KFStates->psi;
  current_position.x=KFStates->x;
  current_position.y=KFStates->y;
  }
  
double distance2line(point curr_pos, point old_waypoint, point next_waypoint);

aauship_control::ref computeref(point curr_pos, point reference_point);

point CircleIntersection(point curr_pos,point old_waypoint,point next_waypoint,double dist);


int main(int argc, char **argv)
{
  ros::init(argc,argv,"path_follower_node");
  ros::NodeHandle n;
  ros::Subscriber kf_update = n.subscribe("/kf_statesnew",1000,KF_callback);
  ros::Publisher ref_pub = n.advertise<aauship_control::ref>("/control_reference", 1);
  ros::Rate(PATH_FOLLOWING_FREQUENCY);
  std::cout<<std::endl<<"######PATH FOLLOWING NODE RUNNING######"<<std::endl;

  prev_wpt.x = 2;
  prev_wpt.y = 2;
  next_wpt.x = 2;
  next_wpt.y = 10;


  while(ENABLE_LOOP)
  {
	float dist = distance2line(current_position,prev_wpt,next_wpt);
	if(dist <=BOAT_RADIUS)
		ref_pub.publish(computeref(current_position,CircleIntersection(current_position,prev_wpt,next_wpt,dist)));
	else 
		ref_pub.publish(computeref(current_position,next_wpt));
  }
  return 1;
}

point CircleIntersection(point curr_pos,point old_waypoint,point next_waypoint,double dist)
{
  point ol_wpt_boat, new_wpt_boat; //Convert to boatframe to get center point in 0,0 
  ol_wpt_boat.x = old_waypoint.x-curr_pos.x;
  ol_wpt_boat.y = old_waypoint.y-curr_pos.y;
  new_wpt_boat.x = next_waypoint.x-curr_pos.x;
  new_wpt_boat.y = next_waypoint.y-curr_pos.y;
  point del_wpt; //Contains the Delta x and y
  del_wpt.x = new_wpt_boat.x-ol_wpt_boat.x;
  del_wpt.y = new_wpt_boat.y-ol_wpt_boat.y;
  //The line description used describes a line using an angle and radius from (0,0) 
  //The actual line will be perpendicular to the point described
  //This description is used to avoid infinite slopes on vertical lines (Ax+B have inf A for vertical lines) 
  //See:  http://docs.opencv.org/2.4/doc/tutorials/imgproc/imgtrans/hough_lines/hough_lines.html for a better description
  float theta =  (M_PI/2)+atan2(del_wpt.y,del_wpt.x); //Note! This is not the angle of the line between waypoints but perpendicular to it (See hough line transform)
  point intersect; //Intersection point of a line perpendicular to the "waypoint"line, which goes through the center of the circle
  intersect.x = cos(theta+M_PI)*dist;
  intersect.y = sin(theta+M_PI)*dist;
  point cross_pt[2]; //This will contain the intersection points between the line and the circle
  //B = distance from perpendicular crossing of line to the intersection point of the circle
  //Pythagoras theorem is used
  float B = sqrt(BOAT_RADIUS*BOAT_RADIUS-dist*dist);

  //Compute crossing points 
  cross_pt[0].x = intersect.x+cos(theta-M_PI/2)*B;  //sin/cos(theta-M_PI)*B creates a vector of length b 
  cross_pt[0].y = intersect.y+sin(theta-M_PI/2)*B;  //Pi is subtracted to get the angle of the line
  cross_pt[1].x = intersect.x-cos(theta-M_PI/2)*B;
  cross_pt[1].y = intersect.y-sin(theta-M_PI/2)*B;
  
  //Return the point closest to the waypoint we try to reach (new waypoint)
  // Change from pow() to normal multiplication when there are two terms involved only
  if(sqrt(pow(cross_pt[0].x-next_waypoint.x,2)+pow(cross_pt[0].y-next_waypoint.y,2))<sqrt(pow(cross_pt[1].x-next_waypoint.x,2)+pow(cross_pt[1].y-next_waypoint.y,2)))
  {
    std::cout<<"Point is: "<<cross_pt[0].x<<","<<cross_pt[0].y;
    return cross_pt[0];
  }
  else 
  {
    std::cout<<"Point is: "<<cross_pt[1].x<<","<<cross_pt[1].y;
    return cross_pt[1];
  }
}

aauship_control::ref computeref(point curr_pos, point reference_point)
{
  aauship_control::ref reference;
  point delta_point;
  delta_point.x = reference_point.x-curr_pos.x;
  delta_point.y = reference_point.y-curr_pos.y;
  reference.psi = atan2(delta_point.y,delta_point.x);
  reference.speed = SPEED;
}

double distance2line(point curr_pos, point old_waypoint, point next_waypoint)
{
  double dist;
  point old_wpt_boat, new_wpt_boat;
  //convert to boat frame
  old_wpt_boat.x = old_waypoint.x-curr_pos.x;
  old_wpt_boat.y = old_waypoint.y-curr_pos.y;
  new_wpt_boat.x = next_waypoint.x-curr_pos.x;
  new_wpt_boat.y = next_waypoint.y-curr_pos.y;

  //See CircleIntersect for a descripton of how this is used
  float theta =  (M_PI/2)+atan2(old_wpt_boat.y-new_wpt_boat.y,old_wpt_boat.x-new_wpt_boat.x);
  dist = new_wpt_boat.x*cos(theta) + new_wpt_boat.y*sin(theta);
  return dist;
}

