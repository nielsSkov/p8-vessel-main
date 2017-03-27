%% Tests
clear
kuka=RobotConnectorKUKA;
cam = webcam('Logitech');
%%
clear original blocks
original=snapshot(cam);
original=original(MyParameters.YMIN:MyParameters.YMAX,...
    MyParameters.XMIN:MyParameters.XMAX,:);
blocks=RecognizeBlocks(original);

x=blocks.blue(1,1);
y=blocks.blue(1,2);
angle=blocks.blue(1,3);
if (angle>0)
    angle=angle-45;
else
    angle=angle+45;
end
PickPlace([x,y,MyParameters.Z+20,angle,0,0],[50, 500, 5, 0, 0, 0],0.5,kuka)

clear original blocks
original=snapshot(cam);
original=original(MyParameters.YMIN:MyParameters.YMAX,...
    MyParameters.XMIN:MyParameters.XMAX,:);
blocks=RecognizeBlocks(original);

x=blocks.yellow(1,1);
y=blocks.yellow(1,2);
angle=blocks.yellow(1,3);
if (angle>0)
    angle=angle-45;
else
    angle=angle+45;
end
PickPlace([x,y,MyParameters.Z+20,angle,0,0],[50, 500, 24, 0, 0, 0],0.5,kuka)