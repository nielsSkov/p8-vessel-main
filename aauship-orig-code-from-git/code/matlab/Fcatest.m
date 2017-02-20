%% 3D plot with force magnitude
clear all;
MPI = pi;
% Laver grid med meshgrid, step bestemmer 'opløsning'
step = 1;
[X,Y] = meshgrid(-100:step:100,-50:step:50);
lenx=length(X(:,1));
leny=length(Y(1,:));
% Safe avoidance radius
rsav = 20;
% Placering af virtuel leader, pt underordnet
vl = [0,0];
% Pos af hvor baad i skal ende
pi0 = [60,11];
% Gains til funktionerne
Kvl = 0.9;
Kij = 0.1;
Kca = 240;
Koa = 240;
% Init af felterne
Ftot = zeros(lenx, leny,2);
Ftotmagn = zeros(lenx,leny);
Fvlmagn = zeros(lenx,leny);
Fijmagn = zeros(lenx,leny);
Fcamagn = zeros(lenx,leny);
Foamagn = zeros(lenx,leny);

% Placering (start og slut) af andre både udover båd i
pj(1,1:2) = [25 , 35];
pj(2,1:2) = [90 , -90];
pj(3,1:2) = [-70,70];
pj0(1,1:2) = [25 , 35];
pj0(2,1:2) = [90 , -90];
pj0(3,1:2) = [-70,70];

% Placering af forhindinger
po(1,1:2) = [-55,-40];
po(2,1:2) = [-60,-60];
po(3,1:2) = [-35,2];

Fmax = 200;

tic
for m = 1:lenx;
    for n = 1:leny;
        pi = [X(1,n),Y(m,1)];
        
        [Fvlmagn(m,n), Fijmagn(m,n), Fcamagn(m,n), Foamagn(m,n)] = potfield(pi, pi0, pj, pj0, po, vl, Fmax, Kvl, Kij, Kca, Koa, rsav);

        Ftotmagn(m,n) = Fvlmagn(m,n)+Fijmagn(m,n)+Fcamagn(m,n)+Foamagn(m,n);
        Ftotmagn(m,n) = min([norm(Ftotmagn(m,n)),Fmax]);%*Ftotmagn(m,n)/norm(Ftotmagn(m,n));
        
        % For at danne et 'låg' på plots hvor de ellers ville være NaN da
        % de er meget større end Fmax
        if isnan(Ftotmagn(m,n))
            Ftotmagn(m,n)  = Fmax;
        end
    end
end
toc
%%
density = 10;
figure(1)
clf;
hold on
axis equal
% surf(X,Y,Fvlmagn);
contour(X, Y, Fvlmagn);
[xvel,yvel] = gradient(-Fvlmagn(1:density:m,1:density:n),step,step);
quiver(X(1,1:density:n),Y(1:density:m,1),xvel,yvel);
title('Contour and quiver plot of Fvl')
hold off

figure(3)
clf;
hold on
% surf(X,Y, Fijmagn);
axis equal
contour(X, Y, Fijmagn);
[xvel,yvel] = gradient(-Fijmagn(1:density:m,1:density:n),step,step);
quiver(X(1,1:density:n),Y(1:density:m,1),xvel,yvel);
title('Fijmagn')
hold off

figure(4)
clf;
hold on
axis equal
contour(X, Y, Fcamagn);
[xvel,yvel] = gradient(-Fcamagn(1:density:m,1:density:n),step,step);
quiver(X(1,1:density:n),Y(1:density:m,1),xvel,yvel);
title('Fcamagn')
hold off

figure(5)
clf;
hold on
axis equal
contour(X, Y, Foamagn);
[xvel,yvel] = gradient(-Foamagn(1:density:m,1:density:n),step,step);
quiver(X(1,1:density:n),Y(1:density:m,1),xvel,yvel);
title('Foamagn')
hold off

h = figure(6)

clf;
set(gcf,'Visible','off'); % Hides the matlab plot because it is ugly
set(gcf,'paperunits','centimeters')
set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure
hold on
axis equal
% surf(X,Y,Ftotmagn);
contour(X, Y, Ftotmagn);
[xvel,yvel] = gradient(-Ftotmagn(1:density:m,1:density:n),step,step);
quiver(X(1,1:density:n),Y(1:density:m,1),xvel,yvel,2);
title('Ftotmagn')
hold off
saveas(h, '/tmp/foo.pdf')

h = figure(7)
density=1;
clf;
set(gcf,'Visible','off'); % Hides the matlab plot because it is ugly
set(gcf,'paperunits','centimeters')
set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure
hold on
axis equal
% surf(X,Y,Ftotmagn);
contour(X, Y, Ftotmagn);
[xvel,yvel] = gradient(-Ftotmagn(1:density:m,1:density:n),step,step);
quiver(X(1,1:density:n),Y(1:density:m,1),xvel,yvel,2);
title('Ftotmagn')
hold off
saveas(h, '/tmp/foo2.pdf')
% figure(7)
% clf;
% hold on
% density = 4;
% [totxvel,totyvel] = gradient(-Ftotmagn(1:density:m,1:density:n),step,step);
% contour(X, Y, Ftotmagn);
% quiver(X(1:density:m,1:density:n), Y(1:density:m,1:density:n),totxvel,totyvel);
% clear m, clear n
% m(1) = 10;
% n(1) = 14;
% for k = 1:1000;
%     A = Ftotmagn(m(k)-1:m(k)+1,n(k)-1:n(k)+1);
%     [minval,index] = min(A(:));
%     [i,j] = ind2sub(size(A),index);
%     m(k+1) = m(k)+(i-2);
%     n(k+1) = n(k)+(j-2);
%     xny(k) = X(m(k),n(k));
%     yny(k) = Y(m(k),n(k));
%     Ftotmagnny(k) = Ftotmagn(m(k),n(k));
% end
% plot3(xny,yny,Ftotmagnny,'r-*')
% plot3(X(m(1),n(1)),Y(m(1),n(1)),Ftotmagn(m(1),n(1)),'bo')
% surf(X,Y,Ftotmagn,'EdgeColor','none');
% axis equal
% xlabel('x')
% ylabel('y')
% zlabel('z')
% hold off

%% Moar boats
n = 6500;
no_boats = 4;
vl = [-10,10];
Kvl = 1;
% Kij = Kvl/no_boats/2;
Kij = 0.5;
rsav = 2;
% Used for max force, eq. (47)
Kv = 1;
Fmin = 10;
% Desired pos, spans the formation
pi0 = zeros(no_boats,2);
pi0(1,1:2) = [0,10];
pi0(2,1:2) = [10,0];
pi0(3,1:2) = [0,-10];
pi0(4,1:2) = [-10,0];

% Initial positions
pij = zeros(no_boats,2,n+1);
pij(1,1:2,1) = [-70,-10];
pij(2,1:2,1) = [-20,-90];
pij(3,1:2,1) = [-90,-30];
pij(4,1:2,1) = [-60,-20];

pvl = zeros(n,2);
pvl(1,:) = vl;
pvl(1:n/2,:) = repmat([0,1000],n/2,1);
pvl(n/2+1:n,:) = repmat([500,1000],n/2,1);

Ftotmagn3 = zeros(n+1,no_boats);
pir = zeros(no_boats,2,n+1);
x=zeros(no_boats,17,n+1);
x(:,1:2,1) = pij(:,1:2,1);
for k = 1:n
    for i = 1:no_boats
        j = 1:no_boats; j(i) = []; % Construct j from i
        [pij(i,:,k+1), minval] = pathgen(18, 1, pij(i,:,k), pi0(i,1:2)+pvl(k,:), pij(j,:,k), pi0(j,1:2)+[pvl(k,:);pvl(k,:);pvl(k,:)], po, vl, Fmax, Kvl, Kij, Kca, Koa, rsav);
        Ftotmagn3(k+1,i) = minval;
%         pir(i,:,k+1) = pij(i,:,k+1) + Ftotmagn3(k+1,i);
%         x(i,:,k+1) = aaushipsimmodel( [pij(i,:,k+1) x(i,3:17,k+1)], [Ftotmagn3(k+1,i), 0, 0, 0], 'tau', 'nonoise', 0 )
        pir(i,:,k+1) = Ftotmagn3(k+1,i);

    end
end

% for i = 1:no_boats
%     plot3(pij(:,1,i),pij(:,2,i),Ftotmagn3(:,i)+2,'r-*')
% end
%
figure(10)
clf
hold on
axis equal
grid on
for i = 1:no_boats
  
    % Trajectory
    out = reshape(pij(i,1:2,:),[2 size(pij,3)])';
    plot(out(:,1),out(:,2),'.-')
    
    % Start
    plot(pij(i,1,1), pij(i,2,1),'ro')
    text(pij(i,1,1), pij(i,2,1),[' ', num2str(i)])

    % Connections
%     out = reshape(pij(:,1:2,n),[2 4 ])';
%     plot(out(:,2),out(:,1),'r*-')
end
axis equal


% Plotting time correlated points
ll = 50;
A = pij(:,1:2,ll:ll:n);
for k = 1:length(A)
%    pause(0.1)
   plot(A(:,1,k),A(:,2,k),'ko-')
end
% figure(11)
% out = reshape(pij(i,1:2,:),[2 size(pij,3)])';
% plot(out)

hold off



figure(11)
clf
for i = 1:no_boats
subplot(no_boats,1, i)
out = reshape(pir(1,1:2,:),[2 size(pir,3)]);
plot(out','.-');grid on;
title(['Boat #', num2str(i)])
end
xlabel('Time [samples]')


