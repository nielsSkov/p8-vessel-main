%% Test Code for the LOS point detection
clear
close all
clc

wp_k=[1 1];
wp_k1=[100 100];
vessel_pos=[0.2161 0.0249];
r=10;

crossing=FindLOSpoint(wp_k,wp_k1,vessel_pos,r);

line_x=linspace(wp_k(1),wp_k1(1),100);
line_y=(wp_k1(2)-wp_k(2))/(wp_k1(1)-wp_k(1))*(line_x-wp_k(1))+wp_k(2);
plot(line_x,line_y)
hold on 
scatter(vessel_pos(1),vessel_pos(2))
circle_x=linspace(vessel_pos(1)-r,vessel_pos(1)+r,100);
circle_y=sqrt(r^2-(circle_x-vessel_pos(1)).^2)+vessel_pos(2);
circley2=-sqrt(r^2-(circle_x-vessel_pos(1)).^2)+vessel_pos(2);
plot(circle_x,circle_y);
plot(circle_x,circley2);
axis equal
scatter(crossing(1),crossing(2));

%% Test code for Distance to waypoint calculation.

wp_k=[2,6];
wp_k1=[6,2];
vessel_pos=[4,2];

FindDistWP(wp_k,wp_k1,vessel_pos)






