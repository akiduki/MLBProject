% MLB automatic annotation project
% Scene segmentation using Tucker decomposition
% Yuanyi Xue @ NYU-Poly

% This script uses Tucker decomposition to find a compact set of basis for
% clustering the scene. It requires the Sandia Tensor Toolbox and scPos.mat

load scPos.mat;

VidPath = 'C:\Users\akiduki\Documents\MATLAB\MLBproj\mlbpb_23570674_600K.mp4';
VidObj = VideoReader(VidPath); % source video object

% Video stats
numFrm = VidObj.NumberOfFrames;
height = VidObj.Height;
width = VidObj.Width;
ROIspatial = [1 height-66 1 width];
ROItemporal = [4130 88777];
trimN = 3;

% Get the segments
numSeg = 200; % number of segments
randIdx = randperm(length(scPos));
segIdx = [scPos(randIdx(1:numSeg))+trimN scPos(randIdx(1:numSeg)+1)-trimN]; % trim a bit

% Query the video and store the data
for idx=1:numSeg,
    currSeg = double(read(VidObj,segIdx(idx,:)));
    currSegGray = squeeze(0.2989*currSeg(:,:,1,:) ...
        + 0.5870*currSeg(:,:,2,:) + 0.1140*currSeg(:,:,3,:));
end
