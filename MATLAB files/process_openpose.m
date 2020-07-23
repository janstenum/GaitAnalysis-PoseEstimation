function output_name = process_openpose()
clearvars -except output_name
[file path] = uigetfile({'*.JSON'},'Pick all JSON files','MultiSelect','on');
[vid_name vid_path] = uigetfile({'*.mov;*.mp4;*.avi;*.qt;*.wmv','Video files (*.mov,*.mp4,*.avi,*.qt,*.wmv)'},'Pick original video file');
[vid_openpose_name vid_openpose_path] = uigetfile({'*.mov;*.mp4;*.avi;*.qt;*.wmv','Video files (*.mov,*.mp4,*.avi,*.qt,*.wmv)'},'Pick OpenPose labeled video file');
cd = pwd;
%%
noLandmarks = 25; % BODY_25 model
noFiles = length(file); % number of files

vid = VideoReader(fullfile(vid_path,vid_name));
vid_openpose = VideoReader(fullfile(vid_openpose_path,vid_openpose_name));
width = vid_openpose.Width; height = vid_openpose.Height;
sR_openpose = vid_openpose.FrameRate;
videoInfo.vid = vid; videoInfo.vid_openpose = vid_openpose;
find_period = find(ismember(vid_name,'.'),1,'last');
output_name = vid_name;
if output_name(find_period) == '.'
    output_name(find_period:end) = [];
end
data = nan(noFiles,noLandmarks,2);
conf = nan(noFiles,noLandmarks);
time_openpose = nan(1,noFiles);
       
for j = 1:noFiles        
    val = jsondecode(fileread(fullfile(path,file{j}))); % load JSON file
    if ~isempty(val.people) % check if any people are detected
        data(j,:,1) = val.people(1).pose_keypoints_2d(1:3:end);
        data(j,:,2) = val.people(1).pose_keypoints_2d(2:3:end);
        conf(j,:) = val.people(1).pose_keypoints_2d(3:3:end);
    end   
end

direction = questdlg('Is the person walking right to left?');
if direction(1) == 'Y'
    data(:,:,1) = -data(:,:,1) + width; % shift origin and direction of horizontal axis to ensure direction of travel is positive
end
data(:,:,2) = -data(:,:,2) + height; % shift origin and direction of vertical axis from upper corner (positive is down) to lower corner (positive is up)

time_openpose = 0:1/sR_openpose:(noFiles-1)/sR_openpose; % time vector

data_openpose.raw_data = data;
data_openpose.time = time_openpose;
data_openpose.conf = conf;

save(fullfile(cd,[output_name '_openpose.mat']),'data_openpose','videoInfo','output_name')

clearvars -except output_name