%% Model for Kalman filter
close all
clear
clc

run Parameters.m
sim('KalmanModelSim.slx')

% Attitude model
A_att=[1 0 0 Ts 0 0 0 0 0;
    0 1 0 0 Ts 0 0 0 0;
    0 0 1 0 0 Ts 0 0 0;
    0 0 0 1 0 0 Ts 0 0;
    0 0 0 0 1 0 0 Ts 0;
    0 0 0 0 0 1 0 0 Ts;
    0 0 0 -droll/Ix 0 0 -Ts*droll/Ix 0 0;
    0 0 0 0 -dpitch/Iy 0 0 -Ts*dpitch/Iy 0;
    0 0 0 0 0 -dyaw/Iz 0 0 -Ts*dyaw/Iz];

B_att=[0 0;
    0 0;
    0 0;
    0 0;
    0 0;
    0 0;
    0 0;
    0 0;
    l1/Iz -l2/Iz];
C_att=[eye(6) zeros(6,3)];

% Position model
a1=1;
a2=0;
a3=0;
a4=1;

A_pos=[1 0 Ts 0 0 0;
    0 1 0 Ts 0 0;
    0 0 1 0 Ts*a1 Ts*a2;
    0 0 0 1 Ts*a3 Ts*a4;
    0 0 -dx/mx*a1 -dx/mx*a3 -Ts*dx/mx 0;
    0 0 -dy/my*a2 -dy/my*a4 0 -Ts*dy/my];

B_pos=[0 0;
    0 0;
    0 0;
    0 0;
    1/mx 1/mx;
    0 0];

C_pos=[1 0 0 0 0 0;
    0 1 0 0 0 0;
    0 0 0 0 1 0;
    0 0 0 0 0 1];

% Total model
A_kal=[A_att zeros(size(A_att,1),size(A_pos,2));
    zeros(size(A_pos,1),size(A_att,2)) A_pos];
B_kal=[B_att;
    B_pos];
C_kal=[C_att zeros(size(C_att,1),size(C_pos,2));
    zeros(size(C_pos,1),size(C_att,2)) C_pos];

% State variances
sigma2_roll=Ts^2;
sigma2_pitch=Ts^2;
sigma2_yaw=Ts^2;
sigma2_rolldot=0.01*Ts;
sigma2_pitchdot=0.01*Ts;
sigma2_yawdot=0.01*Ts;
sigma2_rollddot=0.001;
sigma2_pitchddot=0.001;
sigma2_yawddot=0.001;
sigma2_xn=Ts^2;
sigma2_yn=Ts^2;
sigma2_xndot=0.01*Ts;
sigma2_yndot=0.01*Ts;
sigma2_xnddot=0.001;
sigma2_ynddot=0.001;

% Sensor variance
sigma2_mag_roll=0.1;
sigma2_mag_pitch=0.1;
sigma2_mag_yaw=0.1;
sigma2_gyro_roll=0.1;
sigma2_gyro_pitch=0.1;
sigma2_gyro_yaw=0.1;
sigma2_gps_xn=3;
sigma2_gps_yn=3;
sigma2_acc_xbddot=0.003;
sigma2_acc_ybddot=0.003;

% Covariances matrices
Q=diag([sigma2_roll, sigma2_pitch, sigma2_yaw, sigma2_rolldot, sigma2_pitchdot,...
    sigma2_yawdot, sigma2_rollddot, sigma2_pitchddot, sigma2_yawddot, sigma2_xn,...
    sigma2_yn, sigma2_xndot,sigma2_yndot, sigma2_xnddot, sigma2_ynddot]);
R=diag([sigma2_mag_roll, sigma2_mag_pitch, sigma2_mag_yaw, sigma2_gyro_roll,...
    sigma2_gyro_pitch, sigma2_gyro_yaw, sigma2_gps_xn, sigma2_gps_yn,...
    sigma2_acc_xbddot, sigma2_acc_ybddot]);

% Data
att_data=att.Data';
attdot_data=attdot.Data';
attddot_data=attddot.Data';
roll=att_data(1,:);
pitch=att_data(2,:);
yaw=att_data(3,:);
x_data=x.Data';
xdot_data=xdot.Data';
xddot_data=xddot.Data';

n_samples=size(att_data,2);
n=size(A_kal,1);
nu=size(B_kal,2);
nz=size(C_kal,1);

% biasacc=0*ones(2,n_samples);%[randn(2,1).*sqrt(0.01) zeros(2,n_samples-1)];
% for i=2:1:n_samples
%     biasacc(:,i)=biasacc(:,i-1)+randn(2,1).*sqrt(0.01);
% end
% data_dot_noise=data_dot+randn(n_samples,2).*sqrt(5);
% data_ddot_noise=data_ddot+randn(n_samples,2).*sqrt(0.01)+biasacc';

att_noise=att_data+diag(sqrt([0,0,sigma2_mag_yaw]))*...
    randn(3,n_samples);
attdot_noise=attdot_data+diag(sqrt([sigma2_gyro_roll,sigma2_gyro_pitch,...
    sigma2_gyro_yaw]))*randn(3,n_samples);
x_noise=x_data+diag(sqrt([sigma2_gps_xn,sigma2_gps_yn]))*randn(2,n_samples);
xddot_noise=xddot_data+diag(sqrt([sigma2_acc_xbddot,sigma2_acc_ybddot]))*randn(2,n_samples);

% Not a good way to get roll and pitch
att_noise(1,:)=atan(xddot_noise(1,:)./sqrt(xddot_noise(2,:).^2+9.81.^2));
att_noise(2,:)=atan(xddot_noise(2,:)./sqrt(xddot_noise(1,:).^2+9.81.^2));


meas=[att_noise;
    attdot_noise;
    x_noise;
    xddot_noise];
states=[att_data;
    attdot_data;
    attddot_data;
    x_data;
    xdot_data;
    xddot_data];

u=u.Data';

% Initialization
x00=zeros(n,1);
%x00(7:8,1)=[1;1];
u00=[0;0];
P00=eye(n);
x_kal=zeros(n,n_samples);

% First Prediction
x_kal(:,1)=A_kal*x00+B_kal*u00;%+sqrt(Q)*randn(n,1);
P=A_kal*P00*A_kal'+Q;

% First Update
K=P*C_kal'/(C_kal*P*C_kal'+R);
x_kal(:,1)=x_kal(:,1)+K*(meas(:,1)-C_kal*x_kal(:,1));
P=(eye(n)-K*C_kal)*P;

for k=2:1:n_samples
    % Approximate A_kal using the previous estimation of the angles
    a1=cos(pitch(k-1))*cos(yaw(k-1));
    a2=sin(roll(k-1))*sin(pitch(k-1))*cos(yaw(k-1))-cos(roll(k-1))*sin(yaw(k-1));
    a3=cos(pitch(k-1))*sin(yaw(k-1));
    a4=sin(roll(k-1))*sin(pitch(k-1))*sin(yaw(k-1))+cos(roll(k-1))*cos(yaw(k-1));
    A_pos=[1 0 Ts 0 0 0;
        0 1 0 Ts 0 0;
        0 0 1 0 Ts*a1 Ts*a2;
        0 0 0 1 Ts*a3 Ts*a4;
        0 0 -dx/mx*a1 -dx/mx*a3 -Ts*dx/mx 0;
        0 0 -dy/my*a2 -dy/my*a4 0 -Ts*dy/my];
    A_kal=[A_att zeros(size(A_att,1),size(A_pos,2));
        zeros(size(A_pos,1),size(A_att,2)) A_pos];
    
    % First Prediction
    x_kal(:,k)=A_kal*x_kal(:,k-1)+B_kal*u(:,k-1);%+sqrt(Q)*randn(n,1);
    P=A_kal*P*A_kal'+Q;
    
    % First Update
    K=P*C_kal'/(C_kal*P*C_kal'+R);
    x_kal(:,k)=x_kal(:,k)+K*(meas(:,k)-C_kal*x_kal(:,k));
    P=(eye(n)-K*C_kal)*P;
end

% Plots
% Yaw
figure
hold on
plot(att.Time,meas(1,:))
plot(att.Time,x_kal(1,:))
plot(att.Time,att.Data(:,1))
FigureLatex('$\psi$','Time [s]','Angular Position [rad]',1,{'Measurement', 'Estimation', 'Real'},0,0,12,14,1.2)

% Yaw velocity
figure
hold on
plot(att.Time,meas(6,:))
plot(att.Time,x_kal(6,:))
plot(att.Time,attdot.Data(:,3))
FigureLatex('$\dot{\psi}$','Time [s]','Angular Velocity [rad $^{-1}$]',1,{'Measurement', 'Estimation', 'Real'},0,0,12,14,1.2)

% Yaw acceleration
figure
hold on
plot(att.Time,x_kal(9,:))
plot(att.Time,attddot.Data(:,3))
FigureLatex('$\ddot{\psi}$','Time [s]','Angular Acceleration [rad s$^{-2}$]',1,{'Estimation', 'Real'},0,0,12,14,1.2)

% X position
figure
hold on
plot(x.Time,meas(7,:))
plot(x.Time,x_kal(10,:))
plot(x.Time,x.Data(:,1))
FigureLatex('$x_\mathrm{n}$','Time [s]','Position [m]',1,{'Measurement', 'Estimation', 'Real'},0,0,12,14,1.2)

% X velocity
figure
hold on
plot(x.Time,x_kal(12,:))
plot(x.Time,xdot.Data(:,1))
FigureLatex('$\dot{x_\mathrm{n}}$','Time [s]','Velocity [m s$^{-1}$]',1,{'Estimation', 'Real'},0,0,12,14,1.2)

% X accleration
figure
hold on
plot(att.Time,meas(9,:))
plot(att.Time,x_kal(14,:))
plot(att.Time,xddot.Data(:,1))
FigureLatex('$\ddot{x_\mathrm{b}}$','Time [s]','Acceleration [m s$^{-2}$]',1,{'Measurement', 'Estimation', 'Real'},0,0,12,14,1.2)

