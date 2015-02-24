%% Learning transformation for video
% Inspired from Qiu and Sapiro, Learning Transformations for Clustering and
% Classification, ICLR 2014.
% Author: Yuanyi Xue @ MERL intern
% Initial date: 11/18/2014
% Cleaned up for MLB project on 02/24/2015 by Yuanyi Xue

% This script tries to perform a nuclear norm minization problem of the
% following:
% argmin_T ||TY||_nuc s.t. ||T||_F < \gamma
% By creating an Augmented Lagrangian surrogate
% argmin_{L,T} ||L||_nuc + \lambda/2 ||T||_F s.t. L = TX
% Lag = ||L||_nuc + \lambda/2 ||T||_F + <Y, L-TX> + \mu/2 ||L-TX||_F^2
% Solving two subproblems using ADMM as follows:
% 1) argmin_{L} ||L||_nuc + <Yk, L> + \mu/2 ||L-TkX||_2^2, using SVT
% And
% 2) argmin_{T} \lambda/2 ||T||_F - <Yk, TX> + \mu/2 ||Lk-TX||_2^2
% And an update step on Lagrangian Y,
% Yk+1 = Yk + \mu (Lk+1 - Tk+1X)

% ==================================================================
% This function requires the following packages in the search path:
% 1) PROPACK fast SVD algorithm (for calling lansvd);
% 2) Tygert's finding structure through randomness package (substitute system pca function);
% 3) (Optional, if RPCAflag==1) factorized RPCA program;
% ==================================================================

% Inputs:
% 1) VidSrc - Path of the video source
% 2) VidPara - Struct containing the following fields:
%      .GOPsize = length of video ROI
%      .srcLen = total video length
%      .height/width = size of the video
%      .seek = starting point
% 3) LTpara - Struct containing the LT parameters:
%      .iterThr = Total iteration limit for LT
%      .froThr = Frobenius norm thrsheld, normally 0.001
% 4) RPCApara - Struct containing RPCA parameters:
%      .lambda = Regularizer for sparse component
%      .tol = Convergence check
%      .iterNum = Total iteration limit for RPCA
%      .rank = Rank of the low rank component
% 5) RPCAflag = Flag of RPCA

% Outputs:
% 1) T - learned transform
% 2) TX - transformed frames
% 3) (Optional) L/R/Shat - factorized RPCA results

% Y - the video volume, consisting a N*p matrix, N is height*width, p is
% number of frames (GOP size).
% T - a "fat" transformation matrix of size K*N, K<<N.
function [T,TX,Lhat,Rhat,Shat] = LernTransVideo_ADMM(VidSrc,Vidpara,LTpara,RPCAflag,RPCApara)
addpath('./PROPACK/');
addpath('./randomness/');
addpath('./inexact_alm_rpca/');

GOPsize = Vidpara.GOPsize;
srcLen = Vidpara.srcLen;
height = Vidpara.height;
width = Vidpara.width;
strPos = Vidpara.seek;
Cspace = 'yv12'; % Cspace = 'yv16';
bitDepth = 8; % this should be always the case

% Data Matrix
X = zeros(height*width,GOPsize);
for pos = 1:GOPsize,
    [currY, currU, currV] = yuv_read(VidSrc, bitDepth, height, width, strPos+pos, Cspace);
    currY = double(currY);
    Xori(:,pos) = currY(:);
    tmp = (currY(:)-128)./255;
    X(:,pos) = tmp;
end

% LT parameters
iterThr = LTpara.iterThr; % running for iterThr number of iterations at most
froThr = LTpara.froThr; % Frobenius threshold

% Initialization parameters
T = eye(height*width);
L = zeros(size(X));
% Lagrangians
Y = zeros(size(X));
% Iteration related
iterNum = 1;
n1 = size(X,1);
n2 = size(X,2);
% SVT related
s = 1;
incre = 3;
% ADMM parameters
norm_y = lansvd(X,1,'L');   
mu = 0.25*n1*n2/10000/norm_y; % according to RPCA
mubar = 1e3*mu;
rho = 1; % increasing mu at every iteration
pinvX = pinv(X);
% L2-ball of T
gamma = 1;

while iterNum<iterThr
    % Inexact ADMM   
    % Solve subproblem (1) by SVT
    SVTinput = T*X - (1/mu)*Y;
    s = 1;
    OK = 0; 
    while ~OK
        opts = [];
        opts.eta = 1e-16;
        [U,Sigma,V] = lansvd(SVTinput,s,'L',opts);
        OK = (Sigma(s,s) <= (1/mu)) || ( s == min(n1,n2) );
        s = min(s + incre, min(n1,n2));
    end
    % Thresholding
    sigma = diag(Sigma); r = sum(sigma > (1/mu));
    disp(strcat('reduced rank=',num2str(length(sigma)-r)));
    U = U(:,1:r); V = V(:,1:r); sigma = sigma(1:r) - (1/mu); Sigma = diag(sigma);
    % Update L
    L = U*Sigma*V';
    % Solve subproblem (2) by LS
    % Calculate Omega
    Omega = L + (1/mu)*Y;
    % Update T
    T = Omega*pinvX;
    % Project T back to L2-ball
    % Matrix 2-norm is just the largest singular value
    % Using Tygert's fast pca method
    [junkS,sigmaT,junkV] = pca(T,10,false);
    Tl2 = sqrt(max(diag(sigmaT))); % largest singular value
    T = (gamma/Tl2).*T;        
    % Update Lagrangian Y
    Yprev = Y;
    Ystep = L - T*X;
    Y = Yprev + mu*Ystep;
    Ynorm = norm(Ystep,'fro')/norm(L,'fro');
    % ======= Iteration related log ============
    if iterNum>=2
        disp(strcat('Iteration ',num2str(iterNum),', discrepency=',num2str(Ynorm),', rank of TX=',num2str(rank(T*X)),', rank of L=',num2str(rank(L)),', mu=',num2str(mu)));
    end
    % Check convergence on Y
    if Ynorm < froThr,
        break;
    else
        iterNum = iterNum + 1;
        mu = min([mu * rho mubar]);
    end
end
TX = T*X;
%% Run RPCA
if RPCAflag,
    % Call RPCA to solve!~
    lambda = RPCApara.lambda; %0.1; % regularization term on L1-norm
    tol = RPCApara.tol; %1e-7;
    iterNum = RPCApara.iterNum; %500;
    LRrank = RPCApara.rank; %2;
    
    [Lhat Rhat Shat] = almLRPCA(1,TX,tol,width*height,GOPsize,iterNum,LRrank,[],lambda);
else
    Lhat = [];
    Rhat = [];
    Shat = [];
end
end