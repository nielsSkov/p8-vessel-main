#include <math.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <string>
#include <stdio.h>

#include "ros/ros.h"
#include <std_msgs/Float32.h>
#include "aauship_control/AttitudeStates.h"
#include "aauship_control/PositionStates.h"
#include "aauship_control/KFStates.h"
#include "aauship_control/Ref.h"
#include "aauship_control/KFStates.h"

#define _USE_MATH_DEFINES //Ensures compatibility with math library
#define WAYPOINT_RADIUS 3 //[m]
#define BOAT_RADIUS 3 //[m]
#define PATH_FOLLOWING_RATE 2 //[Hz]
#define SPEED 1 //[m/s]
#define TOL 0.001 //[m] Minimum value to consider a number == 0

struct point{
	float x;
	float y;
}prev_wpt, next_wpt, current_position, velocity;

float heading = 1;


//Callback functions
void att_callback(const aauship_control::AttitudeStates::ConstPtr& att_msg)
{
	heading =  att_msg->yaw;
}
void pos_callback(const aauship_control::PositionStates::ConstPtr& pos_msg)
{
	// current_position.x = pos_msg->xn;
	// current_position.y = pos_msg->yn;
	// velocity.x = pos_msg->xbd;
	// velocity.y = pos_msg->ybd;
}
void KF_callback(const aauship_control::KFStates::ConstPtr& KFStates)
{
	current_position.x = KFStates->x;
  	current_position.y = KFStates->y;
  	velocity.x = KFStates->u;
  	velocity.y = KFStates->v;
}

// //Debug
// void kf_callback(const aauship_control::KFStates::ConstPtr& kf_msg)
// {
// 	heading =  kf_msg->psi;
// 	current_position.x = kf_msg->x;
// 	current_position.y = kf_msg->y;
// }


aauship_control::Ref computeRef(point curr_pos, point reference_point);
point circleIntersection(point curr_pos,point old_waypoint,point next_waypoint,float dist);
float distance2line(point curr_pos, point old_waypoint, point next_waypoint);
float dist2wpt(point curr_pos, point old_waypoint, point next_waypoint);
point perpIntersection(point curr_pos, point old_waypoint, point next_waypoint);
point getWaypoint (std::string line);


int main(int argc, char **argv)
{
	ros::init(argc,argv,"path_follower_node");
	ros::NodeHandle n;
	ros::Subscriber pos_update = n.subscribe("/kf_position",1000,pos_callback);
	ros::Subscriber att_update = n.subscribe("/kf_attitude",1000,att_callback);
	ros::Subscriber kf_update = n.subscribe("/kf_statesnew",1000,KF_callback);
	// //Debug
	// ros::Subscriber kf_update = n.subscribe("/kf_statesnew",1000,kf_callback);
	// //
	ros::Publisher ref_pub = n.advertise<aauship_control::Ref>("/control_reference", 1);
	ros::Rate path_follower_rate(PATH_FOLLOWING_RATE);
	std::cout<<std::endl<<"######PATH FOLLOWING NODE RUNNING######"<<std::endl;

  	//Open txt file that contains the waypoints and read the first two
	std::string line;	
	std::ifstream wptFile;
	wptFile.open ("/home/aauship/p8-vessel-main/aauship_832_ws/src/aauship_control/src/wps.txt");
	if(wptFile.is_open())
	{
		std::getline(wptFile,line,'\n');
		prev_wpt = getWaypoint (line);
		std::getline(wptFile,line,'\n');
		next_wpt = getWaypoint (line);	
	}

	float dist = 1000;
	aauship_control::Ref reference;
	reference.speed = 0;
	reference.yaw = 0;
	point cross;

	while(ros::ok())
	{
		// std::cout<<"Prev: "<<prev_wpt.x<<","<<prev_wpt.y<<std::endl;
		 std::cout<<"Next: "<<next_wpt.x<<","<<next_wpt.y<<std::endl;
		ros::spinOnce();
		//Check if we need to change waypoint
		if (dist2wpt(current_position, prev_wpt, next_wpt)<WAYPOINT_RADIUS)
		{
			if (std::getline(wptFile,line)) //If there is a new waypoint
			{
				//Get new waypoint
				prev_wpt.x = next_wpt.x;
				prev_wpt.y = next_wpt.y;
				next_wpt = getWaypoint (line);
				//Check if there is a crossing point with the line
				dist = distance2line(current_position,prev_wpt,next_wpt);
				if(dist < BOAT_RADIUS)
				{
					cross = circleIntersection(current_position,prev_wpt,next_wpt,dist);
					reference = computeRef(current_position,cross);
				}
				else 
					reference = computeRef(current_position,next_wpt);
			}
			else	//If there are no more waypoints available
				reference.speed = 0;
		}

		else
		{
  			//Check if there is a crossing point with the line
			dist = distance2line(current_position,prev_wpt,next_wpt);
			if(dist < BOAT_RADIUS)
			{
				cross = circleIntersection(current_position,prev_wpt,next_wpt,dist);
				reference = computeRef(current_position,cross);
			}
			else 
				reference = computeRef(current_position,next_wpt);
		}
		//Publish the reference on the topic
		ref_pub.publish(reference);
		//Print some infor (debug)
		//std::cout<<reference.yaw<<","<<heading<<","<<current_position.x<<","<<current_position.y<<","<<cross.x<<","<<cross.y<<std::endl;
		// std::cout<<reference.speed<<std::endl;
		//Ensure the timing of the loop
		path_follower_rate.sleep();
	}
	wptFile.close();
	return 1;
}

point circleIntersection(point curr_pos,point old_waypoint,point next_waypoint,float dist)
{
	point del_wpt, intersection, cross_pt[2]; 	
	float theta, B;
	float dist2_0, dist2_1;
	//Convert to boat frame to get center point in 0,0 
	// ol_wpt_boat.x = old_waypoint.x-curr_pos.x;
	// ol_wpt_boat.y = old_waypoint.y-curr_pos.y;
	// new_wpt_boat.x = next_waypoint.x-curr_pos.x;
	// new_wpt_boat.y = next_waypoint.y-curr_pos.y;
	// del_wpt.x = new_wpt_boat.x-ol_wpt_boat.x;
	// del_wpt.y = new_wpt_boat.y-ol_wpt_boat.y;

	del_wpt.x = next_waypoint.x-old_waypoint.x;
	del_wpt.y = next_waypoint.y-old_waypoint.y;

	//The line description used describes a line using an angle and radius from (0,0) 
	//The actual line will be perpendicular to the point described
	//This description is used to avoid infinite slopes on vertical lines (Ax+B have inf A for vertical lines) 
	//See:  http://docs.opencv.org/2.4/doc/tutorials/imgproc/imgtrans/hough_lines/hough_lines.html for a better description
	theta =  (M_PI/2) + atan2(del_wpt.y,del_wpt.x); //Note! This is not the angle of the line between waypoints but perpendicular to it (See hough line transform)									//Intersection point of a line perpendicular to the "waypoint"line, which goes through the center of the circle
	intersection = perpIntersection(curr_pos, old_waypoint, next_waypoint);

	//Compute distance from perpendicular crossing of line to the intersection point of the circle
	B = sqrt(BOAT_RADIUS*BOAT_RADIUS-dist*dist);		

	//Compute crossing points in NED coordinates															
	if (del_wpt.x<=TOL) 		//If the line is vertical
	{
		cross_pt[0].x = intersection.x;  
		cross_pt[0].y = intersection.y + B;
		cross_pt[1].x = intersection.x;
		cross_pt[1].y = intersection.y - B;
	}
	else if (del_wpt.y<=TOL)	//If the line is horizontal
	{
		cross_pt[0].x = intersection.x + B;  
		cross_pt[0].y = intersection.y;
		cross_pt[1].x = intersection.x - B;
		cross_pt[1].y = intersection.y;
	}
	else						//Otherwise
	{	
		cross_pt[0].x = intersection.x + cos(theta-M_PI/2) * B;  //sin/cos(theta-M_PI)*B creates a vector of length B
		cross_pt[0].y = intersection.y + sin(theta-M_PI/2) * B;  //Pi is subtracted to get the angle of the line
		cross_pt[1].x = intersection.x - cos(theta-M_PI/2) * B;
		cross_pt[1].y = intersection.y - sin(theta-M_PI/2) * B;
	}

	//Return the point closest to the waypoint we try to reach (new waypoint)
	dist2_0 = (cross_pt[0].x-next_waypoint.x) * (cross_pt[0].x-next_waypoint.x) + (cross_pt[0].y-next_waypoint.y) * (cross_pt[0].y-next_waypoint.y);
	dist2_1 = (cross_pt[1].x-next_waypoint.x) * (cross_pt[1].x-next_waypoint.x) + (cross_pt[1].y-next_waypoint.y) * (cross_pt[1].y-next_waypoint.y);
	if (dist2_0 < dist2_1)
	{
		//std::cout<<"Int: "<<cross_pt[0].x<<","<<cross_pt[0].y<<std::endl;
		return cross_pt[0];
	}
	else 
	{
		//std::cout<<"Int: "<<cross_pt[1].x<<","<<cross_pt[1].y<<std::endl;
		return cross_pt[1];
	}
}

aauship_control::Ref computeRef(point curr_pos, point reference_point)
{
	aauship_control::Ref reference;
	point delta_point;

	delta_point.x = reference_point.x-curr_pos.x;
	delta_point.y = reference_point.y-curr_pos.y;

	reference.yaw = atan2(delta_point.y, delta_point.x);// - atan2(velocity.y, velocity.x);
	//reference.yaw -= M_PI;
	reference.speed = SPEED;
	return reference;
}

float distance2line(point curr_pos, point old_waypoint, point next_waypoint)
{
	//Find  the perpendicular distance to the line
	float dist, distx, disty;
	point intersection;
	intersection = perpIntersection(curr_pos, old_waypoint, next_waypoint);
	distx = intersection.x - curr_pos.x;
	disty = intersection.y - curr_pos.y;
	dist = sqrt(distx * distx + disty * disty);
	//std::cout<<intersection.x<<","<<intersection.y<<",";
	return dist;
}

float dist2wpt(point curr_pos, point old_waypoint, point next_waypoint)
{
	//Find  the perpendicular distance to the next waypoint
	float dist, distx, disty;
	point intersection;
	intersection = perpIntersection(curr_pos, old_waypoint, next_waypoint);
	distx = intersection.x - next_waypoint.x;
	disty = intersection.y - next_waypoint.y;
	dist = sqrt(distx * distx + disty * disty);
	std::cout<<"Distance to waypoint"<<dist<<std::endl;
	return dist;
}

point perpIntersection(point curr_pos, point old_waypoint, point next_waypoint)
{
	//Find the crossing point between the two waypoints and the perpendicular line that passes through the position
	point del_wpt, intersection;
	// k = ((next_waypoint.y-old_waypoint.y) * (curr_pos.x-old_waypoint.x) - (next_waypoint.x-old_waypoint.x) * (curr_pos.y-old_waypoint.y)) / ((next_waypoint.y-old_waypoint.y)*(next_waypoint.y-old_waypoint.y) + (next_waypoint.x-old_waypoint.x)*(next_waypoint.x-old_waypoint.x));
	// x = curr_pos.x - k * (next_waypoint.y-old_waypoint.y);		//Intersection of the perpendicular with the line between waypoints
	// y = curr_pos.y + k * (next_waypoint.x-old_waypoint.x);
	del_wpt.x = next_waypoint.x-old_waypoint.x;
	del_wpt.y = next_waypoint.y-old_waypoint.y;
	if (del_wpt.x<=TOL)			//If the line is vertical
	{
		intersection.x = old_waypoint.x;
		intersection.y = curr_pos.y;
	}
	else if (del_wpt.y<=TOL)	//If the line is horizontal
	{
		intersection.x = curr_pos.x;
		intersection.y = old_waypoint.y;
	}
	else						//Otherwise
	{
		intersection.x = (del_wpt.y * del_wpt.y * old_waypoint.x + del_wpt.x * del_wpt.x * curr_pos.x + del_wpt.x * del_wpt.y * (curr_pos.y - old_waypoint.y)) / (del_wpt.y * del_wpt.y + del_wpt.x * del_wpt.x);
		intersection.y = (del_wpt.y * (intersection.x - old_waypoint.x)) / del_wpt.x + old_waypoint.y;
	}
	return intersection;
}

point getWaypoint (std::string line)
{
	//Reads a string in the format "wptx,wpty\n" and returns the coordinates
	//Find comma
	std::size_t index;
	point coordinates;
	std::string xstring;
	std::string ystring;
	//Find "," and divide the string in two
	index = line.find_first_of(",");
	if (index==0)
		xstring = line.substr(0,1);		//string substr (size_t pos = 0, size_t len = npos)
	else
		xstring = line.substr(0,index);
	ystring = line.substr(index+1);
	//Convert the strings into floats
	coordinates.x = atof(xstring.c_str());
	coordinates.y = atof(ystring.c_str());
	return coordinates;
}
