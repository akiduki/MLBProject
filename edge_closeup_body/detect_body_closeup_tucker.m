%% Tucker decomposition and clustering on detected bounding box images for close up scenes
clear all

load '../scene_detect-clustering/clusteredSegments.mat'
load './BoundingBoxAllCloseUp.mat'

totCnts = size(CloseUpIdx,1);
segIdx = randperm(totCnts,100); % selects a 100-sample subset
width = 400;
height = 224;
subimgW = 100;
subimgH = 150;
readySeg = zeros(subimgH,subimgW,3,50,100);

VidSrc = '../videos/mlbpb_23570674_600K.mp4';
VidObj = VideoReader(VidSrc);

for i=1:length(segIdx),
    currSeg = CloseUpIdx(segIdx(i),:);
    currColMu = allColMuFit{segIdx(i)};
    currColSigma = allColSigmaFit{segIdx(i)};
    currRowMu = allRowMuFit{segIdx(i)};
    currRowSigma = allRowSigmaFit{segIdx(i)};
    FrmNum = randi(currSeg,50);
    for FrmOffset=1:length(FrmNum),
%     FrmNum = randi(currSeg,1); % randomly select one frame from it    
        SegFrm = double(read(VidObj,FrmNum(FrmOffset))); % read-in one frame only
        % Get the TV smoothed mu/sigma
%         FrmOffset = FrmNum; %- currSeg(1) + 1;
        ColMu_fit = currColMu(FrmNum(FrmOffset)-currSeg(1)+1);
        ColSigma_fit = currColSigma(FrmNum(FrmOffset)-currSeg(1)+1);
        RowMu_fit = currRowMu(FrmNum(FrmOffset)-currSeg(1)+1);
        RowSigma_fit = currRowSigma(FrmNum(FrmOffset)-currSeg(1)+1);
        % Calculate the corresponding box indices
        RowIdx = [round(RowMu_fit-2*RowSigma_fit) round(RowMu_fit+1.2*RowSigma_fit)];
        RowIdx(RowIdx<1) = 1;
        RowIdx(RowIdx>height) = height;
        ColIdx = [round(ColMu_fit-1.1*ColSigma_fit) round(ColMu_fit+1.1*ColSigma_fit)];
        ColIdx(ColIdx<1) = 1;
        ColIdx(ColIdx>width) = width;
        % Extract the image within the bounding box
        readycurrSeg = SegFrm(RowIdx(1):RowIdx(2),ColIdx(1):ColIdx(2),:);
        % resize to the same resolution
        readycurrSeg = imresize(readycurrSeg,[subimgH subimgW]);
        readySeg(:,:,:,FrmOffset,i) = readycurrSeg;
    end
end
tensorSeg = tensor(readySeg);
% Tucker decomposition
sprank1 = 20;
sprank2 = 8;
crank = 3;
trank = 10;
srank = 20;
T = tucker_als(tensorSeg,[sprank1 sprank2 crank trank srank]);