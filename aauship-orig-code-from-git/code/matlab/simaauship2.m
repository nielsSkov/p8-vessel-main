%% Simulation of aauship
% TODO nonlinear stuff for simulation model

clear all; clf;
%%
% set(gcf,'Visible','off'); % Hides the matlab plot because it is ugly
% set(gcf,'paperunits','centimeters')
% set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
% set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure

%% Pre allocation of variables
ss = load('ssaauship.mat');
N = 2000;
no_boats = 4;
es = N;
ts = ss.ts;
clear ss;
x = zeros(17,no_boats,N+1);
% Line setup
% x(:,1,1) = [-234+32 -200 -234+32 -200 0 0 -4.16 0 0 0 0 0 0 0 0 0 0]';
% x(:,2,1) = [-242+32 -200 -242+32 -200 0 0 -4.16 0 0 0 0 0 0 0 0 0 0]';
% x(:,3,1) = [-250+32 -200 -250+32 -200 0 0 -4.16 0 0 0 0 0 0 0 0 0 0]';
% x(:,4,1) = [-258+32 -200 -258+32 -200 0 0 -4.16 0 0 0 0 0 0 0 0 0 0]';

% Random setup
% % x(:,1,1) = [-234+42 -210 -234+42 -210 0 0 -4.16 0 0 0 0 0 0 0 0 0 0]';
% x(:,1,1) = [-234+42 -210 -234+42 -210 0 0 -4.16 0 0 0 0 0 0 0 0 0 0]';
% % x(:,2,1) = [-242+32 -190 -242+32 -190 0 0 -4.16 0 0 0 0 0 0 0 0 0 0]';
% x(:,2,1) = [-242+120 -190-30 -242+120 -190-30 0 0 -4.16 0 0 0 0 0 0 0 0 0 0]';
% 
% x(:,3,1) = [-250+22 -200 -250+22 -200 0 0 -4.16 0 0 0 0 0 0 0 0 0 0]';
% x(:,4,1) = [-258+12 -210 -258+12 -210 0 0 -4.16 0 0 0 0 0 0 0 0 0 0]';

% x(:,1,1) = [-2260+42 3800-20 -2260+42 3800-20 0 0 -4.16 0 0 0 0 0 0 0 0 0 0]';
% x(:,2,1) = [-2260+120 3800-30 -2260+120 3800-20 0 0 -4.16 0 0 0 0 0 0 0 0 0 0]';
% x(:,3,1) = [-2260+22 3800-10 -2260+22 3800-20 0 0 -4.16 0 0 0 0 0 0 0 0 0 0]';
% x(:,4,1) = [-2260+12 3800-50 -2260+12 3800-20 0 0 -4.16 0 0 0 0 0 0 0 0 0 0]';

x(:,1,1) = [-2234+82 3800 -2234+82 3800 0 0 1.1 0 0 0 0 0 0 0 0 0 0]';
x(:,2,1) = [-2242+82 3760 -2242+82 3760 0 0 1.1 0 0 0 0 0 0 0 0 0 0]';
x(:,3,1) = [-2250+82 3800 -2250+82 3800 0 0 1.1 0 0 0 0 0 0 0 0 0 0]';
x(:,4,1) = [-2258+82 3800 -2258+82 3800 0 0 1.1 0 0 0 0 0 0 0 0 0 0]';

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
% track = load('lawnmover.mat');
track = load('fjordenlawnmower.mat');
% track = [-170 -190; -150 -190; -130 -190; -110 -190; -90 -190; -70 -190; -50 -190; -30 -190; -10 -190; 10 -190; 30 -190; 50 -190; 70 -190; 90 -190; 110 -190; 130 -190; 150 -190; 170 -190; 190 -190; 210 -190; 230 -190; 250 -190; 270 -190; 290 -190; 310 -190; 330 -190; 350 -190; 370 -190; 390 -190; 410 -190; 430 -190; 450 -190; 470 -190; 490 -190];
% track = [-170 -190; -150 -190; -130 -190; -110 -190; -90 -190; -70 -190; -50 -190; -30 -190; -10 -190; 130 -190; 150 -190; 170 -190; 190 -190; 210 -190; 230 -190; 250 -190; 270 -190; 290 -190; 310 -190; 330 -190; 350 -190; 370 -190; 390 -190; 410 -190; 430 -190; 450 -190; 470 -190; 800 -190];
track = [track.track(1,:)-[30,-10];track.track];
% track(1,1) = track(1,1)+10;
error = zeros(no_boats,N);
integral = zeros(no_boats,N);
derivative = zeros(no_boats,N);
serror = zeros(no_boats,N);
sintegral = zeros(no_boats,N);
sderivative = zeros(no_boats,N);
Kp = 2;
Ki = 0.2;
Kd = 25;
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
% limit = 3.07;
%heading(1) = x(7,1,1);

m = 1; % Track counter
pvl = zeros(N+1,2);
% pvl(1,:) = [track(m,2), track(m,1)];  % Set virtual leader
wp_r = 0.1; % waypoint acceptance radius


%% POTFIELD VARS START
MPI = pi;
% Laver grid med meshgrid, step bestemmer 'opløsning'
step = 1;
[X,Y] = meshgrid(-100:step:100,-50:step:50);
lenx=length(X(:,1));
leny=length(Y(1,:));
% Safe avoidance radius
rsav = 3;
% Pos af hvor baad i skal ende
% pi0 = [60,11];
% Gains til funktionerne
Kvl = 4;
Kij = 0.2;
% Kij = Kvl/no_boats/2;
Kca = 240;
Koa = 500;
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


% Used for max force, eq. (47)
Fmin = 10;
% Desired pos, spans the formation
pi0 = zeros(no_boats,2);
% pi0(1,1:2) = [8,-10];
% pi0(2,1:2) = [0,-5];
% pi0(3,1:2) = [-8,0];
% pi0(4,1:2) = [-16,-5];

pi0(1,1:2) = [8,0];
pi0(2,1:2) = [0,5];
pi0(3,1:2) = [-8,10];
pi0(4,1:2) = [-16,5];

% pi0(1,1:2) = [8,0];
% pi0(2,1:2) = [0,0];
% pi0(3,1:2) = [-8,0];
% pi0(4,1:2) = [-16,0];

% Initial positions
pij = zeros(no_boats,2,N+1);
for k = 1:no_boats
    pij(k,1:2,1) = x(1:2,k,1);
end
pir = pij;

% pij(1,1:2,1) = [-70,-10];
% pij(2,1:2,1) = [-20,-90];
% pij(3,1:2,1) = [-90,-30];
% pij(4,1:2,1) = [-60,-20];

% Placering af forhindinger (x,y) . (E,N)
% po(1,1:2) = [-2259,3961];
% po(2,1:2) = [-2275,3955];
po(1,1:2) = [-2266,3961];
po(2,1:2) = [-2275,3955];
po(3,1:2) = [-35,2]*1000;
% po(4,1:2) = [-164,-90]; % Test med dette objekt

%% POTFIELD VARS END
status = zeros(no_boats,N);
flag = 0;
% nomialspeed = 2;
% pvl(1,:) = [track(1,2), track(1,1)];
psif = zeros(1,N);
cte = zeros(no_boats,N);
tic
for k = 1:N

%     pi0(3,1) = cos(k*0.005)*24;
%     pi0(3,2) = sin(k*0.005)*24;

%     fprintf('Timestep #%d\n', k)
    [psivl(k), wp_reached, ctevl(k)] = wp_gen([track(m,2), track(m,1)],[track(m+1,2), track(m+1,1)],[track(m,2), track(m,1)]); % WP Gen
    psif(k) = psivl(k)-pi/2;
    Rz = [cos(psif(k)) -sin(psif(k));
          sin(psif(k))  cos(psif(k))];
%     Rz = eye(2,2);
    %% Global Trajectory Generation from Waypoints
    % Calculate if formation is ok
    for i = 1:no_boats % for all boats, could possibly me moved to to end of the LTG loop, after the simulation update
        % Check if the formation is OK, such that we can move the virtual
        % leader
        pi0dist(i,k) = norm(pir(i,:,k) - (pi0(i,1:2)*Rz' + pvl(k,:)));
        pijdist(i,k) = norm(pij(i,:,k) - (pi0(i,1:2)*Rz' + pvl(k,:)));
        formradius = 2;
        if ( norm(pij(i,:,k) - (pi0(i,1:2)*Rz' + pvl(k,:))) ) < formradius  % WARNING this radius has to be bigger than the radius in the pathgen() call
%         if ( sqrt( (pir(i,1,k) - (pi0(i,1)+pvl(k,1)))^2 + (pir(i,2,k) - (pi0(i,2)+pvl(k,2)))^2 ) ) < 2
%             fprintf('Boat #%d reached pvl+pi0\n',i)
            status(i,k) = 1;
        end
    end

	if status(:,k) == 1
        flag = 1;
    end

    % Calculate if waypoint is reached
    % fprintf('Formation OK\n')
    dist = sqrt((pvl(k,2)-track(m+1,1))^2+(pvl(k,1)-track(m+1,2))^2);
    if flag == 1
        if dist < wp_r
            fprintf('Waypoint #%d was reached\n', m)
            m = m + 1;
%             status(:,k+1) = zeros(no_boats,1);
            pvl(k,:) = [track(m,2), track(m,1)];
        end
    end

    if m >= length(track)
        es = k-1;
        fprintf('End of track, the iteration was #%d\n', k)
        break
    end
    
%     pvl(k+1,:) = [track(m,2), track(m,1)];
%     pvl(k+1,:) = pvl(k,:)+[cos(psivl(k)), sin(psivl(k))]*2*ts;

%     [psivl(k), wp_reached, ctevl(k)] = wp_gen([track(m,2), track(m,1)],[track(m+1,2), track(m+1,1)],[track(m,2), track(m,1)]); % WP Gen

    if flag == 1 %% formation task is asumed ok
        pvl(k+1,:) = pvl(k,:)+[cos(psivl(k)), sin(psivl(k))]*nomialspeed*ts;  % speed here must be bigger than the minimum speed in the speed controller
        % disp('move!')
    else
        pvl(k+1,:) = [track(m,2), track(m,1)]; % TODO
        % disp('formation = track')
    end


    %% Local Trajectory Generation via Potential Fields
    % Ændringer, underlige hakker, fejl i nord-syd, er fordi der ikke er en
    % controller til at opretholde crosstrackerror i den implementerede
    % algoritme. Dette er ikke i fokus lige nu, vi vil hellere se efter hvordan
    % den opfører dig når den drejer.
    for i = 1:no_boats % for all boat
        nomialspeed = 2;
%         fprintf('Boat #%d\n', i)
        j = 1:no_boats; j(i) = []; % Construct j from i
       % Skal bruges til desired hasts
        Kv = 4;
        minf = 200;
        Fmax = minf + Kv*x(8,i,k);
% %         [pir(i,:,k+1), minval] = pathgen(32, 1, pij(i,:,k), pi0(i,1:2)*Rz', pij(j,:,k), pi0(j,1:2)*Rz', po, pvl(k,:), Fmax, Kvl, Kij, Kca, Koa, rsav);
        [a,b,c,d] = potfieldvector( pij(i,:,k), pi0(i,1:2)*Rz', pij(j,:,k), pi0(j,1:2)*Rz', po, pvl(k,:), Fmax, Kvl, Kij, Kca, Koa, rsav);
        minval = norm(a+b-c-d);
        
%         [pir(i,:,k+1), minval] = pathgen(128, 0.5, pij(i,:,k), pi0(i,1:2), pij(j,:,k), pi0(j,1:2), po, pvl(k,:), Fmax, Kvl, Kij, Kca, Koa, rsav);
        Ftotmagn3(k+1,i) = minval;
%         pir(i,:,k+1) = pij(i,:,k+1) + Ftotmagn3(k+1,i);
%         pir(i,:,k+1) = pij(i,:,k+1);
%         [headingdesired(i,k), wp_reached, cte(i,k)] = wp_gen(pir(i,:,k),pir(i,:,k+1),x(1:2,i,k)'); % WP Gen
%         [headingdesired(i,k), wp_reached, cte(i,k)] = wp_gen(pir(i,:,k),pir(i,:,k+1),x(3:4,i,k)'); % WP Gen
% %         [headingdesired(i,k), wp_reached, cte(i,k)] = wp_gen(pij(i,:,k),pir(i,:,k+1),pij(i,:,k)); % WP Gen
        doo =  a+b-c-d;
        headingdesired(i,k) = rad2pipi(atan2(doo(2),doo(1)));
%         headingdesired(i,k) = headingdesired(i,k) - pi/2;

        if ( and(status(i,k) == 1, flag == 0) ) % TODO ondly do this when flag = 0
% % % %             This is making it follow track heading when in
% % % %             formation, this is undesireable. Needs to be fixed.
            headingdesired(i,k) = wp_gen([track(m,2), track(m,1)],[track(m+1,2), track(m+1,1)],[track(m,2), track(m,1)]);
%             headingdesired(i,k) = psivl(k);

%             headingdesired(i,k) = wp_gen(pvl(k,:),pvl(k+1,:),pvl(k,:));
            nomialspeed = 00.0;
            sintegral(i,k) = 0;
        end
        %% Controller

        % PID for speed
%         speeddesired = nomialspeed-0.3 + minval/20;  % uses combined potential field which is not really great

        if ( and(status(i,k) == 1, flag == 0) )
            speeddesired = 0;
        else
            speeddesired = minval/4;  % uses combined potential field which is not really great
            speeddesired = min(speeddesired,4);
%             speeddesired = max(speeddesired,0.7);
        end
%         speeddesired = 2.2;
%         speeddesired = 2  + 0.04*norm(pir(i,:,k) - (pi0(i,1:2) + pvl(k,:)));
        serror(i,k) = speeddesired - x(8,i,k);
%         serror(i,k) = min(pi0dist(i,k),1);
%         serror(i,k) = speeddesired;
%         sintegral(i,k+1) = sintegral(i,k) + serror(i,k);
        sintegral(i,k+1) = pi0dist(i,k);
        sintegral(i,k+1) = sign(sintegral(i,k+1))*min(abs(sintegral(i,k+1)),4);
        if k~=1
            sderivative(i,k) = serror(i,k) - serror(i,k-1);
        end
        speeddiff(i,k+1) = 10*serror(i,k) + 0*sintegral(i,k+1) + 0*sderivative(i,k); % old tuning parameters
%         speeddiff(i,k+1) = 100*serror(i,k) + 50*sintegral(i,k) + 0*sderivative(i,k); % old tuning parameters
%         speeddiff(i,k+1) = 8;

        % PID for heading
        error(i,k) = rad2pipi(headingdesired(i,k)  - heading(i,k));
        integral(i,k) = integral(i,k) + error(i,k);
        if k~=1
            derivative(i,k) = error(i,k) - error(i,k-1);
        end
        thrustdiff(i,k+1) = Kp*error(i,k) + Ki*integral(i,k) + Kd*derivative(i,k);

        % Computed control input (thrust allocation)
        tau(:,i,k+1)=[speeddiff(i,k+1) 0 0 0 thrustdiff(i,k+1)];
        
        u = K\pinv(T)*tau(:,i,k+1);
        u(1:2,k+1) = round(u);
        sat = 200;
        if sat <= u(1,k+1)
            u(1,k+1) = sat;
        elseif u(1,k+1) <= -sat
            u(1,k+1) = -sat;
        end
        if sat <= u(2,k+1)
            u(2,k+1) = sat;
        elseif u(2,k+1) <= -sat
            u(2,k+1) = -sat;
        end
        
    
        %% Simulation
%         x(1:2,i,k) = [x(2,i,k),x(1,i,k)];
%         x(3:4,i,k) = [x(4,i,k),x(3,i,k)];
        x(:,i,k+1) = aaushipsimmodel(x(:,i,k), u(1:2,k+1),'input','wip',wp);
%         x(:,i,k+1) = aaushipsimmodel([x(2,i,k);x(1,i,k);x(3:17,i,k)], u,'input','wip',wp);
%         x(1:2,i,k+1) = [x(2,i,k+1),x(1,i,k+1)];
%         x(3:4,i,k+1) = [x(4,i,k+1),x(3,i,k+1)];
        heading(i,k+1) = rad2pipi(x(7,i,k+1));
%         heading(i,k+1) =x(7,i,k+1);

%         x(:,i,k+1) = [pir(i,:,k+1)'; zeros(15,1)];
        % Rewrite the i'th boats position to the simulated one.
%         pij(i,:,k+1) = x(1:2,i,k+1);
%         pij(i,:,k+1) = [x(1,i,k+1) x(2,i,k+1)];
        pij(i,:,k+1) = [x(3,i,k+1) x(4,i,k+1)];

    end % end of i'th ship
end
toc
save('simdata.mat')
%% Plot the results
t = 0:ts:es*ts-ts;
tt = ts:ts:es*ts;

h = figure(1);
clf

hold on
h1 = plot(track(:,2),track(:,1),'b-o');
shipcolor = [[1 0 0]; [0 1 0]; [0 0 1]; [1.0000    0.8431         0]];
for i = 1:no_boats
    hold on
    out = reshape(pij(i,:,1:es), 2, []);
    plot(out(1,1:es),out(2,1:es),'-k')
    out = reshape(x(:,i,1:es),length(x(:,i,1)),[]);
%     plot(out(1,1:es),out(2,1:es),'*r')
        
    for k = 1:30:es
%         ship(out(1,k),out(2,k),out(7,k),'y')
        ship(out(1,k),out(2,k),out(7,k),shipcolor(i,:))


        out1 = reshape(x(:,1,1:es),length(x(:,1,1)),[]);
        out2 = reshape(x(:,2,1:es),length(x(:,2,1)),[]);
        out3 = reshape(x(:,3,1:es),length(x(:,3,1)),[]);
        out4 = reshape(x(:,4,1:es),length(x(:,4,1)),[]);

        hold on
        h2 = plot([out1(1,k),out2(1,k),out3(1,k),out4(1,k),out1(1,k)],[out1(2,k),out2(2,k),out3(2,k),out4(2,k),out1(2,k)],'r--');

    end
    hold on

%     out = reshape(pir(i,:,1:es), 2, []);
%     plot3(out(1,1:es),out(2,1:es),'-g')
%     plot3(out(1,1:es),out(2,1:es),Ftotmagn3(1:es,i),'-g')

    hold on
    out = reshape(pij(i,:,1:es), 2, []);
    h3 = plot(out(1,1:es),out(2,1:es),'-g');
    out = reshape(pir(i,:,1:es), 2, []);
    h4 = plot(out(1,1:es),out(2,1:es),'-b');

end

plot(pvl(:,1),pvl(:,2),'r+');
% h3 = plot(z(gpsc,2),z(gpsc,1),'g.-');
% plot(track(n,2),track(n,1),'ro')
legend([h1;h2;h3;h4],'track','formation','pij','pir')
xlabel('Easting [m]');
ylabel('Northing [m]');
title('Plot of the NED frame');
grid on
xlim([-250 -50])
% ylim([-130 -20])
axis equal
hold off

% set(gcf,'paperunits','centimeters')
% set(gcf,'papersize',[20,15]) % Desired outer dimensions of figure
% set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure
% saveas(h, '/tmp/hej.pdf')

%%
figure(2);
clf

hold on
for i = 1:no_boats
    subplot(2,1,1)
    hold on
    out = reshape(x(:,i,1:es),length(x(:,i,1)),[]);
    plot(out(8,1:es),'Color',shipcolor(i,:))

    subplot(2,1,2)
    hold on
    h1 = plot(1:es,heading(i,1:es),'Color',shipcolor(i,:),'LineStyle','-','Marker','.');
    h2 = plot(1:es,headingdesired(i,1:es),'Color',shipcolor(i,:));

end
subplot(2,1,1)
title('Surge velocities of the vessels')
xlabel('Samples')
ylabel('Surge velocity [m/s]')
legend('Vessel 1','Vessel 2','Vessel 3','Vessel 4')
grid on
subplot(2,1,2)
title('Individual headings and desired headings')
xlabel('Samples')
ylabel('Heading [rad]')
legend([h1;h2],'Heading','Headingdesired')
grid on
hold off
%%
figure(3)
clf
for i = 1:no_boats
    plot(1:es,error(i,1:es),'Color',shipcolor(i,:))
    hold on
end
legend('Vessel 1','Vessel 2','Vessel 3','Vessel 4')
grid on
title('Error between heading and desired heading')
xlabel('Samples')
ylabel('Heading error [rad]')

%%
figure(4);
clf
hold on
for i = 1:no_boats
    out = reshape(tau(:,i,1:es),length(tau(:,i,1)),[]);
    hold on
    subplot(2,1,1)
    plot(out(1,1:es),'Color',shipcolor(i,:))
    hold on
    subplot(2,1,2)
    plot(out(5,1:es),'Color',shipcolor(i,:))
end
subplot(211)
legend('Vessel 1, tau_X', 'Vessel 2, tau_X', 'Vessel 3, tau_X', 'Vessel 4, tau_X')
title('Force input in surge')
xlabel('Samples')
ylabel('Force [N]')
hold on
grid on
subplot(212)
legend('Vessel 1, tau_N', 'Vessel 2, tau_N', 'Vessel 3, tau_N', 'Vessel 4, tau_N')
title('Force input in yaw')
xlabel('Samples')
ylabel('Force [N]')
hold on
grid on

%%
figure(5);
clf
% plotting cross track error, which is the same for all boats since they
% follow their paths perfectly
for i = 1:no_boats
%     hold on
%     subplot(2,1,1)
%     hold on
%     grid on
%     plot(cte(i,:),'Color',shipcolor(i,:))
%     ylabel('Cross track error [m]')
    hold on
    plot(pi0dist(i,:),'Color',shipcolor(i,:))
    grid on
end
legend('Vessel 1','Vessel 2','Vessel 3','Vessel 4')
title('Individual distance from reference')
xlabel('Samples')
ylabel('pir-pi0+pvl distance error [m]')

%%
figure(6);
clf
for i = 1:no_boats
    hold on
    plot(pijdist(i,:),'Color',shipcolor(i,:))
    grid on
end
legend('Vessel 1','Vessel 2','Vessel 3','Vessel 4')
title('Individual vessel distances from reference')
xlabel('Samples')
ylabel('pij-pi0+pvl distance error [m]')



%%
% Figure for error plotting
% errorplot = figure(100);
% nick = sqrt((x_hat(1:es,2)-x(1:es,2)).^2 + (x_hat(1:es,1)-x(1:es,1)).^2);
% meanerror = mean(nick);
% plot(1:es,nick)
% legend('Euclidian position error')
% xlabel('Samples')
% ylabel('Position error [m]')

%%DEBUG
% figure(2)
% euler = quatern2euler(quaternConj(quaternion)) * (180/pi);	% use conjugate for sensor frame relative to Earth and convert to degrees.
% eulerinrad = euler(1:es,3) * (pi/180) + pi/2;
% plot(tt, x(1:es,7), tt, headingdesired(1:es),'-.', tt, x_hat(1:es,7),tt,eulerinrad,'k')
% legend('x(:,7)', 'Desired heading', 'x_{hat}(:,7)','Heading from Mahony')
% legpos = [.2, .2, .2, .2];
% set(legend, 'Position', legpos)
% xlabel('time')
% ylabel('rad')
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
% figure(3)
% subplot(2,1,1)
% plot(t,x_hat(1:es,8),'r',t,z(1:es,4),'b',t,x(1:es,8),'-.g')
% ylabel('Surge vel [m/s]')
% xlabel('Time [s]')
% legend('Estimate','Meas','Ideal')
% subplot(2,1,2)
% plot(t,x_hat(1:es,9),'r',t,z(1:es,5),'b',t,x(1:es,9),'-.g')
% ylabel('Sway vel [m/s]')
% xlabel('Time [s]')
% legend('Estimate','Meas','Ideal')
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
% figure(4)
% subplot(2,2,1)
% plot(x_hat(gpsc,2),x_hat(gpsc,1),'r', z(gpsc,2),z(gpsc,1),'b')
% axis equal
% legend('x_{hat}(1:2)','z(1:2)')
% xlabel('Easting (m)')
% ylabel('Norting (m)')
% 
% subplot(2,2,2)
% plot(tt,x_hat(1:es,7),'r',tt,z(1:es,3))
% legend('x_{hat}(7)','z(3)')
% xlabel('Time (s)')
% ylabel('Heading (rad)')
% 
% subplot(2,2,3)
% plot(tt,x_hat(1:es,8),'r',tt,z(1:es,4),'b',tt,x(1:es,8),'-.g')
% legend('x_{hat}(8)','z(4)','Ideal')
% xlabel('Time (s)')
% ylabel('u Speed (m/s)')
% 
% subplot(2,2,4)
% plot(tt,x_hat(1:es,9),'r',tt,z(1:es,5),'b',tt,x(1:es,9),'-.g')
% legend('x_{hat}(9)','z(5)','Ideal')
% xlabel('Time (s)')
% ylabel('v Speed (m/s)')

% subplot(2,2,4)
% plot(tt,x_hat(1:es,13),'r',tt,x_hat(1:es,14),'r',tt,z(1:es,6),'b',tt,z(1:es,7),'b')
% legend('x_{hat}(13)','x_{hat}(14)','z(6)','z(7)')
% xlabel('Time (s)')
% ylabel('Acceleration (m/s^2)')% 

% Plots af acceleration
% figure(5)
% subplot(2,1,1)
% plot(tt,x_hat(1:es,13),'r',tt,z(1:es,6),'b',tt,x(1:es,13),'-.g')
% legend('x_{hat}(13)','z(6)','Ideal')
% xlabel('Time (s)')
% ylabel('Acceleration (m/s^2)')
% subplot(2,1,2)
% plot(tt,x_hat(1:es,14),'r',tt,z(1:es,7),'b',tt,x(1:es,14),'-.g')
% legend('x_{hat}(14)','z(7)','Ideal')
% xlabel('Time (s)')
% ylabel('Acceleration (m/s^2)')

% Plot af Nord og Øst hver for sig
% figure(6)
% subplot(2,1,1)
% plot(tt,x_hat(1:es,1),'r',tt,z(1:es,1),'b',tt,x(1:es,1),'-.g')
% legend('N est','N meas','N ideal')
% xlabel('time')
% ylabel('N')
% subplot(2,1,2)
% plot(tt,x_hat(1:es,2),'r',tt,z(1:es,2),'b',tt,x(1:es,2),'-.g')
% legend('E est','E meas','E ideal')
% xlabel('time')
% ylabel('E')

% Plot of KF angles and AHRS angles
% figure(7)
% euler = quatern2euler(quaternConj(quaternion)) * (180/pi);	% use conjugate for sensor frame relative to Earth and convert to degrees.
% plot(t,euler(1:es,1),'g',t,euler(1:es,2),'b',t,euler(1:es,3),'r')

% Plot af thrustdiff til error detection
% figure(8)
% plot(tt,thrustdiff(1:length(tt))')
% title('Thrustdiff')
% xlabel('time')
% ylabel('Thrustdiff')

