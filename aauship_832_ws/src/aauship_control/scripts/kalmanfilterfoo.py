#!/usr/bin/env python2
# Kalman filter example demo in Python

import roslib; roslib.load_manifest('aauship_control')

import rospy
from std_msgs.msg import String
from aauship_control.msg import *
from math import sin, cos

import numpy
import pylab
import scipy.io as sio
import scipy.linalg as linalg


class KF(object):
    def __init__(self):
        # Load discretised model constants
        self.ssmat = sio.loadmat('ssaauship.mat')
        
        # Measurement noise vector and covarince matrix
        #self.v = numpy.array([3.0, 3.0, 13.5969e-006, 0.2, 0.2, 0.00033, 0.00033])
        #self.R = numpy.diag(self.v)

        # Process noise vector and covariance matrix
        self.w = numpy.array([0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.01, 0.01, 0.01, 0.01, 0.01, 0.033, 0.033, 0.033, 0.033, 0.033])
        self.Q = numpy.diag(self.w)
        self.no_of_states = 17

    def aaushipsimmodel(self, x, u):
        # Linear simulation step
        xn = self.ssmat['Ad'].dot(x[2:12]) + self.ssmat['Bd'].dot(u)

        eta   = numpy.zeros(5)
        nu    = numpy.zeros(5)
        nudot = numpy.zeros(5)
        xs    = numpy.zeros(self.no_of_states)

        # Calculate positions with euler integration
        xn[4] = xn[9]*self.ssmat['ts'] + x[6]
        Rz    = numpy.matrix([[cos(xn[4]), -sin(xn[4])], [sin(xn[4]), cos(xn[4])]])
        eta[0:2] = x[0:2] + Rz.dot(xn[5:7])*float(self.ssmat['ts'])

        # Compute Fossen vectors
        eta[2:5] = xn[7:10]*self.ssmat['ts'] + x[4:7]
        nu       = xn[5:10]
        nudot    = xn[5:10]-x[7:12]

        # Full state simulaiton vector
        xs[0:2] = eta[0:2]
        xs[2:4] = xn[0:2]
        xs[4:7] = eta[2:5]
        xs[7:12] = nu
        xs[12:17] = nudot

        return xs


    # Seems like the KalmanF does not return the same as the matlab implementation at the moment!!!
    def KalmanF(self, x, u, z, P_plus, R):
        # System matrix
        PHI = numpy.zeros([17,17])
        PHI[0:2,0:2] = numpy.matrix([[1,0],[0,1]])
        PHI[2:12,2:12] = self.ssmat['Ad']
        PHI[12:17,12:17] = numpy.diag([1,1,1,1,1])
        PHI[12:17,7:12] = self.ssmat['Ad'][5:10,5:10]

        # Measurement matrix
        h = numpy.zeros([7,17])
        h[0:2,0:2] = numpy.diag([1,1])
        h[2:5,6:9] = numpy.diag([1,1,1])
        h[5:7,12:14] = numpy.diag([1,1])
        H = h;

        # The nonlinear contribution to the system
        PHI[0:2,7:9] = numpy.matrix([ [float(self.ssmat['ts'])*cos(x[6]),-float(self.ssmat['ts'])*sin(x[6])], 
                       [float(self.ssmat['ts'])*sin(x[6]), float(self.ssmat['ts'])*cos(x[6])] ])
        # PHI(1:2,8:9) = [ts*cos(x(7)) -ts*sin(x(7)); ts*sin(x(7)) ts*cos(x(7))]; 
        # print(PHI[0:2,7:9]) # seems to be ok now

        #Q = numpy.diag(numpy.ones([17]))
        Q = numpy.diag([0.001,0.001,0.001,0.001,0.001,0.001,0.001,0.01,0.01,0.01,0.01,0.01,0.033,0.033,0.033,0.033,0.033])
        # Prediction
        x_hat_minus = self.aaushipsimmodel(x,u);
        P_minus = PHI*P_plus*PHI + Q;
        
        # Update
        z_bar = z - h.dot(x_hat_minus);
        #print(R)
        S = H.dot(P_minus.dot(H.T)) + R; # test the individual vars and operators in this line
        #print(S) # Something is wrong with S
        # S = H*P_minus*H' + R

        K = P_minus.dot(H.T).dot(linalg.inv(S));
        x_hat_plus = x_hat_minus + K.dot(z_bar);
        P_plus = (numpy.eye(17) - K.dot(H)).dot(P_minus).dot( (numpy.eye(17) - K.dot(H)).T ) + K.dot(R).dot(K.T);
       
        # Return estimated state vector
        return (x_hat_plus,P_plus)
        

    def run(self):
        print('Testing Kalman filter function')
        x = numpy.array([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]) # state vector
        u = numpy.array([8,0,0,0,0]) # input vector
        z = numpy.array([1,1,1,1,1,1,1]) # measurement vector
        #xs = self.aaushipsimmodel(x,u)
        #print(xs)

        self.P_plus = numpy.zeros([17,17])
        R = numpy.diag([3.0, 3.0, 13.5969, 0.1, 0.1, 0.0524, 0.0524])
        (xest,self.P_plus) = self.KalmanF(x, u, z, self.P_plus, R)
        print(xest)
        print('Done testing Kalman filter function')

if __name__ == '__main__':
    w = KF()
    w.run()
