%% Test Code for the LOS point detection
clear
close all
clc

wp_k=[0 0];
wp_k1=[10 15];
vessel_pos=[5 5];
R=10;

crossing=FindLOSpoint(wp_k,wp_k1,vessel_pos,R);

line_x=linspace(wp_k(1),wp_k1(1),100);
line_y=(wp_k1(2)-wp_k(2))/(wp_k1(1)-wp_k(1))*(line_x-wp_k(1))+wp_k(2);
plot(line_x,line_y)
hold on 
scatter(vessel_pos(1),vessel_pos(2))
circle_x=linspace(vessel_pos(1)-R,vessel_pos(1)+R,100);
circle_y=sqrt(R^2-(circle_x-vessel_pos(1)).^2)+vessel_pos(2);
circley2=-sqrt(R^2-(circle_x-vessel_pos(1)).^2)+vessel_pos(2);
plot(circle_x,circle_y);
plot(circle_x,circley2);
axis equal
scatter(crossing(1),crossing(2));

