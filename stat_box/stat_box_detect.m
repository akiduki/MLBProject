%% MLB project statistics box detection and SWT

%% convert all color image into gray image:

% ImgfileDir = '/Users/Chenge/Documents/2014Fall/lymphedema/xcodeproj/SWT_MLB/SWT_MLB/box_images/';
 ImgfileDir ='/Users/Chenge/Documents/github/codes_to_be_pushed/';
frames = dir([ImgfileDir '*.png']);

% for i = 1:length(frames)
%     curFrame = imread([ImgfileDir frames(i).name]);
%     gray_img=rgb2gray(curFrame);
%     gray_img=imresize(gray_img, 8);
%     imwrite(gray_img,['/Users/Chenge/Documents/github/inProgress/pytesseract-0.1.5/src/',frames(i).name],'png' );
% end


%% create all masks
for i = 1:length(frames)
    curFrame = imread([ImgfileDir frames(i).name]);
    gray_img=rgb2gray(curFrame);
    masked_img=edge_mask(gray_img,1);
    imwrite(masked_img,['/Users/Chenge/Documents/github/inProgress/pytesseract-0.1.5/src/',frames(i).name],'png' );
end

%% blurred image
for i = 1:length(frames)
    curFrame = imread([ImgfileDir frames(i).name]);
    gray_img=rgb2gray(curFrame);
    imshow(gray_img);
    h = fspecial('gaussian', size(gray_img), 0.3);
    g = imfilter(gray_img, h); 
    imwrite(g,['/Users/Chenge/Documents/github/inProgress/pytesseract-0.1.5/src/',frames(i).name],'png' );

end

%% cropped image
for i = 1:10%length(box_ind)
    title=['box[',num2str(box_ind(i)),'].png'];
    curFrame = imread([ImgfileDir title]);
%     gray_img=rgb2gray(curFrame);
    cropped=curFrame(4:20,48:180);    
    cropped_sc = imresize(cropped, 6); % 20/7

%     level= graythresh(cropped);
%     cropped=im2bw(cropped, level);
    imwrite(cropped_sc,['/Users/Chenge/Documents/github/inProgress/pytesseract-0.1.5/src/',num2str(box_ind(i)),'.png'],'png' );
end



%% erosion
box_ind=red_box;
for i = 1:length(box_ind)
    title=['box[',num2str(box_ind(i)),'].png'];
    curFrame = imread([ImgfileDir title]);
%     gray_img=rgb2gray(curFrame);
    cropped=curFrame(4:24,48:180);
    cropped_sc = imresize(cropped, 6); % 20/7
    
    level= graythresh(cropped_sc);
%     level=0.3;
    cropped_sc_bw=im2bw(cropped_sc, level);
%     imshow(cropped);
%     cropped=bwmorph(cropped,'skel',inf);
%     cropped = bwmorph(cropped_sc_bw,'open');
    se = strel('disk',4);        
    cropped_sc_erode = imerode(cropped_sc_bw,se);
    name_for_image = sprintf('%08s',num2str(box_ind(i)));
    imwrite(cropped_sc_erode,['/Users/Chenge/Documents/github/inProgress/pytesseract-0.1.5/src/red_box/',name_for_image,'.png'] );

end




%% write the box frame number into txt
load /Users/Chenge/Documents/github/MLBProject/box_images/box_detect_SVM_Model.mat
blue_box=find(predicted_label==1);
red_box=find(predicted_label==2);
box_ind=[blue_box;red_box];



for i=1:length(predicted_label)
    change = diff(predicted_label);    
end

box_change_ind= find(change~=0);

middle=zeros(1,length(box_change_ind)-1);
for k=1:length(box_change_ind)-1
    middle(k)=floor(0.5*(box_change_ind(k)+box_change_ind(k+1)));
end


% filename1='box.txt';
% fileID1 = fopen(filename1,'w');
% 
% for j=1:size(box_ind,1)
%     fprintf(fileID1,'%d ',box_ind);
%     fprintf(fileID1,'\n\n');
%    
% end
% fclose(fileID1);


save('box.mat','box_ind');




%% read from video
vidObj = VideoReader('/Users/Chenge/Desktop/MLB/mlbpb_23570674_600K.mp4');
% Read in all video frames.
% vidFrames = read(vidObj);

% Get the number of frames.
numFrames = get(vidObj, 'NumberOfFrames');
for i=1:length(box_ind)
    im_ind=box_ind(i);
    curFrame=read(vidObj,im_ind);
    gray=rgb2gray(curFrame);
    height=size(gray,1);    width=size(gray,2);
    box_gray=gray(157:height-24,75:width-74);
    name_loc=box_gray(4:24,48:180);
    cropped_sc = imresize(name_loc, 6); % 20/7
    
    level= graythresh(cropped_sc);
%     level=0.3;
    cropped_sc_bw=im2bw(cropped_sc, level);
    se = strel('disk',4);        
    cropped_sc_erode = imerode(cropped_sc_bw,se);
    cropped_sc_final = bwareaopen(cropped_sc_erode, 10);
    name_for_image = sprintf('%08s',num2str(box_ind(i)));
    imwrite(cropped_sc_final,['/Users/Chenge/Documents/github/inProgress/pytesseract-0.1.5/src/matching_box/',name_for_image,'.png'] );

    
end

% img=read(vidObj,29680);
% imshow(img);


%% get the representative images
for i=1:length(middle)
    curFrame=read(vidObj,middle(i)+10);
    name_for_image = sprintf('%08s',num2str(middle(i)+10));
    imwrite(curFrame,['/Users/Chenge/Documents/github/inProgress/pytesseract-0.1.5/src/representatives/',name_for_image,'.png'] );

end

%% get the most frequent name string
[frame_num,first_name,last_name]=textread('/Users/Chenge/Documents/github/inProgress/REAL_Name.txt','%08d %s %s');
name=cell(size(first_name));
for i=1:length(first_name)
    name{i}=[first_name{i},' ',last_name{i}];
end

group_start=zeros(1,length(box_change_ind)-1);
group_end=zeros(1,length(box_change_ind)-1);
most_common_string=cell(length(box_change_ind)-1,1);
for i=1:length(box_change_ind)-1
    name_same_group=cell(1);
    group_ind=[];
    prev=box_change_ind(i);
    next=box_change_ind(i+1);
    k=1;
    for j=1:length(frame_num)
        if frame_num(j)>prev && frame_num(j)<=next
            group_ind=[group_ind,j];
            name_same_group{k}=name{j};
            k=k+1;
        end
    end
    if ~isempty(name_same_group{1}) && length(name_same_group)~=1
%         name_same_group=cellstr(name_same_group);
        group_start(i)=frame_num(min(group_ind));
        group_end(i)=frame_num(max(group_ind));
        [unique_strings, ~, string_map]=unique(name_same_group);
        most_common_string{i}=unique_strings(mode(string_map));
    end
end


stat=[num2cell(group_start'),num2cell(group_end'),most_common_string];
fileID = fopen('/Users/Chenge/Documents/github/inProgress/stat_box.txt','w');
for i=1:size(stat,1)
    ssss=stat{i,1};
    eend=stat{i,2};
    nnam=cell2mat(stat{i,3});
    fprintf(fileID,'%d %d %s\n',ssss,eend,nnam);
end
fclose(fileID);





