function MoveHome(kuka)
%MoveHome(kuka)
% Moves robot arm to home position defined in MyParameters.m

x=MyParameters.HOMEX+MyParameters.OFFSETX;
y=MyParameters.HOMEY+MyParameters.OFFSETY;
z=MyParameters.HOMEZ+MyParameters.OFFSETZ;
a=MyParameters.OFFSETA;
b=MyParameters.OFFSETB;
c=MyParameters.OFFSETC;
moveLinear(kuka,x,y,z,a,b,c,0.3)
end