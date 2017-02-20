% test for aauship.m
clear all
N = 40;
clf


x = zeros(10,N);
xdot = zeros(10,N);

NED = zeros(2,N);

for k = 1:N
    [xdot(:,k)] = aauship(x(:,k), [4 0 0 0 0]', 'foo'); % SHIP
    x(:,k+1)=xdot(:,k)*0.05+x(:,k); % Euler integration, now assuming dt = 1, dt*xdot when not true
end

subplot(2,1,1)
plot(x(5,:),x(4,:),'-r.');
ship(x(5,1:N),x(4,1:N),rad2pipi(-1*x(6,1:N)+pi/2),'r');
ylabel('Northing [m]')
xlabel('Easting [m]')
axis equal
subplot(2,1,2)
plot(x(6,:),'.-')
xlabel('Time [samples]')
ylabel('Heading angle [rad]')
