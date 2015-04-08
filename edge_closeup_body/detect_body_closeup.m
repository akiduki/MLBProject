%% Edge detector based body detection
clear all
load '../scene_detect-clustering/clusteredSegments.mat'

% Pre-allocation for large arrays
totCnts = size(CloseUpIdx,1);
allColMu = cell(totCnts,1);
allColSigma = cell(totCnts,1);
allRowMu = cell(totCnts,1);
allRowSigma = cell(totCnts,1);
allColMuFit = cell(totCnts,1);
allColSigmaFit = cell(totCnts,1);
allRowMuFit = cell(totCnts,1);
allRowSigmaFit = cell(totCnts,1);

% Video pre-ambles
width = 400;
height = 224;
showimage = 0;
% Read-in video
VidSrc = '../videos/mlbpb_23570674_600K.mp4';
VidObj = VideoReader(VidSrc);

for segId=1:totCnts,
strPt = CloseUpIdx(segId,1);
endPt = CloseUpIdx(segId,2);
GOPsize = endPt - strPt + 1;

SegFrm = single(read(VidObj,[strPt endPt]));
SegFrmGray = squeeze(0.2989*SegFrm(:,:,1,:)+0.5870*SegFrm(:,:,2,:)+0.1140*SegFrm(:,:,3,:));
clear('SegFrm'); % release some memory

% Get sobel edge map
for FrmNum=1:GOPsize,
    currFrm = SegFrmGray(:,:,FrmNum);
    currEdge = edge(currFrm,'sobel');
    % Block the logo regions
    currEdge(1:40,1:100) = 0;
    currEdge(1:45,335:end) = 0;
    currEdge(164:202,75:325) = 0;
%     currEdgeDilate = bwmorph(currEdge,'dilate');
    [Rows,Cols] = find(currEdge~=0);
    if ~isempty(Rows),
% Option 1 - Connected components
%     tmp = zeros(length(Rows),length(Rows));
%     for i=1:length(Rows),
%         for j=1:length(Rows),
%             junk = abs(Cols(i)-Cols(j))+abs(Rows(i)-Rows(j));
%             if junk > 20,
%                 junk = 0;
%             else
%                 junk = 1;
%             end
%             tmp(i,j) = junk;
%         end
%     end
%     tmpSP = sparse(tmp);
%     [S,C] = graphconncomp(tmpSP);
%     allCnts = histc(C,1:S);
%     Cidx = find(allCnts == max(allCnts));
%     idx = find(C==Cidx);
%     currEdgeConn = zeros(size(currEdge));
%     for i=1:length(idx),
%         currEdgeConn(Rows(idx(i)),Cols(idx(i))) = 1;
%     end
%     RowsConn = Rows(idx);
%     ColsConn = Cols(idx);
%     RowIdx = [min(RowsConn) max(RowsConn)];
%     ColIdx = [min(ColsConn) max(ColsConn)];
%     SegFrm(RowIdx(1):RowIdx(1)+2,ColIdx(1):ColIdx(2),1,FrmNum) = 255;
%     SegFrm(RowIdx(1):RowIdx(1)+2,ColIdx(1):ColIdx(2),2:3,FrmNum) = 0;
%     SegFrm(RowIdx(2):RowIdx(2)+2,ColIdx(1):ColIdx(2),1,FrmNum) = 255;
%     SegFrm(RowIdx(2):RowIdx(2)+2,ColIdx(1):ColIdx(2),2:3,FrmNum) = 0;
%     SegFrm(RowIdx(1):RowIdx(2),ColIdx(1):ColIdx(1)+2,1,FrmNum) = 255;
%     SegFrm(RowIdx(1):RowIdx(2),ColIdx(1):ColIdx(1)+2,2:3,FrmNum) = 0;
%     SegFrm(RowIdx(1):RowIdx(2),ColIdx(2):ColIdx(2)+2,1,FrmNum) = 255;  
%     SegFrm(RowIdx(1):RowIdx(2),ColIdx(2):ColIdx(2)+2,2:3,FrmNum) = 0;  
%     imshow(uint8(SegFrm(:,:,:,FrmNum)));
%     pause(.1);
% Option 2 - Fit gaussian on projections
        pdRows = fitdist(Rows,'normal');
        pdCols = fitdist(Cols,'normal');
        RowMu(FrmNum) = pdRows.mu;
        RowSigma(FrmNum) = pdRows.sigma;
        ColMu(FrmNum) = pdCols.mu;
        ColSigma(FrmNum) = pdCols.sigma;
    end
end
%% Smoothing
TValpha = 1;
TViter = 10;
[u,s] = TVRegDiff( ColMu, TViter, TValpha, [], 'small', 1e-6, [], 0, 0 );
% u: scaled gradient 
A = cumsum(u)/length(ColMu);
ColMu_fit = ColMu(1)+A(1:end-1);
[u,s] = TVRegDiff( ColSigma, TViter, TValpha, [], 'small', 1e-6, [], 0, 0 );
A = cumsum(u)/length(ColSigma);
ColSigma_fit = ColSigma(1)+A(1:end-1);
[u,s] = TVRegDiff( RowMu, TViter, TValpha, [], 'small', 1e-6, [], 0, 0 );
A = cumsum(u)/length(RowMu);
RowMu_fit = RowMu(1)+A(1:end-1);
[u,s] = TVRegDiff( RowSigma, TViter, TValpha, [], 'small', 1e-6, [], 0, 0 );
A = cumsum(u)/length(RowSigma);
RowSigma_fit = RowSigma(1)+A(1:end-1);
allColMu{segId} = ColMu;
allColSigma{segId} = ColSigma;
allRowMu{segId} = RowMu;
allRowSigma{segId} = RowSigma;
allColMuFit{segId} = ColMu_fit;
allColSigmaFit{segId} = ColSigma_fit;
allRowMuFit{segId} = RowMu_fit;
allRowSigmaFit{segId} = RowSigma_fit;
end
% %% Visualization
% for i=1:GOPsize,
%     RowIdx = [round(RowMu_fit(i)-2*RowSigma_fit(i)) round(RowMu_fit(i)+1.2*RowSigma_fit(i))];
%     RowIdx(RowIdx<1) = 1;
%     RowIdx(RowIdx>height) = height;
%     ColIdx = [round(ColMu_fit(i)-1.1*ColSigma_fit(i)) round(ColMu_fit(i)+1.1*ColSigma_fit(i))];
%     ColIdx(ColIdx<1) = 1;
%     ColIdx(ColIdx>width) = width;
%     SegFrm(RowIdx(1):RowIdx(1)+2,ColIdx(1):ColIdx(2),1,i) = 255;
%     SegFrm(RowIdx(1):RowIdx(1)+2,ColIdx(1):ColIdx(2),2:3,i) = 0;
%     SegFrm(RowIdx(2):RowIdx(2)+2,ColIdx(1):ColIdx(2),1,i) = 255;
%     SegFrm(RowIdx(2):RowIdx(2)+2,ColIdx(1):ColIdx(2),2:3,i) = 0;
%     SegFrm(RowIdx(1):RowIdx(2),ColIdx(1):ColIdx(1)+2,1,i) = 255;
%     SegFrm(RowIdx(1):RowIdx(2),ColIdx(1):ColIdx(1)+2,2:3,i) = 0;
%     SegFrm(RowIdx(1):RowIdx(2),ColIdx(2):ColIdx(2)+2,1,i) = 255;  
%     SegFrm(RowIdx(1):RowIdx(2),ColIdx(2):ColIdx(2)+2,2:3,i) = 0;  
%     imshow(uint8(SegFrm(:,:,:,i)));
%     pause(.1);
% end