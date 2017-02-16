function [ xs, eta, nu, nudot] = aaushipsimmodel( x, in, intyp, pn, wp )
%#codegen
%AAUSHIP Control Model of AAUSHIHP
%   This is a simple model of AAUSHIP, supposed to be a simulation model
%   
%   Since AAUSHIP is a twin propeller ship and has no rudder angle the
%   interface for this is different than the other ship models used in
%   the MSS toolbox.
% 
%   State vector: x = [x y phi theta psi u v p q r]'
%   Position vector: eta = [N E phi theta psi]'
%   Velocity vector: nu = [u v p q r]'
%   Force input vector: tau = [X Y K M N]'

% Check of input and state dimensions
if (length(x)  ~= 17),error('x-vector must have dimension 17!');end

% TODO Add control allocation matrix and saturation with printable warnings
% Thrust allocation 
% lx1 = 0.41; lx2 = 0.18; lx3 = 0.48; lx4 = 0.48; ly3 = 0.05; ly4 = 0.05;
% lz3 = 0.05; lz4 = 0.05;
% a = atan(ly3/lx3);
% az = atan(lz3/lz3);
% T = [ 0 0 1 1;...
%       1 1 -sin(a) sin(a);...
%       -1 -1 0 0;...
%       0 0 sin(az)*lz3 sin(az*lz4);...
%       lx1 -lx2 -sin(a)*lx3 sin(a)*lx4];
% K = eye(4,4);
% K(3,3) = 0.2657/2;
% K(4,4) = 0.2657/2;
% uf = [0 0 15 15]'; % Thruster force vector [N]
% ta = T*K*(uf+[0 0 24.8350/2 24.8350/2]');
T =[    0.9946    0.9946
         0         0
    0.0052   -0.0052
    0.0995    0.0995
   -0.0497    0.0497];
K = eye(2,2);
K(1,1) = 0.26565;
K(2,2) = 0.26565;

% Linear simulation step
ss = load('ssaauship.mat');

if strcmp(intyp, 'input') == 1 
%     if (length(in) ~= 2),error('tau-vector must have dimension 2!');end
    tau = (T*K*in); % control input actuator
elseif strcmp(intyp, 'tau') == 1
    if (length(in) ~= 5),error('tau-vector must have dimension 5!');end
    tau = in; % body frame force
else
    disp('youareretard')
end



eta   = zeros(5,1);
nu    = zeros(5,1);
nudot = zeros(5,1);
xs    = zeros(17,1);


% % xn = ss.Ad*x(3:12) + ss.Bd*tau;
% % 
% % % Calculate positions with euler integration
% % xn(5)      = xn(10)*ss.ts + x(7);  % Yaw
% % % xn(5)      = xn(10)*ss.ts + xn(5);  % Yaw
% % Rz         = [cos(xn(5)) -sin(xn(5)); sin(xn(5)) cos(xn(5))];
% % % R          = diag(ones(5,1));
% % % R(1:2,1:2) = Rz(1:2,1:2);
% % eta(1:2)   = x(1:2) + Rz*xn(6:7)*ss.ts; % Positions in N and E
% % % xn(1:5)    = eta(1:5);
% % 
% % % Compute fossen vectors
% % eta(3:5)   = xn(8:10)*ss.ts+x(5:7);     % Positions in pitch, roll and yaw
% % nu         = xn(6:10);                  % Velocities
% % nudot      = diff([x(8:12) xn(6:10)]'); % Accelerations
% % % nudot     = ss.Ad(6:7,:)*x + ss.Bd(6:7,:)*tau - x(6:7); % Algebraic way of calculating accelerations in one step
% % 
% % % Full state simulation vector
% % xs(1:2) = eta(1:2); % N, E
% % xs(3:4) = xn(1:2);  % x, y
% % xs(5:7) = eta(3:5); % phi, theta, psi
% % xs(8:12) = nu;      % u, v, p, q, r
% % xs(13:17) = nudot;  % u_dot, v_dot, p_dot, q_dot, r_dot
% % if strcmp(pn,'wip')
% %     xs = xs + wp.*randn(17,1);
% % %     disp('foo')
% % else
% % %     disp('kat')
% % end



x = x(3:12);
xold = x;

x = ss.Ad*xold+ ss.Bd*tau;
% Rotation matrix for linear and angular transformation
J = eulerang(x(3), x(4), x(5));
J = [J(1:2,1:2),J(1:2,4:6); J(4:6,1:2),J(4:6,4:6)];  % remove dimension

x(1:5) = xold(1:5) + J*x(6:10)*ss.ts;

xs(1:2)  = x(1:2);  % N,E aka x,y
xs(3:7)  = x(1:5);  % x,y,phi,theta,psi
xs(8:12) = x(6:10); % u,v,p,q,r
