// #include "ros/ros.h"
// #include "sensor_msgs/Joy.h"
// #include "aauship_control/Faps.h"
// #include "aauship_control/LLIinput.h"
// #include <std_msgs/Float32.h>
// #include "aauship_control/KFStates.h"

#include <sstream>
#include <stdint.h>
#include <string>
#include <iostream>
#include <fstream>
#include <math.h>

///////////////////////
// Defines
#define RADIUS 22.5				// Radius of turn
#define N_WPS_TURN 10			// number of waypoints per turn
#define DIST_WPS_LINE 50		// waypoint on line every __ meters
#define isX 1;
#define isY 0;  


//////////////////////
// Initialize Functions

bool getXYstart(float diff_x, float diff_y, float* start, float (*co_ord)[2][2]);
void coOrds(float* line_wps, float* turn, float start, int num_wps_line);
void populateWPS(float wps[][2], float* turn, float* line_wps, int num_lines, int num_wps_line, float* start);
void swapXY(float wps[][2], int num_wps, bool xy);
void writeWPS(float wps[][2], int num_wps);

// Main function
int main(int argc, char **argv)
{
	// min and max co-ordinates
	float co_ord[2][2] = {{0, 0}, {1000, 500}};

	// gets x and y lengths
	float diff_x = co_ord[1][0] - co_ord[0][0];
	float diff_y = co_ord[1][1] - co_ord[0][1];

	// calculates number of lines that need to be made
	int num_lines = ceil((fmin(diff_x, diff_y)-RADIUS)/(2*RADIUS))+1;

	// gets max_diff
	float max_diff = fmax(diff_x, diff_y);

	// Gets start co-ord and defines direction of path
	float start[2] = {0,0};
	bool X_Y = getXYstart(diff_x, diff_y, start, &co_ord);	// is x or y the longest line --> x = isX = 1, y = isY = 0 

	// number of wps per line
	int num_wps_line = floor(max_diff/DIST_WPS_LINE)+1;
	
	// Calculates number of waypoints and creates array for waypoints
	int num_wps = num_lines*num_wps_line + (num_lines-1)*(N_WPS_TURN-1);
	float wps [num_wps][2];
	memset(wps, 0, sizeof(wps));
	float (*waypoints)[2] = wps;

	// Calculates repeatable co-ords for path
	float line_wps[num_wps_line];	
	float turn[N_WPS_TURN];
	coOrds(line_wps, turn, start[1], num_wps_line);

	// Calculates and populates waypoint array
	populateWPS(waypoints, turn, line_wps, num_lines, num_wps_line, start);

	// Function if x and y co-ords need to be swapped
	swapXY(waypoints, num_wps, X_Y);
	writeWPS(waypoints, num_wps);
	return 0;
}

//////////////////////////////////////
// Functions

// Function to get start co-ordinates and checks whether x or y is the longer line
bool getXYstart(float diff_x, float diff_y, float* start, float (*c)[2][2])
{
	bool xy;
	if(diff_x <= diff_y)
	{
		start[0] = (*c)[0][0]+RADIUS;
		start[1] = (*c)[0][1];
		xy = isY;
	}
	else if(diff_x > diff_y)
	{
		start[0] = (*c)[0][1]+RADIUS;
		start[1] = (*c)[0][0];
		xy = isX;
	}
	else
	{
		std::cout<<"Error with co-ordinates"<<std::endl;
	}
	return xy;
}

void coOrds(float* line_wps, float* turn, float start, int num_wps_line)
{
	// co-ords for line
	for (int i = 0; i < num_wps_line; ++i)
	{
		line_wps[i] = start+i*DIST_WPS_LINE;
	}
	// co-ords for turn
	float turn_dist = 2*RADIUS/N_WPS_TURN;
	// gets co-ords of turn between lines
	for(int i = 1; i < N_WPS_TURN; i++)
	{
		turn[i] = i*turn_dist;
	}
}

// Function to populate WPS array
void populateWPS(float wps[][2], float* turn, float* line_wps, int num_lines, int num_wps_line, float* start)
{
	// make wps
	int count = 0;
	float circ0 = 0;
	float circ1 = 0;
	float line0 = 0;
	for(int i = 0; i < num_lines; i++)
	{
		line0 = start[0]+i*2*RADIUS;
		// If even, line WPS counts upwards
		if(i%2 == 0)
		{
			// WPS for line
			for(int j = 0; j < num_wps_line; j++)
			{
				wps[count][0] = line0;
				wps[count][1] = line_wps[j];
				count = count + 1;
			}
			if(i < num_lines - 1)
			{
				circ0 = line0+RADIUS;
				circ1 = wps[count-1][1];
				// WPS for turn
				for(int j = 1; j < N_WPS_TURN; j++)
				{
					wps[count][0] = turn[j]+line0;
					wps[count][1] = sqrt( pow(RADIUS,2) - pow((wps[count][0]-circ0), 2) )/2 + circ1;
					count = count + 1;
				}
			}
		}
		// If odd, line WPS counts downwards
		else
		{
			// WPS for line
			for(int j = num_wps_line-1; j >= 0; j--)
			{
				wps[count][0] = start[0]+i*2*RADIUS;
				wps[count][1] = line_wps[j];
				count = count + 1;
			}
			if(i < num_lines - 1)
			{
				circ0 = line0+RADIUS;
				circ1 = wps[count-1][1];
				// WPS for turn
				for(int j = 1; j < N_WPS_TURN; j++)
				{
					wps[count][0] = turn[j]+line0;
					wps[count][1] = -( sqrt( pow(RADIUS,2) - pow((wps[count][0]-circ0), 2) )/2 + circ1);
					count = count + 1;
				}
			}
		}
	}
}

// Function to swap x and y co-ords if needed
void swapXY(float wps[][2], int num_wps, bool xy)
{
	// Switch wps[...][0] with wps[...][1]
	if(xy)
	{
		for(int i = 0; i < num_wps; i++)
		{
			float temp0 = wps[i][0];
			float temp1 = wps[i][1];
			wps[i][0] = temp1;
			wps[i][1] = temp0;
		}
	}
}

// Function to write WPS array
void writeWPS(float wps[][2], int num_wps)
{
	std::fstream fs;
	fs.open("waypoints.txt", std::fstream::out);
	for(int i = 0; i< num_wps; i++)
	{
		//fs<<"Fuck this shit\n";
		fs<<wps[i][0]<<","<<wps[i][1]<<std::endl;
		//printf("%f\t%f\n", wps[i][0],wps[i][1]);
	}
	fs.close();
	//printf("%i\n", num_wps);
}