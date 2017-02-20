function [ output_args ] = ship( x, y, psi, color)
%SHIP Ship graphic object
%   Required arguments
%   x   = x coordinate
%   y   = y coordinate
%   psi = heading in radians
%   Optional arguments are, skips, color, and shape.

    if (length(x)~=length(y) || length(y)~=length(psi) )
        error('The coordinate vectors and or heading vector is not of equal length')
        return
    end
    
    % Shape definitions
    % Arrow shape
%     X = [-0.3 0 -0.3 0.97-0.3];
%     Y = [0.38/2 0 -0.38/2 0];
    % Tanker shape
%     X = [-5 -4.5 3 5 3 -4.5 -5];
%     Y = [1 1.1 1.1 0 -1.1 -1.1 -1];
    % AAUSHIP
    X = [-1.12/2 0.32 1.12/2 0.32 -1.12/2];
    Y = [0.15 0.15 0 -0.15 -0.15];

    psi = psi ;
    % Transform stuff and plot them
    for dd = 1:length(x)
        % Rotate
        R = [cos(psi(dd)) -sin(psi(dd)); sin(psi(dd)) cos(psi(dd))]; % CCW rotation
        P = [X;Y];
        P = R*P;
        % Translate
        for kk = 1:length(P)
            P(1,kk) = P(1,kk)+x(dd);
            P(2,kk) = P(2,kk)+y(dd);
        end
        hold on
        fill(P(1,:),P(2,:),color);
        plot(x,y,'k+');
        hold off
    end
  
    axis equal
    
end

