% MLB automatic annotation project
% Scene cut detection and segmentation
% Based on frame correlation
% Yuanyi Xue @ NYU-Poly

% This script uses a heuristic to detect the scene cut and outputs the frame
% number of each scene segment; the heuristic examines the 1-step frame
% difference of the video, and flags a scene cut whenever the average frame
% difference of the past frames is significant different from the current
% frame difference.

% Tunnable parameters:
% 1) lookbackLen: determine the length of the frames for calculating the
% average frame difference, this also assumes the minimal scene cut, default=15;
% 2) diffRatio: determine the deviation of the frame difference for
% labeling as a scene cut, default=5;
% 3) ROIspatial: 4x1 vector, determine the start and end spatial indices [dim1start dim1end dim2start dim2end];
% 4) ROItemporal: 2x1 vector, determine the start and end frame number.

clear all
%% Pre-ambles - Video read-in and frame difference calculation
VidPath = '../videos/mlbpb_23570674_600K.mp4';
VidObj = VideoReader(VidPath); % source video object

% Video stats
numFrm = VidObj.NumberOfFrames;
height = VidObj.Height;
width = VidObj.Width;

% Tunnable parameters
lookbackLen = 5;
offset = 10;
diffRatio = 10;
diffRatioDiff = 10;
ROIspatial = [1 height-66 1 width];
ROItemporal = [4130 88777];
fDiff = zeros(ROItemporal(2)-ROItemporal(1),1);
halfROIh = round(ROIspatial(2)/2);
halfROIw = round(ROIspatial(4)/2);

%% 1 - Calculating the frame difference
% matlabpool open
Delay = 30;
for idx = ROItemporal(1)+1:ROItemporal(2),
    colorFrm = read(VidObj,idx-Delay);
    prevFrm = double(colorFrm(:,:,2));
    prevFrmGray = double(rgb2gray(colorFrm));
    colorFrm = read(VidObj,idx);
    currFrm = double(colorFrm(:,:,2));
    currFrmGray = double(rgb2gray(colorFrm));
%     prevFrm = double(rgb2gray(read(VidObj,idx-1)));
%     currFrm = double(rgb2gray(read(VidObj,idx)));
    % Only consider the spatial ROI
    prevFrm = prevFrm(ROIspatial(1):ROIspatial(2),ROIspatial(3):ROIspatial(4));
    currFrm = currFrm(ROIspatial(1):ROIspatial(2),ROIspatial(3):ROIspatial(4));
    % 1-step F-diff for four quadrants
    fDiff(idx-ROItemporal(1)) = mean((currFrm(:) - prevFrm(:)).^2);
    % 2D cross correlation
    currFrmRes = imresize(currFrm,0.5,'nearest');
    prevFrmRes = imresize(prevFrm,0.5,'nearest');
    Cross = (currFrmRes-mean2(currFrmRes)).*(prevFrmRes-mean2(prevFrmRes));
    fCrossDelayed(idx-ROItemporal(1)) = sum(Cross(:));
    disp(['Processed ' num2str(idx-ROItemporal(1)) ' frame']);
end
% matlabpool close
%% 2 - Check scene cut
load frameCrossVal.mat
load frameCrossValDelayed.mat
fCrossDiff = fCross(2:end) - fCross(1:end-1);
fDiffDiff = abs(fDiff(2:end) - fDiff(1:end-1));
fCrossDiffThr = -7*1e6;
fCrossDiffThr2 = -2.5*1e6;
fDiffDiffThr = 500;
scLabel = zeros(size(fDiff,1),1);
scFlag = 0;
idx = lookbackLen+offset+1;
while idx <= length(scLabel),
    if ~scFlag,
%         fCrossDiffThr = mean(fCrossDiff(idx-15:idx-1));
%         fDiffDiffThr = mean(fDiffDiff(idx-15:idx-1));
        if fCrossDiff(idx) <= fCrossDiffThr,
            scFlag = 1;
            scLabel(idx) = 1;
        elseif fCrossDiff(idx) <= fCrossDiffThr2 && ...
                fDiffDiff(idx) >= fDiffDiffThr,
            scFlag = 1;
            scLabel(idx) = 1;
        end
        idx = idx + 1;
    else
        % For every newly detected scene cut, assume the next scene cut is
        % at least $lookbacklen away.
        idx = idx + lookbackLen + offset;
        scFlag = 0;
    end 
end
%% 3 - Output the scene cut segments
scPos = find(scLabel==1);
scPos = scPos + ROItemporal(1) - 2;