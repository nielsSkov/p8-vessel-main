classdef MyParameters
    properties (Constant = true)
        % Robot parameters
        OFFSETX=292;
        OFFSETY=-424.89;
        OFFSETZ=545;
        HEIGHT=100;
        HOMEX=100;
        HOMEY=600;
        HOMEZ=200;
        Z=5;
        Z1=5;
        Z2=24;
        Z3=43;
        % Vision parameters
        BLACK_THRESHOLD=0.2;        % Threshold in value to find black blocks
        COLOR_THRESHOLD=0.43;       % Threshold in saturation to find color blocks
        YELLOW=0.12;                % Hue for yellow
        ORANGE=0.05;                % Hue for orange
        BLUE=0.61;                  % Hue for blue
        GREEN=0.44;                 % Hue for green
        AREA_MIN=250;               % Min area to consider the found object a brick
        MASK_SIDE=5;                % Mask side length to be used to find the color
        XMIN=152;
        XMAX=718;
        YMIN=148;
        YMAX=652;
        K=[ -0.0228   -0.5874  309.9805;
            -0.6192    0.0108  345.7641;
            -0.0002    0.0000    1.0000];
    end
end