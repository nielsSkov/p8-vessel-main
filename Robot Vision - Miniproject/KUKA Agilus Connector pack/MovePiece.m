function MovePiece(piece_pose,final_pose,order)
% This function grabs a piece located at piece_pose and takes it to
% final_pose. The order indicates if it is the first, second or third 
% piece of the Simpson figure
run Parameters.m
x=piece_pose(1)+offsetX;
y=piece_pose(1)+offsetY;
z=piece_pose(1)+offsetZ;
a=piece_pose(1)+offsetA;
b=piece_pose(1)+offsetB;
c=piece_pose(1)+offsetC;

moveLinear(kuka,x,y,z,

end

