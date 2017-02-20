%% Simulation of aauship
% TODO nonlinear stuff for simulation model

clear all; clf;
% set(gcf,'Visible','off'); % Hides the matlab plot because it is ugly
% set(gcf,'paperunits','centimeters')
% set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
% set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure

%% Pre allocation of variables
ss = load('ssaauship.mat');
N = 200;
no_boats = 4;
es = N;
ts = ss.ts;
clear ss;
x = zeros(17,no_boats,N+1);
x(:,1,1) = [0 0 0 0 0 0 pi/2+pi 0 0 0 0 0 0 0 0 0 0]';
x(:,2,1) = [0 10 0 10 0 0 0 0 0 0 0 0 0 0 0 0 0]';
x(:,3,1) = [0 20 0 20 0 0 0 0 0 0 0 0 0 0 0 0 0]';
x(:,4,1) = [0 31 0 31 0 0 0 0 0 0 0 0 0 0 0 0 0]';
z = zeros(N,7);
x_hat = x;
P_plus = zeros(17,17);
xdot = zeros(N,17);
tau = zeros(5,no_boats,N+1);
% taus = [80 0 0 0 0]';
% tau = repmat(taus',N,1);
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
u = zeros(2,1);

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
        0.0000    0.0000
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
track = [x(1,1:2);track.track]*4;
error = zeros(no_boats,N);
integral = zeros(no_boats,N);
derivative = zeros(no_boats,N);
serror = zeros(no_boats,N);
sintegral = zeros(no_boats,N);
sderivative = zeros(no_boats,N);
Kp = 2;
Ki = 0.0;
Kd = 40;
thrustdiff = zeros(no_boats,N);
speeddiff = zeros(no_boats,N);
heading = zeros(no_boats,N);
headingdesired = zeros(no_boats,N);
speeddesired = 1;

%% Simulation
figure(1)
clf;
hold on
rev = 0;
limit = 3.07;
% heading(1) = x(1,7);

m = 1; % Track counter
pvl = zeros(N+1,2);
pvl(1,:) = [track(m,2)+8, track(m,1)+4];  % Set virtual leader
wp_r = 1; % waypoint acceptance raidus

%% POTFIELD VARS START
MPI = pi;
% Laver grid med meshgrid, step bestemmer 'opløsning'
step = 1;
[X,Y] = meshgrid(-100:step:100,-50:step:50);
lenx=length(X(:,1));
leny=length(Y(1,:));
% Safe avoidance radius
% rsav = 20;
% Pos af hvor baad i skal ende
% pi0 = [60,11];
% Gains til funktionerne
Kvl = 0.9;
Kij = 0.1;
Kca = 240;
Koa = 240;
% Init af felterne
Ftot = zeros(lenx, leny,2);
Ftotmagn = zeros(lenx,leny);
Fvlmagn = zeros(lenx,leny);
Fijmagn = zeros(lenx,leny);
Fcamagn = zeros(lenx,leny);
Foamagn = zeros(lenx,leny);

% % Placering (start og slut) af andre både udover båd i
% pj(1,1:2) = [25 , 35];
% pj(2,1:2) = [90 , -90];
% pj(3,1:2) = [-70,70];
% pj0(1,1:2) = [25 , 35];
% pj0(2,1:2) = [90 , -90];
% pj0(3,1:2) = [-70,70];
% 
% % Placering af forhindinger
% po(1,1:2) = [-55,-40];
% po(2,1:2) = [-60,-60];
% po(3,1:2) = [-35,2];

Kvl = 1;
% Kij = Kvl/no_boats/2;
Kij = 0.5;
rsav = 2;
% Used for max force, eq. (47)
Kv = 1;
Fmin = 10;
% Desired pos, spans the formation
pi0 = zeros(no_boats,2);
pi0(1,1:2) = [0,10];
pi0(2,1:2) = [10,0];
pi0(3,1:2) = [0,-10];
pi0(4,1:2) = [-10,0];

% Initial positions
pij = zeros(no_boats,2,N+1);
pir = pij;
% pij(1,1:2,1) = [-70,-10];
% pij(2,1:2,1) = [-20,-90];
% pij(3,1:2,1) = [-90,-30];
% pij(4,1:2,1) = [-60,-20];

% Placering af forhindinger
po(1,1:2) = [-55,-40]*100;
po(2,1:2) = [-60,-60]*100;
po(3,1:2) = [-35,2]*100;


Fmax = 200;
%% POTFIELD VARS END

for k = 1:N
%     fprintf('Timestep #%d\n', k)
%     [psivl(k), wp_reached, ctevl(k)] = wp_gen([track(m,2), track(m,1)],[track(m+1,2), track(m+1,1)],[track(m,2), track(m,1)]); % WP Gen
%     Rz = [cos(psivl(k)) -sin(psivl(k));
%           sin(psivl(k))  cos(psivl(k))];
    Rz = eye(2,2); % Ignore rotation
    %% Global Trajectory Generation from Waypoints
    % Calculate if formation is ok
    for i = 1:no_boats % for all boats, could possibly me moved to to end of the LTG loop, after the simulation update
        % Check if the formation is OK, such that we can move the virtual
        % leader        
        if ( norm(pir(i,:,k) - (pi0(i,1:2)*Rz'+pvl(k,:))) ) < 2
%         if ( sqrt( (pir(i,1,k) - (pi0(i,1)+pvl(k,1)))^2 + (pir(i,2,k) - (pi0(i,2)+pvl(k,2)))^2 ) ) < 2
            fprintf('Boat #%d reached pi0\n',i)
            % Calculate if waypoint is reached
            dist = sqrt((pvl(k,2)-track(m,1))^2+(pvl(k,1)-track(m,2))^2);
            if dist < wp_r
                wp_reached = 1;
                fprintf('Waypoint #%d was reached\n', m)
                m = m + 1;
            end
        end
    end
    if m >= length(track)
        es = k-1;
        fprintf('End of track, the iteration was #%d\n', k)
        break
    end

    pvl(k+1,:) = [track(m,2)+8, track(m,1)+4];
%     pvl(k+1,:) = [k,k];

    %% Local Trajectory Generation via Potential Fields

    for i = 1:no_boats % for all boat
%         fprintf('Boat #%d\n', i)
        j = 1:no_boats; j(i) = []; % Construct j from i

        [pir(i,:,k+1), minval] = pathgen(32, 0.2, pij(i,:,k), pi0(i,1:2)*Rz', pij(j,:,k), pi0(j,1:2)*Rz', po, pvl(k,:), Fmax, Kvl, Kij, Kca, Koa, rsav);
%         [pir(i,:,k+1), minval] = pathgen(32, 1, pij(i,:,k), pi0(i,1:2), pij(j,:,k), pi0(j,1:2), po, pvl(k,:), Fmax, Kvl, Kij, Kca, Koa, rsav);
%         [pij(i,:,k+1), minval] = pathgen(32, 1, [pij(i,2,k),pij(i,1,k)], [pi0(i,2),pi0(i,1)]*Rz', [pij(j,2,k),pij(j,1,k)], [pi0(j,2),pi0(j,1)]*Rz', po, [pvl(k,1),pvl(k,2)], Fmax, Kvl, Kij, Kca, Koa, rsav);
        Ftotmagn3(k+1,i) = minval;
%         pir(i,:,k+1) = pij(i,:,k+1) + Ftotmagn3(k+1,i);
%         pir(i,:,k+1) = pij(i,:,k+1);
        
        [headingdesired(i,k), wp_reached, cte(i,k)] = wp_gen(pir(i,:,k),pir(i,:,k+1),x(1:2,i,k)'); % WP Gen
%         [headingdesired(i,k), wp_reached, cte(i,k)] = wp_gen(pir(i,:,k),pir(i,:,k+1),pij(i,:,k)); % WP Gen
%         [headingdesired(i,k), wp_reached, cte(i,k)] = wp_gen([3+i,3+i],[4+i,4+i],x(3:4,i,k)'); % WP Gen
%         [headingdesired(i,k), wp_reached, cte(i,k)] = wp_gen(pij(i,:,k),pi0(i,:),pij(i,:,k)); % WP Gen
%         [headingdesired(i,k), wp_reached, cte(i,k)] = wp_gen([pir(i,2,k),pir(i,1,k)],[pir(i,2,k+1),pir(i,1,k+1)], [x(2,i,k+1) x(1,i,k+1)]); % WP Gen
%         headingdesired(i,k) = -headingdesired(i,k);% + pi/2;
%         headingdesired(i,k) = 9*pi/4;

        %% Controller

        % PID for speed
        speeddesried = minval;
        serror(i,k) = speeddesired - x(8,i,k);
        sintegral(i,k) = sintegral(i,k) + serror(i,k);
        if k~=1
            sderivative(i,k) = serror(i,k) - serror(i,k-1);
        end
%         speeddiff(i,k+1) = 20*serror(i,k) + 50*sintegral(i,k) + 10*sderivative(i,k); % old tuning parameters
%         speeddiff(i,k+1) = 100*serror(i,k) + 50*sintegral(i,k) + 0*sderivative(i,k); % old tuning parameters
        speeddiff(i,k+1) = 8;

        % PID for heading
        error(i,k) = rad2pipi(headingdesired(i,k)  - heading(i,k));
        integral(i,k) = integral(i,k) + error(i,k);
        if k~=1
            derivative(i,k) = error(i,k) - error(i,k-1);
        end
        thrustdiff(i,k+1) = Kp*error(i,k) + Ki*integral(i,k) + Kd*derivative(i,k);

        % Computed control input (thrust allocation)
        tau(:,i,k+1)=[speeddiff(i,k+1) 0 0 0 thrustdiff(i,k+1)];
        u = inv(K)*pinv(T)*tau(:,i,k+1);
        u = round(u);
    
        %% Simulation
%         x(3:4,i,k) = [x(4,i,k), x(3,i,k)];
        x(:,i,k+1) = aaushipsimmodel(x(:,i,k), u,'input','wip',wp);
%         x(3:4,i,k+1) = [x(4,i,k+1), x(3,i,k+1)];
        heading(i,k+1) = x(7,i,k+1);

        % Rewrite the i'th boats position to the simulated one.
        pij(i,:,k+1) = x(3:4,i,k+1);
%         pij(i,:,k+1) = [x(3,i,k+1) x(4,i,k+1)];

%         x(:,i,k+1) = [pir(i,:,k+1)'; zeros(15,1)];

    end % end of i'th ship
end

%% Plot the results
t = 0:ts:es*ts-ts;
tt = ts:ts:es*ts;

figure(1);
clf

hold on
h1 = plot(track(:,2),track(:,1),'b-o');
for i = 1:no_boats
    hold on
    out = reshape(pij(i,:,1:es), 2, []);
    h3 = plot(out(1,1:es),out(2,1:es),'-k');
    out = reshape(x(:,i,1:es),length(x(:,i,1)),[]);
%     plot(out(1,1:es),out(2,1:es),'-r')
        
    for k = 1:79:es
        ship(out(2,k+1),out(1,k+1),-out(7,k+1)+pi/2,'y')
    end
    hold on

    out = reshape(pir(i,:,1:es), 2, []);
    h4 = plot(out(1,1:es),out(2,1:es),'-g');    

    hold on
end
hold on
h2 = plot(pvl(:,1),pvl(:,2),'r+');
% h3 = plot(z(gpsc,2),z(gpsc,1),'g.-');
% plot(track(n,2),track(n,1),'ro')
% legend([h1;h2;h3],'Trajectory','State','Marker for recieved GPS','Estimate','GPS meas','Location','eastoutside')
legend([h1,h2,h3,h4],'desired trajectory','pvl','x, ship trajectory','pir')
xlabel('Easting [m]');
ylabel('Northing [m]');
title('Plot of the NED frame');
grid on
xlim([-40 40])
axis equal
hold off
