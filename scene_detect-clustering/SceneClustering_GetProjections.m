clear all
load scPos.mat;
load tucker_tensor.mat;

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
AllsegIdx = [scPos(1:length(scPos)-1)+trimN scPos(2:length(scPos))-trimN];
AllsegLen = AllsegIdx(:,2) - AllsegIdx(:,1) + 1;
segIdx = AllsegIdx(find(AllsegLen>50),:);
segLen = AllsegLen(find(AllsegLen>50));
allFeat = zeros(size(T2.U{1},2)*size(T2.U{2},2)*size(T2.U{3},2),length(segLen));

for idx=1:length(segLen),
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
        readySegGray(:,:,:) = currSegGray;
    else
        keepIdx = 1:size(currSegGray,3);
        randIdx = randi(size(currSegGray,3),1,temporalCut-size(currSegGray,3));
        keepIdx = [keepIdx randIdx];
        % sort
        keepIdx = sort(keepIdx,'ascend');
        readySegGray(:,:,:) = currSegGray(:,:,keepIdx);
    end
    % Project to the Tucker Tensor to get the core
    currCore = ttm(tensor(readySegGray),{T2.U{1}', T2.U{2}', T2.U{3}'});
    currFlat = currCore.data(:);
    allFeat(:,idx) = currFlat;
end

% Run subspace clustering on allFeat
numClusters = 10;
rho = 1; % adjacency matrix thresholding parameter
mu = 20; % ADMM parameter
projFlag = 0;
affFlag = 0;
outlierFlag = 0;
[dataCtr,CMat] = SSC(allFeat,projFlag,affFlag,mu,outlierFlag,rho,numClusters);