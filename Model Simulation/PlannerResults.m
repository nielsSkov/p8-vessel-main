%% Diagnosis script

plot(xn_3DOF.Data,yn_3DOF.Data,'--r','LineWidth',2)
hold on 
plot(wps(:,1),wps(:,2),'-ok');

xlim([-150 200])
ylim([-20 300])

circle_x=linspace(-100-30,-100+30,100);
circle_y=sqrt(30^2-(circle_x-(-100)).^2)+20;
circley2=-sqrt(30^2-(circle_x-(-100)).^2)+20;
plot(circle_x,circle_y);
plot(circle_x,circley2);