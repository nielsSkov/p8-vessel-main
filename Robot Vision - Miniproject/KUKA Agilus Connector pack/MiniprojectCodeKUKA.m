%% Miniproject Code KUKA

kuka=RobotConnectorKUKA;

offsetX=411.69;
offsetY=-285.27;
offsetZ=342.19;
offsetC=180;

homex=50;
homey=450;
homez=50;
%%
%robotClearBuf(kuka)

%A=getPosition(kuka)

%robotClearBuf(kuka)

%getJoint(kuka)
%openGrapper(kuka)
positionX=homex;
positionY=homey;
positionZ=50;
orientationA=0;
orientationB=0;
orientationC=0;

positionX=positionX+offsetX;
positionY=positionY+offsetY;
positionZ=positionZ+offsetZ;

orientationC=orientationC+offsetC;

moveLinear(kuka,positionX,positionY,positionZ,orientationA,orientationB,orientationC,0.2)