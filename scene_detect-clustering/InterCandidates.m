function [interD,mvList] = InterCandidates(frame,range,blkSize,posX,posY)
% the 16x16 version of finding inter-prediction candidates
% 1) frame: reference frame
% 2) range: search range in full pixel precision
% 3) posX: the position of block in X
% 4) posY: the position of block in Y
% 5) blkSize: the block size of the frame
% 6) width/height: width and height of the video
% outputs: 
% 1) the (inter) dictionary (candidate 16x16 blocks flattened to column vectors)
% 2) MVlist: list of all corresponding MVs

[width, height] = size(frame);
% currBlk = frame(posX:posX+blkSize-1,posY:posY+blkSize-1);
interD = zeros(blkSize*blkSize,1);
mvList = [];
% get the blocks inside the search range
for offsetX = -range+1:range,
    for offsetY = -range+1:range,
        if offsetX+posX <= 0 || offsetX+posX+blkSize > width+1 ||...
                offsetY+posY <= 0 || offsetY+posY+blkSize > height+1,
            continue;
        else
            searchBlk = frame(offsetX+posX:offsetX+posX+blkSize-1,...
                offsetY+posY:offsetY+posY+blkSize-1);
            interD = [interD searchBlk(:)];
            mvList = [mvList;
                offsetX offsetY];
        end
    end
end
interD(:,1) = [];
        