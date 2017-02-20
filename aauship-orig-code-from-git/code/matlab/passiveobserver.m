%%%%%%%%%%%%%%%%%%%%%
%%%%   passive   %%%%
%%%%   Observer  %%%%
%%%%   Design    %%%%
%%%%%%%%%%%%%%%%%%%%%
clc; clear all; clf;

% SImulation parameters
N = 900;
h = 0.1; % Sampling time

% System matrices
ss = load('ssaauship.mat');

% MRB = ss.MRB;
% MRB = [MRB(1:2,1:2) MRB(1:2,5);...
%        MRB(5,1:2) MRB(5,5)];

% D = ss.D;
% D = [D(1:2,1:2) D(1:2,5);...
%        D(5,1:2) D(5,5)];

% Example 11.6 page 318 in Fossen
MRB = [5.3122*10^6 0 0;
       0 8.2831*10^6 0;
       0 0 3.7454*10^9];
D = [5.0242*10^4 0 0;
     0 2.7229*10^5 -4.393*10^6;
     0 -4.3933*10^6 4.1894*10^8]; 

i_MRB = inv(MRB);
rbg = ss.r_g';

H_6dof  = [eye(3) Smtrx(rbg)';...
           zeros(3,3) eye(3)];
Ht_6dof = [eye(3) zeros(3,3);...
           Smtrx(rbg) eye(3)];

H  = [H_6dof(1:2,1:2) H_6dof(1:2,6)
      H_6dof(6,1:2) H_6dof(6,6)]; % 3DOF
Ht = [Ht_6dof(1:2,1:2) Ht_6dof(1:2,6)
      Ht_6dof(6,1:2) Ht_6dof(6,6)]; % 3DOF

% iM_t = inv(Ht)*inv(Ht*(MRB)*H);
% eta_d = [8 3 2 0 0 0.5]';

eta = zeros(N,3);
dot_est_eta = zeros(N,3);
est_eta = zeros(N,3);
dot_est_b = zeros(N,3);
est_b = zeros(N,3);
dot_est_nu = zeros(N,3);
est_nu = zeros(N,3);
est_nu(1,:) = [0 0 pi/4];
err_y = zeros(N,3);
% est_rotD = zeros(2,2,N);
% est_pos = zeros(2,N);
R = zeros(3,3);
Rt = zeros(3,3);

k2 = diag([1.1 1.1 1.1])*10;
k4 = diag([0.1 0.1 0.01])*10;
k3 = 0.1*k4;
T = diag([1000 1000 1000]);

% Eta0 = [0 0 0 0 (45*pi/180)];
% tau = [0 0 0 0 0]';

% load test4.mat
% eta = [simout.Data(:,1:3) zeros(numel(simout.Data(:,1)),2) simout.Data(:,4)]';
% h = 0.2;

% Pre allocation of variables
N = 4000;
es = N;
x = zeros(N,10);
x(1,:) = [0 0 0 0 pi/4 6 0 0 0 0]';
xdot = zeros(N,10);
NED = zeros(N,2);
taus = [500 0 0 0 3]';
tau = repmat(taus',N,1);
% tau(:,1) = (1:N)/600;
% taus = [10 0 0 0 0]';
% tau(ceil(N/2)+1:N,:)  = repmat(taus',N/2,1);
heading = zeros(N,1);

% for j = 2:N; % Passive Nonlinear Observer on vessel
    for k = 1:N-1;
    % Simulation of vessel
    x(k+1,:) = aauship(x(k,:)', tau(k,:)');
    eta(k+1,:) = [x(k+1,1:2) x(k+1,5)];
%     psi=x(k,5);
%     Rz = [cos(psi) -sin(psi);
%           sin(psi)  cos(psi)];
%     Rzt = Rz';
      
    if k ~=  1
%         NED(k+1,:) = Rz*x(k,6:7)'*0.1 + NED(k,:)';
%         NED_dist(k+1,1:2) = NED(k+1,1:2) + (diag([1.0035,1.0035])*randn(2,1)/10)';
%         heading(k) = (x(k,10)'*0.1 + heading(k-1));
%         heading_dist(k) = heading(k) + 0.0359*rand(1);
        
        dot_est_eta(k+1,:) = R*est_nu(k,:)' + k2*err_y(k,:)';
        est_eta(k+1,:) = est_eta(k,:)' + h*dot_est_eta(k+1,:)';
        dot_est_b(k+1,:) = 0; % -T\est_b(:,k) + k3*err_y(:,k);
        est_b(k+1,:) = 0; % est_b(:,k) + h*dot_est_b(:,k+1);
        dot_est_nu(k+1,:) = -i_MRB*D*est_nu(k,:)' + i_MRB*Rt*est_b(k+1,:)' ...
                          +  i_MRB*[tau(k,1:2) tau(k,5)]' + i_MRB*Rt*k4*err_y(k,:)';
        est_nu(k+1,:) = est_nu(k,:)' + h*dot_est_nu(k+1,:)';

        err_y(k+1,:) = eta(k+1,:)' - est_eta(k+1,:)';
        
        [R,R1,R2] = eulerang(0,0,est_nu(k+1,3));
%         Rt = R';
%         R = [R1 zeros(3,2);
%               zeros(2,3) diag(ones(1,2))];
        R = R1;
        Rt = R';
    end
    end
    
    figure(1)
    plot(err_y)
    legend('error x','error y', 'error yaw (psi)')
    
    figure(2)
    plot(est_eta(:,2),est_eta(:,1))
    axis equal

%     % Observer equations
%     dot_est_eta(:,j) = R*est_nu(:,j-1) + k2*err_y(:,j-1);
%     est_eta(:,j) = est_eta(:,j-1) + h*dot_est_eta(:,j);
%     
%     dot_est_b(:,j) = -T\est_b(:,j-1) + k3*err_y(:,j-1);
%     est_b(:,j) = est_b(:,j-1) + h*dot_est_b(:,j);
%     
%     dot_est_nu(:,j) = -iM_t*Dl*est_nu(:,j-1) + iM_t*Rt*est_b(:,j) + iM_t*tau + iM_t*Rt*k4*err_y(:,j-1);
%     est_nu(:,j) = est_nu(:,j-1) + h*dot_est_nu(:,j); % Estimates
%     
%     err_y(:,j) = eta(:,j) - est_eta(:,j); 
%     
%     R = eulerang(0,0,est_nu(6,j)); 
%     Rt = R';
% end


% % Generate required figures
% 
% h1 = figure(1);
% plot(simout.Data(:,2),simout.Data(:,1),'m.'); hold on
% plot(est_eta(2,:)',est_eta(1,:)',est_eta(2,1)',est_eta(1,1)','.', 'MarkerSize',20);
% text(est_eta(2,1)',est_eta(1,1)','\leftarrow start')
% hold off
% title('ROV trajectory')
% legend('Measurements','Estimates');
% xlabel('Easting [m]')
% ylabel('Northing [m]')
% axis equal; grid on
% % saveas(h1,'plot/1st.eps','psc2')
% % !epstopdf plot/1st.eps
% 
% h2 = figure(2);
% subplot(4,1,1)
% plot(simout.Time,simout.Data(:,1),simout.Time,est_eta(1,:)'); grid on
% title('Time evolution of estimates and measurements')
% legend('n(t)','est n(t)')
% ylabel('Northing [m]');
% subplot(4,1,2)
% plot(simout.Time,simout.Data(:,2),simout.Time,est_eta(2,:)'); grid on
% legend('e(t)','est e(t)')
% ylabel('Easting [m]');
% subplot(4,1,3)
% plot(simout.Time,simout.Data(:,3),simout.Time,est_eta(3,:)'); grid on
% legend('d(t)','est d(t)')
% ylabel('Depth [m]');
% subplot(4,1,4)
% plot(simout.Time,simout.Data(:,4),simout.Time,est_eta(6,:)'); grid on
% legend('psi(t)','est psi(t)'); xlabel('Time [s]')
% ylabel('Yaw angle [rad]');
% xlabel('Time [s]');
% % saveas(h2,'plot/2nd.eps','psc2')
% % !epstopdf plot/2nd.eps
% 
% h3 = figure(3);
% 
% subplot(4,1,1)
% plot(simout.Time,est_eta(1,:)'); grid on
% title('Time evolution of estimates')
% ylabel('Northing [m]');
% legend('est n(t)')
% subplot(4,1,2)
% plot(simout.Time,est_eta(2,:)'); grid on
% ylabel('Easting [m]');
% legend('est e(t)')
% subplot(4,1,3)
% plot(simout.Time,est_eta(3,:)'); grid on
% ylabel('Depth [m]');
% legend('est d(t)')
% subplot(4,1,4)
% plot(simout.Time,est_eta(6,:)'); grid on
% ylabel('Yaw angle [rad]');
% legend('est psi(t)'); xlabel('Time [s]')
% 
% % saveas(h3,'plot/3rd.eps','psc2')
% % !epstopdf plot/3rd.eps
 

