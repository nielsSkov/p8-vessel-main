%% Design of Robust Model
close all
clear
clc

run Parameters

m=m-2.6;
Iz=Iz-0.22;
%%
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

refYaw = 1;      % [rad]
refXdot = 1;        % [m/s]

nx = size(A,2);
nu = size(B,2);
ny = size(C,1);
nz = ny + nu;
nd = nu;    % number of input disturbance states
nw = ny;    % number of output noise states


%% Integral Action
% Extended ss model with integral states

Ai = [A zeros(nx,ny);
    -C -0.001*eye(ny,ny)];
Bi = [B; 
    zeros(ny,nu)];
Ci = [C zeros(ny,ny)];
Di = D;
%% Hinfinity Model with disturbances

A1=[Ai zeros(nx+ny,nd);
    zeros(nd,nx+ny) -50*eye(nd,nd)];

Bdist=[0 0;
    1/Iz 0;
    0 1/m];

B1 = [Bdist zeros(nx,nw) zeros(nx,ny);
    zeros(ny,nd) zeros(ny,nw) eye(ny,ny)
    50*eye(nd,nd) zeros(ny,nw) zeros(nd,ny)];

B2 = [Bi;
    zeros(nd,nd)];

C1 = [diag([1,0.5,0.5,1,1,1,1]);   %Weighting on the states
    zeros(nu,nx+ny+nd)];

D11 = [zeros(nx,nd) zeros(nx, nw) zeros(nx, ny);
    zeros(ny, nd) zeros(ny, nw) zeros(ny, ny);
    zeros(nd, nd) zeros(nd, nw) zeros(nd, ny);
    zeros(nu, nd) zeros(nu, nw) zeros(nu, ny)];

D12 = [zeros(nx+ny+nd,nu);  %Weighting on the inputs
     0.001*eye(nu,nu)];

C2 = [Ci zeros(ny,nd);
    zeros(ny,nx) eye(ny) zeros(ny,nd)];

D21 = [zeros(ny,nd) eye(ny, nw) zeros(ny,ny);
    zeros(ny,nd) zeros(ny, nw) zeros(ny,ny)];

D22 = zeros(2*ny,nu);

N = [A1 B1 B2;
    C1 D11 D12;
    C2 D21 D22];

Ah = A1;

Bh = [B1 B2];

Ch = [C1;
    C2];

Dh = [D11 D12;
    D21 D22];

sysN = ss(Ah,Bh,Ch,Dh);
[k,g,gfin, info] = hinfsyn(sysN,2*ny,nu,'GMIN',1,'GMAX',5,'DISPLAY','on','TOLGAM',0.01);
%info.GAMFI

F = -info.KFI(1:2,1:3)
FI= -info.KFI(1:2,4:5)
Fd=-info.KFI(1:2,6:7);

%% Hinfinity Model

Bdist=[0 0;
    1/Iz 0;
    0 1/m];

B1 = [0.1*Bdist zeros(nx,nw) zeros(nx,ny);
    zeros(ny,nd) zeros(ny,nw) eye(ny,ny)];

B2 = Bi;

C1 = [diag([1,0.5,0.5,1,1]);   %Weighting on the states
    zeros(nu,nx+ny)];

D11 = [zeros(nx,nd) zeros(nx, nw) zeros(nx, ny);
    zeros(ny, nd) zeros(ny, nw) zeros(ny, ny);
    zeros(nu, nd) zeros(nu, nw) zeros(nu, ny)];

D12 = [zeros(nx+ny,nu);  %Weighting on the inputs
     0.001*eye(nu,nu)];

C2 = [Ci;
    zeros(ny,nx) eye(ny)];

D21 = [zeros(ny,nd) 10*eye(ny, nw) zeros(ny,ny);
    zeros(ny,nd) zeros(ny, nw) zeros(ny,ny)];

D22 = zeros(2*ny,nu);

N = [Ai B1 B2;
    C1 D11 D12;
    C2 D21 D22];

Ah = Ai;

Bh = [B1 B2];

Ch = [C1;
    C2];

Dh = [D11 D12;
    D21 D22];

sysN = ss(Ah,Bh,Ch,Dh);
[k,g,gfin, info] = hinfsyn(sysN,2*ny,nu,'GMIN',1,'GMAX',1.2);
info.KFI

F = info.KFI(1:2,1:3)
FI= info.KFI(1:2,4:5)

%% Hinfinity Model extended with the disturbance

A1=[Ai zeros(nx+ny,nd);
    zeros(nd,nx+ny+nd)];
Bdist=[0 0;
    1/Iz 0;
    0 1/m];

B1 = [0.1*Bdist zeros(nx,nw) zeros(nx,ny);
    zeros(ny,nd) zeros(ny,nw) eye(ny,ny);
    eye(nd,nd) zeros(nd,nw) zeros(nd,ny)];
B2 = [Bi
      zeros(nd,nu)];

C1 = [diag([1,0.5,0.5,1,1,1,1]);   %Weighting on the states
    zeros(nu,nx+ny+nd)];

D11 = [zeros(nx,nd) zeros(nx, nw) zeros(nx, ny);
    zeros(ny, nd) zeros(ny, nw) zeros(ny, ny);
    zeros(nd, nd) zeros(nd, nw) zeros(nd, ny);
    zeros(nu, nd) zeros(nu, nw) zeros(nu, ny)];

D12 = [zeros(nx+ny+nd,nu);  %Weighting on the inputs
     0.001*eye(nu,nu)];

C2 = [Ci zeros(ny,nd);
    zeros(ny,nx) eye(ny) zeros(ny,nd)];

D21 = [zeros(ny,nd) ones(ny, nw) zeros(ny,ny);
    zeros(ny,nd) zeros(ny, nw) zeros(ny,ny)];

D22 = zeros(2*ny,nu);

N = [A1 B1 B2;
    C1 D11 D12;
    C2 D21 D22];

Ah = A1;

Bh = [B1 B2];

Ch = [C1;
    C2];

Dh = [D11 D12;
    D21 D22];

sysN = ss(Ah,Bh,Ch,Dh);
[k,g,gfin, info] = hinfsyn(sysN,2*ny,nu,'GMAX',2,'GMIN',2)
info.KFI

F = info.KFI(1:2,1:3)
FI= info.KFI(1:2,4:5)


%% Hinf 2

%A1 = A;

%B1 = [Bdist zeros(nx,nw) zeros(nx,ny)];

%B2 = B;

%C1 = [Ci;
%    zeros(nu,nx)];

% D11 = [zeros(ny,nd) zeros(ny,nw) eye(ny,ny);
%     zeros(nu,nd) zeros(nu,nw) zeros(nu,ny)];
% 
% D12 = [zeros(ny,nu);
%     eye(nu,nu)];

%C2 = C;

%D21 = [zeros(ny,nd) eye(ny, nw) zeros(ny,ny)];

%D22 = zeros(ny,nu);

% N = [Ai B1 B2;
%     C1 D11 D12;
%     C2 D21 D22];
% 
% Ah = Ai;
% 
% Bh = [B1 B2];
% 
% Ch = [C1;
%     C2];
% 
% Dh = [D11 D12;
%     D21 D22];
% 
% sysN = ss(Ah,Bh,Ch,Dh);
% [k,g,gfin, info] = hinfsyn(sysN,ny,nu);
% info.KFI


%%

% [numG1, denG1] = ss2tf(A,B,C,D,1);
% %[z,p] = tf2zp(numG1,denG1);
% [numG2, denG2] = ss2tf(A,B,C,D,2);
% %[z,p] = tf2zp(numG2,denG2);
% 
% 
% G11 = tf(numG1(1,:), denG1);
% G12 = tf(numG2(1,:), denG2);
% G21 = tf(numG1(2,:), denG1);
% G22 = tf(numG2(2,:), denG2);
% 
% G = [G11 G12;
%     G21 G22];


%[k,g,gfin, info] = hinfsyn(G,ny,nu);
