function [ x_hat_plus P_plus ] = KalmanF( x, u, z, P_plus, R , Q )
load('ssaauship.mat');

states = 17;
x_hat_plus = zeros(states);
P_minus = zeros(states,states);
x_hat_minus = zeros(states);


T =[    0.9946    0.9946
         0         0
    0.0052   -0.0052
    0.0995    0.0995
   -0.0497    0.0497];
K = eye(2,2);
K(1,1) = 0.26565;
K(2,2) = 0.26565;


% Process noise
% w = [0.0001 0.0001 0.0001 0.0001 0.0001 0.0001 0.0001 0.0001 0.0001 0.00000001 0.00000001 0.00000001 0.10 0.00000010 0.00000010 0.00000010 0.00000010]';
% states = [N E x y phi theta psi u v p q r dotu dotv dotphi dottheta dotpsi]

% Measurement noise
% v = [3 3 13.5969e-006 0.1 0.1 0.0524 0.0524]';

% R = diag(v)*diag(1.5*[10 10 1 100 100 1 1]'); % Skal gaines på de rigtige elementer
% Q = diag(w);

% gpsc = 0;
% jj = 1;
%%
PHI = zeros(17,17);
PHI(1:2,1:2) = [1 0; 0 1];
PHI(3:12,3:12) = Ad;
PHI(13:17,13:17) = diag([1 1 1 1 1]);
PHI(13:17,8:12) = Ad(6:10,6:10);
%%
% Model state vector
% x = aaushipsimmodel(x, u);
% noise = randn(17,1).*w;
% x_noisy = x + noise;

% Measurement matrix
h = zeros(7,17);
h(1:2,1:2) = diag([1 1]);
h(3:5,7:9) = diag([1 1 1]);
h(6:7,13:14) = diag([1 1]);

H(:,:) = h;

PHI(1:2,8:9) = [ts*cos(x(7)) -ts*sin(x(7)); ts*sin(x(7)) ts*cos(x(7))]; % The nonlinear contribution to the system



% Computed control input
uu = inv(K)*pinv(T)*u; % u is really tau, uu is the control input vector
uu = round(uu);
% tau(k,:) = (T*K*u)';

% Prediction
x_hat_minus = aaushipsimmodel(x,uu,'input','nop');
P_minus = PHI*P_plus*PHI + Q;

% Update
z_bar = z - h*x_hat_minus;
S = H*P_minus*H' + R;
K = P_minus*H'*inv(S);

% if mod(k,10)
%     K(1:2,:,k) = zeros(2,7);
%     K(:,1:2,k) = zeros(17,2);
%     K(8:9,:,k) = zeros(2,7);
%     K(:,4:5,k) = zeros(17,2);
% else
%     gpsc(jj) = k;
%     jj=jj+1;
% end
    
x_hat_plus = x_hat_minus + K * z_bar;
P_plus = (eye(17) - K*H) * P_minus * (eye(17) - K * H)' + K*R*K';
end
