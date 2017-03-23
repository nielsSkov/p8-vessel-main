// // Jeppe forsoeger at imp kalmanFilter
#include "ros/ros.h"
#include "aauship_control/KalmanFilter.h"

#include <cstdlib>
#include <cmath>
#include <iostream>
#include <fstream>
#include <aauship_control/ekf.h>
#include <aauship_control/ukf.h>
#include <sys/time.h>

using namespace ekf;
//#define SIGMA 10.0
//#define RHO 28.0
//#define BETA 8.0/3.0
//#define DT 0.01
//#define X0 0.1
//#define Y0 1.2
//#define Z0 0.4
#define N0    0.0
#define E0    0.0
#define X0    0
#define Y0    0
#define PHI   0
#define THETA 0
#define PSI   0.0
#define U     0
#define V     0
#define P     0
#define Q     0
#define R     0
#define DOTU  0
#define DOTV  0
#define DOTP  0
#define DOTQ  0
#define DOTR  0
#define DT    0.05
#define NOISE_AMPLITUDE 2.0
#define VERBOSE true


// KF update step
void KalmanFilter::KalmanFilterUpdate(void) { // should not have void parameeters
int i=0;

    struct timeval before, after;
    srand(time(NULL));
		//  Above should probably be removed

    
    // Definition of the parameters and state variables
    ekf_param p;
    ekf_state s;
    // The parameters for the evolution equation
    s.params = gsl_vector_alloc(1);
    s.params->data[0] = DT;
    // Initialization of the parameters
    p.n = 17;
    p.no = 7;
    //EvolutionNoise * evolution_noise = new ekf::EvolutionAnneal(1e-2, 0.99, 1e-8);
    EvolutionNoise * evolution_noise = new ekf::EvolutionRLS(1e-2, 0.9995);
    //EvolutionNoise * evolution_noise = new ekf::EvolutionRobbinsMonro(1e-5, 1e-6);
    p.evolution_noise = evolution_noise;
    p.observation_noise = 1e-1;
    p.prior_pk = 1.0;
    p.observation_gradient_is_diagonal = true;
    // Initialization of the state and parameters
    ekf_init(p,s);
 
 
		// Initialize the parameter vector to some random values
    for(int i = 0 ; i < p.n ; i++)
        gsl_vector_set(s.xk,i,5.0*(2.0*rand()/double(RAND_MAX-1)-1.0));
    s.xk->data[0] = -15.0;
    s.xk->data[1] = -15.0;
    s.xk->data[2] = -15.0;
    // Allocate the input/output vectors
    gsl_vector * xi = gsl_vector_alloc(p.n);
    gsl_vector * yi = gsl_vector_alloc(p.no);
    gsl_vector_set_zero(yi);
    /***********************************************/
    /***** Iterate the learning on the samples *****/
    /***********************************************/
    int epoch = 0;
    xi->data[0]  = N0   ;
    xi->data[1]  = E0   ;
    xi->data[2]  = X0   ;
    xi->data[3]  = Y0   ;
    xi->data[4]  = PHI  ;
    xi->data[5]  = THETA;
    xi->data[6]  = PSI  ;
    xi->data[7]  = U    ;
    xi->data[8]  = V    ;
    xi->data[9]  = P    ;
    xi->data[10] = Q    ;
    xi->data[11] = R    ;
    xi->data[12] = DOTU ;
    xi->data[13] = DOTV ;
    xi->data[14] = DOTP ;
    xi->data[15] = DOTQ ;
    xi->data[16] = DOTR ;
    std::ofstream outfile("example-009.data");
    std::ofstream outfile_rms("example-009-rms.data");
    double rms= 0.0;
    double errorBound = NOISE_AMPLITUDE/2.0;
    int count_time=0;
    int nb_steps_below_error=1000;
    //int is_counting=0;
    gettimeofday(&before, NULL);
    outfile << epoch << " ";
    for(int i = 0 ; i < 17 ; ++i)
        outfile << xi->data[i] << " " ;
    for(int i = 0 ; i < 7 ; ++i)
        outfile << yi->data[i] << " " ;
    for(int i = 0 ; i < 17 ; ++i)
        outfile << s.xk->data[i] << " " ;
    outfile << std::endl;
    while( epoch < 8000)
    {
    //printf("Epoch %i \n", epoch);
    // Evaluate the true dynamical system
    f(s.params, xi, xi);
    h(s.params, xi, yi);
    // Provide the observation and iterate
//    ekf_iterate(p,s,f,df,h,dh,yi);
    epoch++;
    rms = 0.0;
    for(int i = 0 ; i < p.n ; ++i)
        rms += gsl_pow_2(xi->data[i] - s.xk->data[i]);
        rms /= double(p.n);
        rms = sqrt(rms);
        if(rms <= errorBound)
        {
            count_time++;
            if(count_time >= nb_steps_below_error)
            break;
        }
        else
        {
            count_time = 0;
        }
        printf("[%i] True state : %e %e %e %e %e %e %e %e %e %e %e %e %e %e %e %e %e, estimated : %e %e %e %e %e %e %e %e %e %e %e %e %e %e %e %e %e\n", epoch,
            xi->data[0] ,
            xi->data[1] ,
            xi->data[2] ,
            xi->data[3] ,
            xi->data[4] ,
            xi->data[5] ,
            xi->data[6] ,
            xi->data[7] ,
            xi->data[8] ,
            xi->data[9] ,
            xi->data[10],
            xi->data[11],
            xi->data[12],
            xi->data[13],
            xi->data[14],
            xi->data[15],
            xi->data[16],
            s.xk->data[0] ,
            s.xk->data[1] ,
            s.xk->data[2] ,
            s.xk->data[3] ,
            s.xk->data[4] ,
            s.xk->data[5] ,
            s.xk->data[6] ,
            s.xk->data[7] ,
            s.xk->data[8] ,
            s.xk->data[9] ,
            s.xk->data[10],
            s.xk->data[11],
            s.xk->data[12],
            s.xk->data[13],
            s.xk->data[14],
            s.xk->data[15],
            s.xk->data[16]);
        outfile << epoch << " ";
        for(int i = 0 ; i < 17 ; ++i)
            outfile << xi->data[i] << " " ;
        for(int i = 0 ; i < 7 ; ++i)
            outfile << yi->data[i] << " " ;
        for(int i = 0 ; i < 17 ; ++i)
            outfile << s.xk->data[i] << " " ;
        outfile << std::endl;
        outfile_rms << rms << std::endl;
    }
    gettimeofday(&after, NULL);
    double sbefore = before.tv_sec + before.tv_usec * 1E-6;
    double safter = after.tv_sec + after.tv_usec * 1E-6;
    double total = safter - sbefore;
    outfile.close();
    outfile_rms.close();
    std::cout << " Run on " << epoch << " epochs ;" << std::scientific << total / double(epoch) << " s./step " << std::endl;
    printf("I found the following parameters : %e %e %e ; The true parameters being : %e %e %e \n", s.xk->data[0], s.xk->data[1], s.xk->data[6], N0, E0, PSI);
    std::cout << " Outputs are saved in example-009*.data " << std::endl;
    std::cout << " You can plot them using e.g. gnuplot : " << std::endl;
    //std::cout << " gnuplot Data/plot-example-009.gplot ; gv Output/example-009-rms.ps ; gv Output/example-009-Lorentz.ps " << std::endl;
    /***********************************************/
    /**** Free the memory ****/
    /***********************************************/
    ekf_free(p,s);

}

/* example-009.cc
*
* Copyright (C) 2011-2014 Jeremy Fix
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 3 of the License, or (at
* your option) any later version.
*
* This program is distributed in the hope that it will be useful, but
* WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
*/
/* In this example, we use EKF for state/parameter estimation in order to estimate the state and parameters of a Lorentz attractor */

/*************************************************************************************/
/* Definition of the evolution and observation functions */
/*************************************************************************************/
// Evolution function
void KalmanFilter::f(gsl_vector * params, gsl_vector * xk_1, gsl_vector * xk)
{
    double n = gsl_vector_get(xk_1,0);
    double e = gsl_vector_get(xk_1,1);
    double x = gsl_vector_get(xk_1,2);
    double y = gsl_vector_get(xk_1,3);
    double phi = gsl_vector_get(xk_1,4);
    double theta = gsl_vector_get(xk_1,5);
    double psi = gsl_vector_get(xk_1,6);
    double u = gsl_vector_get(xk_1,7);
    double v = gsl_vector_get(xk_1,8);
    double roll = gsl_vector_get(xk_1,9);
    double pitch = gsl_vector_get(xk_1,10);
    double yaw = gsl_vector_get(xk_1,11);
    double dotu = gsl_vector_get(xk_1,12);
    double dotv = gsl_vector_get(xk_1,13);
    double dotroll = gsl_vector_get(xk_1,14);
    double dotpitch = gsl_vector_get(xk_1,15);
    double dotyaw = gsl_vector_get(xk_1,16);
    double dt = gsl_vector_get(params, 0);
    gsl_vector_set(xk, 0, n);
    gsl_vector_set(xk, 1, e);
    gsl_vector_set(xk, 2, x);
    gsl_vector_set(xk, 3, y);
    gsl_vector_set(xk, 4, phi);
    gsl_vector_set(xk, 5, theta);
    gsl_vector_set(xk, 6, psi);
    gsl_vector_set(xk, 7, u);
    gsl_vector_set(xk, 8, v);
    gsl_vector_set(xk, 9, roll);
    gsl_vector_set(xk, 10, pitch);
    gsl_vector_set(xk, 11, yaw);
    gsl_vector_set(xk, 12, dotu);
    gsl_vector_set(xk, 13, dotv);
    gsl_vector_set(xk, 14, dotroll);
    gsl_vector_set(xk, 15, dotpitch);
    gsl_vector_set(xk, 16, dotyaw);
}

// Jacobian of the evolution function
void KalmanFilter::df(gsl_vector * params, gsl_vector * xk_1, gsl_matrix * Fxk)
{
    double n = gsl_vector_get(xk_1,0);
    double e = gsl_vector_get(xk_1,1);
    double x = gsl_vector_get(xk_1,2);
    double y = gsl_vector_get(xk_1,3);
    double phi = gsl_vector_get(xk_1,4);
    double theta = gsl_vector_get(xk_1,5);
    double psi = gsl_vector_get(xk_1,6);
    double u = gsl_vector_get(xk_1,7);
    double v = gsl_vector_get(xk_1,8);
    double roll = gsl_vector_get(xk_1,9);
    double pitch = gsl_vector_get(xk_1,10);
    double yaw = gsl_vector_get(xk_1,11);
    double dotu = gsl_vector_get(xk_1,12);
    double dotv = gsl_vector_get(xk_1,13);
    double dotroll = gsl_vector_get(xk_1,14);
    double dotpitch = gsl_vector_get(xk_1,15);
    double dotyaw = gsl_vector_get(xk_1,16);
    double dt = gsl_vector_get(params, 0);
    // Derivatives for N(t+1)
    gsl_matrix_set(Fxk, 0, 0, 1.0);
    gsl_matrix_set(Fxk, 0, 1, 0.0);
    gsl_matrix_set(Fxk, 0, 2, 0.0);
    gsl_matrix_set(Fxk, 0, 3, 0.0);
    gsl_matrix_set(Fxk, 0, 4, 0.0);
    gsl_matrix_set(Fxk, 0, 5, 0.0);
    gsl_matrix_set(Fxk, 0, 6, 0.0);
    gsl_matrix_set(Fxk, 0, 7, 0.0);
    gsl_matrix_set(Fxk, 0, 8, 0.0);
    gsl_matrix_set(Fxk, 0, 9, 0.0);
    gsl_matrix_set(Fxk, 0, 10, 0.0);
    gsl_matrix_set(Fxk, 0, 11, 0.0);
    gsl_matrix_set(Fxk, 0, 12, 0.0);
    gsl_matrix_set(Fxk, 0, 13, 0.0);
    gsl_matrix_set(Fxk, 0, 14, 0.0);
    gsl_matrix_set(Fxk, 0, 15, 0.0);
    gsl_matrix_set(Fxk, 0, 16, 0.0);
    // Derivatives for E(t+1)
    gsl_matrix_set(Fxk, 1, 0, 0.0);
    gsl_matrix_set(Fxk, 1, 1, 1.0);
    gsl_matrix_set(Fxk, 1, 2, 0.0);
    gsl_matrix_set(Fxk, 1, 3, 0.0);
    gsl_matrix_set(Fxk, 1, 4, 0.0);
    gsl_matrix_set(Fxk, 1, 5, 0.0);
    gsl_matrix_set(Fxk, 1, 6, 0.0);
    gsl_matrix_set(Fxk, 1, 7, 0.0);
    gsl_matrix_set(Fxk, 1, 8, 0.0);
    gsl_matrix_set(Fxk, 1, 9, 0.0);
    gsl_matrix_set(Fxk, 1, 10, 0.0);
    gsl_matrix_set(Fxk, 1, 11, 0.0);
    gsl_matrix_set(Fxk, 1, 12, 0.0);
    gsl_matrix_set(Fxk, 1, 13, 0.0);
    gsl_matrix_set(Fxk, 1, 14, 0.0);
    gsl_matrix_set(Fxk, 1, 15, 0.0);
    gsl_matrix_set(Fxk, 1, 16, 0.0);
    // Derivatives for x(t+1)
    gsl_matrix_set(Fxk, 2, 0, 0.0);
    gsl_matrix_set(Fxk, 2, 1, 0.0);
    gsl_matrix_set(Fxk, 2, 2, 1.0);
    gsl_matrix_set(Fxk, 2, 3, 0.0);
    gsl_matrix_set(Fxk, 2, 4, 0.0);
    gsl_matrix_set(Fxk, 2, 5, 0.0);
    gsl_matrix_set(Fxk, 2, 6, 0.0);
    gsl_matrix_set(Fxk, 2, 7, 0.0);
    gsl_matrix_set(Fxk, 2, 8, 0.0);
    gsl_matrix_set(Fxk, 2, 9, 0.0);
    gsl_matrix_set(Fxk, 2, 10, 0.0);
    gsl_matrix_set(Fxk, 2, 11, 0.0);
    gsl_matrix_set(Fxk, 2, 12, 0.0);
    gsl_matrix_set(Fxk, 2, 13, 0.0);
    gsl_matrix_set(Fxk, 2, 14, 0.0);
    gsl_matrix_set(Fxk, 2, 15, 0.0);
    gsl_matrix_set(Fxk, 2, 16, 0.0);
    // Derivatives for y(t+1)
    gsl_matrix_set(Fxk, 3, 0, 0.0);
    gsl_matrix_set(Fxk, 3, 1, 0.0);
    gsl_matrix_set(Fxk, 3, 2, 0.0);
    gsl_matrix_set(Fxk, 3, 3, 1.0);
    gsl_matrix_set(Fxk, 3, 4, 0.0);
    gsl_matrix_set(Fxk, 3, 5, 0.0);
    gsl_matrix_set(Fxk, 3, 6, 0.0);
    gsl_matrix_set(Fxk, 3, 7, 0.0);
    gsl_matrix_set(Fxk, 3, 8, 0.0);
    gsl_matrix_set(Fxk, 3, 9, 0.0);
    gsl_matrix_set(Fxk, 3, 10, 0.0);
    gsl_matrix_set(Fxk, 3, 11, 0.0);
    gsl_matrix_set(Fxk, 3, 12, 0.0);
    gsl_matrix_set(Fxk, 3, 13, 0.0);
    gsl_matrix_set(Fxk, 3, 14, 0.0);
    gsl_matrix_set(Fxk, 3, 15, 0.0);
    gsl_matrix_set(Fxk, 3, 16, 0.0);
    // Derivatives for phi(t+1)
    gsl_matrix_set(Fxk, 4, 0, 0.0);
    gsl_matrix_set(Fxk, 4, 1, 0.0);
    gsl_matrix_set(Fxk, 4, 2, -0.000047368775740);
    gsl_matrix_set(Fxk, 4, 3, 0.004282051934167);
    gsl_matrix_set(Fxk, 4, 4, 0.845057894901144);
    gsl_matrix_set(Fxk, 4, 5, -0.001585132859674);
    gsl_matrix_set(Fxk, 4, 6, -0.006037628365521);
    gsl_matrix_set(Fxk, 4, 7, -0.001634208621250);
    gsl_matrix_set(Fxk, 4, 8, 0.158428534679433);
    gsl_matrix_set(Fxk, 4, 9, -5.869213055434965);
    gsl_matrix_set(Fxk, 4, 10, -0.054820991730417);
    gsl_matrix_set(Fxk, 4, 11, -0.230859896547226);
    gsl_matrix_set(Fxk, 4, 12, 0.0);
    gsl_matrix_set(Fxk, 4, 13, 0.0);
    gsl_matrix_set(Fxk, 4, 14, 0.0);
    gsl_matrix_set(Fxk, 4, 15, 0.0);
    gsl_matrix_set(Fxk, 4, 16, 0.0);
    // Derivatives for theta(t+1)
    gsl_matrix_set(Fxk, 5, 0, 0.0);
    gsl_matrix_set(Fxk, 5, 1, 0.0);
    gsl_matrix_set(Fxk, 5, 2, -0.004009144592212);
    gsl_matrix_set(Fxk, 5, 3, 0.000822953153928);
    gsl_matrix_set(Fxk, 5, 4, -0.029965504425292);
    gsl_matrix_set(Fxk, 5, 5, 0.865852803887239);
    gsl_matrix_set(Fxk, 5, 6, -0.001299812197086);
    gsl_matrix_set(Fxk, 5, 7, -0.147577962531828);
    gsl_matrix_set(Fxk, 5, 8, 0.027659274325152);
    gsl_matrix_set(Fxk, 5, 9, -1.036331359780794);
    gsl_matrix_set(Fxk, 5, 10, -4.948665811403822);
    gsl_matrix_set(Fxk, 5, 11, -0.045698363336979);
    gsl_matrix_set(Fxk, 5, 12, 0.0);
    gsl_matrix_set(Fxk, 5, 13, 0.0);
    gsl_matrix_set(Fxk, 5, 14, 0.0);
    gsl_matrix_set(Fxk, 5, 15, 0.0);
    gsl_matrix_set(Fxk, 5, 16, 0.0);
    // Derivatives for psi(t+1)
    gsl_matrix_set(Fxk, 6, 0, 0.0);
    gsl_matrix_set(Fxk, 6, 1, 0.0);
    gsl_matrix_set(Fxk, 6, 2, 0.0);
    gsl_matrix_set(Fxk, 6, 3, 0.0);
    gsl_matrix_set(Fxk, 6, 4, 0.0);
    gsl_matrix_set(Fxk, 6, 5, 0.0);
    gsl_matrix_set(Fxk, 6, 6, 1.0);
    gsl_matrix_set(Fxk, 6, 7, 0.0);
    gsl_matrix_set(Fxk, 6, 8, 0.0);
    gsl_matrix_set(Fxk, 6, 9, 0.0);
    gsl_matrix_set(Fxk, 6, 10, 0.0);
    gsl_matrix_set(Fxk, 6, 11, 0.0);
    gsl_matrix_set(Fxk, 6, 12, 0.0);
    gsl_matrix_set(Fxk, 6, 13, 0.0);
    gsl_matrix_set(Fxk, 6, 14, 0.0);
    gsl_matrix_set(Fxk, 6, 15, 0.0);
    gsl_matrix_set(Fxk, 6, 16, 0.0);
    // Derivatives for u(t+1)
    gsl_matrix_set(Fxk, 7, 0, dt*cos(psi));
    gsl_matrix_set(Fxk, 7, 1, dt*sin(psi));
    gsl_matrix_set(Fxk, 7, 2,  0.049723406204869);
    gsl_matrix_set(Fxk, 7, 3,  0.000000533491234);
    gsl_matrix_set(Fxk, 7, 4, -0.000019426501116);
    gsl_matrix_set(Fxk, 7, 5, -0.000086975759482);
    gsl_matrix_set(Fxk, 7, 6, -0.000000842685134);
    gsl_matrix_set(Fxk, 7, 7,  0.988964802425052);
    gsl_matrix_set(Fxk, 7, 8,  0.000017884125782);
    gsl_matrix_set(Fxk, 7, 9, -0.000670202021289);
    gsl_matrix_set(Fxk, 7, 10, -0.003201606995903);
    gsl_matrix_set(Fxk, 7, 11, -0.000029556488868);
    gsl_matrix_set(Fxk, 7, 12,  0.988964802425052);
    gsl_matrix_set(Fxk, 7, 13,  0.000017884125782);
    gsl_matrix_set(Fxk, 7, 14, -0.000670202021289);
    gsl_matrix_set(Fxk, 7, 15, -0.003201606995903);
    gsl_matrix_set(Fxk, 7, 16, -0.000029556488868);
    // Derivatives for v(t+1)
    gsl_matrix_set(Fxk, 8, 0, dt*(-sin(psi)));
    gsl_matrix_set(Fxk, 8, 1, dt*cos(psi));
    gsl_matrix_set(Fxk, 8, 2,  0.000012127867596);
    gsl_matrix_set(Fxk, 8, 3,  0.045837548347937);
    gsl_matrix_set(Fxk, 8, 4,  0.039922222094321);
    gsl_matrix_set(Fxk, 8, 5,  0.000405862255594);
    gsl_matrix_set(Fxk, 8, 6, -0.000569417909974);
    gsl_matrix_set(Fxk, 8, 7,  0.000406627565023);
    gsl_matrix_set(Fxk, 8, 8,  0.840360099012158);
    gsl_matrix_set(Fxk, 8, 9,  1.477258087981388);
    gsl_matrix_set(Fxk, 8, 10,  0.013643189863155);
    gsl_matrix_set(Fxk, 8, 11, -0.024926387639480);
    gsl_matrix_set(Fxk, 8, 12,  0.000406627565023);
    gsl_matrix_set(Fxk, 8, 13,  0.840360099012158);
    gsl_matrix_set(Fxk, 8, 14,  1.477258087981388);
    gsl_matrix_set(Fxk, 8, 15,  0.013643189863155);
    gsl_matrix_set(Fxk, 8, 16, -0.024926387639480);
    // Derivatives for p(t+1)
    gsl_matrix_set(Fxk, 9, 0,                0.0);
    gsl_matrix_set(Fxk, 9, 1,                0.0);
    gsl_matrix_set(Fxk, 9, 2, -0.000001585666563);
    gsl_matrix_set(Fxk, 9, 3,  0.000141647982862);
    gsl_matrix_set(Fxk, 9, 4,  0.044921818677197);
    gsl_matrix_set(Fxk, 9, 5, -0.000053032470022);
    gsl_matrix_set(Fxk, 9, 6, -0.000196473915310);
    gsl_matrix_set(Fxk, 9, 7, -0.000073027846587);
    gsl_matrix_set(Fxk, 9, 8,  0.006788922250085);
    gsl_matrix_set(Fxk, 9, 9,  0.752899321745734);
    gsl_matrix_set(Fxk, 9, 10, -0.002445889774367);
    gsl_matrix_set(Fxk, 9, 11, -0.009625312696845);
    gsl_matrix_set(Fxk, 9, 12, -0.000073027846587);
    gsl_matrix_set(Fxk, 9, 13,  0.006788922250085);
    gsl_matrix_set(Fxk, 9, 14,  0.752899321745734);
    gsl_matrix_set(Fxk, 9, 15, -0.002445889774367);
    gsl_matrix_set(Fxk, 9, 16, -0.009625312696845);
    // Derivatives for q(t+1)
    gsl_matrix_set(Fxk, 10, 0,                0.0);
    gsl_matrix_set(Fxk, 10, 1,                0.0);
    gsl_matrix_set(Fxk, 10, 2, -0.000288466147122);
    gsl_matrix_set(Fxk, 10, 3,  0.000059754445484);
    gsl_matrix_set(Fxk, 10, 4, -0.002169255036631);
    gsl_matrix_set(Fxk, 10, 5,  0.040350145693658);
    gsl_matrix_set(Fxk, 10, 6, -0.000093936003883);
    gsl_matrix_set(Fxk, 10, 7, -0.012072492561263);
    gsl_matrix_set(Fxk, 10, 8,  0.002334197445616);
    gsl_matrix_set(Fxk, 10, 9, -0.086588459653789);
    gsl_matrix_set(Fxk, 10, 10,  0.595468162879000);
    gsl_matrix_set(Fxk, 10, 11, -0.003796674187051);
    gsl_matrix_set(Fxk, 10, 12, -0.012072492561263);
    gsl_matrix_set(Fxk, 10, 13,  0.002334197445616);
    gsl_matrix_set(Fxk, 10, 14, -0.086588459653789);
    gsl_matrix_set(Fxk, 10, 15,  0.595468162879000);
    gsl_matrix_set(Fxk, 10, 16, -0.003796674187051);
    // Derivatives for r(t+1)
    gsl_matrix_set(Fxk, 11, 0,                0.0);
    gsl_matrix_set(Fxk, 11, 1,                0.0);
    gsl_matrix_set(Fxk, 11, 2, -0.000000147096000);
    gsl_matrix_set(Fxk, 11, 3, -0.000004613815804);
    gsl_matrix_set(Fxk, 11, 4, -0.000454980362467);
    gsl_matrix_set(Fxk, 11, 5, -0.000004922258035);
    gsl_matrix_set(Fxk, 11, 6,  0.049680806806460);
    gsl_matrix_set(Fxk, 11, 7, -0.000005145503670);
    gsl_matrix_set(Fxk, 11, 8, -0.000202061143866);
    gsl_matrix_set(Fxk, 11, 9, -0.017394200825761);
    gsl_matrix_set(Fxk, 11, 10, -0.000172595493010);
    gsl_matrix_set(Fxk, 11, 11,  0.987291639691711);
    gsl_matrix_set(Fxk, 11, 12, -0.000005145503670);
    gsl_matrix_set(Fxk, 11, 13, -0.000202061143866);
    gsl_matrix_set(Fxk, 11, 14, -0.017394200825761);
    gsl_matrix_set(Fxk, 11, 15, -0.000172595493010);
    gsl_matrix_set(Fxk, 11, 16,  0.987291639691711);
    // Derivatives for dotu(t+1)
    gsl_matrix_set(Fxk, 12, 0, 0.0);
    gsl_matrix_set(Fxk, 12, 1, 0.0);
    gsl_matrix_set(Fxk, 12, 2, 0.0);
    gsl_matrix_set(Fxk, 12, 3, 0.0);
    gsl_matrix_set(Fxk, 12, 4, 0.0);
    gsl_matrix_set(Fxk, 12, 5, 0.0);
    gsl_matrix_set(Fxk, 12, 6, 0.0);
    gsl_matrix_set(Fxk, 12, 7, 0.0);
    gsl_matrix_set(Fxk, 12, 8, 0.0);
    gsl_matrix_set(Fxk, 12, 9, 0.0);
    gsl_matrix_set(Fxk, 12, 10, 0.0);
    gsl_matrix_set(Fxk, 12, 11, 0.0);
    gsl_matrix_set(Fxk, 12, 12, 1.0);
    gsl_matrix_set(Fxk, 12, 13, 0.0);
    gsl_matrix_set(Fxk, 12, 14, 0.0);
    gsl_matrix_set(Fxk, 12, 15, 0.0);
    gsl_matrix_set(Fxk, 12, 16, 0.0);
    // Derivatives for dotv(t+1)
    gsl_matrix_set(Fxk, 13, 0, 0.0);
    gsl_matrix_set(Fxk, 13, 1, 0.0);
    gsl_matrix_set(Fxk, 13, 2, 0.0);
    gsl_matrix_set(Fxk, 13, 3, 0.0);
    gsl_matrix_set(Fxk, 13, 4, 0.0);
    gsl_matrix_set(Fxk, 13, 5, 0.0);
    gsl_matrix_set(Fxk, 13, 6, 0.0);
    gsl_matrix_set(Fxk, 13, 7, 0.0);
    gsl_matrix_set(Fxk, 13, 8, 0.0);
    gsl_matrix_set(Fxk, 13, 9, 0.0);
    gsl_matrix_set(Fxk, 13, 10, 0.0);
    gsl_matrix_set(Fxk, 13, 11, 0.0);
    gsl_matrix_set(Fxk, 13, 12, 0.0);
    gsl_matrix_set(Fxk, 13, 13, 1.0);
    gsl_matrix_set(Fxk, 13, 14, 0.0);
    gsl_matrix_set(Fxk, 13, 15, 0.0);
    gsl_matrix_set(Fxk, 13, 16, 0.0);
    // Derivatives for dotp(t+1)
    gsl_matrix_set(Fxk, 14, 0, 0.0);
    gsl_matrix_set(Fxk, 14, 1, 0.0);
    gsl_matrix_set(Fxk, 14, 2, 0.0);
    gsl_matrix_set(Fxk, 14, 3, 0.0);
    gsl_matrix_set(Fxk, 14, 4, 0.0);
    gsl_matrix_set(Fxk, 14, 5, 0.0);
    gsl_matrix_set(Fxk, 14, 6, 0.0);
    gsl_matrix_set(Fxk, 14, 7, 0.0);
    gsl_matrix_set(Fxk, 14, 8, 0.0);
    gsl_matrix_set(Fxk, 14, 9, 0.0);
    gsl_matrix_set(Fxk, 14, 10, 0.0);
    gsl_matrix_set(Fxk, 14, 11, 0.0);
    gsl_matrix_set(Fxk, 14, 12, 0.0);
    gsl_matrix_set(Fxk, 14, 13, 0.0);
    gsl_matrix_set(Fxk, 14, 14, 1.0);
    gsl_matrix_set(Fxk, 14, 15, 0.0);
    gsl_matrix_set(Fxk, 14, 16, 0.0);;
    // Derivatives for dotq(t+1)
    gsl_matrix_set(Fxk, 15, 0, 0.0);
    gsl_matrix_set(Fxk, 15, 1, 0.0);
    gsl_matrix_set(Fxk, 15, 2, 0.0);
    gsl_matrix_set(Fxk, 15, 3, 0.0);
    gsl_matrix_set(Fxk, 15, 4, 0.0);
    gsl_matrix_set(Fxk, 15, 5, 0.0);
    gsl_matrix_set(Fxk, 15, 6, 0.0);
    gsl_matrix_set(Fxk, 15, 7, 0.0);
    gsl_matrix_set(Fxk, 15, 8, 0.0);
    gsl_matrix_set(Fxk, 15, 9, 0.0);
    gsl_matrix_set(Fxk, 15, 10, 0.0);
    gsl_matrix_set(Fxk, 15, 11, 0.0);
    gsl_matrix_set(Fxk, 15, 12, 0.0);
    gsl_matrix_set(Fxk, 15, 13, 0.0);
    gsl_matrix_set(Fxk, 15, 14, 0.0);
    gsl_matrix_set(Fxk, 15, 15, 1.0);
    gsl_matrix_set(Fxk, 15, 16, 0.0);
    // Derivatives for dotr(t+1)
    gsl_matrix_set(Fxk, 16, 0, 0.0);
    gsl_matrix_set(Fxk, 16, 1, 0.0);
    gsl_matrix_set(Fxk, 16, 2, 0.0);
    gsl_matrix_set(Fxk, 16, 3, 0.0);
    gsl_matrix_set(Fxk, 16, 4, 0.0);
    gsl_matrix_set(Fxk, 16, 5, 0.0);
    gsl_matrix_set(Fxk, 16, 6, 0.0);
    gsl_matrix_set(Fxk, 16, 7, 0.0);
    gsl_matrix_set(Fxk, 16, 8, 0.0);
    gsl_matrix_set(Fxk, 16, 9, 0.0);
    gsl_matrix_set(Fxk, 16, 10, 0.0);
    gsl_matrix_set(Fxk, 16, 11, 0.0);
    gsl_matrix_set(Fxk, 16, 12, 0.0);
    gsl_matrix_set(Fxk, 16, 13, 0.0);
    gsl_matrix_set(Fxk, 16, 14, 0.0);
    gsl_matrix_set(Fxk, 16, 15, 0.0);
    gsl_matrix_set(Fxk, 16, 16, 1.0);
}

// Observation function
void KalmanFilter::h(gsl_vector * params, gsl_vector * xk , gsl_vector * yk)
{
    for(unsigned int i = 0 ; i < yk->size ; ++i)
    gsl_vector_set(yk, i, gsl_vector_get(xk,i) + NOISE_AMPLITUDE*rand()/ double(RAND_MAX));
}

// Jacobian of the observation function
void KalmanFilter::dh(gsl_vector * params, gsl_vector * xk , gsl_matrix * Hyk)
{
    gsl_matrix_set_zero(Hyk);
    gsl_matrix_set(Hyk, 0, 0, 1.0);
    gsl_matrix_set(Hyk, 1, 1, 1.0);
    gsl_matrix_set(Hyk, 2, 6, 1.0);
    gsl_matrix_set(Hyk, 3, 7, 1.0);
    gsl_matrix_set(Hyk, 4, 8, 1.0);
    gsl_matrix_set(Hyk, 5, 12, 1.0);
    gsl_matrix_set(Hyk, 6, 13, 1.0);
}

