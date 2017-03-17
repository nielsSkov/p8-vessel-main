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
R=10;
AcceptRadius=10;
wps=[1 1;
    10 15;
    10 20;
    15 20;
    30 5;
    30 30];

