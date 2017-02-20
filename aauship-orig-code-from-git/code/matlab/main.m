clear all; clf;

Nskip=1;
N = 999;
% headingdesired=sin(1:0.01:N/100);
headingdesired = ones(1,N)*pi/2+pi/4;

%x = [ u v r x y psi delta ]'
x = zeros(7,N);
xdot = zeros(7,N);
x(6,1) = (pi/4)*3; % skal lige afgrænses til intervalled 0 til 2*pi
x(4:5,1) = [0 4000];
U = zeros(1,N);
error = zeros(1,N);
integral = zeros(1,N);
derivative = zeros(1,N);
Kp = 0.4;
Ki = 10;
Kd = 0;
rudderangle = zeros(1,N);
n = 1;

start = [1000, 10000];
stop = [-10000,10000];
track = [3000,0; 10000,10000; 10000,20000; 0,20100];
track = [x(4:5,1)';track];

% Main loop
for i = 1:Nskip:N

%     [xdot(:,i), U(i)] = mariner(x(:,i), rudderangle(i), 8); % SHIP
%     [xdot(1:6,i)] = aauship(x(1:6,i), [rudderangle(i);0]); % SHIP

    
    [headingdesired(i), wp_reached] = wp_gen(track(n,:),track(n+1,:),x(4:5,i)'); % WP Gen
    
    if (wp_reached == 1)
        n = n+1;
        if n >= length(track)
            break
        end
    end

    x(:,i+1)=xdot(:,i)+x(:,i); % Euler integration, now assuming dt = 1, dt*xdot when not true
    
    error(i) = headingdesired(i) - x(6,i);
    integral(i) = integral(i) + error(i);
    if i~=1
    derivative(i) = error(i) - error(i-1);
    end
    rudderangle(i+1) = Kp*error(i) + Ki*integral(i) + Kd*derivative(i);
end

figure(1)
% ship(x(5,:),x(4,:),rad2pipi(x(6,:)),'r');
% plot(x(5,:),x(4,:),'r.',[start(2),stop(2)]',[start(1),stop(1)]','b-o');
plot(x(5,:),x(4,:),'r.',track(:,2),track(:,1),'b-o');

ylabel('Northing [m]')
xlabel('Easting [m]')
axis equal
