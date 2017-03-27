clear
clc
close all

original=imread('blocks.png');
original=original(MyParameters.YMIN:MyParameters.YMAX,MyParameters.XMIN:MyParameters.XMAX,:);
imtool(original)
x=size(original,2);
y=size(original,1);
imwrite(original,'original.png');

%% Transform into HSV and separate in the different channels
hsv=rgb2hsv(original);

hue=hsv(:,:,1);
saturation=hsv(:,:,2);
value=hsv(:,:,3);

imwrite(hue,'hue.png')
imwrite(saturation,'saturation.png')
imwrite(value,'value.png')

%% Look for blocks
% First, coloured blocks using the saturation channel

saturation=imgaussfilt(saturation,'FilterSize',9);

colour_mask=saturation>MyParameters.COLOR_THRESHOLD*ones(y,x);

% Then, the black blocks using the Value channel
black_mask=value<MyParameters.BLACK_THRESHOLD*ones(y,x);

% Join masks for coloured blocks and black block.
final_mask=black_mask | colour_mask;

imwrite(colour_mask,'colour_mask.png')
imwrite(black_mask,'black_mask.png')
imwrite(final_mask,'final_mask.png')

% Final Processing
se = strel('square',5);                            
final_mask=imopen(final_mask,se);
se = strel('square',5);
final_mask=imclose(final_mask,se);

imwrite(final_mask,'final_mask2.png')

%% Identifying objects
objects = bwconncomp(final_mask);  % Label the objects
area = regionprops(objects,'Area'); % Calculate the areas of the objects
centroid = regionprops(objects,'Centroid'); % Find centroid of the objects
pixelList=regionprops(objects,'PixelList'); % Find the pixel list for each object

nobjects=length(centroid);
centroids=255*repmat(uint8(final_mask),1,1,3); % Converto final_mask to
                                               % be able to put markers
for i=1:1:nobjects
    if area(i).Area(1)>MyParameters.AREA_MIN
        cent_y=round(centroid(i).Centroid(2));
    	cent_x=round(centroid(i).Centroid(1));
        centroids = insertMarker(centroids,[cent_x cent_y],'*','color','blue','size',10);
    end
end

imwrite(centroids,'centroids.png')

%% Finding and storing centroids according to the colour as well as their orientation according with their longest edge
clear lines H theta rho
se = strel('square',3);

blocks = struct('yellow', [], 'green', [], 'blue', [], 'orange', [], 'black', []);

colorlist=[MyParameters.YELLOW MyParameters.GREEN MyParameters.BLUE MyParameters.ORANGE];

centroids_colour=original;

for i=1:1:nobjects
    if area(i).Area(1)>400
        % Get edges in each object and fin the orientation of the longest line
        object_mask = false(y,x); % Create a mask for each object
        for j=1:1:size(pixelList(i).PixelList,1)
            pix_x=pixelList(i).PixelList(j,1);
            pix_y=pixelList(i).PixelList(j,2);
            object_mask(pix_y,pix_x) = 1;
        end
        
        edges=imdilate(object_mask,se)-object_mask;
        [H,theta,rho]=hough(edges,'RhoResolution',1,'ThetaResolution',8);
        P = houghpeaks(H,16,'threshold',ceil(0.1*max(H(:))));
        lines = houghlines(edges,theta,rho,P,'FillGap',10,'MinLength',20);
        nlines=length(lines);
        dist=zeros(1,nlines);
        for k = 1:1:nlines
            dist(k) = norm(lines(k).point1 - lines(k).point2);
        end
        [~,max_dist]=max(dist);
        
        xy = [lines(max_dist).point1; lines(max_dist).point2];
        angle = atan((xy(2,2)-xy(1,2))/(xy(2,1)-xy(1,1)));
        
        if (i==3)
            imwrite(edges,'edges.png')
            imwrite(object_mask,'object_mask.png')
            object=255*repmat(uint8(object_mask),1,1,3);
            object = insertShape(object,'circle',...
                        [xy(1,1) xy(1,2) 5],'LineWidth',3,'color','blue');
            object = insertShape(object,'circle',...
                        [xy(2,1) xy(2,2) 5],'LineWidth',3,'color','blue');  
           	object = insertShape(object,'line',[xy(1,1) xy(1,2) xy(2,1) xy(2,2)],'LineWidth',5,'color','blue');
            imwrite(object,'object.png')
        end
        
        % Get a mask of the object in the hue
        cent_y=round(centroid(i).Centroid(2));
        cent_x=round(centroid(i).Centroid(1));
        region_hue=hue(cent_y-MyParameters.MASK_SIDE:cent_y+MyParameters.MASK_SIDE,...
            cent_x-MyParameters.MASK_SIDE:cent_x+MyParameters.MASK_SIDE);
        region_blackmask=black_mask(cent_y-MyParameters.MASK_SIDE:cent_y+...
            MyParameters.MASK_SIDE,cent_x-MyParameters.MASK_SIDE:cent_x+MyParameters.MASK_SIDE);
        
        % Sort by colour and store centroid and orientation
        if (mean(mean(region_blackmask,1)) >= 0.9)
            blocks.black = [blocks.black; [cent_x cent_y angle]];
            centroids_colour = insertMarker(centroids_colour,...
                [cent_x cent_y],'*','color','white','size',10);
        else
            meanhue=mean(mean(region_hue));
            [~,color_index]=min(abs(meanhue*ones(1,length(colorlist))-colorlist));
            switch color_index
                case 1
                    blocks.yellow = [blocks.yellow; [cent_x cent_y angle]];
                    centroids_colour = insertMarker(centroids_colour,...
                        [cent_x cent_y],'*','color','yellow','size',8);
                case 2
                    blocks.green = [blocks.green; [cent_x cent_y angle]];
                    centroids_colour = insertMarker(centroids_colour,...
                        [cent_x cent_y],'*','color','green','size',8);
                case 3
                    blocks.blue = [blocks.blue; [cent_x cent_y angle]];
                    centroids_colour = insertMarker(centroids_colour,...
                        [cent_x cent_y],'*','color','blue','size',8);
                case 4
                    blocks.orange = [blocks.orange; [cent_x cent_y angle]];
                    centroids_colour = insertMarker(centroids_colour,...
                        [cent_x cent_y],'*','color','red','size',8);
            end
        end
    end
end

imwrite(centroids_colour,'centroids_colour.png')


