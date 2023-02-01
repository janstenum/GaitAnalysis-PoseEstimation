function calculate_gaitParameters_front(videoInfo)
clearvars -except videoInfo

load(fullfile(videoInfo.vid_openpose_path,[videoInfo.vid_openpose_name '_openpose.mat']),'data_openpose','events_openpose')
%% calculate step times
for j = 1:length(events_openpose.lhs_frames)
if ~isempty(events_openpose.rhs_frames(events_openpose.rhs_frames > events_openpose.lhs_frames(j)))
    temp_LR(j) = data_openpose.time(min(events_openpose.rhs_frames(events_openpose.rhs_frames > events_openpose.lhs_frames(j)))) - data_openpose.time(events_openpose.lhs_frames(j));
end
end
gaitParameters.stepTime.right = temp_LR; clearvars j temp_LR   
    
for j = 1:length(events_openpose.rhs_frames)
if ~isempty(events_openpose.lhs_frames(events_openpose.lhs_frames > events_openpose.rhs_frames(j)))
    temp_RL(j) = data_openpose.time(min(events_openpose.lhs_frames(events_openpose.lhs_frames > events_openpose.rhs_frames(j)))) - data_openpose.time(events_openpose.rhs_frames(j));
end
end
gaitParameters.stepTime.left = temp_RL; clearvars j temp_RL   
%% calculate step lengths
for j = 1:length(events_openpose.lhs_frames)
if ~isempty(events_openpose.rhs_frames(events_openpose.rhs_frames > events_openpose.lhs_frames(j)))
    temp_LR_op(j) = data_openpose.depth_change(min(events_openpose.rhs_frames(events_openpose.rhs_frames > events_openpose.lhs_frames(j)))) - data_openpose.depth_change(events_openpose.lhs_frames(j));
end
end
gaitParameters.stepLength.right = temp_LR_op; clearvars j temp_LR
    
for j = 1:length(events_openpose.rhs_frames)
if ~isempty(events_openpose.lhs_frames(events_openpose.lhs_frames > events_openpose.rhs_frames(j)))
    temp_RL_mc(j) = data_openpose.depth_change(min(events_openpose.lhs_frames(events_openpose.lhs_frames > events_openpose.rhs_frames(j)))) - data_openpose.depth_change(events_openpose.rhs_frames(j));
end
end
gaitParameters.stepLength.left = temp_RL_mc; clearvars j temp_RL

% gaitParameters.stepLength.right = abs(data_openpose.scaling.factor*(data_openpose.pose.filt_data(events_openpose.rhs_frames,12,1) - data_openpose.pose.filt_data(events_openpose.rhs_frames,15,1)))';
% gaitParameters.stepLength.left = abs(data_openpose.scaling.factor*(data_openpose.pose.filt_data(events_openpose.lhs_frames,15,1) - data_openpose.pose.filt_data(events_openpose.lhs_frames,12,1)))';
%% calculate gait speed
gaitParameters.gaitSpeed = nanmean([gaitParameters.stepLength.left gaitParameters.stepLength.right])/mean([gaitParameters.stepTime.left gaitParameters.stepTime.right]);
%% save
save(fullfile(videoInfo.vid_openpose_path,[videoInfo.vid_openpose_name '_openpose.mat']),'gaitParameters','-append')
clear