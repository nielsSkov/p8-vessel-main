classdef MyParameters
    properties (Constant = true)
        % Robot parameters
        OFFSETX=411.69;
        OFFSETY=-285.27;
        OFFSETZ=340.12;
        OFFSETA=0;
        OFFSETB=0;
        OFFSETC=180;
        HEIGHT=50;
        HOMEX=50;
        HOMEY=500;
        HOMEZ=200;
        Z=20;
        Z1=5;
        Z2=23;
        Z3=41;
        % Vision parameters
        BLACK_THRESHOLD=0.2;        % Threshold in value to find black blocks
        COLOR_THRESHOLD=0.43;       % Threshold in saturation to find color blocks
        YELLOW=0.12;                % Hue for yellow
        ORANGE=0.05;                % Hue for orange
        BLUE=0.61;                  % Hue for blue
        GREEN=0.44;                 % Hue for green
        AREA_MIN=250;               % Min area to consider the found object a brick
        MASK_SIDE=5;                % Mask side length to be used to find the color
        XMIN=1;
        XMAX=538;
        YMIN=44;
        YMAX=410;
        K=[   -0.0130   -1.0136  296.4194;
            -1.0011   -0.0038  482.2257;
            0.0000   -0.0001    1.0000];
    end
end