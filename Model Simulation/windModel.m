%% Wind Model

% In Aalborg avg wind speeds of 11 knots = 6 m/s
% Design for max wind of 6 m/s

Vmax = 6;
Vmin = 0;

psi = 0;

beta = 2.3;

gamma = beta - psi;     % angle of attack of wind

rho_a = 1.225;          % Density of air

q = 0.5*rho_a*Vmax^2;   % Dynamic pressure of air

% Boat dimensions ///////////// CHECK IF CORRECT NIELS!!!!!!!!!!!!!!
l = 1;                  % length [m]
w = 0.3;                % width [m]
h = 0.15;               % height above water [m]

Afw = w*h;              % frontal area [m^2]
Alw = l*h;              % lateral area [m^2]

% Wind coefficients
% from page 191 in Fossen
cx = 0.7;
cy = 0.87;
cpsi = 0.12;

% Wind Forces

X_wind = -q*cx*cos(gamma)*Afw;
Y_wind = q*cpsi*sin(gamma)*Alw;
Psi_wind = q*cpsi*sin(2*gamma)*Alw*l;
