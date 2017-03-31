close all
clear
clc

% Parameters
m=13;     % [kg] mass
mx=m;
my=m;
Ix=0.06541;     % [kgm2]
Iy=1.08921;     % [kgm2]
Iz=1.10675;     % [kgm2]

dx=2.86;    % [] 
dy=32.5;	% []
dz=0;    % []
droll=0.1094;  % []
dpitch=7.203; % []
dyaw=0.26285;    % []

l1=0.05;   % [m]
l2=0.05;   % [m]

Troll=6.9736;   % [N/m]
Tpitch=131.8316;   % [N/m]

Ts=0.05;
% Path controller parameters
r=5;
AcceptRadius=3;
wps=[0 0;
    0 20;
    0 40;
    0 60;
    0 80;
    0 100;
    5 105;
    10 110;
    15 105;
    20 100;
    20 80;
    20 60;
    20 40;
    20 20;
    20 0;
    25 -5;
    30 -10;
    35 -5;
    40 0;
    40 20;
    40 40;
    40 60;
    40 80;
    40 100;
    45 105;
    50 110;
    55 105;
    60 100;];
% global index
% index=1;
