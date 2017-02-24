% 
% Function: Calcualates bank angle and elevation from accelerometer data.
%
% Parameters:
% ax: array of accelerometer x-axis data
% ay: array of accelerometer y-axis data
% az: array of accelerometer z-axis data
%
% Returns:
% A two element structure containing the elements bank, elevation 
% specified in degrees.  Each element is an array with a size equal 
% to the number of rows in the original accel data array.
%
function be = calc_bankElevation(ax, ay, az)
   
    % Note: tilt method taken from Kionix.  See following paper for
    % details: http://kionix.com/sensors/application-notes.html, 
    % document AN005.
    %
    x2 = ax.^2;
    y2 = ay.^2;
    z2 = az.^2;
    sxz = sqrt(x2 + z2);
    syz = sqrt(y2 + z2);
        
    bank = atan2(ay, sxz);  % -90 <= bank <= 90
	
    % Note that the elevation is negated so that 'nose-up' is recorded as a
    % positive elevation.  You can see this is required if you look at the
    % sign of the accelerometer values when rotation occurs; X goes
    % negative immediately upon a nose-up attitude, and Z goes positive.
    % atan2 looks at signs to determine quadrant, and negative X/
    % positive Z is interpreted as quadrant 4 (nose down).
    elevation = -atan2(ax, syz); % -90 <= elevation <= 90
    
    % return values in array form
    %be = [bank, elevation];
    be.bank = bank;
    be.elevation = elevation;
end