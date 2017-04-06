function PickPlace(initial_pose,final_pose,vel,robot)
% This function grabs a piece located at initial_pose and takes it to
% final_pose. It first reaches the initial_pose at some height and the it
% goes down and grabs the brick. After it goes up again and repeats the
% same procedure to place the brick in the final_pose to finally go up. The
% velocity of the movements is defined by vel.

% Extract initial_pose
x=initial_pose(1)+MyParameters.OFFSETX;
y=initial_pose(2)+MyParameters.OFFSETY;
z=initial_pose(3)+MyParameters.OFFSETZ;
angle=deg2rad(initial_pose(4));
quaternion=eul2quat([angle pi 0]);

% Move to the pose with some heigth, go down, grab the brick and go up
% again
robot.moveLinear(x,y,z+MyParameters.HEIGHT,quaternion(1),quaternion(2),quaternion(3),quaternion(4),vel)
robot.moveLinear(x,y,z,quaternion(1),quaternion(2),quaternion(3),quaternion(4),vel)
robot.gripperOn
robot.moveLinear(x,y,z+MyParameters.HEIGHT,quaternion(1),quaternion(2),quaternion(3),quaternion(4),vel)

% Extract final_pose
x=final_pose(1)+MyParameters.OFFSETX;
y=final_pose(2)+MyParameters.OFFSETY;
z=final_pose(3)+MyParameters.OFFSETZ;
angle=deg2rad(final_pose(4));
quaternion=eul2quat([angle pi 0]);
% Move to the pose with some heigth, go down, release the brick and go up
% again
robot.moveLinear(x,y,z+MyParameters.HEIGHT,quaternion(1),quaternion(2),quaternion(3),quaternion(4),vel)
robot.moveLinear(x,y,z,quaternion(1),quaternion(2),quaternion(3),quaternion(4),vel)
robot.gripperOff
robot.moveLinear(x,y,z+MyParameters.HEIGHT,quaternion(1),quaternion(2),quaternion(3),quaternion(4),vel)
end

