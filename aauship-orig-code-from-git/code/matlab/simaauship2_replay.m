%% Replay of the simulation data aauship in formation
clear all; clf;
load('simdata.mat')
%%
% set(gcf,'Visible','off'); % Hides the matlab plot because it is ugly
% set(gcf,'paperunits','centimeters')
% set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
% set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure


%% Plot the results
t = 0:ts:es*ts-ts;
tt = ts:ts:es*ts;

h = figure(1);
clf

hold on
h1 = plot(track(:,2),track(:,1),'b-o');
shipcolor = [[1 0 0]; [0 1 0]; [0 0 1]; [1.0000 0.8431 0]];

for i = 1:no_boats
    hold on
    out = reshape(pij(i,:,1:es), 2, []);
    h3 = plot(out(1,1:es),out(2,1:es),'-g');

    hir(i) = plot(pir(i,1,k),pir(i,2,k),'r*');
    hcirc(i) = circle( pvl(k,1), pvl(k,2),formradius+2);
    
end
% out = reshape(pir(i,:,1:es), 2, []);
% h4 = plot(out(1,1:es),out(2,1:es),'-b');

% initial
h2 = plot([x(1,1,k),x(1,2,k),x(1,3,k),x(1,4,k),x(1,1,k)],[x(2,1,k),x(2,2,k),x(2,3,k),x(2,4,k),x(2,1,k)],'r--');
hcircc = plot(pvl(1,1),pvl(1,2),'b*');
circle(po(1,1),po(1,2),rsav*2)
circle(po(2,1),po(2,2),rsav*2)

% hir = zeros(no_boats,1); % figure handle for pir
% legend([h1;h2;h3;h4],'track','formation','pij','pir')

% set(findobj(gca, 'Type', 'Line'), 'LineWidth', 2);
xlabel('Easting [m]');
ylabel('Northing [m]');
title('Plot of the NED frame');
grid on
axis equal

start = 2;
stop = es;
nFrames = stop-start;
mov(1:nFrames) = struct('cdata',[], 'colormap',[]);
for k = start:1:stop
    tic
    
%     pi0(3,1) = cos(k*0.005)*24;
%     pi0(3,2) = sin(k*0.005)*24;
    
    h = findall(gca, 'type', 'patch');
    delete(h)
    h = findall(gca, 'type', 'line', 'color', 'k', 'marker', '+');
    delete(h)
    delete(h2)
    h2 = plot([x(1,1,k),x(1,2,k),x(1,3,k),x(1,4,k)],[x(2,1,k),x(2,2,k),x(2,3,k),x(2,4,k)],'r--');
%     delete(hir)
    delete(hcirc)
    delete(hcircc)
    for i = 1:no_boats
%         hold on
%         hir(i) = plot([pij(i,1,k);pir(i,1,k+1)],[pij(i,2,k);pir(i,2,k+1)],'r.-');
%         
        hold on
        ship(x(1,i,k),x(2,i,k),x(7,i,k),shipcolor(i,:));
        
        hold on
        Rz = [cos(psif(k)) -sin(psif(k));
              sin(psif(k))  cos(psif(k))];
        pi0rotated = pi0(i,:)*Rz';
        hcirc(i) = circle( pvl(k,1)+pi0rotated(1), pvl(k,2)+pi0rotated(2), formradius);

    %     out = reshape(pir(i,:,1:es), 2, []);
    %     plot3(out(1,1:es),out(2,1:es),'-g')
    %     plot3(out(1,1:es),out(2,1:es),Ftotmagn3(1:es,i),'-g')

        hold on
    end

    hold on
    hcircc = plot(pvl(k,1),pvl(k,2),'b*');
    toc
    
    xdim = max(pij(:,1,k)) - min(pij(:,1,k));
    ydim = max(pij(:,2,k)) - min(pij(:,2,k));
    mxdim = min(pij(:,1,k))+xdim/2;
    mydim = min(pij(:,2,k))+ydim/2;
    dim = max([xdim, ydim])/2+10;
    xlim([mxdim-dim, mxdim+dim])
    ylim([mydim-dim, mydim+dim])

    title(['Plot of the NED frame. k=',num2str(k)]);
    drawnow('update')
%     mov(k) = getframe(gcf);
    pause(0.001)
end
% movie2avi(mov, 'myPeaks1.avi')

text(mxdim,mydim,'The end','HorizontalAlignment','center','FontSize',80,'Interpreter','latex')
