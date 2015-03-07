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
load('scPos.mat');
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
for seg = 3:size(segIdx,1),
    currSegIdx = segIdx(seg,:);
    currSegLen = currSegIdx(2)-currSegIdx(1)+1;
    MVfield = cell(currSegLen-1,1);
    t = tic;
    for frmIdx = 1:currSegLen-1,
        colorFrm = read(VidObj,currSegIdx(1)+frmIdx);
        prevFrm = single(colorFrm(:,:,2));
        prevFrmGray = double(rgb2gray(colorFrm)); % reference frame
        colorFrm = read(VidObj,currSegIdx(1)+frmIdx-1);
        currFrm = single(colorFrm(:,:,2));
        currFrmGray = double(rgb2gray(colorFrm)); % current frame
        % Only consider the spatial ROI
        prevFrm = prevFrm(ROIspatial(1):ROIspatial(2),ROIspatial(3):ROIspatial(4));
        currFrm = currFrm(ROIspatial(1):ROIspatial(2),ROIspatial(3):ROIspatial(4));
        % Now do the EBMA
        pos = 1;
        nMV = [0 0; 0 0];
        [mheight mwidth] = size(currFrm);
        for i=1:bSize:mheight-bSize+1,
            for j=1:bSize:mwidth-bSize+1,
                currBlk = currFrm(i:i+bSize-1,j:j+bSize-1);
                currFlat = currBlk(:);
                [pCan,pCanMVlist]= InterCandidates(prevFrm,MErange,bSize,i,j);
                [junk,junk,currFrmMV(pos,:),junk] = MotionSearchTV(currFlat,pCan,lambda,nMV,pCanMVlist);
                pos = pos + 1;
                % Update the neighboring MVs for the next block
                if pos <= NumRowBlk,
                    nMV = [currFrmMV(pos-1,:)
                        currFrmMV(pos-1,:)];
                elseif mod(pos,NumRowBlk)==1,
                    nMV = [currFrmMV(pos-NumRowBlk,:)
                        currFrmMV(pos-NumRowBlk,:)];
                else
                    nMV = [currFrmMV(pos-1,:)
                        currFrmMV(pos-NumRowBlk,:)];
                end
            end
        end
        % Save current frame MV field
        MVfield{frmIdx} = currFrmMV;
        disp(['Processed frame ' num2str(frmIdx)]);
    end
    tSeg = toc(t);
    disp(['Processed segment ' num2str(seg) ', time = ' num2str(tSeg)]);
    save(['SegNum=' num2str(seg) '_MVfield.mat'], 'MVfield');
end