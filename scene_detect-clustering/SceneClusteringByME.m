% MLB automatic annotation project
% Scene segmentation using Tucker decomposition
% Yuanyi Xue @ NYU-Poly

% This script perform a total variation regulated motion estimation and use
% the motion field to do the clustering.
% Requires segIdx from the scenecut detection

% Tunable parameters
% lambda : regularization factor, increase to ensure smoother motion field
% bSize: block size for motion estimation
% MErange: motion estimation search range (in integer pixel accuracy)
% ROIspatial/temporal: region for performing motion estimation

clear all
%% Pre-ambles - Video read-in and frame difference calculation
VidPath = '../videos/mlbpb_23570674_600K.mp4';
VidObj = VideoReader(VidPath); % source video object

% Video stats
numFrm = VidObj.NumberOfFrames;
height = VidObj.Height;
width = VidObj.Width;

% Tunnable parameters
lambda = 0.1;
bSize = 8;
ROIspatial = [1 height-66 1 width];
trimN = 3;
MErange = 24;
NumRowBlk = floor((ROIspatial(4)-ROIspatial(3)+1)/bSize);
% segIdx contains all segments
segIdx = [scPos(1:end-1)+trimN scPos(2:end)-trimN]; % trim a bit

% loop over all segments
for seg = 1:size(segIdx,1),
    currSegIdx = segIdx(seg,:);
    currSegLen = currSegIdx(2)-currSegIdx(1)+1;
    MVfield = cell(currSegLen-1,1);
    for frmIdx = 2:currSegLen,
        colorFrm = read(VidObj,frmIdx-1);
        prevFrm = single(colorFrm(:,:,2));
        prevFrmGray = double(rgb2gray(colorFrm)); % reference frame
        colorFrm = read(VidObj,frmIdx);
        currFrm = single(colorFrm(:,:,2));
        currFrmGray = double(rgb2gray(colorFrm)); % current frame
        % Only consider the spatial ROI
        prevFrm = prevFrm(ROIspatial(1):ROIspatial(2),ROIspatial(3):ROIspatial(4));
        currFrm = currFrm(ROIspatial(1):ROIspatial(2),ROIspatial(3):ROIspatial(4));
        % Now do the EBMA
        pos = 1;
        for i=1:bSize:h-bSize+1,
            for j=1:bSize:w-bSize+1,
                currBlk = currFrm(i:i+bSize-1,j:j+bSize-1);
                [pCan,pCanMVlist]= InterCandidates(prevFrm,MErange,bSize,i,j);
                [pBlk,eBlk,currFrmMV(pos,:),pErr] = MotionSearchTV(currFlat,allCan,lambda,nMV,pCanMVlist);
                % Update the neighboring MVs for the next block
                if pos == 1,
                    nMV = [0 0; 0 0];
                elseif pos <= NumRowBlk,
                    nMV = [currFrmMV(pos-1,:)
                        currFrmMV(pos-1,:)];
                elseif mod(pos,NumRowBlk)==1,
                    nMV = [currFrmMV(pos-NumRowBlk,:)
                        currFrmMV(pos-NumRowBlk,:)];
                else
                    nMV = [currFrmMV(pos-1,:)
                        currFrmMV(pos-NumRowBlk,:)];
                end
                pos = pos + 1;
            end
        end
        % Save current frame MV field
        MVfield{frmIdx-1} = currFrmMV;
    end
    save(['SegNum=' num2str(seg) '_MVfield.mat'], 'MVfield');
end