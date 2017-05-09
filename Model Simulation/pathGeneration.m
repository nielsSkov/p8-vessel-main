%%

%clear all
%close all
clc

% Input co-ordinates of area
corners = [0 0;
            0 500;
            1000 500;
            1000 0];
        
corners = [0 0;
            0 1000;
            500 1000;
            500 0];

% turning radius of boat
radius = 22.5;    

% number of waypoints in turns
N = 10+1;

% distance between waypoints on straight line

line_dist = 50;

% start and finish position
minPos = min(corners);
maxPos = max(corners);

% length of x and y position
diffX = maxPos(1) - minPos(1);
diffY = maxPos(2) - minPos(2);

% gets number of lines to survey
numLines = ceil((min(diffX, diffY)-radius)/(2*radius));

% algorithm if x is smaller than y --> surveys on longest path
if diffX <= diffY
    % start position is offset by radius
    startX = minPos(1)+radius;
    % stores waypoints for first line
    pts = minPos(2):line_dist:maxPos(2);
    wps = [startX*ones(size(pts)); pts]';
    % loop to create way
    for i = 1:numLines
        % gets centre_x of turning circle
        circX = startX+(2*i-1)*radius;
        % if-else to determine which turn to make
        % max turn
        if wps(end,2) == maxPos(2)
            % gets centre_y of turning circle
            circY = maxPos(2);
            % creates N equidistant points in x;
            x = linspace(wps(end,1),startX+i*2*radius,N);
            x = x(2:N-1);
            % creates y on circle for given x
            y = sqrt(radius^2-(x-circX).^2)/2+circY;
            % adds waypoints for turning as well as next straight line
            arc = [x;y]';
            pts = maxPos(2):-line_dist:minPos(2);
            line = [(startX+i*2*radius)*ones(size(pts)); pts]';
            wps = [wps;
                arc;
                line];
        % same as above but for min turn
        else
            circY = minPos(2);
            x = linspace(wps(end,1),startX+i*2*radius,N);
            x = x(2:N-1);
            y = -sqrt(radius^2-(x-circX).^2)/2+circY;
            arc = [x;y]';
            pts = minPos(2):line_dist:maxPos(2);
            line = [(startX+i*2*radius)*ones(size(pts)); pts]';
            wps = [wps;
                arc;
                line];
        end
    end  
end

% algorithm if y is smaller than x --> surveys on longest path
if diffX > diffY
    % start position is offset by radius
    startY = minPos(2)+radius;
    % stores first two waypoints for first line
    pts = minPos(1):line_dist:maxPos(1);
    wps = [pts; startY*ones(size(pts))]';
    % loop to create way
    for i = 1:numLines
        % gets centre_y of turning circle
        circY = startY+(2*i-1)*radius;
        % if-else to determine which turn to make
        % max turn
        %wps(end,1)
        if wps(end,1) == maxPos(1)
            % gets centre_y of turning circle
            circX = maxPos(1);
            % creates N equidistant points in x;
            y = linspace(wps(end,2),startY+i*2*radius,N);
            y = y(2:N-1);
            % creates y on circle for given x
            x = sqrt(radius^2-(y-circY).^2)/2+circX;
            % adds waypoints for turning as well as next straight line
            arc = [x;y]';
            pts = maxPos(1):-line_dist:minPos(1);
            line = [pts; (startY+i*2*radius)*ones(size(pts))]';
            wps = [wps;
                arc;
                line];
        % same as above but for min turn
        else
            circX = minPos(1);
            y = linspace(wps(end,2),startY+i*2*radius,N);
            y = y(2:N-1);
            x = -sqrt(radius^2-(y-circY).^2)/2+circX;
            arc = [x;y]';
            pts = minPos(1):line_dist:maxPos(1);
            line = [pts; (startY+i*2*radius)*ones(size(pts))]';
            wps = [wps;
                arc;
                line];
        end
    end  
end

figure
plot(wps(:,1),wps(:,2))
%xlim([minPos(1) maxPos(1)])
%ylim([minPos(2) maxPos(2)])
axis equal