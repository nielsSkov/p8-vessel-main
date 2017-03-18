function PickPlace(initial_pose,final_pose,vel)
% This function grabs a piece located at initial_pose and takes it to
% final_pose. It first reaches the initial_pose at some height and the it
% goes down and grabs the brick. After it goes up again and repeats the
% same procedure to place the brick in the final_pose to finally go up. The
% velocity of the movements is defined by vel.

% Extract initial_pose
x=initial_pose(1)+MyParameters.OFFSETX;
y=initial_pose(2)+MyParameters.OFFSETY;
z=initial_pose(3)+MyParameters.OFFSETZ;
a=initial_pose(4)+MyParameters.OFFSETA;
b=initial_pose(5)+MyParameters.OFFSETB;
c=initial_pose(6)+MyParameters.OFFSETC;

% Move to the pose with some heigth, go down, grab the brick and go up
% again
moveLinear(MyParameters.KUKA,x,y,z+MyParameters.HEIGHT,a,b,c,vel)
moveLinear(MyParameters.KUKA,x,y,z,a,b,c,vel)
closeGrapper(MyParameters.KUKA)
moveLinear(MyParameters.KUKA,x,y,z+MyParameters.HEIGHT,a,b,c,vel)

% Extract final_pose
x=final_pose(1)+MyParameters.OFFSETX;
y=final_pose(2)+MyParameters.OFFSETY;
z=final_pose(3)+MyParameters.OFFSETZ;
a=final_pose(4)+MyParameters.OFFSETA;
b=final_pose(5)+MyParameters.OFFSETB;
c=final_pose(6)+MyParameters.OFFSETC;

% Move to the pose with some heigth, go down, release the brick and go up
% again
moveLinear(MyParameters.KUKA,x,y,z+MyParameters.HEIGHT,a,b,c,vel)
moveLinear(MyParameters.KUKA,x,y,z,a,b,c,vel)
openGrapper(MyParameters.KUKA)
moveLinear(MyParameters.KUKA,x,y,z+MyParameters.HEIGHT,a,b,c,vel)
end

