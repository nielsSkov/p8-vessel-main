classdef MyParameters
    properties (Constant = true)
        % Robot parameters
        KUKA=RobotConnectorKUKA;
        OFFSETX=411.69;
        OFFSETXY=-285.27;
        OFFSETXZ=342.19;
        OFFSETXA=0;
        OFFSETXB=0;
        OFFSETXC=180;
        HEIGHT=50;
        HOMEX=50;
        HOMEY=450;
        HOMEZ=50;
        Z=0;
        Z1=5;
        Z2=25;
        Z3=35;
        % Vision parameters
        BLACK_THRESHOLD=0.2;        % Threshold in value to find black blocks
        COLOR_THRESHOLD=0.43;       % Threshold in saturation to find color blocks
        YELLOW=0.12;                % Hue for yellow
        ORANGE=0.05;                % Hue for orange
        BLUE=0.61;                  % Hue for blue
        GREEN=0.22;                 % Hue for green
        AREA_MIN=250;               % Min area to consider the found object a brick
        MASK_SIDE=5;                % Mask side length to be used to find the color
    end
end