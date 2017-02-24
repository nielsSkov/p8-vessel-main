clear all;

load('ssaauship.mat');

% Test wether x = aauship(x,[0 0 0 0 0]) is the same as x = R*Ad*x
psi = 1;

Rz = [cos(psi) -sin(psi);
      sin(psi)  cos(psi)];
%   Rz = [-sin(psi) -cos(psi);
%       cos(psi)  -sin(psi)];


R = diag(ones(10,1));
R(1:2,1:2) = Rz(:,:);

x = ones(10,1);
x(5) = psi;

x1 = R*Ad*x;
xb= x1(1);yb = x1(2);
x1(1) = cos(psi)*xb-sin(psi)*yb;
x1(2) = sin(psi)*xb+cos(psi)*yb;
x1
x2 = aauship(x,[0 0 0 0 0]','nonlinear')
x1-x2