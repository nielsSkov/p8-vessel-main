clear
clc
close all

% cam=webcam;
% original=snapsho(cam);
original=imread('RealLego4.jpg');
x=size(original,2);
y=size(original,1);

%imshow(Original);

%% Transform into HSV and separate in the different channels
%gray=rgb2gray(original);
hsv=rgb2hsv(original);

hue=hsv(:,:,1);
saturation=hsv(:,:,2);
value=hsv(:,:,3);

figure
subplot(2,2,1)
imshow(original);
subplot(2,2,2)
imshow(hue);
subplot(2,2,3)
imshow(saturation);
subplot(2,2,4)
imshow(value);

%% Look for blocks
% First, coloured blocks using the saturation channel
figure 
subplot(2,2,1);
imshow(original);

saturation=imgaussfilt(saturation,'FilterSize',9);

colour_threshold=0.43;
colour_mask=saturation>colour_threshold*ones(y,x);
subplot(2,2,2);
imshow(colour_mask);

% Then, the black blocks using the Value channel
blackthreshold=0.1;
black_mask=value<blackthreshold*ones(y,x);

subplot(2,2,3)
imshow(black_mask)


% Join masks for coloured blocks and black block.
final_mask=black_mask | colour_mask;

% Final Processing

se = strel('square',10);
final_mask=imopen(final_mask,se);
se = strel('square',10);
final_mask=imclose(final_mask,se);

subplot(2,2,4)
imshow(final_mask)

%% Identifying objects
objects = bwconncomp(final_mask);  % Label the objects
Area = regionprops(objects,'Area'); %Calculate the areas of the objects
Centroid = regionprops(objects,'Centroid'); % Find centroid of the objects
Orientation = regionprops(objects,'Orientation'); % Find orientation 

hold on
for i=1:1:size(Centroid,1)
    if Area(i).Area(1)>100
        plot(Centroid(i).Centroid(1),Centroid(i).Centroid(2),'b*')
        cent_x=Centroid(i).Centroid(1);
        cent_y=Centroid(i).Centroid(2);
        line([cent_x,cent_x+50],[cent_y, cent_y+tand(Orientation(i).Orientation)*50],...
            'Color',[1 0 0],'LineWidth',3)
    end
end
%% Identifying lines in the binary mask to find the orientation.
clear lines H theta rho
%edges = edge(final_mask,'Canny',[0.01 0.02]);
se = strel('square',3);
edges=imdilate(final_mask,se)-final_mask;
[H,theta,rho]=hough(edges,'RhoResolution',1,'ThetaResolution',5);
P = houghpeaks(H,16,'threshold',ceil(0.1*max(H(:))));
%theta=pi/36; %5 degrees
%rho=20; %3 pixels
%lines=houghlines(edges,theta,rho,P,'MinLength',10);
lines = houghlines(edges,theta,rho,P,'FillGap',10,'MinLength',20);
figure 
imshow(edges);
hold on
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'o','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'o','LineWidth',2,'Color','red');
end
% figure
% imshow(imadjust(mat2gray(H)),[],...
%        'XData',theta,...
%        'YData',rho,...
%        'InitialMagnification','fit');
% xlabel('\theta (degrees)')
% ylabel('\rho')
% axis on
% axis normal
% hold on
% colormap(hot)
% x = theta(P(:,2));
% y = rho(P(:,1));
% plot(x,y,'s','color','black');
%% Finding and storing centroids according to the colour
yellow=0.12;
orange=0.05;
cyan=0.57;
blue=0.61;
green=0.22;


blocks = struct('yellow', [], 'green', [], 'blue', [], 'orange', [], 'black', []);

colorlist=[yellow green blue orange];

 for i=1:1:size(Centroid,1)
     cent_y=round(Centroid(i).Centroid(2));
     cent_x=round(Centroid(i).Centroid(1));
     region_hue=hue(cent_y-5:cent_y+5,cent_x-5:cent_x+5);
     region_blackmask=black_mask(cent_y-5:cent_y+5,cent_x-5:cent_x+5);
     if (mean(mean(region_blackmask,1)) >= 0.9)
         blocks.black = [blocks.black; [cent_x cent_y]];
      else
          meanhue=mean(mean(region_hue));
          [~,color_index]=min(abs(meanhue*ones(1,length(colorlist))-colorlist));
          switch color_index
              case 1
                  blocks.yellow = [blocks.yellow; [cent_x cent_y]];
              case 2
                  blocks.green = [blocks.green; [cent_x cent_y]];
              case 3
                  blocks.blue = [blocks.blue; [cent_x cent_y]];
              case 4
                  blocks.orange = [blocks.orange; [cent_x cent_y]];
         end
     end
end




