clear all
for fighandle = findobj('Type','figure')', clf(fighandle), end
% Stuff for handling figure output
set(gcf,'Visible','off'); % Hides the matlab plot because it is ugly
set(gcf,'paperunits','centimeters')
set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure
load('inertia.mat')
linewidth = 1;
%% Data files
logpath = '/afs/ies.auc.dk/group/14gr1034/public_html/tests/';
testname = 'newseatrail';

%% Data files
gps1file = fopen([logpath,testname,'/gps1.log']);
imudata = load([logpath,testname,'/imu.log']);
echofile = fopen([logpath,testname,'/echo.log']);
starttime = imudata(1,13); % Earliest timestamp
annotatefile = fopen([logpath,testname,'/annotate1399289431.26.log'],'r');
% annotatefile = fopen([logpath,testname,'/annotate1400061527.83.log'],'r');
ctlfile = fopen([logpath,testname,'/ctl.log'],'r');

annotate = textscan(annotatefile, '%f%f%s', 'Delimiter', ';');
ctl = textscan(ctlfile, '%f%f%f', 'Delimiter', ',');

%% Reading GPS data
line = textscan(gps1file,'%f,%c,%f,%c,%f,%c,%f,%f');
time = line{1};
nmealat = line{3};
latsign = line{4};
nmealon = line{5};
lonsign = line{6};
nmeaspeed = line{7};
walltime = line{8};

%% Converts the latitude an longitide to decimal coordinates
[pos] = nmea2decimal({nmealat,latsign,nmealon,lonsign});
lat = pos(1,:);
lon = pos(2,:);

% figure(1)
% plot(lon,lat,'.r')
% plot_google_map('maptype','satellite')
% title('WGS84')

%% Tangent plance coordinates xyz (not verified)
% latrad = lat*pi/180;
% lonrad = lon*pi/180;
% hei = gpsdata(:,3);
% N = length(lat);
% hei=zeros(N,1);
% x=zeros(N,1);
% y=zeros(N,1);
% z=zeros(N,1);
% for kk = 1:N
%     %[x(kk) y(kk) z(kk)] = wgs842ecef(latrad(kk),lonrad(kk),0);
%     [x(kk) y(kk) z(kk)] = geodetic2ecef(latrad(kk),lonrad(kk),hei(kk),referenceEllipsoid('wgs84'));
% end
% 
% %% Transform 
% %index = 4;
% %meanlat = latrad(1);
% %meanlon = lonrad(1);
%  meanlat = 57.015179789287792*pi/1

%  meanlon = 9.985062449450744*pi/180;
% meanhei = hei(1);
% % [a b c]=wgs842ecef(meanlat,meanlon,meanhei);
% [a b c]=geodetic2ecef(meanlat,meanlon,meanhei,referenceEllipsoid('wgs84'));
% % plot3(a,b,c,'r*')
% R_e2t = [-sin(meanlat)*cos(meanlon) -sin(meanlat)*sin(meanlon) cos(meanlat);...
%     -sin(meanlon) cos(meanlon) 0;...
%     -cos(meanlat)*cos(meanlon) -cos(meanlat)*sin(meanlon) -sin(meanlat)];
% 
% T = zeros(3,N);
% for kk = 1:N
%     T(:,kk) = R_e2t*([x(kk);y(kk);z(kk)]-[a;b;c]);
% end
% T = T';
% 
% figure(1)
% % T(300:360,:) = 0
% plot(T(:,2),T(:,1))
% title('Raw GPS log (localframe)')

%% ADIS16405 Inertial Measurement Unit
supply = imudata(:,1)*0.002418; % Scale 2.418 mV
gyro = imudata(:,2:4)*0.05; % Scale 0.05 degrees/sec
accl = (imudata(:,5:7)*0.00333)*9.82;   %/333)*9.82; % Scale 3.33 mg (g is gravity, that is g-force)
magn = imudata(:,8:10)*0.0005; % 0.5 mgauss
temp = imudata(:,11)*0.14; % 0.14 degrees celcius 
aux_adc = imudata(:,12)*0.806; % 0.mV
imutime = imudata(:,13)-starttime; % Seconds since start, periodic timing determined by imu

% figure(2)
% subplot(4,1,1)
% plot(imutime, gyro)
% title('Gyrometer')
% ylabel('[degrees/sec]')
% legend('X','Y','Z')
% 
% subplot(4,1,2)
% plot(imutime, accl)
% title('Accelerometer')
% ylabel('[m/s^2]')
% 
% subplot(4,1,3)
% plot(imutime, magn)
% title('Magnetometer')
% ylabel('[gauss]')
% 
% subplot(4,1,4)
% plot(imutime, imudata(:,[1 11:12]))
% title('Supply, temperature and ADC of the ADIS16405 IMU')
% ylabel('[V, degC, V]')
% xlabel('Time [s]')
% legend('Supply','Temp','ADC')



%% Heading
% X_H = X*cos(pitch) + Y*sin(roll)*sin(pitch) - Z*cos(roll)*sin(pitch)
% Y_H = Y*cos(roll) + Z*sin(roll)
% Azimuth = atan2 (Y_H / X_H )

heading = atan2(-magn(:,2),magn(:,1))*180/pi;
% figure(3)
% % subplot(2,1,1)
% 
% % plot(imutime,smooth(heading,15, 'rloess'),'-')
% plot(imutime,heading,'-')
% title('Heading calculated with atan2, not corrected for pitch or roll')
% % subplot(2,1,1)
% plot(imutime,Azimuth)

figure(50)
bias = [0.2582 0.1225 -0.6860];
% bias = [(max(magn(:,1))-min(magn(:,1)))/2+min(magn(:,1)),...
%         (max(magn(:,2))-min(magn(:,2)))/2+min(magn(:,2)),...
%         (max(magn(:,3))-min(magn(:,3)))/2+min(magn(:,3))]
plot3(magn(:,1)-bias(1),magn(:,2)-bias(2),magn(:,3)-bias(3))
xlabel('x');ylabel('y');zlabel('z');
axis equal
grid on
% hold on
% plot3(bias(1), bias(2), bias(3),'r*')
% hold off

%% MEMSENS stuff
magnbias = [magn(:,1)-bias(1) magn(:,2)-bias(2) magn(:,3)-bias(3)];
imu2beh(gyro, accl/9.82, magnbias, length(gyro));
% imu2beh([gyro(:,1) -gyro(:,2) -gyro(:,3)], [accl(:,1) -accl(:,2) -accl(:,3)], [magn(:,1) -magn(:,2) -magn(:,3)], length(gyro));
beh = calc_beh_main('testfile.mat',false,true,true,false);

%% Animate heading
%     figure(42)
% 
% clf
% for ii = 1:length(heading)
%     figure(42)
%     polar([heading(ii)*pi/180,0],[2,0],'-')
%     title(num2str(imutime(ii,1)))
%     pause(0.03)
% end
% hold off

%% Echosounder data
echo.depth.value=NaN;
echo.depth.timestamp=NaN;
echo.temperature.value=NaN;
echo.temperature.timestamp=NaN;

ii=1;

filenotdone = 1;
while(filenotdone > 0)
    % scan single line into matrix
    [str, count] = fscanf(echofile, '%[^\n]', 1);
    % skip over \n
    [strnl, count] = fscanf(echofile, '%[\n]', 1);
    % make sure we stop the while when EOF
    if(count == 0)
        filenotdone = 0;
    end
    
    delim = findstr(',',str);
    % detph data
    if isempty(findstr(str,'$SDDPT,'))~=1
        ii=ii+1;
        s = sscanf(str(delim(1)+1:delim(2)-1), '%f');
        ss = sscanf(str(delim(3)+1:length(str)), '%f');
        if(s)
            echo.depth.value(ii) = s;
            echo.depth.timestamp(ii) = ss;
        else
            echo.depth.value(ii) = NaN;
            echo.depth.timestamp(ii) = NaN;
        end
    end
    
    % temperature data
    if isempty(findstr(str,'$SDMTW,'))~=1
        s = sscanf(str(delim(1)+1:delim(2)-1), '%f');
        ss = sscanf(str(delim(3)+1:length(str)), '%f');
        if(s)
            echo.temperature.value(ii) = s;
            echo.temperature.timestamp(ii) = ss;
        else
            echo.temperature.value(ii) = NaN;
            echo.temperature.timestamp(ii) = NaN;
        end
    end
    
end
figure(4)
plot(echo.depth.timestamp,echo.depth.value,echo.temperature.timestamp',echo.temperature.value)
xlabel('Timestamp [s]')
ylabel('Depth [m] / Temperature [degree C]')
legend('Depth','Temperature')


%% 
figure(100)
scale_imutime = 0.8305;
offset_imutime = 205;
zgyro = smooth(gyro(:,3),21);
hold on
plot(ctl{3}-starttime, ctl{2},'.-',...
     imutime*scale_imutime+offset_imutime,accl(:,1)*100,...
     imutime*scale_imutime+offset_imutime,accl(:,2)*100,...
     imutime*scale_imutime+offset_imutime,accl(:,3)*100,...
     (walltime-starttime)*scale_imutime+offset_imutime,nmeaspeed*100,'.-k',...
     imutime*scale_imutime+offset_imutime,headinf(beh.heading)*0.5,...
     imutime(1:length(imutime)-1)*scale_imutime+offset_imutime,diff(headinf(beh.heading))*50,'m',...
     imutime*scale_imutime+offset_imutime,zgyro*75)

plot((walltime(1057)-starttime)*scale_imutime+offset_imutime,nmeaspeed(1057)*100,'r*')

% plot(ctl{3}-starttime, ctl{2}, imutime*0.865,heading(:,1),'.-k')

legend('control inputs',...
      'accx', 'accy', 'accz',...
      'gps1 speed',...
      'heading', 'diffhead', 'zgyro')
%  ylim([-500 500])
diffad=annotate{1}(1)-starttime-1870;
annotatefill(annotate{1}-diffad-starttime,annotate{2}-diffad-starttime,annotate{3},-150,150)
hold off
xlabel('Time [s]')
ylabel('Control inputs, not sorted by MsgID [-]')

%%
% Plotting speeds from nmeaspeed
% Timediff from nmeasspeed to sample = 828
figure(150)
set(gcf,'Visible','off'); % Hides the matlab plot because it is ugly
set(gcf,'paperunits','centimeters')
set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure
% Determine X_u
m = 13;
surge1 = nmeaspeed(1881-828+2:1901-828+2)*0.5144;% knob til m/s, *0.5144
surge2 = nmeaspeed(1916-828+1:1933-828+1)*0.5144;% knob til m/s, *0.5144
surge3 = nmeaspeed(1961-828:1975-828)*0.5144;% knob til m/s, *0.5144
surge4 = nmeaspeed(2022-828-3:2035-828-3)*0.5144;% knob til m/s, *0.5144
surge5 = nmeaspeed(2112-828-5:2126-828-5)*0.5144;% knob til m/s, *0.5144
surge6 = nmeaspeed(2205-828-5:2212-828-5)*0.5144;% knob til m/s, *0.5144
hold on
grid on
x = 0:27;
plot(-3:(length(surge1)-4),surge1,'r');
plot(-3:(length(surge2)-4),surge2,'g');
plot(-3:(length(surge3)-4),surge3,'y');
plot(-3:(length(surge4)-4),surge4,'b');
plot(-3:(length(surge5)-4),surge5,'k');
plot(-3:(length(surge6)-4),surge6,'c');
k = 3.3*0.5144;
s = 0.22;
plot(x,k*exp(-s*x),'o-','LineWidth',linewidth)
D = s * m;
X_u = D
xlabel('Time [s]')
ylabel('Velocity [m/s]')
legend('Test 1', 'Test 2', 'Test 3', 'Test 4', 'Test 5', 'Test6', 'Regression')
%title('Surge tests')
text(25,0.4,{['k=' num2str(k)] ['s=' num2str(s)] ['X_u=' num2str(X_u)]})
hold off
saveas(figure(150),'surgecoeffs.pdf')

%% Determine Y_v, K_v and N_v. Denne er blevet rettet lidt i, men er ikke opdateret til rapport, da der er lidt tvivl om dens rigtighed.
z_g = 0.03;
x_g = 0.03;
figure(151)
clf;
set(gcf,'Visible','off'); % Hides the matlab plot because it is ugly
set(gcf,'paperunits','centimeters')
set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure
hold on
grid on
x = 0:5;
k = 0.1;
s = 1.5;
plot(x,k*exp(-s*x),'o-','LineWidth',linewidth)
Y_v = s * m
K_v = s * -m * z_g
N_v = s * m * x_g
xlabel('Time [s]')
ylabel('Velocity [m/s]')
legend('Estimate')
%title('Estimate of sway')
text(4,0.035,{['k=' num2str(k)] ['s=' num2str(s)] ['Y_v=' num2str(Y_v)] ['K_v=' num2str(K_v)] ['N_v=' num2str(N_v)]})
hold off
saveas(figure(151),'swaycoeffs.pdf')

%% Plotting data for Y_r, K_r and N_r, propellor
figure(152)
set(gcf,'Visible','off'); % Hides the matlab plot because it is ugly
set(gcf,'paperunits','centimeters')
set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure
k = 0.9;
s = 0.28;
k1 = -1.6;
s1 = 0.22;

% min(find(imutime*scale_imutime+offset_imutime>3278))
x1 = imutime(36763:36860)*scale_imutime+offset_imutime;
x2 = imutime(37236:37344)*scale_imutime+offset_imutime;
x3 = imutime(38248:38341)*scale_imutime+offset_imutime;
x4 = imutime(39237:39344)*scale_imutime+offset_imutime;
x5 = imutime(39898:40018)*scale_imutime+offset_imutime;
x6 = imutime(40480:40589)*scale_imutime+offset_imutime;
heading1 = headinf(beh.heading(36763:36861));
heading2 = headinf(beh.heading(37236:37345));
heading3 = headinf(beh.heading(38248:38342));
heading4 = headinf(beh.heading(39237:39345));
heading5 = headinf(beh.heading(39898:40019));
heading6 = headinf(beh.heading(40480:40590));

hold on
plot(x1-x1(1),diff(heading1),'y')
plot(x2-x2(1),diff(heading2),'g')
plot(x3-x3(1),diff(heading3),'k')
plot(x4-x4(1),diff(heading4),'c')
plot(x5-x5(1),diff(heading5),'m')
plot(x6-x6(1),diff(heading6)-0.5,'Color',[0.9 0.3 0.2])
plot(x6-x6(1),k*exp(-s*(x6-x6(1)))-0.18,'o-','LineWidth',linewidth)
plot(x6-x6(1),k1*exp(-s1*(x6-x6(1))),'o-','LineWidth',linewidth)

xlabel('Time [s]')
ylabel('Velocity [degree/s]')
legend('Test 1', 'Test 2', 'Test 3', 'Test 4', 'Test 5', 'Test6', 'Regression1', 'Regression2')
%title('Yaw, Propeller, cw and ccw')
text(10,-2,{['k=' num2str(k)] ['s=' num2str(s)] ['k1=' num2str(k1)] ['s1=' num2str(s1)]})

grid on
hold off

saveas(figure(152),'yawcoeffspropellor.pdf')

%% Plotting data for Y_r, K_r and N_r, bow thrusters
figure(153)
set(gcf,'Visible','off'); % Hides the matlab plot because it is ugly
set(gcf,'paperunits','centimeters')
set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure
k = 1.6;
s = 0.25;
k1 = -2;
s1 = 0.2;

% min(find(imutime*scale_imutime+offset_imutime>3278))
x1 = imutime(29087:29189)*scale_imutime+offset_imutime;
x2 = imutime(30283:30382)*scale_imutime+offset_imutime;
x3 = imutime(32127:32220)*scale_imutime+offset_imutime;
x4 = imutime(32537:32640)*scale_imutime+offset_imutime;
x5 = imutime(33271:33328)*scale_imutime+offset_imutime;

heading1 = headinf(beh.heading(29087:29190));
heading2 = headinf(beh.heading(30283:30383));
heading3 = headinf(beh.heading(32127:32221));
heading4 = headinf(beh.heading(32537:32641));
heading5 = headinf(beh.heading(33271:33329));

hold on
plot(x1-x1(1),diff(heading1),'y')
plot(x2-x2(1),diff(heading2)-0.5,'g')
plot(x3-x3(1),diff(heading3)-0.4,'k')
plot(x4-x4(1),diff(heading4),'c')
plot(x5-x5(1),diff(heading5)+0.2,'m')

plot(x5-x5(1),k*exp(-s*(x5-x5(1)))-0.18,'o-','LineWidth',linewidth)
plot(x5-x5(1),k1*exp(-s1*(x5-x5(1))),'o-','LineWidth',linewidth)

xlabel('Time [s]')
ylabel('Velocity [degree/s]')
legend('Test 1', 'Test 2', 'Test 3', 'Test 4', 'Test 5', 'Regression1', 'Regression2')
%title('Yaw, Bow thruster, cw and ccw')
text(7,-6,{['k=' num2str(k)] ['s=' num2str(s)] ['k1=' num2str(k1)] ['s1=' num2str(s1)]})

grid on
hold off

saveas(figure(153),'yawcoeffsbow.pdf')

%%
% Determine Y_r, K_r and N_r

% s will be the average from the fittings from bow and propellor due to
% they should be similar
m = 13; %[kg]
s = (0.25+0.2+0.28+0.22)/4;
Y_r = s * m * x_g
K_r = s * -I(3,1)
N_r = s * I(3,3)

%% Determine Y_p and N_p
figure(154)
set(gcf,'Visible','off'); % Hides the matlab plot because it is ugly
set(gcf,'paperunits','centimeters')
set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure
% From roll-regression
% y = k*exp(-s*t)*(-cos(omega*t))+h;
% Constants to fit
hold on
k = 20;
s = 0.007;
omega = 0.103;
h = 3;
m = 13; %[kg]

k1 = 20;
s1 = 0.0059;
omega1 = 0.103;
h1 = 2;
m = 13; %[kg]

k2 = 20;
s2 = (s+s1)/2;
omega2 = 0.103;
h2 = (h+h1)/2;
m = 13; %[kg]

t = 0:300;
I_zx = 0.0536;
I_x = 0.0654;
grid on
% plot(t,k.*exp(-s.*t).*(-cos(omega.*t))+h,'r',t,k1.*exp(-s1.*t).*(-cos(omega1.*t))+h1,'b',t,k2.*exp(-s2.*t).*(-cos(omega2.*t))+h2,'g')
plot(diff(k2.*exp(-s2.*t).*(-cos(omega2.*t))+h2),'r')
plot((k2.*s2.*exp(-s2.*t).*cos(omega2.*t)+k2.*exp(-s2.*t).*sin(omega2.*t).*omega2),'o-','LineWidth',linewidth)

xlabel('Time [samples]')
ylabel('Velocity [degree/s]')
legend('Velocity from regression of position', 'Regression of velocity')
%title('Roll velocity')
text(250,-1.25,{['k=' num2str(k2)] ['s=' num2str(s2)] ['omega=' num2str(omega2)]})

saveas(figure(154),'rollcoeffsvel.pdf')

Y_p = 2 * -m * z_g * s2
K_p = 2 * I(1,1) * s2
N_p = 2 * I(1,3) * s2
