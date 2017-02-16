% 
% Function: Calcualates heading from magnetometer data.  Applies correction
% based on bank/elevation data.
%
% Parameters:
% bank: array of bank angles in radians
% elevation: array of elevation angles in radians
% mx: array of magnetometer x-axis data in gauss
% my: array of magnetometer y-axis data in gauss
% mz: array of magnetometer z-axis data in gauss
% headingGT180: true if heading should be in the range 0 to +/-180, else
%               false if in range 0-360.
%               Default: false
% plotMagnetics: true if magnetics should be plotted, else false
%               Default: false
%
% Returns:
% A three element structure containing the elements bank, elevation and
% heading, specified in degrees.  Each element is an array with a size 
% equal to the number of rows in the original data file.
%
function res = calc_heading(bank, elevation, mx, my, mz, headingGT180, plotMagnetics)
      
    
    % Initial concept based on heading paper from Honeywell.  See:
    % http://www.honeywell.com/sites/servlet/com.merx.npoint.servlets.DocumentServlet?docid=D84A3A7BE-2A47-A0C3-F3BF-E2F7768BD449
    %
    % Essentially, taking out the bank/elevation rotations, then calculating x and y components.
    %
    % NOTE: expecting bank and elevation to be specified in radians ***NOT DEGREES***
    %
    xh = mx .* cos(-elevation) + ...
         my .* sin(-bank) .* sin(-elevation) - ...
         mz .* cos(-bank) .* sin(-elevation);
         
    yh = my .* cos(-bank) + mz .* sin(-bank);
        
    % NOTE: will always result in +/-180 unless modified by next block.
    % Also, heading is negated so the results adhere to right-hand-rule 
    % conventions.
    heading = -atan2(yh, xh);
    
    % determine default parameter values.
    if nargin < 7, plotMagnetics = false; end;
    if nargin < 6, headingGT180 = false; end;
   
    % Determine if heading results should be in the form 0-360.  
    % This block can be effective when 'wraparound' at +/-180 is present.
    if headingGT180
        for i = 1:length(heading)
            if heading(i) < 0 
                heading(i) = 2 * pi + heading(i);
            end;
        end;
    end;
        
    % Map out raw and uncorrected magnetic components
    if plotMagnetics
        
        % plot raw mag values
        figure(31);
        subplot(2, 1, 1);
        plot(mx);
        hold;
        plot(my, 'g');
        plot(mz, 'r');
        ylabel('Gauss');
        title('Magnetic Components');
        legend('Mx', 'My', 'Mz');
        
        % plot out heading based on uncorrected mag data
        subplot(2, 1, 2);
        heading_raw = -atan2(my, mx);
        
        if headingGT180
            for i = 1:length(heading_raw)
                if heading_raw(i) < 0 
                    heading_raw(i) = 2 * pi + heading_raw(i);
                end;
            end;
        end;
        
        heading_raw = rad2deg(heading_raw);
        plot(heading_raw);
        min(heading_raw);
        max(heading_raw);
        title('Uncorrected Heading');
        ylabel('Heading(deg)');
    end;
    
    % return results
    res = heading;
end