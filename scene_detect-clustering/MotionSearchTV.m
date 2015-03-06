function [pBlk,eBlk,posMV,minSSE] = MotionSearchTV(currBlk,canBlk,lambda,nMV,pCanMVlist)
% The exhaustive motion search function, TV regulated
% This function calcuates and compares the sum of sqaured errors between
% each candidate and the current block. The function will then return the
% best candidate in terms of minimizing the SSE, and its corresponding
% position in canBlk matrix.
% Inputs:
% 1) currBlk: the current block to be predicted, flat vector
% 2) canBlk: all candidates, 256xN if there is N candidates and blkSize=16
% Outputs:
% 1) pBlk: predicted block (copied from best mode)
% 2) eBlk: error block
% 3) pos: the best candidate position
% 4) minSSE: the minimal error (SSE)

% find the blocksize
bSize = sqrt(size(currBlk,1));
nlambda = lambda*mean(currBlk(:)); % scale the lambda based on mean block
% ''inflate'' the currBlk to the same size as canBlk
inflatBlk = repmat(currBlk,1,size(canBlk,2));
% calculate the MSE cost
allMSE = mean((inflatBlk-canBlk).^2,1); % summing along the column
% calculate the corresponding TVs
TV = sqrt((pCanMVlist - repmat(nMV(1,:),size(pCanMVlist,1),1)).^2 +...
    (pCanMVlist - repmat(nMV(2,:),size(pCanMVlist,1),1)).^2);
TV = sum(TV,2);
% find the lowest cost
[minSSE,pos] = min(allMSE(:)+nlambda.*TV(:));
tCoef = canBlk(:,pos);
% reshape it back to blkSize*blkSize
pBlk = reshape(tCoef,bSize,bSize);
cBlk = reshape(currBlk,bSize,bSize);
% calculate the error block
eBlk = cBlk - pBlk;
posMV = pCanMVlist(pos,:);
