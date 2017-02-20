% Create a cell array of file names of calibration images.
    for i = 1:6
        imageFileName = sprintf('%d.JPG', i);
        imageFileNames{i} = fullfile('img', imageFileName);
    end

% Detect calibration pattern.
    [imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);

% Generate world coordinates of the corners of the squares.
    squareSize = 34; % square size in millimeters
    worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Calibrate the camera.
    cameraParameters = estimateCameraParameters(imagePoints, worldPoints);

% Remove lens distortion and display results
    I = imread(fullfile('img', '5.JPG'));
    J = undistortImage(I, cameraParameters);

% Display original and corrected image.
    figure; imshowpair(I, J, 'montage');
    title('Original Image (left) vs. Corrected Image (right)');
    
%     save('gopro-hero3-cameraParameters.mat','cameraParameters')