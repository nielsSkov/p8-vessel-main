timedifffile = fopen('~/logs/listener.log','r');
timediff = textscan(timedifffile, '%f%f', 'Delimiter', ';');
daydiff = timediff{2}(1)-timediff{1}(1);
shiptime = timediff{1}-timediff{1}(1);
grstime  = timediff{2}-timediff{2}(1)-daydiff;


plot(diff(grstime-shiptime),'.-')

% plot(1:length(grstime)-1,diff(grstime), 1:length(shiptime)-1,diff(shiptime),'.-')
legend('GRS','SHIP')