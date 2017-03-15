%% Design of the robust controller - suboptimal Hinf
close all
clear
clc

run Parameters

% State Space Model - states=[yaw yaw_dot xb_dot]'
A=[0 1 0;
    0 -dyaw/Iz 0;
    0 0 -dx/mx];
B=[0 0;
    l1/Iz -l2/Iz;
    1/mx 1/mx];
C=[1 0 0;
    0 0 1];
D=[0 0;
    0 0];
n=size(A,1);
nu=size(B,2);
ny=size(C,1);
sys=ss(A,B,C,D);
s=tf('s');
sys_tf=(s*eye(n)-A);
sys_tf=sys_tf\B;
sys_tf=C*sys_tf;

% Weights for the uncertainties and disturbance rejection
wp=1/(s+1);
wu=s/(s+0.1);
Wp1=eye(ny)*wp;
Wp2=eye(ny);
Wu1=eye(ny)*wu;
Wu2=eye(ny);
P=augw(sys,Wu1,Wp1,[]);

%[gamopt,Ak,Bk,Ck,Dk,Acl,Bcl,Ccl,Dcl] = hinfopt(A,B1,B2,C1,C2,D11,D12,D21,D22);
[K,CL,GAM,INFO] = mixsyn(sys,Wu1,Wp1,[]);%hinfsyn(P,'GMAX',10);
[K2,CL2,GAM2,INFO2] = hinfsyn(P,'GMAX',10);