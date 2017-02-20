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
N = 10000;
es = N;
ts = 0.05;
x = zeros(N,17);
x(1,:) = [0 8 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]';
z = zeros(N,7);
x_hat = x;
P_plus = zeros(17,17);
xdot = zeros(N,17);
tau = zeros(N,5);
taus = [8 0 0 0 0]';
tau = repmat(taus',N,1);
% taus = [0 0 0 0 0]';
% tau(ceil(N/2)+1:N,:)  = repmat(taus',N/2,1);
% Measurement noise
v = [1 1 13.5969e-006 0.2 0.2 0.00033 0.00033]'; % Disse må ikke ændres - Kun med mere rigtige tal på U og V
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
track = load('track.mat');
track = [x(1,1:2);track.allwps];
n = 1;
error = zeros(1,N);
integral = zeros(1,N);
derivative = zeros(1,N);
serror = zeros(1,N);
sintegral = zeros(1,N);
sderivative = zeros(1,N);
Kp = 10;
Ki = 0.1;
Kd = 50;
thrustdiff = zeros(1,N);
speeddiff = zeros(1,N);
heading = zeros(N,1);
headingdesired = zeros(N,1);

% init til båd 2
error2 = zeros(1,N);
integral2 = zeros(1,N);
derivative2 = zeros(1,N);
derror = zeros(1,N);
dintegral = zeros(1,N);
dderivative = zeros(1,N);
thrustdiff2 = zeros(1,N);
speeddiff2 = zeros(1,N);
heading2 = zeros(N,1);
headingdesired2 = zeros(N,1);
x2 = zeros(N,17);
x2(1,1:2) = [-10,7];
x2(7) = pi/2;
tau2 = [0 0 0 0 0];
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
    
    % tau2
    tau2(k,:)=[speeddiff2(k) 0 0 0 thrustdiff2(k)];
        
    % Simulation
    x(k+1,:) = aaushipsimmodel(x(k,:)', tau(k,:)','tau','wip',wp);
    x2(k+1,:) = aaushipsimmodel(x2(k,:)', tau2(k,:)','tau','wip',wp);
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
    
    psi=x2(k+1,7);
    Rz = [cos(psi) -sin(psi);
          sin(psi)  cos(psi)];
    
    if k ~=  1
        heading2(k) = x2(k+1,7);
    end
    
    % (Båd 1)
    % PID for speed
    serror(k) = 1 - x(k,8);
    sintegral(k) = sintegral(k) + serror(k);
    if k~=1
        sderivative(k) = serror(k) - serror(k-1);
    end
    speeddiff(k+1) = 20*serror(k) + 50*sintegral(k) + 10*sderivative(k);
    
    % PID for heading
    error(k) = rad2pipi(headingdesired(k)  - heading(k));
    integral(k) = integral(k) + error(k);
    if k~=1
        derivative(k) = error(k) - error(k-1);
    end
    thrustdiff(k+1) = Kp*error(k) + Ki*integral(k) + Kd*derivative(k);
    

    % (Båd 2)
    % PID for dist
    Kp2d = 2;
    Ki2d = 1;
    Kd2d = 0;
    derror(k) = -1 +norm(x(k,1:2)-x2(k,1:2));
    dintegral(k) = dintegral(k) + derror(k);
    if k~=1
        dderivative(k) = derror(k) - derror(k-1);
    end
    speeddiff2(k+1) = Kp2d*derror(k) + Ki2d*dintegral(k) + Kd2d*dderivative(k);
    if speeddiff2(k+1) > 5
        speeddiff2(k+1) = 5;
    end
%     speeddiff2(k+1) = 2;
    
    
%     headingdesired2(k) = rad2pipi(atan2(x(k,1)-x2(k,1),x(k,2)-x2(k,2)));
    now = x2(k,1:2);
    wpe = x(k,1:2);
    [headingdesired2(k), foo1, foo2] = wp_gen(now,wpe,now);
    % PID for heading
    Kp2 = 10;
    Ki2 = 0.1;
    Kd2 = 50;
    error2(k) = rad2pipi(headingdesired2(k)  - heading2(k));
    integral2(k) = integral2(k) + error2(k);
    if k~=1
        derivative2(k) = error2(k) - error2(k-1);
    end
    thrustdiff2(k+1) = Kp2*error2(k) + Ki2*integral2(k) + Kd2*derivative2(k);

end

%% Plot the results
t = 0:ts:es*ts-ts;
tt = ts:ts:es*ts;

sailsim = figure(1);
% set(gcf,'Visible','on'); % Hides the matlab plot because it is ugly
% set(gcf,'paperunits','centimeters')
% set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
% set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure
% subplot(3,1,1)

for k = 1:79:es
    ship(x(k+1,2),x(k+1,1),-x(k+1,7)+pi/2,'y')
end
for k = 1:79:es
%     ship(x2(k+1,2),x2(k+1,1),-x2(k+1,7)+pi/2,'b')
% So heading seems to be calculated correctly according to the below ship
% plots
ship(x2(k+1,2),x2(k+1,1),-headingdesired2(k+1)+pi/2,'b')
end



% for k = 1:100:N
%     ship(NED(k,2),NED(k,1),pi/2-headingdesired(k),'y')
% end
hold on
h1 = plot(track(:,2),track(:,1),'b-o', x(1:es,2),x(1:es,1),'-r', x_hat(gpsc,2),x_hat(gpsc,1), '*');
h2 = plot(x_hat(1:es,2),x_hat(1:es,1),'-k');
h3 = plot(z(gpsc,2),z(gpsc,1),'g.-');
% plot(track(n,2),track(n,1),'ro')
plot(x2(1:es,2),x2(1:es,1),'+-r')
legend([h1;h2;h3],'Trajectory','State','Marker for recieved GPS','Estimate','GPS meas','Location','eastoutside')
xlabel('Easting [m]');
ylabel('Northing [m]');
grid on
axis equal
hold off

% xlim([-5 10])
% ylim([-2 10])
