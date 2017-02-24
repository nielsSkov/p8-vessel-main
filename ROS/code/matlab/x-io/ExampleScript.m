% ExampleScript.m
%
% This script demonstrates use of the MadgwickAHRS and MahonyAHRS algorithm
% classes with example data. ExampleData.mat contains calibrated gyroscope,
% accelerometer and magnetometer data logged from an AHRS device (x-IMU)
% while it was sequentially rotated from 0 degrees, to +90 degree and then
% to -90 degrees around the X, Y and Z axis.  The script first plots the
% example sensor data, then processes the data through the algorithm and
% plots the output as Euler angles.
%
% Note that the Euler angle plot shows erratic behaviour in phi and psi
% when theta approaches �90 degrees. This due to a singularity in the Euler
% angle sequence known as 'Gimbal lock'.  This issue does not exist for a
% quaternion or rotation matrix representation.
%
% Date          Author          Notes
% 28/09/2011    SOH Madgwick    Initial release
% 13/04/2012    SOH Madgwick    deg2rad function no longer used
% 06/11/2012    Seb Madgwick    radian to degrees calculation corrected

%% Start of script

addpath('quaternion_library');      % include quaternion library
close all;                          % close all figures
clear;                              % clear all variables
clc;                                % clear the command terminal

%%
clear all
% node = rosmatlab.node('ahrs_matlab', 'http://aauship:11311');
% node = rosmatlab.node('ahrs_matlab', 'http://t410-arch:11311');
node = rosmatlab.node('ahrs_matlab', 'http://localhost:11311');

% pub = node.addPublisher('test', 'std_msgs/String');
% msg = rosmatlab.message('std_msgs/String', node);
% msg.setData('hello ros');

% pub = node.addPublisher('test', 'tf2_msgs/TFMessage');
% msg = rosmatlab.message('tf2_msgs/TFMessage', node);

% msg.setOrigin([0,0,0]);
% msg.setRotation([1 0 0 0]);

%   static tf::TransformBroadcaster tfbc;
%   tf::Transform transform;
%   transform.setOrigin( tf::Vector3(0,0,0) );
%   tf::Quaternion q(u.getQuaternions(1),u.getQuaternions(2),u.getQuaternions(3),u.getQuaternions(0));
%   tfbc.sendTransform( tf::StampedTransform(transform, ros::Time::now(), "map", "boat"));

% msg.setData('hello ros');

pub = node.addPublisher('test', 'geometry_msgs/Transform');
msg = rosmatlab.message('geometry_msgs/Transform', node);
msgt = rosmatlab.message('geometry_msgs/Vector3', node);
msgt.setX(0);
msgt.setY(0);
msgt.setZ(0);
msgr = rosmatlab.message('geometry_msgs/Quaternion', node);


% msgr.setW(1);
% msgr.setX(1);
% msgr.setY(1);
% msgr.setZ(1);
% 
% msg.setTranslation(msgt)
% msg.setRotation(msgr)
% pause(1);
% pub.publish(msg);

%% Import and plot sensor data

% load('ExampleData.mat');

load('../log-viewer/testfile.mat');
Accelerometer = output_args(:,5:7);
Gyroscope = output_args(:,2:4);
Gyroscope = [Gyroscope(:,1)+4.6 Gyroscope(:,2)+16.15 Gyroscope(:,3)+5.4];
Magnetometer = output_args(:,8:10);
% Magnetometer = [Magnetometer(:,1) Magnetometer(:,2) Magnetometer(:,3)];
time = 0:0.1:length(Accelerometer)/10-0.1;

% N = 100000;
% ab = [1 1 0];
% Accelerometer = randn(N,3)*3.6226e-06; % Standard variance
% Accelerometer = [Accelerometer(:,1)+ab(1) Accelerometer(:,2)+ab(2) Accelerometer(:,3)+ab(3)];
% % mb = [0.1298 -0.0065 -0.0445];%+[-0.0385   -0.0190   -0.0120]; % Magnetometer field
% mb = [1 1 1 ]
% Magnetometer = (randn(N,3)*1.3210e-05); % Standard variance
% Magnetometer = [Magnetometer(:,1)+mb(1) Magnetometer(:,2)+mb(2) Magnetometer(:,3)+mb(3)];
% Gyroscope = randn(N,3)*0.0974; % Allan variance
% time = 0:0.1:length(Accelerometer)/10-0.1;



%%

% figure('Name', 'Sensor Data');
% axis(1) = subplot(3,1,1);
% hold on;
% plot(time, Gyroscope(:,1), 'r');
% plot(time, Gyroscope(:,2), 'g');
% plot(time, Gyroscope(:,3), 'b');
% legend('X', 'Y', 'Z');
% xlabel('Time (s)');
% ylabel('Angular rate (deg/s)');
% title('Gyroscope');
% hold off;
% axis(2) = subplot(3,1,2);
% hold on;
% plot(time, Accelerometer(:,1), 'r');
% plot(time, Accelerometer(:,2), 'g');
% plot(time, Accelerometer(:,3), 'b');
% legend('X', 'Y', 'Z');
% xlabel('Time (s)');
% ylabel('Acceleration (g)');
% title('Accelerometer');
% hold off;
% axis(3) = subplot(3,1,3);
% hold on;
% plot(time, Magnetometer(:,1), 'r');
% plot(time, Magnetometer(:,2), 'g');
% plot(time, Magnetometer(:,3), 'b');
% legend('X', 'Y', 'Z');
% xlabel('Time (s)');
% ylabel('Flux (G)');
% title('Magnetometer');
% hold off;
% linkaxes(axis, 'x');

%% Process sensor data through algorithm

% AHRS = MadgwickAHRS('SamplePeriod', 1/256, 'Beta', 0.1);
% AHRS = MahonyAHRS('SamplePeriod', 1/256, 'Kp', 0.5);

% AHRS = MadgwickAHRS('SamplePeriod', 1/10, 'Beta', 0.1);
AHRS = MahonyAHRS('SamplePeriod', 1/10, 'Kp', 8.8 , 'Ki', 0.5);

quaternion = NaN(length(time), 4);
tic
t = 1;
% for t = 1:length(time)
while t < length(time)

    AHRS.Update(Gyroscope(t,:) * (pi/180), Accelerometer(t,:), Magnetometer(t,:));	% gyroscope units must be radians
    quaternion(t, :) = AHRS.Quaternion;
    
    msgr.setW(quaternion(t,4));
    msgr.setX(quaternion(t,1));
    msgr.setY(quaternion(t,2));
    msgr.setZ(quaternion(t,3));

    msg.setTranslation(msgt)
    msg.setRotation(msgr)
    pub.publish(msg);
    t = t +1;
    if (t==(length(time)-1))
        disp('Again again again! :D')
        t=1;
    end
    pause(0.02)
end
toc

%% Plot algorithm output as Euler angles
% The first and third Euler angles in the sequence (phi and psi) become
% unreliable when the middle angles of the sequence (theta) approaches �90
% degrees. This problem commonly referred to as Gimbal Lock.
% See: http://en.wikipedia.org/wiki/Gimbal_lock

euler = quatern2euler(quaternConj(quaternion)) * (180/pi);	% use conjugate for sensor frame relative to Earth and convert to degrees.

figure('Name', 'Euler Angles');
hold on;
plot(time, euler(:,1), '.-r');
plot(time, euler(:,2), '.-g');
plot(time, -euler(:,3), '.-b');
title('Euler angles');
xlabel('Time (s)');
ylabel('Angle (deg)');
legend('phi', 'theta', 'psi');
hold off;

%% End of script