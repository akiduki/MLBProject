clear all

strPt = 65810; %12275;%12042;
endPt = 65880;%12120;
GOPsize = endPt - strPt + 1;

width = 400;
height = 224;
% Call RPCA to solve!~
lambda = 0.05; % regularization term on L1-norm
tol = 1e-5;
iterNum = 1000;
rank = 1;

VidSrc = '../video_src/mlbpb_23570674_600K.mp4';
VidObj = VideoReader(VidSrc);

SegFrm = double(read(VidObj,[strPt endPt]));
SegFrmGray = squeeze(0.2989*SegFrm(:,:,1,:)+0.5870*SegFrm(:,:,2,:)+0.1140*SegFrm(:,:,3,:));
for i=1:size(SegFrmGray,3),
    currFrm = imresize(SegFrmGray(:,:,i),[height/2 width/2],'nearest');
    X(:,i) = currFrm(:);
end
% Run factorized RPCA
[Lhat Rhat Shat] = almLRPCA(X,tol,width*height*0.25,GOPsize,iterNum,rank,[],lambda);