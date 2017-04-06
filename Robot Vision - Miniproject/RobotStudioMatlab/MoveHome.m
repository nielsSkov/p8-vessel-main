function MoveHome(robot)
%MoveHome(kuka)
% Moves robot arm to home position defined in MyParameters.m

x=MyParameters.HOMEX+MyParameters.OFFSETX;
y=MyParameters.HOMEY+MyParameters.OFFSETY;
z=MyParameters.HOMEZ+MyParameters.OFFSETZ;
robot.moveLinear(x,y,z,0,0,-1,0,'v500');
end