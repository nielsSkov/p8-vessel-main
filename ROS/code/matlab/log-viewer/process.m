clear all
for fighandle = findobj('Type','figure')', clf(fighandle), end
% Stuff for handling figure output
set(gcf,'Visible','off'); % Hides the matlab plot because it is ugly
set(gcf,'paperunits','centimeters')
set(gcf,'papersize',[13,8]) % Desired outer dimensions of figure
set(gcf,'paperposition',[-0.5,0,14.5,8.4]) % Place plot on figure
% load inertia.mat
linewidth = 1;
%% Data files
% logpath = '~/aauship-formation/code/hli/ros/src/aauship/scripts/';
% testname = 'logs';
logpath = '/afs/ies.auc.dk/group/14gr1034/public_html/tests/';
% testname = 'magnetometertest-lab2';
% logpath = '/tmp/';
% testname = 'mb100walkingklingen';
% testname = 'gosejladsnaesten';
% testname = 'nightseatuning';
testname = 'jesperdag2';
% testname = 'mb100-static';
% testname = 'mb100walkingklingen';
% testname = 'nysoetur';
% testname = 'statictest-lab';

%% Data files
gps1file = fopen([logpath,testname,'/gps1.log']);
mb100file = fopen([logpath,testname,'/mb100.log']);
imudata = load([logpath,testname,'/imu.log']);
echofile = fopen([logpath,testname,'/echo.log']);
starttime = imudata(1,13); % Earliest timestamp
% annotatefile = fopen([logpath,testname,'/annotate1416836228.84.log'],'r');
% annotate = textscan(annotatefile, '%f%f%s', 'Delimiter', ';');
% ctlfile = fopen([logpath,testname,'/ctl.log'],'r');
% ctl = textscan(ctlfile, '%f%f%f', 'Delimiter', ',');
lliinput = load([logpath,testname,'/lli_input.csv']);
lliinput(:,1) = lliinput(:,1)/10e8; % Rewrite time unit
% lliinput(1,1), starttime

%% Reading GPS data
% This can parse the very old logs
% line = textscan(gps1file,'%f,%c,%f,%c,%f,%c,%f,%f'); %For old logs
% time = line{1};
% nmealat = line{3};
% latsign = line{4};
% nmealon = line{5};
% lonsign = line{6};
% nmeaspeed = line{7};
% walltime = line{8};

% This can parse the current logs, which uses the normal NMEA sentences
% line = textscan(gps1file,'%6c,%f,%c,%f,%c,%f,%c,%f,%f,%f,,,%4c,%f'); %For new log
% time = line{2};
% nmealat = line{4};
% latsign = line{5};
% nmealon = line{6};
% lonsign = line{7};
% nmeaspeed = line{8};
% nmea_track_angle = line{9};
% nmeadate = line{10};
% walltime = line{12};

% Below is the parsing for the MB100 log
% Examples of $PASHR,POS messages, first one is initial with no fox, second
% is missing altitude info and sugh, the last one is a good message.
% $PASHR,POS,,0,,,,,,,,,,,,,,,Hp23*1D,1416742042.04
% $PASHR,POS,0,6,122516.50,5700.8886914,N,00959.0944350,E,046.185,,,,,3.5,2.4,2.6,2.2,Hp23*16,1416745828.21
% $PASHR,POS,0,6,122516.55,5700.8896215,N,00959.0970895,E,046.847,,097.0,003.159,-000.194,3.5,2.4,2.6,2.2,Hp23*15,1416745828.27

fprintf('Parsing GPS log file...\n')
line = textscan(mb100file,'%s', 'Delimiter','\n');
datlen = length(line{1});
errorcount = 0;
tic
for k = 1:datlen
    b = strsplit(line{1}{k},',','CollapseDelimiters',false);
    if ( length(b) ~= 20 || isempty(b{7}) )
        fprintf('Bad line found, line was: %d\n', k)
        % disp(line{1}{k})
        errorcount = errorcount+1;        
    else
        posmode(k-errorcount,1) = str2double(b{3});
        satcount(k-errorcount,1) = str2double(b{4});
        nmealat(k-errorcount,1) = str2double(b{6});
        latsign(k-errorcount,1) = b{7};
        nmealon(k-errorcount,1) = str2double(b{8});
        lonsign(k-errorcount,1) = b{9};
        nmeaalt(k-errorcount,1) = str2double(b{10});
        nmeaspeed(k-errorcount,1) = str2double(b{13});
        nmea_track_angle(k-errorcount,1) = str2double(b{12});
        walltime(k-errorcount,1) = str2double(b{20});
    end

    if mod(k,1000) == 0
        fprintf('Parsed %d of %d lines of $PASHR\n', k, datlen)
    end
end
toc
fprintf('There was %d bad lines.\n', errorcount)


%% Converts the latitude an longitide to decimal coordinates
fprintf('Converting NMEA latitudes and longitudes...\n')
[pos] = nmea2decimal({nmealat,latsign,nmealon,lonsign});
lat = pos(1,:);
lon = pos(2,:);

figure(1)
clf
%plot(lon(1,161),lat(1,161),'*g')
plot(lon,lat,'.-r')
plot_google_map('maptype','satellite')
range = [48000:49000, 58000:58700, 22000:22700];
plot(lon(range), lat(range),'b.')
range = [48000:49100, 53000:54300];
plot(lon(range), lat(range),'g.')
title('WGS84')

%%
clc
llirange = [min(find(walltime(48000) < lliinput(:,1))) :2:...
            max(find(walltime(48000) < lliinput(:,1)))];
clear left
clear right
clear timel
clear timer
left = zeros(length(llirange),1);
right = zeros(length(llirange),1);
data = NaN(length(llirange),1);

mll = min(llirange)-1;
i = 0; j = 0; % Other input counter
m = 0; % Bad pair counter/jumper, used to remove loose samples
for k = llirange
    if (lliinput(k,3) == 3 && lliinput(k+1,3) == 5) % control-node
        disp('ctlnode')
        left(k-mll-i) = lliinput(k+1,4);
        timel(k-mll-i) = lliinput(k+1,1)/10e8;
        right(k-mll-j) = lliinput(k,4);
        timer(k-mll-j) = lliinput(k,1)/10e8;

        j = j+1;
        i = i+1;
        data(k-mll) = 1;
    elseif (lliinput(k,3) == 5 && lliinput(k+1,3) == 3) % joy-node
        disp('joynode')
        left(k-mll-i) = lliinput(k,4);     
        timel(k-mll-i) = lliinput(k,1)/10e8;
        right(k-mll-j) = lliinput(k+1,4);
        timer(k-mll-j) = lliinput(k+1,1)/10e8;

        j = j+1;
        i = i+1;
    end
end
% TODO, remove loose samples

left(k-mll-i:length(left)) = [];
timel(k-mll-i:length(timel)) = [];

right(k-mll-j:length(right)) = [];
timer(k-mll-j:length(timer)) = [];

data(k-mll-i:length(data)) = [];

figure(2)
clf
hold on
plot(timel,left,'b-')
plot(timer,right,'r-')
% plot(data,'g.')

legend('left','right')
hold off

length(right), length(left)



%% Tangent plance coordinates xyz (not verified)
fprintf('Calculating NED coordinates...\n')
latrad = lat*pi/180;
lonrad = lon*pi/180;
% hei = gpsdata(:,3);
N = length(lat);
hei=zeros(N,1);
x=zeros(N,1);
y=zeros(N,1);
z=zeros(N,1);
for kk = 1:N
    %[x(kk), y(kk), z(kk)] = wgs842ecef(latrad(kk),lonrad(kk),0);
    [x(kk), y(kk), z(kk)] = geodetic2ecef(latrad(kk),lonrad(kk),hei(kk),referenceEllipsoid('wgs84'));
end

%% Transform 
%index = 4;
%meanlat = latrad(1);
%meanlon = lonrad(1);
% meanlat = 57.015179789287792*pi/180;
% meanlon = 9.985062449450744*pi/180;
klingen = load('../../hli/ros/src/aauship/scripts/klingenberg.mat');
meanlat = klingen.rotlat;
meanlon = klingen.rotlon;
clear klingen
meanhei = 0;%hei(1);
% [a b c]=wgs842ecef(meanlat,meanlon,meanhei);
[a, b, c]=geodetic2ecef(meanlat,meanlon,meanhei,referenceEllipsoid('wgs84'));
% plot3(a,b,c,'r*')
R_e2t = [-sin(meanlat)*cos(meanlon) -sin(meanlat)*sin(meanlon) cos(meanlat);...
    -sin(meanlon) cos(meanlon) 0;...
    -cos(meanlat)*cos(meanlon) -cos(meanlat)*sin(meanlon) -sin(meanlat)];
T = zeros(3,N);
for kk = 1:N
    T(:,kk) = R_e2t*([x(kk);y(kk);z(kk)]-[a;b;c]);
end
T = T';

figure(1)
% T(300:360,:) = 0
plot(T(:,2),T(:,1))
title('Raw GPS log (localframe)')


%% This is supposed to plot the track on the google map also
figure(1)
track = load('../triangletrack.mat');
[tracklat,tracklon,trackh] = ned2geodetic(track.track(:,1), track.track(:,2),...
             zeros(length(track.track),1),...
             meanlat*180/pi, meanlon*180/pi, 0, referenceEllipsoid('wgs84'));
plot(tracklon, tracklat,'wo-')

%% ADIS16405 Inertial Measurement Unit
supply = imudata(:,1)*0.002418; % Scale 2.418 mV
gyro = imudata(:,2:4)*0.05; % Scale 0.05 degrees/sec
gyro(:,1) = gyro(:,1)-0.2888;
gyro(:,2) = gyro(:,2)-0.1282;
gyro(:,3) = gyro(:,3)-0.3322;
%+4.6 Gyroscope(:,2)+16.15 Gyroscope(:,3)+5.4
accl = (imudata(:,5:7)*0.00333)*9.82;   %/333)*9.82; % Scale 3.33 mg (g is gravity, that is g-force)
magn = imudata(:,8:10)*0.0005; % 0.5 mgauss
% magn(17,:) = [0 0 0];
% magn(196,:) = [0 0 0];
% magn(1400,:) = [0 0 0];
temp = imudata(:,11)*0.14; % 0.14 degrees celcius 
aux_adc = imudata(:,12)*0.806; % 0.mV
imutime = imudata(:,13)-starttime; % Seconds since start, periodic timing determined by imu

% Wild point detection
tst = 0;
for ll = 1:length(aux_adc)
    if ( (aux_adc(ll) > 3.1) || (aux_adc(ll) < 0) )
%         gyro(ll,:)
        gyro(ll,:) = [0 0 0];
        tst = tst +1 ;
    end
    
%     if ( (gyro(ll,1) > 10) || (gyro(ll,1) < -10) )
% %         gyro(ll,:)
%         gyro(ll,:) = [0 0 0];
%         tst = tst +1 ;
%     end
%     
%     if ( (gyro(ll,2) > 10) || (gyro(ll,2) < -10) )
% %         gyro(ll,:)
%         gyro(ll,:) = [0 0 0];
%         tst = tst +1 ;
%     end
%     
%     if ( (gyro(ll,3) > 10) || (gyro(ll,3) < -10) )
% %         gyro(ll,:)
%         gyro(ll,:) = [0 0 0];
%         tst = tst +1 ;
%     end
end


%
figure(2)
clf
% subplot(4,1,1)
plot(imutime, gyro, '-', imutime, aux_adc, '.-')
title('Gyrometer')
ylabel('[degrees/sec]')
legend('X','Y','Z') 

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
%%
% bias = [0.2582 0.1225 -0.6860];
% bias = [0 0 0];
%bias = [0.28 0.15 -0.18]; % magnetometertest-lab6, on office chair
bias =  [0.29, 0.15, -0.15]; % bias on nysoetest
% bias = [0 0 0]; % kalmantest, parkeringsplads
% bias = [(max(magn(:,1))-min(magn(:,1)))/2+min(magn(:,1)),...
%         (max(magn(:,2))-min(magn(:,2)))/2+min(magn(:,2)),...
%         (max(magn(:,3))-min(magn(:,3)))/2+min(magn(:,3))]
% figure(50)
% plot3(magn(:,1)-bias(1),magn(:,2)-bias(2),magn(:,3)-bias(3))
% xlabel('x');ylabel('y');zlabel('z');
% axis equal
% grid on

% The equation of the circle, used for bound of ball to determine the
% magnetometer bias.
xcb = 0; ycb = 0; zcb = 0; r = 0.5;
xc = xcb-r:0.01:xcb+r;
yc = ycb - real(sqrt((r^2 - xc.^2 + 2 * xcb .* xc - xcb.^2)));

figure(51)
subplot(311)
plot(magn(:,1)-bias(1),magn(:,2)-bias(2),xc,yc,xc,-yc+2*ycb,xcb,ycb,'r*')
xlabel('x')
ylabel('y')
axis equal
grid on
title('Bias verification, xy-plane')
subplot(312)
plot(magn(:,1)-bias(1),magn(:,3)-bias(3),xc,yc,xc,-yc+2*ycb,xcb,ycb,'r*')
xlabel('x')
ylabel('z')
axis equal
grid on
title('Bias verification, xz-plane')
subplot(313)
plot(magn(:,2)-bias(2),magn(:,3)-bias(3),xc,yc,xc,-yc+2*ycb,xcb,ycb,'r*')
xlabel('y')
ylabel('z')
axis equal
grid on
title('Bias verification, yz-plane')

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
fprintf('Parsing echosounder data...\n')
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
% figure(4)
% plot(echo.depth.timestamp,echo.depth.value,echo.temperature.timestamp',echo.temperature.value)
% xlabel('Timestamp [s]')
% ylabel('Depth [m] / Temperature [degree C]')
% legend('Depth','Temperature')

%% Plot headings to compare with the GPS data
addpath('../x-io')
addpath('../x-io/quaternion_library')
AHRS = MahonyAHRS('SamplePeriod', 1/10, 'Kp', 8.8 , 'Ki', 0.5);
N = length(gyro);
for n = 1:N;
AHRS.Update(gyro(n,:) * (pi/180), accl(n,:), magn(n,:));	% gyroscope units must be radians
quaternion(n,:) = AHRS.Quaternion;
end
euler = quatern2euler(quaternConj(quaternion)) * (180/pi);	% use conjugate for sensor frame relative to Earth and convert to degrees.

figure('Name', 'Euler Angles');
plot(1:N, euler(:,1), '.r', 1:N, euler(:,2), '.g', 1:N, -euler(:,3), '.b'); % Ikke overbevist om at yaw skal være minus
title('Euler angles');
xlabel('Samples');
ylabel('Angle (deg)');
legend('phi', 'theta', 'psi');

%% Save workspace data to mat file
save('processdotm.mat')


