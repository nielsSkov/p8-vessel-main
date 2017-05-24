%%

clear all
close all
clc


%%
kf_att = csvread('/Users/himalkooverjee/Dropbox/CA8/Test_2017_05_23/2017-05-23_yaw-3_test1_att.txt',1);
kf_pos = csvread('/Users/himalkooverjee/Dropbox/CA8/Test_2017_05_23/2017-05-23_yaw-3_test1_pos.txt',1);
lli_in = csvread('/Users/himalkooverjee/Dropbox/CA8/Test_2017_05_23/2017-05-23_yaw-3_test1_input.txt',1);
%lli = csvread('/Users/himalkooverjee/Dropbox/CA8/Project/Tests/test20052017/controller_yaw_neg_2005_lli.txt',1);

yaw_in = kf_att(1,4);
yawd_in = kf_att(1,7);
xb_in = kf_pos(1,10);

yaw_att = kf_att(:,4);
time_yaw = (kf_att(:,1)-kf_att(1,1))*1e-9;
xb_dot = kf_pos(:,10);
time_xb = (kf_pos(:,1)-kf_pos(1,1))*1e-9;
left = zeros(length(lli_in)/2,1);
time_left = zeros(length(lli_in)/2,1);
right = zeros(length(lli_in)/2,1);
time_right = zeros(length(lli_in)/2,1);
num1 = 1;
num2 = 1;

for i = 1:1:length(lli_in(:,4))
    if lli_in(i,4) > 0
        lli_in(i,4) = (lli_in(i,4)-70.0168)/6.6044;
    else
        lli_in(i,4) = (lli_in(i,4)+91.9358)/8.5706;
    end 
    if lli_in(i,3) == 5
        left(num1) = lli_in(i,4);
        time_left(num1) = (lli_in(i,1)-lli_in(1,1))*1e-9;
        num1 = num1 + 1;
    else
        right(num2) = lli_in(i,4);
        time_right(num2) = (lli_in(i,1)-lli_in(1,1))*1e-9;
        num2 = num2 + 1;
    end
end


%%

F_motors = [time_left left right];

%% State Space Model - states=[yaw yaw_dot xb_dot]'


run Parameters.m
A=[0 1 0;
    0 -dyaw/Iz 0;
    0 0 -dx/m];
B=[0 0;
    l1/Iz -l2/Iz;
    1/m 1/m];
C=[1 0 0;
    0 0 1];
D=[0 0;
    0 0];

% Sampling time
Ts = 0.05;

% Sizes of ss model
n=size(A,1);    % Number of states
nu=size(B,2);   % Number of inputs
ny=size(C,1);   % Number of outputs

% ss form
sys=ss(A,B,C,D);

% Discretize with ZOH
d_sys = c2d(sys, Ts, 'zoh');

Ad = d_sys.A;
Bd = d_sys.B;
Cd = d_sys.C;
Dd = d_sys.D;

%%

init_cond = [yaw_in yawd_in xb_in];

sim discreteSSmodel_check.slx


figure
plot(time_yaw,yaw_att)
hold on
plot(y_out.Time, y_out.Data(:,1))
grid on
legend('yaw from boat', 'yaw from model')

figure
plot(time_xb,xb_dot)
hold on
plot(y_out.TIme,y_out.Data(:,2))
grid on
legend('xb from boat', 'xb from model')