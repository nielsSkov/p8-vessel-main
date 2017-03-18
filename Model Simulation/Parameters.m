close all
clear
clc

% Parameters
m=13;     % [kg] mass
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

% Path controller parameters
r=5;
AcceptRadius=3;
wps=[1 1;
    -100 20;
    -100 200;
    0 200;
    100 200;
    20 20;
    100 20;
    100 -150];
% global index
% index=1;
