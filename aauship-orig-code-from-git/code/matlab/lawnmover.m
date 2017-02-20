%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%lawn mower generator%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Updated smaller track
clear all
clear all
% Box options
boxheigth = 1000;
boxwidth = 300;

% ll = [0,0];
lr = [boxwidth,0];
ur = [boxwidth,boxheigth];
% ul = [0,boxheigth];

% load('/afs/ies.auc.dk/group/14gr1034/Private/matlab/gpx2local/klingenberg.mat')
load('../hli/ros/src/aauship/scripts/fjorden.mat')

% Turning restrictions
tr = 30; % turning radius
s = 2*tr;
n = 1;
figure(1)
clf
hold on
while ((lr(2) + n*s) <= (ur(2) - s))
rightwps(n,:) = [lr(1)-s , lr(2)+n*s]
leftwps(n,:) = [s,rightwps(n,2)]
plot([leftwps(n,1),rightwps(n,1)],[leftwps(n,2),rightwps(n,2)])
n = n+1
end

% y = [-tr:0.1:tr]';
y = [-tr+0.0001:0.01:tr-0.001]';
x = sqrt((tr)^2-y.^2);
cl = length(x)-1;

g = 1;
k = 1;
for l = 2:cl
%     norm([x(l)-x(l+1),y(l)-y(l+k)])
    if ( norm([x(l-k)-x(l),y(l-k)-y(l)]) > 1.5)
        xx(g) = x(l);
        yy(g) = y(l);
        g = g  +1;
        k = 1;
    else
        k = k+1;
    end
    l = l+1;
end
clear x y
x = xx';
y = yy';
cl = length(y)-1;

N=n-1;
k=1;
hold on
for n = 1:N
if mod(n,2)==1 %ulige
    hold on
    allwps(k,:) = leftwps(n,:);
    k = k+1
    allwps(k,:) = rightwps(n,:);
    k = k+1
    plot(allwps(k-1,1),tr+allwps(k-1,2),'*')
    allwps(k:k+cl,:) = [x+allwps(k-1,1),y+tr+allwps(k-1,2)];
%     allwps(k:k+cl,:) = [allwps(k-1,1)+sqrt((tr)^2-y.^2+2.*y.*allwps(k-1,2)-allwps(k-1,2).^2),y];
    k = k+cl;
    n = n+1
elseif mod(n,2)==0 %lige
    allwps(k,:) = rightwps(n,:);
    k = k+1
    allwps(k,:) = leftwps(n,:);
    k = k+1
    plot(allwps(k-1,1),tr+allwps(k-1,2),'*')
    allwps(k:k+cl,:) = [-(x-allwps(k-1,1)),y+tr+allwps(k-1,2)];
    k = k+cl;
    n = n+1
end
end
% save('track.mat','track')

% figure(1)
% plot(allwps(:,1),allwps(:,2),'.-')
% axis equal

% allwps(:,2) = allwps(:,2)+(-57);
% allwps(:,1) = allwps(:,1)+(-46.5);
allwps(:,2) = allwps(:,2)+(-2260);
allwps(:,1) = allwps(:,1)+(3800);

% allwps(1,2) = -2300;
% allwps(1,1) = 3900;

a = 35*pi/180;
Rz = [cos(a) -sin(a);
      sin(a)  cos(a)];
for i = 1:length(allwps)
    allwps(i,:) = (allwps(i,:)-allwps(1,:))*Rz+allwps(1,:);
    end

figure(2)
clf
% plot(inner(:,2),inner(:,1),'b', outer(:,2),outer(:,1),'g', allwps(:,2),allwps(:,1),'.-r')
plot(all(:,2),all(:,1),'b', allwps(:,2),allwps(:,1),'.-r')
axis equal
track = [allwps(:,1) allwps(:,2)];
save('fjordenlawnmower.mat','track')

% 
% %% Just a simple triangle wp
% clear all;
% load('../hli/ros/src/aauship/scripts/fjorden.mat')
% 
% clear allwps
% 
% allwps(:,1) = [3850 4150 3950 4400 4200 4500];
% allwps(:,2) = [-2500 -2300 -2100 -1900 -1700 -1500];
% 
% figure(3)
% plot(all(:,2),all(:,1),'b',allwps(:,2),allwps(:,1),'.-r')
% axis equal
% 
% track = [allwps(:,1) allwps(:,2)];
% save('fjordtriangle.mat','track')
% 
% %% Only a small line segment
% clear all;
% load('../hli/ros/src/aauship/scripts/fjorden.mat')
% 
% clear allwps
% 
% allwps(:,1) = [3900 4400];
% allwps(:,2) = [-2500 -1500];
% 
% figure(4)
% plot(all(:,2),all(:,1),'b',allwps(:,2),allwps(:,1),'.-r')
% axis equal
% 
% track = [allwps(:,1) allwps(:,2)];
% save('fjordlinesegment.mat','track')
% 
% %% Very small line segment
% clear all;
% load('../hli/ros/src/aauship/scripts/fjorden.mat')
% 
% clear allwps
% 
% allwps(:,1) = [3900 4150];
% allwps(:,2) = [-2500 -1900];
% 
% figure(5)
% plot(all(:,2),all(:,1),'b',allwps(:,2),allwps(:,1),'.-r')
% axis equal
% 
% track = [allwps(:,1) allwps(:,2)];
% save('fjordsmalllinesegment.mat','track')
% 
% %% Larger line segment
% clear all;
% load('../hli/ros/src/aauship/scripts/fjorden.mat')
% 
% clear allwps
% 
% allwps(:,1) = [3900 3920 3940 3970 4000 4030 4080 4140 4220 4290 4350 4430 4500 4610 4700 4830 4980 5130 5290 5500 5700 5900 6070 6180 6250 6300 6400 6510 6630 6740 6840 6920 7020 7100];
% allwps(:,2) = [-2500 -2400 -2300 -2200 -2100 -2000 -1900 -1800 -1700 -1600 -1500 -1400 -1300 -1200 -1100 -1000 -900 -800 -700 -600 -500 -400 -300 -200 -100 0 100 200 300 400 500 600 700 800];
% 
% figure(6)
% plot(all(:,2),all(:,1),'b',allwps(:,2),allwps(:,1),'.-r')
% axis equal
% 
% track = [allwps(:,1) allwps(:,2)];
% save('fjordlargepath.mat','track')
% 
% 
% 
% 



