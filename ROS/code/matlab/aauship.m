function [ xn ] = aauship( x, tau, type )
%AAUSHIP Control Model of AAUSHIHP
%   This is a simple model of AAUSHIP, it does not have the fidelity to be
%   called a simulation model, so it is more like a Control Design Model.
%   
%   Since AAUSHIP is a twin propeller ship and has no rudder angle the
%   interface for this is different than the other vessel models used in
%   the MSS toolbox.
%
%   See Property 3.1, chap 7.5+
%   
%   State vector: x = [x y phi theta psi u v p q r]'  % default
%   State vector: xn = [x_n y_n phi theta psi u v p q r]'  % nonlinear
%   State vector: xn = [x_n y_n phi theta psi u v p q r U chi a_x a_y a_z
%   m_x m_y m_z g_x g_y g_z]'
%   Force vector: tau = [X Y K M N]'

% Check of input and state dimensions
if (length(x)  ~= 10),error('x-vector must have dimension 10!');end
if (length(tau) ~= 5),error('tau-vector must have dimension 5!');end

ss = load('ssaauship.mat');

xdot = ss.Ad*x + ss.Bd*tau;
xn = xdot;

if strcmp(type, 'nonlinear');
    xn(5) = xn(10)*ss.ts + x(5);
    psi=xn(5);
    Rz = [cos(psi) -sin(psi);
          sin(psi)  cos(psi)];
    xn(1:2) = Rz*xn(6:7)*ss.ts + x(1:2);
end
end
