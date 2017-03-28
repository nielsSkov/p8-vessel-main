%%
corners = [0 0;
            0 100;
            50 100;
            50 0];
        
radius = 1;    

N = 10;

minPos = min(corners);
maxPos = max(corners);

diffX = maxPos(1) - minPos(1);
diffY = maxPos(2) - minPos(2);

numLines = ceil((min(diffX, diffY)-radius)/radius)/2;

if diffX <= diffY
    startX = minPos(1)+radius;
    wps = [startX minPos(2)
        [startX maxPos(2)];];
    for i = 1:numLines
        circX = startX+(2*i-1)*radius
        if wps(end) == maxPos(2)
            circY = maxPos(2);
            x = linspace(wps(end,1),startX+i*2*radius,N);
            x = x(2:N-1);
            %realsqrt(radius^2-(x-circX).^2)
            y = sqrt(radius^2-(x-circX).^2)+circY;
            arc = [x;y]';
            wps = [wps;
                arc;
                startX+i*2*radius maxPos(2);
                startX+i*2*radius minPos(2)];
        else
            circY = minPos(2);
            x = linspace(wps(end,1),startX+i*2*radius,N);
            x = x(2:N-1);
            %realsqrt(radius^2-(x-circX).^2)
            y = -sqrt(radius^2-(x-circX).^2)+circY;
            arc = [x;y]';
            wps = [wps;
                arc;
                startX+i*2*radius minPos(2);
                startX+i*2*radius maxPos(2)];
        end
    end
    
end

plot(wps(:,1),wps(:,2))
%xlim([minPos(1) maxPos(1)])
%ylim([minPos(2) maxPos(2)])
axis equal