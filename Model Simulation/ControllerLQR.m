%% Design of LQR controller
close all
clear
clc

run Parameters

% State Space Model - states=[yaw yaw_dot xb_dot]'
A=[0 1 0;
    0 -dyaw/Iz 0;
    0 0 -dx/m];
B=[0 0;
    l1/Iz -l2/Iz;
    1/m 1/m];
C=[1 0 0;
    0 0 1];
D=[0 0;
    0 0];

% Sampling time
Ts = 0.05;

% Sizes of ss model
n=size(A,1);    % Number of states
nu=size(B,2);   % Number of inputs
ny=size(C,1);   % Number of outputs

% ss form
sys=ss(A,B,C,D);

% Discretize with ZOH
d_sys = c2d(sys, Ts, 'zoh');

Ad = d_sys.A;
Bd = d_sys.B;
Cd = d_sys.C;
Dd = d_sys.D;

% Creates controllability matrix
Co = ctrb(Ad,Bd);
% If rnk = 3, then full rank for delayed system
rnk = rank(Co);

%% Integral Action
% Extended ss model with integral states

Ai = [Ad zeros(n,ny);
    -Cd eye(ny,ny)];
Bi = [Bd; 
    zeros(ny,nu)];
Ci = [Cd zeros(ny,ny)];
Di = Dd;

%% LQR weights

% For Q Matrix
maxYaw = 1000;          %[rad]
maxYawDot = 10;          %[rad/s]
maxXDot = 1000;             %[m/s]
Q = diag([maxYaw maxYawDot maxXDot 0.01 0.01]);
Q = 1./(Q.^2);
Q(Q==Inf)=0;

% For R Matrix
maxF1 = 60;             %[N]
maxF2 = maxF1;          %[N]

R = diag([maxF1 maxF2]);
R = 1./(R.^2);
R(R==Inf)=0;

% LQR Controller

Fe = dlqr(Ai,Bi,Q,R);

eig(Ai-Bi*Fe);

Acl = Ai-Bi*Fe;
Bcl = [zeros(n,ny);
    eye(ny,ny)];        % Input matrix for ref signals
Ccl = Ci;
Dcl = Di;

sys_cl = ss(Acl,Bcl,Ccl,Dcl, Ts);

% step(d_sys);
% figure;
% step(sys_cl);

% Split Fe into state feedback gain and integral state gain 
F = Fe(1:2,1:3);
Fi = Fe(1:2,4:5);


refYaw = 1;      % [rad]
refXdot = 1;        % [m/s]

%% Plot Outputs of Simulation


% plot(xn_3DOF.Data,yn_3DOF.Data)
% axis equal
