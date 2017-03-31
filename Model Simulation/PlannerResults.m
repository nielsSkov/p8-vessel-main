%% Script to check the performance of the trajectory following.
%run ControllerLQR.m
sim PathFollowingModel.slx

plot(xn_3DOF.Data,yn_3DOF.Data,'-r')
hold on 
plot(wps(:,1),wps(:,2),'--xk');

FigureLatex('Performance of the Path Follower Algorithm','Position in $x_\mathrm{n}$ axis [m]',...
    'Position in $y_\mathrm{n}$ axis [m]',1,{'Vessel Position','Path'},0,0,12,13,1.2)

% 
%xlim([-150 200])
%ylim([-20 300])

%circle_x=linspace(-100-AcceptRadius,-100+AcceptRadius,100);
%circle_y=sqrt(AcceptRadius^2-(circle_x-(-100)).^2)+20;
%circley2=-sqrt(AcceptRadius^2-(circle_x-(-100)).^2)+20;
%plot(circle_x,circle_y);
%plot(circle_x,circley2);