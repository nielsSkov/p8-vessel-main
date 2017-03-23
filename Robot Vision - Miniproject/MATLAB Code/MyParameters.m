classdef MyParameters
    properties (Constant = true)
        % Robot parameters
        OFFSETX=411.69;
        OFFSETY=-285.27;
        OFFSETZ=340.12;
        OFFSETA=0;
        OFFSETB=0;
        OFFSETC=180;
        HEIGHT=100;
        HOMEX=50;
        HOMEY=500;
        HOMEZ=200;
        Z=5;
        Z1=6;
        Z2=23;
        Z3=42;
        % Vision parameters
        BLACK_THRESHOLD=0.2;        % Threshold in value to find black blocks
        COLOR_THRESHOLD=0.43;       % Threshold in saturation to find color blocks
        YELLOW=0.12;                % Hue for yellow
        ORANGE=0.05;                % Hue for orange
        BLUE=0.61;                  % Hue for blue
        GREEN=0.44;                 % Hue for green
        AREA_MIN=250;               % Min area to consider the found object a brick
        MASK_SIDE=5;                % Mask side length to be used to find the color
        XMIN=126;
        XMAX=513;
        YMIN=108;
        YMAX=468;
        K=[   -0.0128   -1.0079  298.1341
            -1.0376    0.0344  337.8621
            -0.0000    0.0002    1.0000];
    end
end