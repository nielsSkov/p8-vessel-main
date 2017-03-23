#include "ros/ros.h"
#include "sensor_msgs/Joy.h"
#include "aauship_control/Faps.h"
#include "aauship_control/LLIinput.h"
#include <std_msgs/Float32.h>
#include "aauship_control/KFStates.h"

#include <sstream>
#include <stdint.h>
#include <string>
//Controller rate (hz)
#define CONTROLLER_RATE 20.0
#define PRINT_DELTA_TIME false
#define CONTROLLER_OUTPUT true        //For debugging


//State Feedback values
#define f11  5.1053//*10e3
#define f12  0.2773//*10e3
#define f13  0.2595//*10e3
#define f21  -5.1053//*10e3
#define f22  -0.2773//*10e3
#define f23  0.2595//*10e3
//Intergral Feedback values
#define fi11 -1.5833//*10e3
#define fi12 -0.1303//*10e3
#define fi21  1.5833//*10e3
#define fi22 -0.1303//*10e3
//Define Dimensions
#define Fn 2
#define Fm 3

//Define values for first order curve
// to fit Force vs PWM
#define m 0.26565
#define c 24.835

float r[Fn] = {0,1};
float x[Fm] = {0,0,0};
float y[Fn] = {0,0};

void KF_callback(const aauship_control::KFStates::ConstPtr& KFStates)
  {

  x[0] = KFStates->psi;
  x[1] = KFStates->r;
  x[2]=KFStates->u;
  std::cout<<"[LQR] X states: "<<x[0]<<" "<<x[1]<<" "<<x[2]<<"\n";
  y[0] = KFStates->psi;
  y[1] = KFStates->u;


  }

void multiply_state_fb(float F[Fn][Fm], float x[Fm], float *u_state)
{
  float u_tmp[Fn];
  //std::cout<<u_state[0]<<std::endl;
  for (int i = 0; i < Fn; i++)
  {
    u_tmp[i] = u_state[i];
  }
  for(int i=0;i<Fn;i++)
  {
    for(int j=0;j<Fm;j++)
    {
      u_state[i] = u_tmp[i]+F[i][j]*x[j];
    }
  }
  //std::cout<<"u_state[0]: "<<u_state[0]<<"\n u_state[1]: "<<u_state[1]<<std::endl;
}

void integrator(float F_int[Fn][Fn],float y[Fn], float r[Fn],float* x_int,float *u_integral)
{
  // Forward eulers method: x(k+1) = x(k)+Ts*(r(k)-y(k))
  // Adapted from Matlab Discrete Integrator Help Page
  //Notice x_int(k+1) is x_int(k) when used, then overwritten to x_int(k+1)
  for(int i=0;i<Fn;i++)
  {
    x_int[i] = (1/CONTROLLER_RATE)*(r[i]-y[i])+x_int[i];
  }
  for(int i=0;i<Fn;i++)
  {
    for(int j=0;j<Fn;j++)
    {
      u_integral[i] = u_integral[i]+F_int[i][j]*x_int[j];
    }
  }

}

int16_t force2PWM(float u)
{
  //std::cout<<"u: "<<u<<std::endl;
  int pwm = ((m*u)-c);
  //std::cout<<"PWM: "<<pwm<<std::endl;
  if (pwm < 100)
  {
    return 0;
  }
  else
  {
    return pwm;
  }
}



int main(int argc, char **argv)
{
  ros::init(argc,argv,"lqr_node");
  ros::NodeHandle n;
  ros::Subscriber kf_update = n.subscribe("/kf_statesnew",1000,KF_callback);
  ros::Publisher lli_pub = n.advertise<aauship_control::LLIinput>("lli_input", 1);
  ros::Rate lqr_rate(CONTROLLER_RATE);
  std::cout<<std::endl<<"######LQR CONTROLLER RUNNING######"<<std::endl;
  //Used for measuring loop time
  aauship_control::LLIinput lli_msg;
  double current_time = ros::Time::now().toSec();
  double old_time= current_time;
  double delta_t,delta_t_mean;
  int counter = 0;
  //****TEST VALUE*******
  float x_TEST [Fm]={1,1,1};



  /////////State Feedback Variables\\\\\\\\\\
  
  float F[Fn][Fm] = {
    {f11,f12,f13},
    {f21,f22,f23}
  };
  float u_state[Fn]={0,0};
  //////////Integrator Feedback Variables\\\\\\\\\\\

  float x_int[Fn]={0,0};
  float u_integral[Fn]={0,0};
  float F_int[Fn][Fn] = {
    {fi11,fi12},
    {fi21,fi22}
  };

  ////////Extended Feedback Variables\\\\\\\\\\\\

  float u[Fn] = {0,0};


  while(ros::ok)
  {	
    old_time = current_time;
    current_time = ros::Time::now().toSec();
    delta_t = current_time - old_time;
    delta_t_mean = delta_t_mean+delta_t;
    counter ++;
    multiply_state_fb(F,x,u_state);
    integrator(F_int,y,r,x_int,u_integral);
    //std::cout<<"u_state[0]: "<<u_state[0]<<"\n u_state[1]: "<<u_state[1]<<std::endl;
    //std::cout<<"u_integral[0]: "<<u_integral[0]<<"\n u_integral[1]: "<<u_integral[1]<<std::endl;
    for (int i = 0; i < Fn; i++)
    {
      u[i] = -(u_state[i] + u_integral[i]);
      if (u[i]<-25)
      {
        u[i] = -25;
      }
      else if (u[i]>40)
      {
        u[i] = 40;
      }
      std::cout<<"u["<<i<<"]: "<<u[i]<<std::endl;
    }
    if(PRINT_DELTA_TIME && counter%100 == 0){
      std::cout<<"Time Delta: "<<delta_t<<"\n";
      std::cout<<"Time Delta Mean: "<<delta_t_mean/counter<<"\n";
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
      std::cout<<"Right Motor: "<<u[0]<<", PWM: "<<force2PWM(u[0])<<
      "\n Left Motor: "<<u[1]<<", PWM: "<<force2PWM(u[1])<<std::endl;
    }

    ros::spinOnce();//gets the newest values
    lqr_rate.sleep();//Ensures the timing of the loop
  }
  return 0;
}





