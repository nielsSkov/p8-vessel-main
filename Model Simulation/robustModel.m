%% Design of Robust Model
close all
clear
clc

run Parameters


%% Varying Parameters
m=m-2.6;
Iz=Iz-0.22;

% Reference signals for simulink
refYaw = 1;      % [rad]
refXdot = 1;        % [m/s]

%% State Space Model
% states=[yaw yaw_dot xb_dot]'
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

nx = size(A,2);         % number of states
nu = size(B,2);         % number of controlled inputs
ny = size(C,1);         % number of measured outputs

% Cz is C matrix for performance output (Z) equation (Weightings)
% For states
Cz = [1 0 0;
    0 0.5 0;
    0 0 0.5];

% Dz is D matrix for performance output (Z) equation (Weightings)
% For inputs
Dz = [0.001 0;
    0 0.001];

nz = ny + nu;
nw = ny;    % number of output noise states

%% Integral Model

ni = ny;                % number of reference (integral) signals to track

Ai = -0.001*eye(ni);
Bi = eye(ni);

% C matrix for performance output (Z) equation (Weightings)
% For integral states
Ci = [1 0;
    0 1];

%% Disturbance Model

nd = nu;    % number of input disturbance states

Ad = -50*eye(nd);
Bd = 50*eye(nd);

% Matrix describing how disturbance forces affect states
Bdist=[0 0;
    1/Iz 0;
    0 1/m];

% C matrix for performance output (Z) equation (Weightings)
% For input disturbance states
Cd = [1 0;
    0 1];
%% Noise Model

nn = ny;    % number of output measurement noise states

An = -200*eye(nn);
Bn = 00*eye(nn);

% C matrix for performance output (Z) equation (Weightings)
% For output measurement noise states
Cn = [1 0;
    0 1];

%% H infinity Model
% x' = A1x + B1w  + B2u     - state equation
% z  = C1x + D11w + D12u    - performance output equation
% y  = C2x + D21w + D22u    - measured output equation
%
% x = [x xi xd xn]'         - [states int_states dist_states noise_states]'
% w = [r d n]'              - uncontrollable inputs
% u = u                     - controllable inputs
% z = [x xi xd xn u]'       - weightings / performance outputs
% y = [y r]                 - measured ouputs

A1 = [A zeros(nx,ni+nd+nn);             % states
    -C Ai zeros(ni,nd+nn);              % integral states 'xi = -Cx+r'
    zeros(nd,nx+ni) Ad zeros(nd,nn);    % disturbance states
    zeros(nn,nx+ni+nd) An];             % noise states

B1 = [zeros(nx,ni) Bdist zeros(nx,nn);  % effect of uncont inputs on states
    eye(ni,ni) zeros(ni,nd+nn);         % adding ref to int_states
    zeros(nd,ni) Bd zeros(nd,nn);       % see disturbance model
    zeros(nn,ni+nd) Bn];                % see noise model

B2 = [B;
    zeros(ni+nd+nn,nu)];

C1 = [Cz zeros(nx,ni+nd+nn);
    zeros(ni,nx) Ci zeros(ni,nd+nn);
    zeros(nd,nx+ni) Cd zeros(nd,nn);
    zeros(nn,nx+ni+nd) Cn;
    zeros(nu,nx+ni+nd+nn)];

D11 = zeros(nx+ni+nd+nn+nu,ni+nd+nn);

D12 = [zeros(nx+ni+nd+nn,nu);
    Dz];

C2 = [C zeros(ny,ni+nd+nn);
    zeros(ni,nx) eye(ni) zeros(ni,nd+nn)];

D21 = [zeros(ny,ni+nd) eye(nn);
    zeros(ni,ni+nd+nn)];

D22 = zeros(ny+ni,nu);

N = [A1 B1 B2;
    C1 D11 D12;
    C2 D21 D22];

%% H infinity controller design
    
Ah = A1;

Bh = [B1 B2];

Ch = [C1;
    C2];

Dh = [D11 D12;
    D21 D22];

sysN = ss(Ah,Bh,Ch,Dh);
[k,g,gfin, info] = hinfsyn(sysN,2*ny,nu,'GMIN',1,'GMAX',5,'DISPLAY','on','TOLGAM',0.01);
%info.GAMFI

F  = -info.KFI(1:2,1:3);git 
FI = -info.KFI(1:2,4:5);
Fd = -info.KFI(1:2,6:7);

