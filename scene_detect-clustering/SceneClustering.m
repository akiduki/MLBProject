% MLB automatic annotation project
% Scene segmentation using Tucker decomposition
% Yuanyi Xue @ NYU-Poly

% This script uses the 4th dimension of Tuker decomposition to perform scene
% clustering. Needs the segIdx and tucker tensor T/T2 to run.

tensorSize = size(tensorSegGray,4);

for h=1:tensorSize(1),
    for w=1:tensorSize(2),
        for t=1:tensorSize(3),
            curr4slice = tensorSegGray(h,w,t,:);
            % do the multi-way projection
            currCore = ttm(curr4slice,{T.U{4}'});
            currCoeff = ttm(currCore,{T.U{4}});
        end
    end
end