% 
% Function: Main function that calls sub-functions to determine bank, elevation
% and heading.  Plots results.
%
% Parameters:
% fname: name of data file to process
% headingGT180: true if heading should be plotted in 0-360 range, false if 0 to
%               +/-180.
% hasCounterCol: true if a counter is present in the first column, else
%                false
% preSmooth: true if a smoother should be applied to sensor data, else
%            false
% postSmooth: true if a smoother should be applied to the calculated bank, 
%             elevation and pitch data, else false.
%
% Returns:
% A four element structure containing the elements bank, elevation and heading
% specified in degrees, and a version element (string), which indicates the 
% current version of this application.  Each element of bank, elevation and 
% heading is an array with a size equal to the number of rows in the original 
% data file.
%
function beh = calc_beh_main(fname, headingGT180, hasCounterCol, preSmooth, postSmooth)

    % Current version of distribution
    VERSION = '1.0.0';
    
    % Size of window to use in smoothing routines.
    % MATLab default is 5, but depending on amount of noise may need to be
    % adjusted higher.
    PRE_SMOOTH_WINDOW = 10; 
    POST_SMOOTH_WINDOW = 10;
    
    % if smoothers are not specified, assume false
    if nargin < 5, postSmooth = false;  end    % smooth sensor data
    if nargin < 4, preSmooth = false; end      % smooth processed data (b/e/h)
    
    % assume a counter colunm is not present unless
    % specified by the user.
    if nargin < 3
        hasCounterCol = false; 
    end
    
%     close all;
    data = load(fname);
    
    % Run a pre-smoothing routine on the raw data?
    if preSmooth
        
        % First column of data is typically counter - no need to smooth
        for i = 2:size(data, 2)
            data(:, i) = smooth(data(:, i), PRE_SMOOTH_WINDOW);
        end;
    end;

    % NOTE: column 1 contains counter data - ignore
    % Columns 2-4 Gyro, 5-7 Accel, 8-10 Mag
    if hasCounterCol
        accelIdx = 5;
    else
        accelIdx = 4;
    end
    magIdx = accelIdx + 3;
    data = data.output_args;
    ax = data(:, accelIdx);
    ay = data(:, accelIdx + 1);
    az = data(:, accelIdx + 2);   
    mx = data(:, magIdx);
    my = data(:, magIdx + 1);
    mz = data(:, magIdx + 2);
   
    be = calc_bankElevation(ax, ay, az);
    heading = calc_heading(be.bank, be.elevation, mx, my, mz, headingGT180, true);
    
    % convert data from radians to degrees
    bank = rad2deg(be.bank);
    elevation = rad2deg(be.elevation);
    heading = rad2deg(heading);
    
    % smooth processed data?
    if postSmooth
        bank = smooth(bank, POST_SMOOTH_WINDOW);
        elevation = smooth(elevation, POST_SMOOTH_WINDOW);
        heading = smooth(heading, POST_SMOOTH_WINDOW);
    end
    
    % plot raw accelerations
%     figure(32);
%     subplot(3, 1, 1);
%     plot(ax);
%     title('Ax');
%     ylabel('G');
%     subplot(3, 1, 2);
%     plot(ay);
%     title('Ay');
%     ylabel('G');
%     subplot(3, 1, 3);
%     plot(az);
%     title('Az');
%     ylabel('G');
    
    
    % plot R/P/Y
    figure(33);
    subplot(3, 1, 1);
    plot(bank);
    title('Bank (Roll)');
    ylabel('Angle(deg)');
    subplot(3, 1, 2);
    plot(elevation);
    title('Elevation (Pitch)');
    ylabel('Angle(deg)');
    subplot(3, 1, 3);
    plot(heading);
    title('Heading (Bank/Elevation Corrected)');
    ylabel('Heading(deg)');
% %     
%     figure;
%     for ii = 1:length(heading)
%         polar([heading(ii)*pi/180,0],[2,0],'-')
%         title(num2str(data(ii,1)))
%         pause(0.01)
%     end
%     
    % return a structure containing bank, elevation and heading
    beh.bank = bank;
    beh.elevation = elevation;
    beh.heading = heading;
    beh.version = VERSION;
end