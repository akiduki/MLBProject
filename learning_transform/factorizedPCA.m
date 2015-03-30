clear all
load '../scene_detect-clustering/cluster5VidIdx.mat'
addpath('./inexact_alm_rpca/');
segId = 48;
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
for i=1:size(SegFrmGray,3),
    currFrm = SegFrmGray(:,:,i);%imresize(SegFrmGray(:,:,i),[height/2 width/2],'nearest');
    X(:,i) = currFrm(:);
end
% Run factorized RPCA
% [Lhat Rhat Shat] = almLRPCA(X,tol,width*height*0.25,GOPsize,iterNum,rank,[],lambda);
[Ahat Ehat iter] = inexact_alm_rpca(X,lambda,tol,iterNum);

for i=1:GOPsize,
    currFrm = reshape(Ahat(:,i),height,width);
    imshow(currFrm,[]);
    pause(.1);
end