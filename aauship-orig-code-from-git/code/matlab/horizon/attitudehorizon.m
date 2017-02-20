% This script plots the roll angle on top of a image or movie, this is to
% compare the estimated values with the horizon.

% Maybe use http://www.mathworks.se/help/vision/ref/undistortimage.html
% to undistort wide angle image from GoPro.

clf, clear all

f = imread('horizon-demo.jpg');
[height, width, colors] = size(f);

a = -tan(deg2rad(1));
b = 400;

x = [0 width];
y = a*x+b;

subplot(2,1,1)
hold on
image(f)
axis image
set(gca,'YDir','reverse');
plot(x,y,'y','LineWidth',1)
text(10,20,['Angle: ' num2str(a)])
hold off