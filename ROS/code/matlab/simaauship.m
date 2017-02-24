%% Simulation of aauship
% TODO nonlinear stuff for simulation model

clear all; clf;
addpath(genpath('x-io'))
AHRS = MahonyAHRS('SamplePeriod', 1/10, 'Kp', 18 , 'Ki', 8);
% set(gcf,'Visible','off'); % Hides the matlab plot because it is ugly
% set(gcf,'paperunits','centimeters')
% set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
% set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure

%% Pre allocation of variables
ss = load('ssaauship.mat');
N = 5000;
es = N;
ts = ss.ts;
clear ss;
x = zeros(N,17);
x(1,:) = [-25 -49 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]';
z = zeros(N,7);
x_hat = x;
P_plus = zeros(17,17);
xdot = zeros(N,17);
tau = zeros(N,5);
taus = [80 0 0 0 0]';
tau = repmat(taus',N,1);
% taus = [0 0 0 0 0]';
% tau(ceil(N/2)+1:N,:)  = repmat(taus',N/2,1);
% Measurement noise
v = [3 3 13.5969e-006 0.2 0.2 0.00033 0.00033]'; % Disse må ikke ændres - Kun med mere rigtige tal på U og V
R_i = diag(v);
R = R_i;
% process noise kalman
w = [0.00001 0.00001 0.001 0.001 0.001 0.001 0.001 0.01 0.01 0.01 0.01 0.01 0.0033 0.0033 0.0033 0.0033 0.0033]';
Q = diag(w);
% process noise
wp = [0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.0000 0.0000 0.0000000 0.0000000 0.0000000 0.000 0 0 0 0]';
gpsc = 0;
jj = 1;

%% Thrust allocation 
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

%% Waypoints
% start = [100, 1000];
% stop = [-1000,1000];
track = load('lawnmoversmall.mat');
track = [x(1,1:2);track.track];
n = 1;
error = zeros(1,N);
integral = zeros(1,N);
derivative = zeros(1,N);
serror = zeros(1,N);
sintegral = zeros(1,N);
sderivative = zeros(1,N);
Kp = 2;
Ki = 0.0;
Kd = 40;
thrustdiff = zeros(1,N);
speeddiff = zeros(1,N);
heading = zeros(N,1);
headingdesired = zeros(N,1);

%% Simulation
figure(1)
clf;
hold on
rev = 0;
limit = 3.07;
heading(1) = x(1,7);
for k = 1:N
%     x(k+1,:) = aauship(x(k,:)', ta); % Used fo thrust allocaiton testing

    % GNC
    [headingdesired(k), wp_reached, cte(k)] = wp_gen(track(n,:),track(n+1,:),x(k,1:2)); % WP Gen
    if (wp_reached == 1)
        n = n+1;
        if n >= length(track)
            es = k-1;
            break
        end
    end

    % Computed control input
    tau(k,:)=[speeddiff(k) 0 0 0 thrustdiff(k)];
    
    u = inv(K)*pinv(T)*tau(k,:)';
    u = round(u);
    tau(k,:) = (T*K*u)';

        
    % Simulation
    x(k+1,:) = aaushipsimmodel(x(k,:)', u,'input','wip',wp);
%     aaushipsimmodel(zeros(17,1),ones(2,1),'input','wip',1)
    
% % 	For test of acceleration - Right now seems weird
% %     if x(k,8) >= 2.75
% %         tau(k+1,1) = 0;
% %     end
           %%% Calculate the IMY measurements from the aaushipsimmodel
            accelbody = [x(k,13) x(k,14) 0]';
            accelimu(:,k) = accelbody + transpose(Rzyx(x(k,5),x(k,6),x(k,7)))*[0;0;9.82];

            declination = 2.1667*pi/180; % angle from north
            inclination = 70.883*pi/180; % angle from north-east plane
            magnbody = [x(k,13) x(k,14) 0]';
            magnimu(:,k) = magnbody + transpose(Rzyx(x(k,5),x(k,6),x(k,7)))*[0;inclination;declination];

            xgyro(k) = x(k,15); % dot_p
            ygyro(k) = x(k,16); % dot_q
            zgyro(k) = x(k,17); % dot_r
            xaccl(k) = accelimu(1,k);
            yaccl(k) = accelimu(2,k);
            zaccl(k) = accelimu(3,k);
            xmagn(k) = magnimu(1,k);
            ymagn(k) = magnimu(2,k);
            zmagn(k) = magnimu(3,k);
                       
            AHRS.Update([xgyro(k) ygyro(k) zgyro(k)] * (pi/180), [xaccl(k) yaccl(k) zaccl(k)], [xmagn(k) ymagn(k) zmagn(k)]);	% gyroscope units must be radians
            quaternion(k, :) = AHRS.Quaternion;
                       
            
    % Generere z m støj
%     if k < 300
    z(k,1:2) = x(k,1:2) + [v(1) v(2)].*randn(2,1)';
    z(k,3) = x(k,7) + v(3).*randn(1,1)';
    z(k,4:5) = x(k,8:9) + [v(4) v(5)].*randn(2,1)';
    z(k,6:7) = x(k,13:14) + [v(6) v(7)].*randn(2,1)';
%     else
%     z(k,1:2) = [v(1) v(2)].*randn(2,1)';
%     z(k,3) = v(3).*randn(1,1)';
%     z(k,4:5) = [v(4) v(5)].*randn(2,1)';
%     z(k,6:7) = [v(6) v(7)].*randn(2,1)';
%     end
    
    if mod(k,20) ~= 0
        R(1,1) = 10*10^10;
        R(2,2) = 10*10^10; 
    else
        R = R_i;
        gpsc(jj) = k;
        jj = jj+1;
    end
    
    [x_hat(k+1,:), P_plus] = KalmanF(x_hat(k,:)', tau(k,:)', z(k,:)', P_plus, R, Q);

    psi=x(k+1,7);
    Rz = [cos(psi) -sin(psi);
          sin(psi)  cos(psi)];
    
    if k ~=  1
        heading(k) = x(k+1,7);
    end
    
    % PID for speed
    serror(k) = 1 - x(k,8);
    sintegral(k) = sintegral(k) + serror(k);
    if k~=1
        sderivative(k) = serror(k) - serror(k-1);
    end
    speeddiff(k+1) = 20*serror(k) + 50*sintegral(k) + 10*sderivative(k);
    speeddiff(k+1) = 8;
    
    % PID for heading
    error(k) = rad2pipi(headingdesired(k)  - heading(k));
    integral(k) = integral(k) + error(k);
    if k~=1
        derivative(k) = error(k) - error(k-1);
    end
    thrustdiff(k+1) = Kp*error(k) + Ki*integral(k) + Kd*derivative(k);
end

%% Plot the results
t = 0:ts:es*ts-ts;
tt = ts:ts:es*ts;

sailsim = figure(1)
% set(gcf,'Visible','on'); % Hides the matlab plot because it is ugly
% set(gcf,'paperunits','centimeters')
% set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
% set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure
% subplot(3,1,1)

for k = 1:79:es
    ship(x(k+1,2),x(k+1,1),-x(k+1,7)+pi/2,'y')
end
% for k = 1:100:N
%     ship(NED(k,2),NED(k,1),pi/2-headingdesired(k),'y')
% end
hold on
h1 = plot(track(:,2),track(:,1),'b-o', x(1:es,2),x(1:es,1),'-r', x_hat(gpsc,2),x_hat(gpsc,1), '*');
h2 = plot(x_hat(1:es,2),x_hat(1:es,1),'-k');
h3 = plot(z(gpsc,2),z(gpsc,1),'g.-');
% plot(track(n,2),track(n,1),'ro')
legend([h1;h2;h3],'Trajectory','State','Marker for recieved GPS','Estimate','GPS meas','Location','eastoutside')
xlabel('Easting [m]');
ylabel('Northing [m]');
grid on
axis equal
hold off

% Figure for error plotting
errorplot = figure(100)
nick = sqrt((x_hat(1:es,2)-x(1:es,2)).^2 + (x_hat(1:es,1)-x(1:es,1)).^2);
meanerror = mean(nick)
plot(1:es,nick)
legend('Euclidian position error')
xlabel('Samples')
ylabel('Position error [m]')

%%DEBUG
figure(2)
euler = quatern2euler(quaternConj(quaternion)) * (180/pi);	% use conjugate for sensor frame relative to Earth and convert to degrees.
eulerinrad = euler(1:es,3) * (pi/180) + pi/2;
plot(tt, x(1:es,7), tt, headingdesired(1:es),'-.', tt, x_hat(1:es,7),tt,eulerinrad,'k')
legend('x(:,7)', 'Desired heading', 'x_{hat}(:,7)','Heading from Mahony')
legpos = [.2, .2, .2, .2];
set(legend, 'Position', legpos)
xlabel('time')
ylabel('rad')


%%DEBUGEND
% csvwrite('positions.csv',[x(1:es,1:2) -x(1:es,5)+pi/2])
% figure(2)
% subplot(2,1,1)
% plot(tt,heading(1:es),tt,headingdesired(1:es))
% legend('ship heading','desired heading')
% 
% subplot(2,1,2)
% plot(t,cte(1:es))
% % plot(t,error(1:es))


%%
figure(3)
subplot(2,1,1)
plot(t,x_hat(1:es,8),'r',t,z(1:es,4),'b',t,x(1:es,8),'-.g')
ylabel('Surge vel [m/s]')
xlabel('Time [s]')
legend('Estimate','Meas','Ideal')
subplot(2,1,2)
plot(t,x_hat(1:es,9),'r',t,z(1:es,5),'b',t,x(1:es,9),'-.g')
ylabel('Sway vel [m/s]')
xlabel('Time [s]')
legend('Estimate','Meas','Ideal')
% subplot(2,3,3)
% plot(t,x_hat(1:es,10),'r',t,x(1:es,10),'-.g')
% ylabel('Roll vel [rad/s]')
% xlabel('Time [s]')
% legend('Estimate','Ideal')
% subplot(2,3,4)
% plot(t,x_hat(1:es,11),'r',t,x(1:es,11),'-.g')
% ylabel('Pitch vel [rad/s]')
% xlabel('Time [s]')
% legend('Estimate','Ideal')
% subplot(2,3,5)
% plot(t,x_hat(1:es,12),'r',t,x(1:es,12),'-.g')
% ylabel('Yaw vel [rad/s]')
% xlabel('Time [s]')
% legend('Estimate','Ideal')

% 
% figure(4);clf;
% subplot(3,1,1)
% plot(t,x(1:es,3))
% ylabel('Rool angle [rad]')
% subplot(3,1,2)
% plot(t,x(1:es,4))
% ylabel('Pitch angle [rad]')
% subplot(3,1,3)
% plot(t,x(1:es,5))
% ylabel('Yaw angle [rad]')
% xlabel('Time [s]')


%%%%%%%%%%%%%%%%%%%%%%%%%%% Plots til bestemmelse af Q
figure(4)
subplot(2,2,1)
plot(x_hat(gpsc,2),x_hat(gpsc,1),'r', z(gpsc,2),z(gpsc,1),'b')
axis equal
legend('x_{hat}(1:2)','z(1:2)')
xlabel('Easting (m)')
ylabel('Norting (m)')

subplot(2,2,2)
plot(tt,x_hat(1:es,7),'r',tt,z(1:es,3))
legend('x_{hat}(7)','z(3)')
xlabel('Time (s)')
ylabel('Heading (rad)')

subplot(2,2,3)
plot(tt,x_hat(1:es,8),'r',tt,z(1:es,4),'b',tt,x(1:es,8),'-.g')
legend('x_{hat}(8)','z(4)','Ideal')
xlabel('Time (s)')
ylabel('u Speed (m/s)')

subplot(2,2,4)
plot(tt,x_hat(1:es,9),'r',tt,z(1:es,5),'b',tt,x(1:es,9),'-.g')
legend('x_{hat}(9)','z(5)','Ideal')
xlabel('Time (s)')
ylabel('v Speed (m/s)')

% subplot(2,2,4)
% plot(tt,x_hat(1:es,13),'r',tt,x_hat(1:es,14),'r',tt,z(1:es,6),'b',tt,z(1:es,7),'b')
% legend('x_{hat}(13)','x_{hat}(14)','z(6)','z(7)')
% xlabel('Time (s)')
% ylabel('Acceleration (m/s^2)')% 

% Plots af acceleration
figure(5)
subplot(2,1,1)
plot(tt,x_hat(1:es,13),'r',tt,z(1:es,6),'b',tt,x(1:es,13),'-.g')
legend('x_{hat}(13)','z(6)','Ideal')
xlabel('Time (s)')
ylabel('Acceleration (m/s^2)')
subplot(2,1,2)
plot(tt,x_hat(1:es,14),'r',tt,z(1:es,7),'b',tt,x(1:es,14),'-.g')
legend('x_{hat}(14)','z(7)','Ideal')
xlabel('Time (s)')
ylabel('Acceleration (m/s^2)')

% Plot af Nord og Øst hver for sig
figure(6)
subplot(2,1,1)
plot(tt,x_hat(1:es,1),'r',tt,z(1:es,1),'b',tt,x(1:es,1),'-.g')
legend('N est','N meas','N ideal')
xlabel('time')
ylabel('N')
subplot(2,1,2)
plot(tt,x_hat(1:es,2),'r',tt,z(1:es,2),'b',tt,x(1:es,2),'-.g')
legend('E est','E meas','E ideal')
xlabel('time')
ylabel('E')

% Plot of KF angles and AHRS angles
figure(7)
euler = quatern2euler(quaternConj(quaternion)) * (180/pi);	% use conjugate for sensor frame relative to Earth and convert to degrees.
plot(t,euler(1:es,1),'g',t,euler(1:es,2),'b',t,euler(1:es,3),'r')

% Plot af thrustdiff til error detection
figure(8)
plot(tt,thrustdiff(1:length(tt))')
title('Thrustdiff')
xlabel('time')
ylabel('Thrustdiff')





