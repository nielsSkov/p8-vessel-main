% clear
% clc
% close all

% cam=webcam;
% original=snapsho(cam);
% original=imread('RealLego4.jpg');
%cam = webcam('Logitech');
original=snapshot(cam);
original=original(138:end,131:512,:);
%imtool(original)
x=size(original,2);
y=size(original,1);

%imshow(Original);
blackthreshold=0.1;
colour_threshold=0.43;
yellow=0.12;
orange=0.05;
cyan=0.57;
blue=0.61;
green=0.22;
area_min=250;

image_points=[348 304;
              335 22;
              65 24;
              59 307
              183 139
              18 307;
              63 181]';

real_points=40*[0 0;
             7 0;
             7 7;
             0 7;
             4 4
             0 8;
             3 7]';
        
 K=vgg_H_from_x_lin(image_points,real_points);  
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


colour_mask=saturation>colour_threshold*ones(y,x);
subplot(2,2,2);
imshow(colour_mask);

% Then, the black blocks using the Value channel
black_mask=value<blackthreshold*ones(y,x);

subplot(2,2,3)
imshow(black_mask)


% Join masks for coloured blocks and black block.
final_mask=black_mask | colour_mask;

% Final Processing

se = strel('square',5);
final_mask=imopen(final_mask,se);
se = strel('square',5);
final_mask=imclose(final_mask,se);

subplot(2,2,4)
imshow(final_mask)
%% Identifying objects and their properties
objects = bwconncomp(final_mask);  % Label the objects
area = regionprops(objects,'Area'); %Calculate the areas of the objects
centroid = regionprops(objects,'Centroid'); % Find centroid of the objects
% orientation = regionprops(objects,'Orientation'); % Find orientation
% minor=regionprops(objects,'MinorAxisLength');
% major=regionprops(objects,'MajorAxisLength');
pixelList=regionprops(objects,'PixelList');

nobjects=length(centroid);

%% Finding and storing centroids according to the colour as well as their orientation according with their longest edge
clear lines H theta rho
se = strel('square',3);

colorlist=[yellow green blue orange];

blocks = struct('yellow', [], 'green', [], 'blue', [], 'orange', [], 'black', []);

for i=1:1:nobjects
    if area(i).Area(1)>area_min
        % Get edges in each object and fin the orientation of the longest line
        object_mask = false(y,x); % Create a mask for each object
        for j=1:1:size(pixelList(i).PixelList,1)
            pix_x=pixelList(i).PixelList(j,1);
            pix_y=pixelList(i).PixelList(j,2);
            object_mask(pix_y,pix_x) = 1;
        end
        
        edges=imdilate(object_mask,se)-object_mask;
        figure
        imshow(object_mask)
        hold on
        [H,theta,rho]=hough(edges,'RhoResolution',1,'ThetaResolution',5);
        P = houghpeaks(H,16,'threshold',ceil(0.1*max(H(:))));
        lines = houghlines(edges,theta,rho,P,'FillGap',10,'MinLength',20);
        nlines=length(lines);
        dist=zeros(1,nlines);
        for k = 1:1:nlines
            dist(k) = norm(lines(k).point1 - lines(k).point2);
        end
        [~,max_dist]=max(dist);
        
        xy1_real=K*[lines(max_dist).point1 1]';
        xy1_real=xy1_real(1:2)'/xy1_real(3);
        xy2_real=K*[lines(max_dist).point2 1]';
        xy2_real=xy2_real(1:2)'/xy2_real(3);
        
        xy=[lines(max_dist).point1;lines(max_dist).point2];
        
        xy_real = [xy1_real; xy2_real];
        angle = atan((xy_real(2,2)-xy_real(1,2))/(xy_real(2,1)-xy_real(1,1)));
        
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color',[0 0.7 0]);
        plot(xy(1,1),xy(1,2),'o','LineWidth',2,'Color',[0 0 0.7]);
        plot(xy(2,1),xy(2,2),'o','LineWidth',2,'Color',[0.7 0 0]);
        hold off
        
        % Get a mask of the object in the hue
        cent_y=round(centroid(i).Centroid(2));
        cent_x=round(centroid(i).Centroid(1));
        region_hue=hue(cent_y-5:cent_y+5,cent_x-5:cent_x+5);
        region_blackmask=black_mask(cent_y-5:cent_y+5,cent_x-5:cent_x+5);
        cent_real=K*[cent_x,cent_y,1]';
        cent_real=cent_real(1:2)'/cent_real(3);
        
        % Sort by colour and store centroid and orientation
        if (mean(mean(region_blackmask,1)) >= 0.9)
            blocks.black = [blocks.black; [cent_x cent_y angle]];
        else
            meanhue=mean(mean(region_hue));
            [~,color_index]=min(abs(meanhue*ones(1,length(colorlist))-colorlist));
            switch color_index
                case 1
                    blocks.yellow = [blocks.yellow; [cent_real angle]];
                case 2
                    blocks.green = [blocks.green; [cent_real angle]];
                case 3
                    blocks.blue = [blocks.blue; [cent_real angle]];
                case 4
                    blocks.orange = [blocks.orange; [cent_real angle]];
            end
        end
        
%         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
%         plot(xy(1,1),xy(1,2),'o','LineWidth',2,'Color','yellow');
%         plot(xy(2,1),xy(2,2),'o','LineWidth',2,'Color','red');
%         line([cent_x,cent_x+50],[cent_y, cent_y+tan(angle)*50],...
%             'Color',[1 0 0],'LineWidth',3)
        
    end
end
