#include "ros/ros.h"
#include "aauship_control/AttitudeStates.h"
#include "aauship_control/ADIS16405.h"
#include "aauship_control/LLIinput.h"

#include <cstdlib>
#include <cmath>
#include <iostream>
#include <fstream>

//#include <aauship_control/ekf.h>
//#include <aauship_control/ukf.h>
#include <sys/time.h>
#include <std_msgs/Float32.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_linalg.h>

//Constants
#define KF_ATTITUDE_RATE 20.0
#define N_STATES 9
#define N_INPUTS 2
#define N_MEAS 6
#define TS 0.05
//System constants
#define DROLL 0.1094 
#define DPITCH 7.0203
#define DYAW 0.26285
#define IX 0.06541
#define IY 1.08921
#define IZ 1.10675 
#define L1 0.05
#define L2 0.05
//State variances
#define SIGMA2_ROLL 0.0025
#define SIGMA2_PITCH 0.0025
#define SIGMA2_YAW 0.0025
#define SIGMA2_ROLLD 0.005
#define SIGMA2_PITCHD 0.005
#define SIGMA2_YAWD 0.005
#define SIGMA2_ROLLDD 0.001
#define SIGMA2_PITCHDD 0.001
#define SIGMA2_YAWDD 0.001
//Sensor variances
#define SIGMA2_ACCROLL 0.00001165
#define SIGMA2_ACCPITCH 0.00002264
#define SIGMA2_MAGYAW 0.00779021
#define SIGMA2_GYROX 0.01033425
#define SIGMA2_GYROY 3.98414543
#define SIGMA2_GYROZ 0.03143791
//Gyro biases
#define BIAS_GYROX 0.03753197
#define BIAS_GYROY 4.49556388
#define BIAS_GYROZ 0.16183876

//Values for first order curve to fit Force vs PWM
#define M 0.26565
#define N 24.835


//Global variables
double meas[N_MEAS] = {0,0,0,0,0,0};
double states[N_STATES] = {0,0,0,0,0,0,0,0,0};
double inputs[N_INPUTS] = {0,0};


//Callback functions
void imu_callback(const aauship_control::ADIS16405::ConstPtr& imu_msg)
{
	double magxh = 0;
	double magyh = 0;

	//Calculate roll and pitch from the accelerometer measurements
	//Roll = atan(yacc / sqrt(xacc^2 + zacc^2)) and pitch = atan(xacc / sqrt(yacc^2 + zacc^2))
	meas[0] = atan2((imu_msg->yaccl),sqrt((imu_msg->xaccl)*(imu_msg->xaccl)+(imu_msg->zaccl)*(imu_msg->zaccl)));	 
	meas[1] = -atan2((imu_msg->xaccl),sqrt((imu_msg->yaccl)*(imu_msg->yaccl)+(imu_msg->zaccl)*(imu_msg->zaccl)));

	//Calculate yaw using the megnetometer data
	magxh = (imu_msg->xmagn) * cos(states[1]) + (imu_msg->ymagn) * sin(states[0]) * sin(states[1]) + (imu_msg->zmagn) * cos(states[0]) * sin(states[1]);
	magyh = (imu_msg->ymagn) * cos(states[0]) + (imu_msg->zmagn) * sin(states[0]);
	meas[2] = atan2(magyh,magxh);

	//Store the gyro measurements
	meas[3] = imu_msg->xgyro + BIAS_GYROX;	//Negative bias
	meas[4] = -imu_msg->ygyro - BIAS_GYROY;	//Positive bias
	meas[5] = -imu_msg->zgyro + BIAS_GYROZ;	//Negative bias
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
	double mult = 0;

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
void matrix_vector_multiplication(gsl_matrix * a, double * b, double * result)
{
	int n = a->size1;	//Rows of a
	int m = a->size2;	//Columns of a
	double mult = 0;

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
	ros::init(argc,argv,"KF_attitude_node");
	ros::NodeHandle n;
	ros::Subscriber imu_update = n.subscribe("/imu",1000,imu_callback);
	ros::Subscriber lli_update = n.subscribe("/lli_input",1000,lli_callback);
	ros::Publisher att_pub = n.advertise<aauship_control::AttitudeStates>("/kf_attitude", 1);
	ros::Rate KF_attitude_rate(KF_ATTITUDE_RATE);
	std::cout<<std::endl<<"######ATTITUDE KF NODE RUNNING######"<<std::endl;

	//Temporary matrices
	gsl_matrix * TEMP_9x9 = gsl_matrix_alloc(N_STATES,N_STATES);
	gsl_matrix * TEMP2_9x9 = gsl_matrix_alloc(N_STATES,N_STATES);
	gsl_matrix * TEMP_6x9 = gsl_matrix_alloc(N_MEAS,N_STATES);
	gsl_matrix * TEMP_9x6 = gsl_matrix_alloc(N_STATES,N_MEAS);
	gsl_matrix * TEMP_6x6 = gsl_matrix_alloc(N_MEAS,N_MEAS);
	//Identity matrix
	gsl_matrix * I_9x9 = gsl_matrix_alloc(N_STATES,N_STATES);
	gsl_matrix_set_identity(I_9x9);  
	gsl_matrix * I_6x6 = gsl_matrix_alloc(N_MEAS,N_MEAS);
	gsl_matrix_set_identity(I_6x6);  

	//////System matrices//////
	double Ainit[N_STATES][N_STATES] = {
		{1,0,0,TS,0,0,0,0,0},
		{0,1,0,0,TS,0,0,0,0},
		{0,0,1,0,0,TS,0,0,0},
		{0,0,0,1,0,0,TS,0,0},
		{0,0,0,0,1,0,0,TS,0},
		{0,0,0,0,0,1,0,0,TS},
		{0,0,0,-DROLL/IX,0,0,-TS*DROLL/IX,0,0},
		{0,0,0,0,-DPITCH/IY,0,0,-TS*DPITCH/IY,0},
		{0,0,0,0,0,-DYAW/IZ,0,0,-TS*DYAW/IZ}
	};
	double Binit[N_STATES][N_INPUTS] = {
		{0,0},
		{0,0},
		{0,0},
		{0,0},
		{0,0},
		{0,0},
		{0,0},
		{0,0},
		{L1/IZ,-L2/IZ},
	};
	double Cinit[N_MEAS][N_STATES] = {
		{1,0,0,0,0,0,0,0,0},
		{0,1,0,0,0,0,0,0,0},
		{0,0,1,0,0,0,0,0,0},
		{0,0,0,1,0,0,0,0,0},
		{0,0,0,0,1,0,0,0,0},
		{0,0,0,0,0,1,0,0,0}
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
	double Qinit[N_STATES] = {SIGMA2_ROLL,SIGMA2_PITCH,SIGMA2_YAW,SIGMA2_ROLLD,SIGMA2_PITCHD,SIGMA2_YAWD,SIGMA2_ROLLDD,SIGMA2_PITCHDD,SIGMA2_YAWDD};
	double Rinit[N_MEAS] = {SIGMA2_ACCROLL,SIGMA2_ACCPITCH,SIGMA2_MAGYAW,SIGMA2_GYROX,SIGMA2_GYROY,SIGMA2_GYROZ};
	//Store the matrices in gsl form
	gsl_matrix * Q = gsl_matrix_calloc(N_STATES,N_STATES);
	gsl_matrix * R = gsl_matrix_calloc(N_MEAS,N_MEAS);
	for (int i = 0; i < N_STATES; i++)   
		gsl_matrix_set(Q,i,i,Qinit[i]);
	for (int i = 0; i < N_MEAS; i++)
		gsl_matrix_set(R,i,i,Rinit[i]);

	//////First prediction//////
	//Predict states  as states = A * states + B * inputs
	double temp_states[N_STATES];
	double temp_states2[N_STATES];
	double temp_meas[N_MEAS];
	matrix_vector_multiplication(A, states, temp_states);
	matrix_vector_multiplication(B, inputs, temp_states2);
	for(int i = 0 ; i < N_STATES ; i++)
		states[i] = temp_states[i] + temp_states2[i];
	//Calculate new P as A*P*A'+Q
	matrix_multiplication(A,P,TEMP_9x9);
	matrix_multiplication(TEMP_9x9,Atrans,P);
	gsl_matrix_add (P,Q);

	while(ros::ok())
	{	
		ros::spinOnce();

		// std::cout<<gsl_matrix_get(P,0,0)<<" "<<gsl_matrix_get(P,1,1)<<" "<<std::endl;
		// std::cout<<gsl_matrix_get(P,2,2)<<" "<<gsl_matrix_get(P,3,3)<<" "<<std::endl;
		// std::cout<<gsl_matrix_get(P,4,4)<<" "<<gsl_matrix_get(P,5,5)<<" "<<std::endl;
		// std::cout<<gsl_matrix_get(P,6,6)<<" "<<gsl_matrix_get(P,7,7)<<" "<<std::endl;
		// std::cout<<gsl_matrix_get(P,8,8)<<std::endl;
		// std::cout<<"---------------------------------"<<std::endl;

		//////Update step//////
		//Calculate K as P*C'/(C*P*C'+R)
		matrix_multiplication(C,P,TEMP_6x9);
		matrix_multiplication(TEMP_6x9,Ctrans,TEMP_6x6);
		gsl_matrix_add (TEMP_6x6,R);
		gsl_linalg_cholesky_decomp(TEMP_6x6);
		gsl_linalg_cholesky_invert (TEMP_6x6);	
		matrix_multiplication(Ctrans,TEMP_6x6,TEMP_9x6);
		matrix_multiplication(P,TEMP_9x6,K);
		//Correct the states as states = states + K * (meas - C * states)
		matrix_vector_multiplication(C, states, temp_meas);
		for(int i = 0 ; i < N_MEAS ; i++)
			temp_meas[i] = meas[i] - temp_meas[i];
		matrix_vector_multiplication(K,temp_meas,temp_states);
		for(int i = 0 ; i < N_STATES ; i++)
			states[i] = states[i] + temp_states[i];
		//Update P as (I - K * C) * P
		matrix_multiplication(K,C,TEMP_9x9);
		gsl_matrix_scale (TEMP_9x9, -1.0);
		gsl_matrix_add(TEMP_9x9,I_9x9);
		matrix_multiplication(TEMP_9x9,P,TEMP2_9x9);
		gsl_matrix_memcpy(P,TEMP2_9x9);

		//////Prediction step//////
		//Predict states as states = A * states + B * inputs
		matrix_vector_multiplication(A, states, temp_states);
		matrix_vector_multiplication(B, inputs, temp_states2);
		for(int i = 0 ; i < N_STATES ; i++)
			states[i] = temp_states[i] + temp_states2[i];
		//Calculate new P as A*P*A'+Q
		matrix_multiplication(A,P,TEMP_9x9);
		matrix_multiplication(TEMP_9x9,Atrans,P);
		gsl_matrix_add (P,Q); 	

		//Publish the states
		aauship_control::AttitudeStates att_msg;
		att_msg.roll = states[0];
		att_msg.pitch = states[1];
		att_msg.yaw = states[2];
		att_msg.rolld = states[3];
		att_msg.pitchd = states[4];
		att_msg.yawd = states[5];
		att_msg.rolldd = states[6];
		att_msg.pitchdd = states[7];
		att_msg.yawdd = states[8];
		att_pub.publish(att_msg);

		//Ensures the timing of the loop
		KF_attitude_rate.sleep();
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
	gsl_matrix_free (TEMP_9x9);
	gsl_matrix_free (TEMP2_9x9);
	gsl_matrix_free (TEMP_6x6);
	gsl_matrix_free (TEMP_9x6);
	gsl_matrix_free (TEMP_6x6);
	gsl_matrix_free (I_9x9);
	return 0;
}
