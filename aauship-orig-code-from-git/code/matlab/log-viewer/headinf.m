function [ output_args ] = headinf( x )
%HEADINF Converts plus minus 180 degres to not be constrained
%   Detailed explanation goes here
    limit = 172;
    rev   = 0;
    output_args = zeros(length(x),1);
    for i = 1:length(x)-1
        output_args(i) = x(i)+rev;
        if (x(i) >= limit) && (x(i+1) <= -limit)
%             disp('up')
            rev = rev + 360;
        elseif (x(i) <= -limit) && (x(i+1) >= limit)
%             disp('down')
            rev = rev - 360;
        end
    end
    output_args(i+1) = x(i+1) + rev;
end
