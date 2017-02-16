% Thrust allocation 
clear all;

% Dette er til at kontrollere alle thrusters
% Husk at yaw er relativt lille, men dette er ok

% Arm
r(1:3,1) = [0.41;0.00;0.05];
r(1:3,2) = [-0.18;0.00;0.05];
r(1:3,3) = [-0.48;0.05;0.05];
r(1:3,4) = [-0.48;-0.05;0.05];

alpha = atan(r(3,:)./r(1,:));

F1 = [0;1;0];
F2 = [0;1;0];
F3 = [cos(alpha(3));0;-sin(alpha(3))];
F4 = [cos(alpha(4));0;-sin(alpha(4))];

F1r = cross(r(:,1),F1);
F2r = cross(r(:,2),F2);
F3r = cross(r(:,3),F3);
F4r = cross(r(:,4),F4);

% F1t = F1(3)*r(2,3)
% F2t = 1;
% F3t = 1;
% F4t = 1;

% T = [F1,F2,F3,F4] % Torque
% T = [0,0,cos(alpha(3)),cos(alpha(4));1,1,0,0;T]

T = [F1,F2,F3,F4];
T = T(1:2,:);
T = [T;F1r,F2r,F3r,F4r]
% 
% T = [ 0 0 1 1;...
%       1 1 -sin(a) sin(a);...
%       -1 -1 0 0;...
%       0 0 sin(az)*lz3 sin(az*lz4);...
%       lx1 -lx2 -sin(a)*lx3 sin(a)*lx4];

K = eye(4,4);

% K(3,3) = 0.2657/2;
% K(4,4) = 0.2657/2;
u = [0 0 2 10]'; % Thruster force vector [N]
tau = T*K*u;
fprintf('X (surge)\t%f\n', tau(1))
fprintf('Y (sway)\t%f\n', tau(2))
fprintf('K (roll)\t%f\n', tau(3))
fprintf('M (pitch)\t%f\n', tau(4))
fprintf('N (yaw)\t\t%f\n', tau(5))

%tau= [tau(1);tau(2);tau(3);tau(4);tau(5)];

u_check = inv(K)*pinv(T)*tau



%% 
% Dette er til at kontrollere de to main thrusters for sig selv
% Husk at yaw er relativt lille, men dette er ok

T = [F3,F4];
T = T(1:2,:);
T = [T;F3r,F4r];

K = eye(2,2);
K(1,1) = 0.26565;
K(2,2) = 0.26565;

u = u(3:4);

tau = T*K*u

u_check = inv(K)*pinv(T)*tau


