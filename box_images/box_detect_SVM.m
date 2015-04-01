% MLB Automatic Annotation Project
% Stats box detection by SVM

% read positive and negative samples
clear all;
posi = './positive/';
nega = './negative/';
setSize = 51;
SVMopts = '-t 0 -c 10';
posMat = [];
negMat = [];

AllLabel = zeros(setSize*2,1);
% RedIdx = [5 11:35 65:73 90:100];
% BlueIdx = setdiff(1:100,RedIdx);

for i=1:setSize,
    currPosName = [posi 'positive_' num2str(i) '.png'];
    currNegName = [nega 'negative_' num2str(i) '.png'];
    currPos = imread(currPosName);
    currNeg = imread(currNegName);
    % resize to make it more viable
    currPos = rgb2gray(imresize(currPos, 0.5, 'nearest'));
    currNeg = rgb2gray(imresize(currNeg, 0.5, 'nearest'));
    posMat = [posMat; transpose(currPos(:))];
    negMat = [negMat; transpose(currNeg(:))];
end
AllFeatMat = [double(posMat); double(negMat)];
AllLabel(1:51) = 1;
% AllLabel(BlueIdx) = 2;

% Train SVM
model = svmtrain(AllLabel, AllFeatMat, SVMopts);

%% testing the trained SVM
test = './test/';
testLabel = zeros(25,1);
RedIdx = [3 4 6 9];
BlueIdx = setdiff(1:10,RedIdx);
testLabel(RedIdx) = 1;
testLabel(BlueIdx) = 2;
posTestMat = [];
negTestMat = [];

for i=1:15,
    currNegName = [test 'negative_' num2str(i) '.png'];
    if i <= 10,
        currPosName = [test 'positive_' num2str(i) '.png'];
        currPos = imread(currPosName);
        currPos = rgb2gray(imresize(currPos, 0.5, 'nearest'));
        posTestMat = [posTestMat; transpose(currPos(:))];
    end
    currNeg = imread(currNegName);
    currNeg = rgb2gray(imresize(currNeg, 0.5, 'nearest'));
    negTestMat = [negTestMat; transpose(currNeg(:))];
end
testFeatMat = [double(posTestMat); double(negTestMat)];
[predicted_label, accuracy, decision_values] = svmpredict(testLabel, testFeatMat, model);

%% Go process the whole video
% load 'box_detect_SVM_Model.mat'
VidPath = '..\videos\mlbpb_23570674_600K.mp4';
VidObj = VideoReader(VidPath); % source video object

% 74 156 -74 -24
% 94 14 -182 -190

% Video stats
numFrm = VidObj.NumberOfFrames;
height = VidObj.Height;
width = VidObj.Width;
predicted_label = zeros(numFrm,1);
dec = zeros(numFrm,1);

for idx=1:numFrm,
    currFrm = read(VidObj,idx);
%     currFrm = currFrm(157:end-24,75:end-74,:);
    currFrm = currFrm(15:end-190,95:end-182,:);
    currFrm = rgb2gray(imresize(currFrm, 0.5, 'nearest'));
    % call SVM model
    predicted_label(idx) = svmpredict(0,transpose(double(currFrm(:))),model);
    disp(['Processed ' num2str(idx)]);
end