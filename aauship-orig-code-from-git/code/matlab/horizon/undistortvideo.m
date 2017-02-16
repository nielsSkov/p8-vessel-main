%% Undistorts the videom from the gopro hero3
load('gopro-hero3-cameraParameters.mat')

vidin = vision.VideoFileReader('GOPR3942.MP4','VideoOutputDataType','uint8');
vidininfo = info(vidin);
vidout = vision.VideoFileWriter('corrected.avi');
vidout.VideoCompressor='MJPEG Compressor';
vidout.FrameRate = vidininfo.VideoFrameRate;
% count = 0
% tic
% while ~isDone(vidin)
% 
%       % Read a video frame and run the detector.
%       videoFrame = step(vidin);
%       count= count+1
% end
% toc
%%
close all
k = 1;
for k =1:100
% while ~isDone(vidin)
    % Next frame
    tic
    img = step(vidin);
    
    % Remove lens distortion
    J = undistortImage(img, cameraParameters);
    
    % Add some text ingo
    J = insertText(J,[10,10],sprintf('Frame: %d\nRate: %d fps',k,vidout.FrameRate),'FontSize',40);
    
    % Save undistorted frame
    step(vidout,J);
    fprintf('Frame number %d done\n',k)
%     k=k+1;
    toc
end
release(vidin);
release(vidout);