function [videoInfo] = process_openpose_trackPerson_addition_front()
clearvars -except videoInfo

[videoInfo.vid_openpose_name videoInfo.vid_openpose_path] = uigetfile({'*.mov;*.mp4;*.avi;*.qt;*.wmv','Video files (*.mov,*.mp4,*.avi,*.qt,*.wmv)'},'Pick OpenPose labeled video file');
[~,videoInfo.vid_openpose_name,videoInfo.extension] = fileparts(videoInfo.vid_openpose_name);

videoInfo.json_path = fullfile(videoInfo.vid_openpose_path,'JSON_Files');
json_folder_files = dir(videoInfo.json_path);
no_json_files = length(json_folder_files)-2;
file = cell(1,no_json_files);
for i = 1:no_json_files
   file{i} = json_folder_files(i+2).name; 
end; clearvars i
%%
openpose.pose.bodyModel = 'BODY_25';
switch openpose.pose.bodyModel
    case 'BODY_25'
        openpose.pose.keypoints = {'Nose','Neck','RShoulder','RElbow','RWrist','LShoulder','LElbow','LWrist','MidHip','RHip','RKnee','RAnkle','LHip','LKnee','LAnkle','REye','LEye','REar','LEar','LBigToe','LSmallToe','LHeel','RBigToe','RSmallToe','RHeel'};
        openpose.pose.noKeypoints = length(openpose.pose.keypoints); % BODY_25 model
    case 'BODY_21'
        openpose.pose.noLandmarks = 21; % BODY_21 model
end
for i = 1:70
openpose.face.keypoints{i} = ['Face_' num2str(i)];
end; clearvars i; openpose.face.noKeypoints = length(openpose.face.keypoints);
for i = 1:21
openpose.hand_left.keypoints{i} = ['hand_left_' num2str(i)];
end; clearvars i; openpose.hand_left.noKeypoints = length(openpose.hand_left.keypoints);
for i = 1:21
openpose.hand_right.keypoints{i} = ['hand_right_' num2str(i)];
end; clearvars i;  openpose.hand_right.noKeypoints = length(openpose.hand_right.keypoints);

data_openpose.noFiles = length(file); % number of files

videoInfo.json_files = file;
videoInfo.vid_openpose = VideoReader(fullfile(videoInfo.vid_openpose_path,[videoInfo.vid_openpose_name videoInfo.extension]));

frameInfo.multiplePersonsDetected = false(data_openpose.noFiles,1);
frameInfo.numberPersonsDetected = zeros(data_openpose.noFiles,1);

data_openpose.time = nan(1,data_openpose.noFiles);
data_openpose.time = 0:1/videoInfo.vid_openpose.FrameRate:(data_openpose.noFiles-1)/videoInfo.vid_openpose.FrameRate; % time vector

for j = 1:data_openpose.noFiles        
    val = jsondecode(fileread(fullfile(videoInfo.json_path,file{j}))); % load JSON file
    if length(val.people) > 1; frameInfo.multiplePersonsDetected(j) = true; end % check if multiple persons are tracked in frame
    if ~isempty(val.people) % check if any people are detected
        frameInfo.numberPersonsDetected(j) = length(val.people);
        for k = 1:length(val.people)
        val.people(k).pose_keypoints_2d(val.people(k).pose_keypoints_2d==0) = nan; 
        
        data_openpose.pose.data_raw(k,j,:,1) = val.people(k).pose_keypoints_2d(1:3:end);
        data_openpose.pose.data_raw(k,j,:,2) = val.people(k).pose_keypoints_2d(2:3:end);
        conf.pose(k,j,:) = val.people(k).pose_keypoints_2d(3:3:end);

        if ~isempty(val.people(k).face_keypoints_2d)
        val.people(k).face_keypoints_2d(val.people(k).face_keypoints_2d==0) = nan; 

        data_openpose.face.data_raw(k,j,:,1) = val.people(k).face_keypoints_2d(1:3:end);
        data_openpose.face.data_raw(k,j,:,2) = val.people(k).face_keypoints_2d(2:3:end);
        conf.face(k,j,:) = val.people(k).face_keypoints_2d(3:3:end);         
        end
        
        if ~isempty(val.people(k).hand_left_keypoints_2d)
        val.people(k).hand_left_keypoints_2d(val.people(k).hand_left_keypoints_2d==0) = nan; 

        data_openpose.hand_left.data_raw(k,j,:,1) = val.people(k).hand_left_keypoints_2d(1:3:end);
        data_openpose.hand_left.data_raw(k,j,:,2) = val.people(k).hand_left_keypoints_2d(2:3:end);
        conf.hand_left(k,j,:) = val.people(k).hand_left_keypoints_2d(3:3:end);         
        end

        if ~isempty(val.people(k).hand_right_keypoints_2d)
        val.people(k).hand_right_keypoints_2d(val.people(k).hand_right_keypoints_2d==0) = nan; 

        data_openpose.hand_right.data_raw(k,j,:,1) = val.people(k).hand_right_keypoints_2d(1:3:end);
        data_openpose.hand_right.data_raw(k,j,:,2) = val.people(k).hand_right_keypoints_2d(2:3:end);
        conf.hand_right(k,j,:) = val.people(k).hand_right_keypoints_2d(3:3:end);         
        end
        
        end; clearvars k
    end   
end; clearvars j


if max(frameInfo.numberPersonsDetected) > 1 % use trackPerson code if multiple persons detected
%     [trackPerson_manual_input] = trackPerson_openpose_manual_input(data,conf,time_openpose,numberPersonsDetected,vid_openpose,output_name,bodyModel);
[personTrack] = trackPerson_openpose_manual_input(data_openpose,videoInfo,frameInfo,openpose);
%     [personTrack.trackPerson_auto] = trackPerson_openpose_automatic_tracking(data,conf,time_openpose,numberPersonsDetected,trackPerson_manual_input,bodyModel);
[personTrack] = trackPerson_openpose_automatic_tracking(data_openpose,videoInfo,frameInfo,openpose,personTrack);
%     [personTrack.trackPerson_inspect] = trackPerson_openpose_visual_inspection(data,conf,time_openpose,numberPersonsDetected,vid_openpose,trackPerson_manual_input,trackPerson_auto,output_name,bodyModel);
[personTrack] = trackPerson_openpose_visual_inspection(data_openpose,videoInfo,frameInfo,openpose,personTrack);

frameInfo.trackPerson_manual_input = personTrack.trackPerson_manual_input;
frameInfo.trackPerson_inspect = personTrack.trackPerson_inspect;
 
% for i = 1:pose.noKeypoints
%     for j = 1:data_openpose.noFiles 
%         if isnan(frameInfo.trackPerson_inspect.inspectionTrack_personID(j))
%             eval(['data_openpose.data_personTracked_raw.' pose.keypoints{i} '(' num2str(j) ',:) = nan(1,2);' ])
%         else
%             eval(['data_openpose.data_personTracked_raw.' pose.keypoints{i} '(' num2str(j) ',:) = data_openpose.data_raw.frame_' num2str(j) '.person_' num2str(frameInfo.trackPerson_inspect.inspectionTrack_personID(j)) '.' pose.keypoints{i} ';' ])
%         end
%     end; clearvars j
% end; clearvars i

data_openpose.pose.data_personTracked_raw = nan(data_openpose.noFiles,openpose.pose.noKeypoints,2);
for j = 1:data_openpose.noFiles
    if ~isnan(personTrack.trackPerson_inspect.inspectionTrack_personID(j))
        data_openpose.pose.data_personTracked_raw(j,:,:) = data_openpose.pose.data_raw(personTrack.trackPerson_inspect.inspectionTrack_personID(j),j,:,:);
    end
end 

% if any(any(~isnan(frameInfo.trackPerson_inspect.partialTrack_personID)))  
%     for j = 1:data_openpose.noFiles
%        if any(~isnan(trackPerson_inspect.partialTrack_personID(j,:)))
%             [noPerson_partialTrack noKeypoints noDim] = size(trackPerson_inspect.partialTrack_data{j});
%             for i = 1:noPerson_partialTrack
%                 keypointIndices_partialTrack = ~isnan(squeeze(trackPerson_inspect.partialTrack_data{j}(i,:,1)));
%                 data_personTrack(j,keypointIndices_partialTrack,:) = trackPerson_inspect.partialTrack_data{j}(i,keypointIndices_partialTrack,:);
%             end; clearvars i
%        end
%     end; clearvars j
% end    
    
else % multiple persons not detected    
    
% for i = 1:pose.noKeypoints
%     for j = 1:data_openpose.noFiles 
%         eval(['data_openpose.data_personTracked_raw.' pose.keypoints{i} '(' num2str(j) ',:) = data_openpose.data_raw.frame_' num2str(j) '.person_1.' pose.keypoints{i} ';' ])
%     end; clearvars j
% end; clearvars i

data_openpose.pose.data_personTracked_raw = data_openpose.pose.data_raw;
    
end





opts.Interpreter = 'tex';
opts.Default = 'Yes';
data_openpose.direction = questdlg('Is the person walking away or toward from the camera?','Walking direction','Away','Toward',1);

% if strcmp(data_openpose.direction,'Away')

% for j = 1:data_openpose.noFiles 
%     eval(['test_isPerson = ~isempty(data_openpose.data_raw.frame_' num2str(j) ');'])
%     if test_isPerson
%         eval(['no_isPerson = length(fieldnames(data_openpose.data_raw.frame_' num2str(j) '));'])
%         for k = 1:no_isPerson
%             for i = 1:pose.noKeypoints
%                 eval(['data_openpose.data_raw_reOriented.frame_' num2str(j) '.person_' num2str(k) '.' pose.keypoints{i} '(1)  = -data_openpose.data_raw.frame_' num2str(j) '.person_' num2str(k) '.' pose.keypoints{i} '(1) + videoInfo.vid_openpose.Width;' ])
%             end; clearvars i
%         end; clearvars k
%     end
% end; clearvars j
%   
% for i = 1:pose.noKeypoints
%         eval(['data_openpose.data_personTracked_raw_reOriented.' pose.keypoints{i} '(:,1) = -data_openpose.data_personTracked_raw.' pose.keypoints{i} '(:,1) + videoInfo.vid_openpose.Width;' ])
% end; clearvars i 

switch data_openpose.direction
    case 'Away'
%     data(:,:,1) = -data(:,:,1) + width; % shift origin and direction of horizontal axis to ensure direction of travel is positive
    data_openpose.pose.data_personTracked_raw_reOriented(:,:,1) = -data_openpose.pose.data_personTracked_raw(:,:,1) + videoInfo.vid_openpose.Width;
    data_openpose.pose.data_raw_reOriented(:,:,1) = -data_openpose.pose.data_raw(:,:,1) + videoInfo.vid_openpose.Width;
    case 'Toward'
%     data(:,:,1) = data(:,:,1) + width;
    data_openpose.pose.data_personTracked_raw_reOriented(:,:,1) = data_openpose.pose.data_personTracked_raw(:,:,1) + videoInfo.vid_openpose.Width;
    data_openpose.pose.data_raw_reOriented(:,:,1) = data_openpose.pose.data_raw(:,:,1) + videoInfo.vid_openpose.Width;
end




% end

% for j = 1:data_openpose.noFiles 
%     eval(['test_isPerson = ~isempty(data_openpose.data_raw.frame_' num2str(j) ');'])
%     if test_isPerson
%         eval(['no_isPerson = length(fieldnames(data_openpose.data_raw.frame_' num2str(j) '));'])
%         for k = 1:no_isPerson
%             for i = 1:pose.noKeypoints
%                 eval(['data_openpose.data_raw_reOriented.frame_' num2str(j) '.person_' num2str(k) '.' pose.keypoints{i} '(2)  = -data_openpose.data_raw.frame_' num2str(j) '.person_' num2str(k) '.' pose.keypoints{i} '(2) + videoInfo.vid_openpose.Height;' ])
%             end; clearvars i
%         end; clearvars k
%     end
% end; clearvars j
% 
% for i = 1:pose.noKeypoints
%         eval(['data_openpose.data_personTracked_raw_reOriented.' pose.keypoints{i} '(:,2) = -data_openpose.data_personTracked_raw.' pose.keypoints{i} '(:,2) + videoInfo.vid_openpose.Height;' ])
% end; clearvars i

data_openpose.pose.data_personTracked_raw_reOriented(:,:,2) = -data_openpose.pose.data_personTracked_raw(:,:,2) + videoInfo.vid_openpose.Height;
data_openpose.pose.data_raw_reOriented(:,:,2) = -data_openpose.pose.data_raw(:,:,2) + videoInfo.vid_openpose.Height;

save(fullfile(videoInfo.vid_openpose_path,[videoInfo.vid_openpose_name '_openpose.mat']),'data_openpose','videoInfo','frameInfo','openpose');

clearvars -except videoInfo