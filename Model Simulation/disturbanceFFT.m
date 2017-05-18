%%

clc
clear all
close all

%%

data = csvread('/Users/himalkooverjee/Documents/AAU/CA8/Project/p8-vessel-main/aauship_832_ws/src/2017-05-04_still_test_imu.csv',1);

x_accel = data(2:end,6);
y_accel = data(2:end,7);
time = data(2:end,1) - data(2,1);
time = time/1e9;

plot(x_accel(1:end));

%%
xdft = fft(x_accel(1:1800));

DT = 0.1;
% sampling frequency
Fs = 1/DT;
DF = Fs/size(x_accel(1:1800),1);
freq = 0:DF:Fs/2;
xdft = xdft(1:length(xdft)/2+1);
plot(freq(2:end),abs(xdft(2:end)))

%plot(time,x_accel);

%%

xdft = fft(x_accel(1:1800));
L = 1800;
Fs = 1/0.1;

P2 = abs(xdft);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
plot(f,P1) 

FigureLatex('Single-Sided Amplitude Spectrum of $x_\mathrm{acc}$',...
    'Frequency of $x_\mathrm{acc}$ [Hz]', 'Amplitude of $x_\mathrm{acc}$',0,0,0,[0;5],[0;1],12,13,1.2);

saveas(gca,'test.pdf');
system('pdfcrop test.pdf test.pdf');