#include "ros/ros.h"
#include <std_msgs/Float32.h>

#include "aauship_control/LLIinput.h"
s
#include "aauship_control/Ref.h"
#include "aauship_control/AttitudeStates.h"
#include "aauship_control/PositionStates.h"

#include <sstream>
#include <stdint.h>
#include <string>

#define _USE_MATH_DEFINES
#include <math.h>

//Controller rate (hz)
#define CONTROLLER_RATE 20.0
#define PRINT_DELTA_TIME false
#define CONTROLLER_OUTPUT true        //For debugging

#define DIVIS 1

/////Robust//////
//State Feedback values
// #define f11  2231.7//5105.3//1872.4//
// #define f12  1510.5//277.3//1511.5//
// #define f13  1000.8//259.5//1001.2//
// #define f21  -2231.7//-5105.3//-1872.4//
// #define f22  -1510.5//-277.3//-1511.5//
// #define f23  1000.8//259.5//1001.2//
// //Integral Feedback values
// #define fi11 -1151.0//-1583.3//-821.4415//
// #define fi12 -422.3//-130.3//-411.5664//
// #define fi21 1151.0//1583.3//821.4415//
// #define fi22 -422.3//-130.3//-411.5664//

/////LQR//////
//State Feedback values 
#define f11  124.3988//186.9423/DIVIS
#define f12  113.7050//118.1940/DIVIS
#define f13  88.7435//92.0377/DIVIS
#define f21  -124.3988//-186.9423/DIVIS
#define f22  -113.7050//-118.1940/DIVIS
#define f23  88.7435//92.0377/DIVIS
//Integral Feedback values
#define fi11 -20.6709//-101.9488/DIVIS
#define fi12 -17.7744//-87.1600/DIVIS
#define fi21 20.6709//101.9488/DIVIS
#define fi22 -17.7744//-87.1600/DIVIS


//Define Dimensions
#define Fn 2
#define Fm 3

//Define values for first order curve
// to fit Force vs PWM
#define MPOS 6.6044//3.8955//0.26565
#define NPOS 70.0168//88.9365//24.835
#define MNEG 8.5706//8.6806//0.26565
#define NNEG 91.9358//63.52//24.835

//Filter coefficient for exponential smoothing filter
#define ALPHA 0.01f


//Reference
float r[Fn] = {0,0};
//States
float x[Fm] = {0,0,0};
//Output
float y[Fn] = {0,0};
//Moving Average
float xb_sum = 0.0f;
float xb_old[30];
int sat = 0;
float yaw_old = 0;
int piCount = 0;


//Exponential Smoothing Filter
float yb_old = 0.0f;

// Callback functions
void KF_callback(const aauship_control::KFStates::ConstPtr& KFStates)
{
  // x[0] = (KFStates->psi) - M_PI; // We receive it from the 
  // x[1] = KFStates->r;

  //////////Exponential Smoothing Filter///////
  y[1] = ALPHA * KFStates->u + (1-ALPHA) * yb_old;
  yb_old = y[1];

  //y[1] = KFStates->u;

  x[2] = y[1];

}

void att_callback(const aauship_control::AttitudeStates::ConstPtr& att_msg)
{
     x[0] = att_msg->yaw;
     x[1] = att_msg->yawd;
     y[0] = x[0];

     //Corrects jumps between -PI and PI
     if ((y[0] - yaw_old) > M_PI)
        piCount++;
     else if ((y[0] - yaw_old) < -M_PI)
        piCount--;
     yaw_old = y[0]; 
     y[0] = y[0] - 2*M_PI*piCount;
     x[0] = y[0];
}

void pos_callback(const aauship_control::PositionStates::ConstPtr& pos_msg)
{
  // Current
  // x[2] = pos_msg->xbd;
  // y[1] = x[2];
  ////////Moving Average Filter////////
  // for(int i = 29; i > 0; i--)
  // {
  //   xb_old[i] = xb_old[i-1];
  // }
  // xb_old[0] = pos_msg->xbd;
  // for(int i = 0; i < 30; i++)
  // {
  //   xb_sum = xb_sum + xb_old[i];
  // }
  // x[2] = xb_sum/30.0f;
  //y[1] = x[2];
  //
}

void ref_callback(const aauship_control::Ref::ConstPtr& Ref)
{
  r[0] = Ref->yaw;
  r[1] = Ref->speed;
}

//Other functions
void multiply_state_fb(float F[Fn][Fm], float x[Fm], float *u_state)
{
  for(int i = 0; i < Fn; i++)
  {
    u_state[i] = 0;
    for(int j = 0; j < Fm; j++)
    {
      u_state[i] = F[i][j] * x[j] + u_state[i];
    }
  }
  //std::cout<<"u_state[0]: "<<u_state[0]<<"\n u_state[1]: "<<u_state[1]<<std::endl;
}

void integrator(float F_int[Fn][Fn],float y[Fn], float r[Fn],float* x_int,float *u_integral)
{
  // Forward eulers method: x(k+1) = x(k)+Ts*(r(k)-y(k))
  // Adapted from Matlab Discrete Integrator Help Page
  //Notice x_int(k+1) is x_int(k) when used, then overwritten to x_int(k+1)
  float e = 0;

  for(int i=0;i<Fn;i++)
  {
    e = r[i]-y[i];
    std::cout<<"reference "<<i<<": "<<r[i]<<std::endl;
    
    //Chooses shortest path
    // if (i == 0)       
    // {
    //   if (e < -M_PI)
    //   {
    //     e += 2 * M_PI;
    //   }
    //   else if (e > M_PI)
    //   {
    //     e -= 2 * M_PI;
    //   }
    // }

    std::cout<<"error "<<i<<": "<<e<<std::endl;

    // Anti wind up
    // if (sat)
    // {
    // 	e = 0;
    // }

    x_int[i] = (1/CONTROLLER_RATE)*e + x_int[i];
  }

  for(int i=0;i<Fn;i++)
  {
    u_integral[i] = 0;
    for(int j=0;j<Fn;j++)
    {
      u_integral[i] = F_int[i][j] * x_int[j] + u_integral[i];
    }
    // std::cout<<"Fint["<<i<<"]: "<<u_integral[i]<<std::endl;
  }
}

int16_t force2PWM(float u)
{
	int pwm = 0;
	if (u >= 0)
	{
	  	pwm = MPOS * u + NPOS;
	}
	else
	{
	  	pwm = MNEG * u - NNEG;
	}
	return pwm;
}

int main(int argc, char **argv)
{
  ros::init(argc,argv,"lqr_node");
  ros::NodeHandle n;
  ros::Subscriber kf_update = n.subscribe("/kf_statesnew",1000,KF_callback);
  ros::Subscriber att_update = n.subscribe("/kf_attitude",1000,att_callback);
  ros::Subscriber pos_update = n.subscribe("/kf_position",1000,pos_callback);
  ros::Subscriber ref_update = n.subscribe("/control_reference",1000,ref_callback);
  ros::Publisher lli_pub = n.advertise<aauship_control::LLIinput>("/lli_input", 1);
  ros::Rate lqr_rate(CONTROLLER_RATE);
  std::cout<<std::endl<<"######LQR CONTROLLER RUNNING######"<<std::endl;
  //Used for measuring loop time
  aauship_control::LLIinput lli_msg;
  double current_time = ros::Time::now().toSec();
  double start_time =current_time;
  //****TEST VALUE*******
  // float x_TEST [Fm]={1,1,1};

  /////////State Feedback Variables\\\\\\\\\\
  
  float F[Fn][Fm] = {
    {f11,f12,f13},
    {f21,f22,f23}
  };
  // float u_state[Fn]={0,0};
  //////////Integrator Feedback Variables\\\\\\\\\\\

  float x_int[Fn]={0,0};
  // float u_integral[Fn]={0,0};
  float F_int[Fn][Fn] = {
    {fi11,fi12},
    {fi21,fi22}
  };

  // init MA
  // for(int i = 0; i < 30; i++)
  // {
  //   xb_old[i] = 0.0f;
  // }

  ////////Extended Feedback Variables\\\\\\\\\\\\

  // float u[Fn] = {0,0};

  int count = 0;
  while(ros::ok())
  {	
    // if(count < 400)
    // {
    //   count ++;
    // }
    // else
    // {
    //   count = 1000;
    //   r[0] = 1;
    // }

    // inputs
    ros::spinOnce();//gets the newest values
    float u_state[Fn]={0,0};
    float u_integral[Fn]={0,0};
    float u[Fn] = {0,0};

    current_time = ros::Time::now().toSec();
    multiply_state_fb(F,x,u_state);
    integrator(F_int,y,r,x_int,u_integral);
    //std::cout<<"time "<<current_time-start_time<<std::endl;
    std::cout<<"xbdot: "<<x[2]<<"ref: "<<r[1]<<std::endl;
    std::cout<<"u_state[0]: "<<u_state[0]<<"\n u_state[1]: "<<u_state[1]<<std::endl;
    std::cout<<"u_integral[0]: "<<u_integral[0]<<"\n u_integral[1]: "<<u_integral[1]<<std::endl;
    for (int i = 0; i < Fn; i++)
    {
      u[i] = -(u_state[i] + u_integral[i]);
      // if (u[i]<-10)
      // {
      //   sat = 1;
      //   u[i] = -10;
      // }
      // else if (u[i]>10)
      // {
      //   sat = 1;
      //   u[i] = 10;
      // }
      std::cout<<"F["<<i<<"] in PWM: "<<force2PWM(u[i])<<std::endl;
    }
    if(CONTROLLER_OUTPUT)
    {
      lli_msg.DevID = 10;
      lli_msg.MsgID = 5;
      lli_msg.Data = force2PWM(u[0]);
      lli_msg.Time = current_time;
      lli_pub.publish(lli_msg);

      lli_msg.DevID = 10;
      lli_msg.MsgID = 3;
      lli_msg.Data = force2PWM(u[1]);
      lli_msg.Time = current_time;
      lli_pub.publish(lli_msg);
    }
    else
    {
      //std::cout<<"Right Motor: "<<u[0]<<", PWM: "<<force2PWM(u[0])<<
      //"\n Left Motor: "<<u[1]<<", PWM: "<<force2PWM(u[1])<<std::endl;
    }

    lqr_rate.sleep();//Ensures the timing of the loop
  }
  return 0;
}
