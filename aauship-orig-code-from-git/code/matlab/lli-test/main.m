% This script is supposed to test the sensors
kk = 0
for kk = 1:0.1:2*pi
box = [-4.2,-4.7,1.5
     4.8,-4.7,1.5
     4.8,9.7,1.5
     -4.2,9.2,1.5
     -4.2,-4.7,-3
     4.8,-4.7,-3
     4.8,9.7,-3
     -4.2,9.2,-3];
pitch = kk;
yaw=0;
roll=0;
R = [cos(yaw)*cos(pitch), -sin(yaw)*cos(roll)+cos(yaw)*sin(pitch)*sin(pitch), sin(yaw)*sin(roll)+cos(yaw)*cos(roll)*sin(pitch)
    sin(yaw)*cos(pitch), cos(yaw)*cos(roll)+sin(roll)*sin(pitch)*sin(yaw), -cos(yaw)*sin(pitch)+sin(pitch)*sin(yaw)*cos(roll)
    -sin(pitch), cos(pitch)*sin(roll), cos(pitch)*cos(roll)]
box = box*R
% clf 
hold off
plot3(box(:,1),box(:,2),box(:,3),'*')
hold on
cornors = [1,2,3,4];
fill3(box(cornors,1),box(cornors,2),box(cornors,3),1)
cornors = [2,3,7,6];
fill3(box(cornors,1),box(cornors,2),box(cornors,3),1)
cornors = [4,8,5,1];
fill3(box(cornors,1),box(cornors,2),box(cornors,3),1)
cornors = [5,6,2,1];
fill3(box(cornors,1),box(cornors,2),box(cornors,3),1)
cornors = [5,6,7,8];
fill3(box(cornors,1),box(cornors,2),box(cornors,3),2)
cornors = [3,4,8,7];
fill3(box(cornors,1),box(cornors,2),box(cornors,3),1)
axis([-10 10 -10 10 -10 10])
xlabel('x');
ylabel('y');
zlabel('z');
pause(0.1)
end
