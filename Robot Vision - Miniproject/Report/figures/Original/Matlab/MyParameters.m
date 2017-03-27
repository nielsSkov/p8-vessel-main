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
        COLOR_THRESHOLD=0.2;       % Threshold in saturation to find color blocks
        YELLOW=0.12;                % Hue for yellow
        ORANGE=0.05;                % Hue for orange
        BLUE=0.61;                  % Hue for blue
        GREEN=0.44;                 % Hue for green
        AREA_MIN=250;               % Min area to consider the found object a brick
        MASK_SIDE=5;                % Mask side length to be used to find the color
        XMIN=46;
        XMAX=433;
        YMIN=46;
        YMAX=433;
        H=[   -0.0086   -1.0150  296.0846
            -1.0165    0.0028  340.7488
            -0.0000    0.0001    1.0000];
    end
end