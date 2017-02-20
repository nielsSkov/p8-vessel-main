function [ output_args ] = nmea2decimal( data )
%% Converts NMEA positions to decimal positions
% Degree minute to decimal degree
% 
% Degree minute format:
% Latitude:   ddmm.mmmm
% Longitude:  dddmm.mmmm
% Decimal format:
% Latitude:   dd.ddddddddd
% Longitude:  dd.ddddddddd

% lat=[5700.8842977:1:5702.8842977]'
% latsign=['N';'N';'N']
% lon=[00959.1547838:1:00961.1547838]'
% lonsign=['E';'E';'E']
% data= {lat,latsign,lon,lonsign}
% data = {5700.8842977,'N',00959.1547838,'E';5700.8842977,'N',00959.1547838,'E';5700.8842977,'N',00959.1547838,'E'};
% data = {5700.8842977;'N';00959.1547838;'E',5700.8842977;'N';00959.1547838;'E',5700.8842977;'N';00959.1547838;'E'};
% data = [data;data;data];

if data{2} == 'S'
    data{1} = data{1} * (-1);
end
if data{4} == 'W'
    data{3} = data{3} * (-1);
end
pos = [[data{:,1}]';[data{:,3}]'];
majorangle = floor(pos/100);
minorangle =  (pos - majorangle*100)/60;
angle = majorangle + minorangle;
% fprintf('N%.9f E%.9f\n',[abs(angle(1,:))',abs(angle(2,:))']')

output_args = [angle(1,:);angle(2,:)];
end