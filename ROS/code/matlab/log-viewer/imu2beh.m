function [ output_args ] = imu2beh( gyro, accel, mag, len )
%IMU2BEH Prepare data file for calc_beh_main.m
%   Convert imu.log data matrix to a file that calc_beh_main.m accepts

% supply = imudata(:,1)*0.002418; % Scale 2.418 mV
% gyro = imudata(:,2:4)*0.05; % Scale 0.05 degrees/sec
% accl = (imudata(:,5:7)*0.00333)*9.82;   %/333)*9.82; % Scale 3.33 mg (g is gravity, that is g-force)
% magn = imudata(:,8:10)*0.0005; % 0.5 mgauss
% temp = imudata(:,11)*0.14; % 0.14 degrees celcius 
% aux_adc = imudata(:,12)*0.806; % 0.806 mV
% imutime = imudata(:,13)-starttime; % Seconds since start, periodic timing determined by imu

output_args = zeros(len,10);
output_args(:,1) = [1:len]';
output_args(:,2:4) = gyro(1:len,:);
output_args(:,5:7) = accel(1:len,:);
output_args(:,8:10) = mag(1:len,:);
save('testfile.mat', 'output_args');