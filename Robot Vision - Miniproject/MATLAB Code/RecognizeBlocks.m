function [blocks]=RecognizeBlocks(original)
% This function receives an image and returns the founded bricks, sorted by
% color, and its position and orientation with respect to the base x-axis.

x=size(original,2);
y=size(original,1);

% Transform into HSV and separate in the different channels
hsv=rgb2hsv(original);
hue=hsv(:,:,1);
saturation=hsv(:,:,2);
value=hsv(:,:,3);

% Find the blocks in the image
saturation=imgaussfilt(saturation,'FilterSize',9);  % First, find coloured blocks using the saturation channel
colour_mask=saturation>MyParameters.COLOR_THRESHOLD*ones(y,x);
black_mask=value<MyParameters.BLACK_THRESHOLD*ones(y,x);          % Then, the black blocks using the value channel
final_mask=black_mask | colour_mask;                % Join masks for coloured blocks and black blocks
se = strel('square',5);                             % Procesing of the mask to fill holes and eliminate noise
final_mask=imopen(final_mask,se);
se = strel('square',5);
final_mask=imclose(final_mask,se);

% Identifying objects and their properties
objects = bwconncomp(final_mask);           % Label the objects
area = regionprops(objects,'Area');         % Calculate the areas of the objects
centroid = regionprops(objects,'Centroid'); % Find centroid of the objects
pixelList=regionprops(objects,'PixelList'); % Fins the pixels of each block
nobjects=length(centroid);                  % Number of objects found

% Find and store centroids according to the colour as well as their
% orientation according with their longest edge
se = strel('square',3);
colorlist=[MyParameters.YELLOW MyParameters.GREEN MyParameters.BLUE MyParameters.ORANGE];
blocks = struct('yellow', [], 'green', [], 'blue', [], 'orange', [], 'black', []);

for i=1:1:nobjects
    if area(i).Area(1)>MyParameters.AREA_MIN
        object_mask = false(y,x);                   % Create a mask for each object using the pixwl list
        for j=1:1:size(pixelList(i).PixelList,1)
            pix_x=pixelList(i).PixelList(j,1);
            pix_y=pixelList(i).PixelList(j,2);
            object_mask(pix_y,pix_x) = 1;
        end
        edges=imdilate(object_mask,se)-object_mask;                         % Find the edges of the object mask by substacting the image and its dilation
        [H,theta,rho]=hough(edges,'RhoResolution',1,'ThetaResolution',5);   % Find lines in the resulting image using the Hough transform
        P = houghpeaks(H,16,'threshold',ceil(0.1*max(H(:))));
        lines = houghlines(edges,theta,rho,P,'FillGap',10,'MinLength',20);
        nlines=length(lines);
        dist=zeros(1,nlines);
        for k = 1:1:nlines                          % The longest line is stored and used to define the orientation
            dist(k) = norm(lines(k).point1 - lines(k).point2);
        end
        [~,max_dist]=max(dist);
        
        xy1_real=MyParameters.H*[lines(max_dist).point1 1]';     % The position of the points that define the line are trasnformed
        xy1_real=xy1_real(1:2)'/xy1_real(3);        % to real positions using the projection matrix
        xy2_real=MyParameters.H*[lines(max_dist).point2 1]';
        xy2_real=xy2_real(1:2)'/xy2_real(3);
        
        xy_real = [xy1_real; xy2_real];
        angle = atand((xy_real(2,2)-xy_real(1,2))/(xy_real(2,1)-xy_real(1,1)));
        % The angle with
        % respect to the base x
        % axis is found using
        % this two points
        
        % Get a mask of the object in the hue channel and on the black mask
        cent_y=round(centroid(i).Centroid(2));
        cent_x=round(centroid(i).Centroid(1));
        region_hue=hue(cent_y-MyParameters.MASK_SIDE:cent_y+MyParameters.MASK_SIDE,cent_x-MyParameters.MASK_SIDE:cent_x+MyParameters.MASK_SIDE);
        region_blackmask=black_mask(cent_y-MyParameters.MASK_SIDE:cent_y+MyParameters.MASK_SIDE,cent_x-MyParameters.MASK_SIDE:cent_x+MyParameters.MASK_SIDE);
        cent_real=MyParameters.H*[cent_x,cent_y,1]';
        cent_real=cent_real(1:2)'/cent_real(3);
        
        % Sort by colour and store centroid position and orientation
        if (mean(mean(region_blackmask,1)) >= 0.8)
            blocks.black = [blocks.black; [cent_real angle]];
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
    end
end

end