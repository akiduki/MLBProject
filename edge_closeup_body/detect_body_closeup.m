% Edge detector based body detection
clear all
load '../scene_detect-clustering/cluster5VidIdx.mat'

segId = 25;
strPt = cluster5Idx(segId,1);
endPt = cluster5Idx(segId,2);
GOPsize = endPt - strPt + 1;

width = 400;
height = 224;
% Call RPCA to solve!~
% lambda = 0.1; % regularization term on L1-norm
lambda = 0.01;
tol = 1e-5;
iterNum = 100;
rank = 2;

VidSrc = '../videos/mlbpb_23570674_600K.mp4';
VidObj = VideoReader(VidSrc);

SegFrm = double(read(VidObj,[strPt endPt]));
SegFrmGray = squeeze(0.2989*SegFrm(:,:,1,:)+0.5870*SegFrm(:,:,2,:)+0.1140*SegFrm(:,:,3,:));

% Get sobel edge map
for i=1:GOPsize,
    currFrm = SegFrmGray(:,:,i);
    currEdge = edge(currFrm,'sobel');
    % Block the logo regions
    currEdge(14:40,30:100) = 0;
    currEdge(12:45,335:380) = 0;
    currEdge(164:202,75:325) = 0;
    [Rows,Cols] = find(currEdge~=0);
    pdRows = fitdist(Rows,'normal');
    pdCols = fitdist(Cols,'normal');
    RowIdx = [round(pdRows.mu-2*pdRows.sigma) round(pdRows.mu+1.2*pdRows.sigma)];
    RowIdx(RowIdx<1) = 1;
    ColIdx = [round(pdCols.mu-1.2*pdCols.sigma) round(pdCols.mu+1.2*pdCols.sigma)];
    SegFrm(RowIdx(1):RowIdx(1)+2,ColIdx(1):ColIdx(2),:,i) = 255;
    SegFrm(RowIdx(2):RowIdx(2)+2,ColIdx(1):ColIdx(2),:,i) = 255;
    SegFrm(RowIdx(1):RowIdx(2),ColIdx(1):ColIdx(1)+2,:,i) = 255;
    SegFrm(RowIdx(1):RowIdx(2),ColIdx(2):ColIdx(2)+2,:,i) = 255;  
%     GMMdata = [Cols Rows];
%     GMModel = fitgmdist(GMMdata,1);
%     scatter(GMMdata(:,1),GMMdata(:,2));
%     hold on;
%     ezcontour(@(x1,x2)pdf(GMModel,[x1 x2]),get(gca,{'XLim','YLim'}));
%     % vertical and horizontal projections
%     edgeVer = sum(double(currEdge),1);
%     edgeHor = sum(double(currEdge),2);
%     plot(edgeVer);pause(.1);plot(edgeHor);pause(.1);
%     VerMean = mean(edgeVer(:));
%     VerStd = std(edgeVer(:));
%     VerCI = [VerMean-1.41*VerStd VerMean+1.41*VerStd];
%     tmp = find(edgeVer>=VerCI(1));
%     tmp2 = find(edgeVer<=VerCI(2));
%     VerIdx = [tmp(1) tmp2(1)];
%     HorMean = mean(edgeHor(:));
%     HorStd = std(edgeHor(:));
%     HorCI = [HorMean-1.41*HorStd HorMean+1.41*HorStd];
%     tmp = find(edgeHor>=HorCI(1));
%     tmp2 = find(edgeHor<=HorCI(2));
%     HorIdx = [tmp(1) tmp2(1)];
    imshow(uint8(SegFrm(:,:,:,i)));
    pause(.1);
end