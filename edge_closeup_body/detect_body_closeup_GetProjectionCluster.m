%% Tucker decomposition and clustering on detected bounding box images for close up scenes

load '../scene_detect-clustering/clusteredSegments.mat'
load './BoundingBoxAllCloseUp.mat'
load './BoundingBox_tucker_5D.mat'

% totCnts = size(CloseUpIdx,1);
% segIdx = randperm(totCnts,100); % selects a 100-sample subset
width = 400;
height = 224;
subimgW = 100;
subimgH = 150;
% readySeg = zeros(subimgH,subimgW,3);

VidSrc = '../videos/mlbpb_23570674_600K.mp4';
VidObj = VideoReader(VidSrc);

for i=1:size(CloseUpIdx,1),
    currSeg = CloseUpIdx(i,:);
    currColMu = allColMuFit{i};
    currColSigma = allColSigmaFit{i};
    currRowMu = allRowMuFit{i};
    currRowSigma = allRowSigmaFit{i};
    FrmNum = randi(currSeg,50);
    readycurrSeg = zeros(subimgH,subimgW,3,length(FrmNum));
    for FrmOffset=1:length(FrmNum),
%     FrmNum = randi(currSeg,1); % randomly select one frame from it    
        SegFrm = double(read(VidObj,FrmNum(FrmOffset))); % read-in one frame only
        % Get the TV smoothed mu/sigma
%         FrmOffset = FrmNum - currSeg(1) + 1;
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
        currBox = SegFrm(RowIdx(1):RowIdx(2),ColIdx(1):ColIdx(2),:);
        % resize to the same resolution
        readycurrSeg(:,:,:,FrmOffset) = imresize(currBox,[subimgH subimgW]);
        % derive tucker components
    end
    currCore = ttm(tensor(readycurrSeg),{T.U{1}', T.U{2}', T.U{3}', T.U{4}'});
    currFlat = currCore.data(:);
    allFeat(:,i) = currFlat;
end

% Run subspace clustering on allFeat
numClusters = 4;
rho = 1; % adjacency matrix thresholding parameter
mu = 20; % ADMM parameter
projFlag = 0;
affFlag = 0;
outlierFlag = 0;
[dataCtr,CMat] = SSC(allFeat,projFlag,affFlag,mu,outlierFlag,rho,numClusters);
%% Visualization
VidPath = '..\videos\mlbpb_23570674_600K.mp4';
VidObj = VideoReader(VidPath); % source video object
temporalCut = 150;
subImgH = 112*2;
subImgW = 200*2;
segIdx = CloseUpIdx;
for i=1:4,
    rowIdx = 0;
    clusterIdx = find(dataCtr==i);
    totImg = length(clusterIdx);
    numRowSubImg = 5;
    numColSubImg = ceil(totImg/numRowSubImg);
    stitchImg = zeros((subImgH+10)*numColSubImg,(subImgW+10)*numRowSubImg,3);
    for j = 1:length(clusterIdx),
        currSeg = read(VidObj,segIdx(clusterIdx(j),:));
        currInput = double(squeeze(currSeg(:,:,:,30)));
%         currInput = imresize(currInput,0.5,'nearest');
        currData = [currInput 255*ones(subImgH,10,3)
            255*ones(10,subImgW,3) 255*ones(10,10,3)];
        if mod(j,numRowSubImg)==1,
            rowIdx = rowIdx + 1;
            colIdx = 1;
        else
            colIdx = colIdx + 1;
        end
        rowRange = 1+(rowIdx-1)*(subImgH+10):rowIdx*(subImgH+10);
        colRange = 1+(colIdx-1)*(subImgW+10):colIdx*(subImgW+10);
        stitchImg(rowRange,colRange,:) = currData;
    end
    allImg{i} = stitchImg(:,:,1);
    disp(['Processed ' num2str(i)]);
end

for i=1:4,
    figure(i);
    imshow(allImg{i},[0 255]);
    title(['Cluster = ' num2str(i)]);
end
save('OneFrameCluster.mat','dataCtr','CMat','allFeat','allImg');