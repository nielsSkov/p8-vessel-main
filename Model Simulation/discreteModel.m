%% model script

clc
clear all
close all

run ControllerLQR.m

N = 100;
ref = [0;1];
x_int = zeros(2,N+1);
x = zeros(3,N+1);
y = zeros(2,N);
u = zeros(2,N);
u_state = zeros(2,N);
u_int = zeros(2,N);

for i=1:N
    u = zeros(2,N);
    u_state = zeros(2,N);
    u_int = zeros(2,N);
    y(:,i) = Cd*x(:,i)
    u_state(:,i) = F*x(:,i)
    u_int(:,i) = Fi*x_int(:,i)
    u(:,i) = -(u_state(:,i)+u_int(:,i))
    
    x(:,i+1) = Ad*x(:,i)+Bd*u(:,i)
    x_int(:,i+1) = 1/Ts*(ref-y(:,i))+x_int(i)
    
    for j=1:2
        if u(j,i)>40
            u(j,i)=40;
        end
        if u(j,i)<0
            u(j,i) =0;
        end
    end
end

plot(y(1,:))
