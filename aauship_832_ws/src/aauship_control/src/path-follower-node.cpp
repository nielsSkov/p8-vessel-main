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

///#define _USE_MATH_DEFINES //Ensures compatibility with math library
#define WAYPOINT_RADIUS 5 //[m]
#define BOAT_RADIUS 10 //[m]
#define PATH_FOLLOWING_RATE 2 //[Hz]
#define ENABLE_LOOP true
#define DISABLE_LOOP false
#define SPEED 0.3 //[m/s]

struct point{
	double x;
	double y;
}prev_wpt,next_wpt;

float heading = 1;
point current_position;


//Callback functions
void att_callback(const aauship_control::AttitudeStates::ConstPtr& att_msg)
{
	heading =  att_msg->yaw;
}
void pos_callback(const aauship_control::PositionStates::ConstPtr& pos_msg)
{
	current_position.x = pos_msg->xn;
	current_position.y = pos_msg->yn;
}
//Debug
void kf_callback(const aauship_control::KFStates::ConstPtr& kf_msg)
{
	heading =  kf_msg->psi;
	current_position.x = kf_msg->x;
	current_position.y = kf_msg->y;
// 	std::cout<<"xn: "<<current_position.x<<std::endl;
// 	std::cout<<"yn: "<<current_position.y<<std::endl;
}


aauship_control::Ref computeRef(point curr_pos, point reference_point);
point circleIntersection(point curr_pos,point old_waypoint,point next_waypoint,double dist);
double distance2line(point curr_pos, point old_waypoint, point next_waypoint);
double dist2wpt(point curr_pos, point old_waypoint, point next_waypoint);
point getWaypoint (std::string line);


int main(int argc, char **argv)
{
	ros::init(argc,argv,"path_follower_node");
	ros::NodeHandle n;
	ros::Subscriber pos_update = n.subscribe("/kf_position",1000,pos_callback);
	ros::Subscriber att_update = n.subscribe("/kf_attitude",1000,att_callback);
	//Debug
	ros::Subscriber kf_update = n.subscribe("/kf_statesnew",1000,kf_callback);
	//
	ros::Publisher ref_pub = n.advertise<aauship_control::Ref>("/control_reference", 1);
	ros::Rate path_follower_rate(PATH_FOLLOWING_RATE);
	//std::cout<<std::endl<<"######PATH FOLLOWING NODE RUNNING######"<<std::endl;

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
		// std::cout<<"Prev point is: "<<prev_wpt.x<<","<<prev_wpt.y<<std::endl;
		// std::cout<<"Next point is: "<<next_wpt.x<<","<<next_wpt.y<<std::endl;
	}

	float dist = 1000;
	aauship_control::Ref reference;
	reference.speed = 0;
	reference.yaw = 0;
	point cross;

	while(ros::ok())
	{
		ros::spinOnce();
		// std::cout<<"dist2wpt: "<<dist2wpt(current_position, prev_wpt, next_wpt)<<std::endl;
		if (dist2wpt(current_position, prev_wpt, next_wpt)<WAYPOINT_RADIUS)
		{
			if (std::getline(wptFile,line)) //If there is a new waypoint
			{
				//Get new waypoint
				prev_wpt.x = next_wpt.x;
				prev_wpt.y = next_wpt.y;
				next_wpt = getWaypoint (line);
				//std::cout<<"Prev point is: "<<prev_wpt.x<<","<<prev_wpt.y<<std::endl;
				//std::cout<<"Next point is: "<<next_wpt.x<<","<<next_wpt.y<<std::endl;

				//Check if there is a crossing point with the line
				dist = distance2line(current_position,prev_wpt,next_wpt);
				//std::cout<<"dist: "<<dist<<std::endl;
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
			// std::cout<<"dist2: "<<dist<<std::endl;
			if(dist < BOAT_RADIUS)
			{
				cross = circleIntersection(current_position,prev_wpt,next_wpt,dist);
				reference = computeRef(current_position,cross);
			}
			else 
				reference = computeRef(current_position,next_wpt);
		}
		reference.yaw = M_PI / 4;
		ref_pub.publish(reference);
		//std::cout<<"SpeedRef: "<<reference.speed<<std::endl;
		//std::cout<<"YawRef: "<<reference.yaw<<std::endl;
		//std::cout<<"Yaw: "<<heading<<std::endl;
		//Ensures the timing of the loop
		std::cout<<reference.yaw<<","<<heading<<","<<current_position.x<<","<<current_position.y<<","<<cross.x<<","<<cross.y<<std::endl;
		path_follower_rate.sleep();
	}
	wptFile.close();
	return 1;
}

point circleIntersection(point curr_pos,point old_waypoint,point next_waypoint,double dist)
{
	point ol_wpt_boat, new_wpt_boat, del_wpt; 				//Convert to boat frame to get center point in 0,0 
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
	float theta =  (M_PI/2) + atan2(del_wpt.y,del_wpt.x); //Note! This is not the angle of the line between waypoints but perpendicular to it (See hough line transform)
	point intersect; 										//Intersection point of a line perpendicular to the "waypoint"line, which goes through the center of the circle
	intersect.x = cos(theta) * dist + curr_pos.x;
	intersect.y = sin(theta) * dist + curr_pos.y;
	point cross_pt[2]; //This will contain the intersection points between the line and the circle

	float B = sqrt(BOAT_RADIUS*BOAT_RADIUS-dist*dist);		//B = distance from perpendicular crossing of line to the intersection point of the circle
																//Pythagoras theorem is used
	//Compute crossing points in NED coordinates
	cross_pt[0].x = intersect.x + cos(theta-M_PI/2) * B;  //sin/cos(theta-M_PI)*B creates a vector of length B
	cross_pt[0].y = intersect.y + sin(theta-M_PI/2) * B;  //Pi is subtracted to get the angle of the line
	cross_pt[1].x = intersect.x - cos(theta-M_PI/2) * B;
	cross_pt[1].y = intersect.y - sin(theta-M_PI/2) * B;

	//Return the point closest to the waypoint we try to reach (new waypoint)
	double dist2_0 = (cross_pt[0].x-next_waypoint.x) * (cross_pt[0].x-next_waypoint.x) + (cross_pt[0].y-next_waypoint.y) * (cross_pt[0].y-next_waypoint.y);
	double dist2_1 = (cross_pt[1].x-next_waypoint.x) * (cross_pt[1].x-next_waypoint.x) + (cross_pt[1].y-next_waypoint.y) * (cross_pt[1].y-next_waypoint.y);
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
	reference.yaw = atan2(delta_point.y,delta_point.x);
	reference.speed = SPEED;
	return reference;
}

double distance2line(point curr_pos, point old_waypoint, point next_waypoint)
{
	//Find  the perpendicular distance to the line
	double dist;
	float distx, disty, k, x, y;
	point del_wpt;
	// k = ((next_waypoint.y-old_waypoint.y) * (curr_pos.x-old_waypoint.x) - (next_waypoint.x-old_waypoint.x) * (curr_pos.y-old_waypoint.y)) / ((next_waypoint.y-old_waypoint.y)*(next_waypoint.y-old_waypoint.y) + (next_waypoint.x-old_waypoint.x)*(next_waypoint.x-old_waypoint.x));
	// x = curr_pos.x - k * (next_waypoint.y-old_waypoint.y); 		//Intersection of the perpendicular with the line between waypoints
	// y = curr_pos.y + k * (next_waypoint.x-old_waypoint.x);
	del_wpt.x = next_waypoint.x-old_waypoint.x;
	del_wpt.y = next_waypoint.y-old_waypoint.y;
	x = (del_wpt.y * del_wpt.y * old_waypoint.x + del_wpt.x * del_wpt.x * curr_pos.x + del_wpt.x * del_wpt.y * (curr_pos.y - old_waypoint.y)) / (del_wpt.y * del_wpt.y + del_wpt.x * del_wpt.x);
	y = (del_wpt.y * (curr_pos.x - old_waypoint.x)) / del_wpt.x + old_waypoint.y;
	distx = x - curr_pos.x;
	disty = y - curr_pos.y;
	dist = sqrt(distx * distx + disty * disty);
	return dist;
}

double dist2wpt(point curr_pos, point old_waypoint, point next_waypoint)
{
	//Find  the perpendicular distance to the next waypoint
	double dist;
	float distx, disty, k, x, y;
	point del_wpt;
	// k = ((next_waypoint.y-old_waypoint.y) * (curr_pos.x-old_waypoint.x) - (next_waypoint.x-old_waypoint.x) * (curr_pos.y-old_waypoint.y)) / ((next_waypoint.y-old_waypoint.y)*(next_waypoint.y-old_waypoint.y) + (next_waypoint.x-old_waypoint.x)*(next_waypoint.x-old_waypoint.x));
	// x = curr_pos.x - k * (next_waypoint.y-old_waypoint.y);		//Intersection of the perpendicular with the line between waypoints
	// y = curr_pos.y + k * (next_waypoint.x-old_waypoint.x);
	del_wpt.x = next_waypoint.x-old_waypoint.x;
	del_wpt.y = next_waypoint.y-old_waypoint.y;
	x = (del_wpt.y * del_wpt.y * old_waypoint.x + del_wpt.x * del_wpt.x * curr_pos.x + del_wpt.x * del_wpt.y * (curr_pos.y - old_waypoint.y)) / (del_wpt.y * del_wpt.y + del_wpt.x * del_wpt.x);
	y = (del_wpt.y * (curr_pos.x - old_waypoint.x)) / del_wpt.x + old_waypoint.y;
	distx = x - next_waypoint.x;
	disty = y - next_waypoint.y;
	dist = sqrt(distx * distx + disty * disty);
	return dist;
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