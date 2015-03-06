% MLB automatic annotation project
% Scene segmentation using Tucker decomposition
% Yuanyi Xue @ NYU-Poly

% This script uses Tucker decomposition to find a compact set of basis for
% clustering the scene. It requires the Sandia Tensor Toolbox and scPos.mat

clear all
load scPos.mat;

VidPath = '..\videos\mlbpb_23570674_600K.mp4';
VidObj = VideoReader(VidPath); % source video object

% Video stats
numFrm = VidObj.NumberOfFrames;
height = VidObj.Height;
width = VidObj.Width;
ROIspatial = [1 height-66 1 width];
ROItemporal = [4130 88777];
temporalCut = 150; % fixed 1500 frames
trimN = 3;

% Get the segments
numSeg = 150; % number of segments
randIdx = randperm(length(scPos)-1);
segIdx = [scPos(randIdx(1:numSeg))+trimN scPos(randIdx(1:numSeg)+1)-trimN]; % trim a bit

% 4-D tensor for storing all data
readySegGray = zeros(round(ROIspatial(2)/2),round(ROIspatial(4)/2),temporalCut,numSeg);
% Query the video and store the data
for idx=1:numSeg,
    currSeg = single(read(VidObj,segIdx(idx,:)));
    currSegGray = squeeze(0.2989*currSeg(:,:,1,:) ...
        + 0.5870*currSeg(:,:,2,:) + 0.1140*currSeg(:,:,3,:));
    % Only consider the ROI region
    currSegGray = currSegGray(ROIspatial(1):ROIspatial(2),...
        ROIspatial(3):ROIspatial(4),:);
    currSegGray = imresize(currSegGray,0.5,'nearest');
    for i = 1:size(currSegGray,3),
        currSegGray(:,:,i) = currSegGray(:,:,i)-mean2(squeeze(currSegGray(:,:,i)));
    end
    % Temporally resize to 150 frames
    if size(currSegGray,3)>=temporalCut,
        allIdx = randperm(size(currSegGray,3));
        currSegGray(:,:,allIdx(temporalCut+1:end)) = [];
        readySegGray(:,:,:,idx) = currSegGray;
    else
        keepIdx = [];
        frmidx = 1;
        for i=1:(temporalCut-size(currSegGray,3)),
            rng('shuffle');
            tmp = randperm(size(currSegGray,3));
            keepIdx = [keepIdx tmp(1)];
        end
        % keepIdx stores all repeat frame locations
        for i=1:size(currSegGray,3),          
            readySegGray(:,:,frmidx,idx) = currSegGray(:,:,i);
            frmidx = frmidx + 1;
            if ismember(i,keepIdx),
                readySegGray(:,:,frmidx,idx) = readySegGray(:,:,frmidx-1,idx);                
                frmidx = frmidx + 1;
            end
        end
    end
end
tensorSegGray = tensor(readySegGray);
% Do Tucker decomposition for the tensor
sprank1 = 20;
sprank2 = 80;
trank = 15;
srank = 15;
T = tucker_als(tensorSegGray,[sprank1 sprank2 trank srank]);

T2 = tucker_als(tensorSegGray,[8 32 15 10]);
