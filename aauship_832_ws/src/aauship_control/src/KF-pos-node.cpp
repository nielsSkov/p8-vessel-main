#include "ros/ros.h"
#include "aauship_control/PositionStates.h"
#include "aauship_control/AttitudeStates.h"
#include "aauship_control/ADIS16405.h"
#include "aauship_control/LLIinput.h"

#include <cstdlib>
#include <cmath>
#include <iostream>
#include <fstream>

#include <sys/time.h>
#include <std_msgs/Float32.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_linalg.h>

//Constants
#define KF_POSITION_RATE 20.0
#define N_STATES 6
#define N_INPUTS 2
#define N_MEAS 4
#define TS 0.05
//Values for first order curve to fit Force vs PWM
#define M 0.26565
#define N 24.835
//System constants
#define MX 13
#define MY 13
#define DX 0.5
#define DY 7
#define IX 3.6
#define IY 2.3

//State variances
#define SIGMA2_XN 1
#define SIGMA2_YN 1
#define SIGMA2_XBDOT 1
#define SIGMA2_YBDOT 1
#define SIGMA2_XBDDOT 1
#define SIGMA2_YBDDOT 1
//Measurements variances
#define SIGMA2_GPSXN 1
#define SIGMA2_GPSYN 1
#define SIGMA2_ACCXBDDOT 1
#define SIGMA2_ACCYBDDOT 1

//Global variables
float meas[N_MEAS] = {0,0,0,0};
float states[N_STATES] = {0,0,0,0,0,0};
float inputs[N_INPUTS] = {0,0};
float att[3] = {0,0,0};


//Callback functions
void gps_callback(const aauship_control::ADIS16405::ConstPtr& gps_msg)
{

}

void imu_callback(const aauship_control::ADIS16405::ConstPtr& imu_msg)
{
	//Store the accelerometr data in xb and yb
	meas[2] = imu_msg->xaccl;
	meas[3] = imu_msg->yaccl;
}

void att_callback(const aauship_control::AttitudeStates::ConstPtr& att_msg)
{
	//Store the attitude data
	att[0] = att_msg->roll;
	att[1] = att_msg->pitch;
	att[2] = att_msg->yaw;
}

void lli_callback(const aauship_control::LLIinput::ConstPtr& lli_msg)
{
	//Calculate forces as M * PWM - N
	if (lli_msg->DevID == 10 && lli_msg->MsgID == 5)
		inputs[0] = M * lli_msg->Data - N;
	if (lli_msg->DevID == 10 && lli_msg->MsgID == 3)
		inputs[1] = M * lli_msg->Data - N;
}


//Matrix multiplication function
void matrix_multiplication(gsl_matrix * a,gsl_matrix * b,gsl_matrix * result)
{
	int n = a->size1;	//Rows of a
	int m = a->size2;	//Columns of a a and rows of b
	int p = b->size2;	//Columns of b
	float mult = 0;

	for (int i = 0; i < n; i++)
	{
		for(int j = 0; j < p; j++)
		{
			mult = 0;
			for(int k = 0; k < m; k++)
				mult = mult + gsl_matrix_get(a,i,k) * gsl_matrix_get(b,k,j);
			gsl_matrix_set(result,i,j,mult);
		}
	}
}

//Matrix vector multiplication function
void matrix_vector_multiplication(gsl_matrix * a, float * b, float * result)
{
	int n = a->size1;	//Rows of a
	int m = a->size2;	//Columns of a
	float mult = 0;

	for (int i = 0; i < n; i++)
	{
		mult = 0;
		for(int j = 0; j < m; j++)
			mult = mult + gsl_matrix_get(a,i,j) * b[j];
		result[i] = mult;
	}
}

//Main function
int main(int argc, char **argv)
{
	ros::init(argc,argv,"KF_position_node");
	ros::NodeHandle n;
	ros::Subscriber gps_update = n.subscribe("/gps",1000,gps_callback);
	ros::Subscriber imu_update = n.subscribe("/imu",1000,imu_callback);
	ros::Subscriber lli_update = n.subscribe("/lli_input",1000,lli_callback);
	ros::Subscriber att_update = n.subscribe("/kf_attitude",1000,att_callback);
	ros::Publisher pos_pub = n.advertise<aauship_control::PositionStates>("/kf_position", 1);
	ros::Rate KF_position_rate(KF_POSITION_RATE);
	std::cout<<std::endl<<"######POSITION KF RUNNING######"<<std::endl;

	//Temporary matrices
	gsl_matrix * TEMP_6x6 = gsl_matrix_alloc(N_STATES,N_STATES);
	gsl_matrix * TEMP_4x6 = gsl_matrix_alloc(N_MEAS,N_STATES);
	gsl_matrix * TEMP_6x4 = gsl_matrix_alloc(N_STATES,N_MEAS);
	gsl_matrix * TEMP_4x4 = gsl_matrix_alloc(N_MEAS,N_MEAS);
	//Identity matrix
	gsl_matrix * I_6x6 = gsl_matrix_alloc(N_STATES,N_STATES);
	gsl_matrix_set_identity(I_6x6);  

	//////System matrices//////
	//Components of the rotation matrix R=[a1 a2 ~;a3 a4 ~;~ ~ ~] 
	float a1 = cos(att[1]) * cos(att[2]);
	float a2 = sin(att[0]) * sin(att[1]) * cos(att[2]) - cos(att[0]) * sin(att[2]);
	float a3 = cos(att[1]) * sin(att[2]);
	float a4 = sin(att[0]) * sin(att[1]) * sin(att[2]) + cos(att[0]) * cos(att[2]);
	//System matrices
	float Ainit[N_STATES][N_STATES] = {
		{1,0,TS*a1,TS*a2,0,0},
		{0,1,TS*a3,TS*a4,0,0},
		{0,0,1,0,TS,0},
		{0,0,0,1,0,TS},
		{0,0,-DX/MX,0,-TS*DX/MX,0},
		{0,0,0,-DY/MY,0,-TS*DY/MY},
	};
	float Binit[N_STATES][N_INPUTS] = {
		{0,0},
		{0,0},
		{0,0},
		{0,0},
		{1/MX,1/MY},
		{0,0},
	};
	float Cinit[N_MEAS][N_STATES] = {
		{1,0,0,0,0,0},
		{0,1,0,0,0,0},
		{0,0,1,0,0,0},
		{0,0,0,1,0,0}
	};
	//Store the matrices in gsl form
	gsl_matrix * A = gsl_matrix_alloc(N_STATES,N_STATES);
	gsl_matrix * Atrans = gsl_matrix_alloc(N_STATES,N_STATES);
	gsl_matrix * B = gsl_matrix_alloc(N_STATES,N_INPUTS);
	gsl_matrix * C = gsl_matrix_alloc(N_MEAS,N_STATES);
	gsl_matrix * Ctrans = gsl_matrix_alloc(N_STATES,N_MEAS);
	for (int i = 0; i < N_STATES; i++)    //Use the same loop for the three matrices
	{
		for (int j = 0; j < N_STATES; j++)
			gsl_matrix_set(A,i,j,Ainit[i][j]);
		for (int k = 0; k < N_INPUTS; k++)
			gsl_matrix_set(B,i,k,Binit[i][k]);
		for (int l = 0; l < N_MEAS; l++)
			gsl_matrix_set(C,l,i,Cinit[l][i]);
	}
	gsl_matrix_transpose_memcpy(Atrans,A);
	gsl_matrix_transpose_memcpy(Ctrans,C);

	//////Kalman filter matrices initialization//////
	gsl_matrix * P = gsl_matrix_alloc(N_STATES,N_STATES);  //Initialize as identity
	gsl_matrix_set_identity(P);  
	gsl_matrix * K = gsl_matrix_calloc(N_STATES,N_MEAS);    //Initialize as zeros

	//////Weight matrices//////
	float Qinit[N_STATES] = {SIGMA2_XN,SIGMA2_YN,SIGMA2_XBDOT,SIGMA2_YBDOT,SIGMA2_XBDDOT,SIGMA2_YBDDOT};
	float Rinit[N_MEAS] = {SIGMA2_GPSXN,SIGMA2_GPSYN,SIGMA2_ACCXBDDOT,SIGMA2_ACCYBDDOT};
	//Store the matrices in gsl form
	gsl_matrix * Q = gsl_matrix_calloc(N_STATES,N_STATES);
	gsl_matrix * R = gsl_matrix_calloc(N_MEAS,N_MEAS);
	for (int i = 0; i < N_STATES; i++)   
		gsl_matrix_set(Q,i,i,Qinit[i]);
	for (int i = 0; i < N_MEAS; i++)
		gsl_matrix_set(R,i,i,Rinit[i]);

	//////First prediction//////
	//Predict states  as states = A * states + B * inputs
	float temp_states[N_STATES];
	float temp_states2[N_STATES];
	float temp_meas[N_MEAS];
	matrix_vector_multiplication(A, states, temp_states);
	matrix_vector_multiplication(B, inputs, temp_states2);
	for(int i = 0 ; i < N_STATES ; i++)
		states[i] = temp_states[i] + temp_states2[i];
	//Calculate new P as A*P*A'+Q
	matrix_multiplication(A,P,TEMP_6x6);
	matrix_multiplication(TEMP_6x6,Atrans,P);
	gsl_matrix_add (P,Q);

	//Debug
	//gsl_linalg_cholesky_decomp(Ptemp);
	//gsl_linalg_cholesky_invert (Ptemp);
	//std::cout<<gsl_matrix_get(Ptemp,0,0)<<" "<<gsl_matrix_get(Ptemp,0,1)<<" "<<std::endl;
	//std::cout<<gsl_matrix_get(Ptemp,1,0)<<" "<<gsl_matrix_get(Ptemp,1,1)<<" "<<std::endl;
	// std::cout<<" "<<states[0]<<" "<<std::endl;
	// std::cout<<" "<<states[1]<<" "<<std::endl;

	while(ros::ok)
	{	
		ros::spinOnce();

		// std::cout<<gsl_matrix_get(P,0,0)<<" "<<gsl_matrix_get(P,1,1)<<" "<<std::endl;
		// std::cout<<gsl_matrix_get(P,2,2)<<" "<<gsl_matrix_get(P,3,3)<<" "<<std::endl;
		// std::cout<<gsl_matrix_get(P,4,4)<<" "<<gsl_matrix_get(P,5,5)<<" "<<std::endl;
		// std::cout<<gsl_matrix_get(P,6,6)<<" "<<gsl_matrix_get(P,7,7)<<" "<<std::endl;
		// std::cout<<gsl_matrix_get(P,8,8)<<std::endl;

		//////Update step//////
		//Calculate K as P*C'/(C*P*C'+R)
		matrix_multiplication(C,P,TEMP_4x6);
		matrix_multiplication(TEMP_4x6,Ctrans,TEMP_4x4);
		gsl_matrix_add (TEMP_4x4,R);
		gsl_linalg_cholesky_decomp(TEMP_4x4);
		gsl_linalg_cholesky_invert (TEMP_4x4);	
		matrix_multiplication(Ctrans,TEMP_4x4,TEMP_4x6);
		matrix_multiplication(P,TEMP_4x6,K);
		//Correct the states as states = states + K * (meas - C * states)
		matrix_vector_multiplication(C, states, temp_meas);
		for(int i = 0 ; i < N_STATES ; i++)
			temp_meas[i] = meas[i] - temp_meas[i];
		matrix_vector_multiplication(K,temp_meas,temp_states);
		for(int i = 0 ; i < N_STATES ; i++)
			states[i] = states[i] + temp_states[i];
		//Update P as (I - K * C) * P
		matrix_multiplication(K,C,TEMP_6x6);
		gsl_matrix_scale (TEMP_6x6, -1.0);
		gsl_matrix_add(TEMP_6x6,I_6x6);

		//////Update A matrix//////
		a1 = cos(att[1]) * cos(att[2]);
		a2 = sin(att[0]) * sin(att[1]) * cos(att[2]) - cos(att[0]) * sin(att[2]);
		a3 = cos(att[1]) * sin(att[2]);
		a4 = sin(att[0]) * sin(att[1]) * sin(att[2]) + cos(att[0]) * cos(att[2]);
		gsl_matrix_set(A,2,0,TS*a1);
		gsl_matrix_set(A,3,0,TS*a2);
		gsl_matrix_set(A,2,1,TS*a3);
		gsl_matrix_set(A,3,1,TS*a4);

		//////Prediction step//////
		//Predict states as states = A * states + B * inputs
		matrix_vector_multiplication(A, states, temp_states);
		matrix_vector_multiplication(B, inputs, temp_states2);
		for(int i = 0 ; i < N_STATES ; i++)
			states[i] = temp_states[i] + temp_states2[i];
		//Calculate new P as A*P*A'+Q
		matrix_multiplication(A,P,TEMP_6x6);
		matrix_multiplication(TEMP_6x6,Atrans,P);
		gsl_matrix_add (P,Q); 	

		//Publish the states
		aauship_control::PositionStates pos_msg;
		pos_msg.xn = states[0];
		pos_msg.yn = states[1];
		pos_msg.xb_vel = states[2];
		pos_msg.yb_vel = states[3];
		pos_msg.xb_acc = states[4];
		pos_msg.yb_acc = states[5];
		pos_pub.publish(pos_msg);

		//Ensures the timing of the loop
		KF_position_rate.sleep();
	}

	//Free the allocated matrices
	gsl_matrix_free (A);
	gsl_matrix_free (B);
	gsl_matrix_free (C);
	gsl_matrix_free (Atrans);
	gsl_matrix_free (Ctrans);
	gsl_matrix_free (P);
	gsl_matrix_free (K);
	gsl_matrix_free (Q);
	gsl_matrix_free (R);
	gsl_matrix_free (TEMP_6x6);
	gsl_matrix_free (TEMP_6x6);
	gsl_matrix_free (TEMP_4x6);
	gsl_matrix_free (TEMP_4x4);
	gsl_matrix_free (I_6x6);
	return 0;
}
