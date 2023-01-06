function calculate_gaitParameters_jointAngles_sag(videoInfo)
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
%% calculate stance times
for j = 1:length(events_openpose.lhs_frames)
if ~isempty(events_openpose.lhs_frames(events_openpose.lhs_frames > events_openpose.lhs_frames(j)))
    temp_L(j) = ( data_openpose.time(min(events_openpose.lto_frames(events_openpose.lto_frames > events_openpose.lhs_frames(j)))) - data_openpose.time(events_openpose.lhs_frames(j)) ) ;
end
end
gaitParameters.stanceTime.left = temp_L; clearvars j temp_L   
    
for j = 1:length(events_openpose.rhs_frames)
if ~isempty(events_openpose.rhs_frames(events_openpose.rhs_frames > events_openpose.rhs_frames(j)))
    temp_R(j) = ( data_openpose.time(min(events_openpose.rto_frames(events_openpose.rto_frames > events_openpose.rhs_frames(j)))) - data_openpose.time(events_openpose.rhs_frames(j)) ) ;
end
end
gaitParameters.stanceTime.right = temp_R; clearvars j temp_R   
%% calculate swing times
for j = 1:length(events_openpose.lhs_frames)
if ~isempty(events_openpose.lhs_frames(events_openpose.lhs_frames > events_openpose.lhs_frames(j)))
    temp_L(j) = ( data_openpose.time(min(events_openpose.lhs_frames(events_openpose.lhs_frames > events_openpose.lhs_frames(j)))) - data_openpose.time(min(events_openpose.lto_frames(events_openpose.lto_frames > events_openpose.lhs_frames(j)))) ) ;
end
end
gaitParameters.swingTime.left = temp_L; clearvars j temp_L   
    
for j = 1:length(events_openpose.rhs_frames)
if ~isempty(events_openpose.rhs_frames(events_openpose.rhs_frames > events_openpose.rhs_frames(j)))
    temp_R(j) = ( data_openpose.time(min(events_openpose.rhs_frames(events_openpose.rhs_frames > events_openpose.rhs_frames(j)))) - data_openpose.time(min(events_openpose.rto_frames(events_openpose.rto_frames > events_openpose.rhs_frames(j)))) ) ;
end
end
gaitParameters.swingTime.right = temp_R; clearvars j temp_R  
%% calculate double support times
for j = 1:length(events_openpose.lhs_frames)
if ~isempty(events_openpose.lhs_frames(events_openpose.lhs_frames > events_openpose.lhs_frames(j)))
    temp_LR(j) = ( data_openpose.time(min(events_openpose.lto_frames(events_openpose.lto_frames > events_openpose.lhs_frames(j)))) - data_openpose.time(min(events_openpose.rhs_frames(events_openpose.rhs_frames > events_openpose.lhs_frames(j)))) ) ;
end
end
gaitParameters.dsTime.left_to_right = temp_LR; clearvars j temp_LR   
    
for j = 1:length(events_openpose.rhs_frames)
if ~isempty(events_openpose.rhs_frames(events_openpose.rhs_frames > events_openpose.rhs_frames(j)))
    temp_RL(j) = ( data_openpose.time(min(events_openpose.rto_frames(events_openpose.rto_frames > events_openpose.rhs_frames(j)))) - data_openpose.time(min(events_openpose.lhs_frames(events_openpose.lhs_frames > events_openpose.rhs_frames(j)))) ) ;
end
end
gaitParameters.dsTime.right_to_left = temp_RL; clearvars j temp_RL   
%% calculate step lengths
gaitParameters.stepLength.right = abs(data_openpose.scaling.factor*(data_openpose.pose.filt_data(events_openpose.rhs_frames,12,1) - data_openpose.pose.filt_data(events_openpose.rhs_frames,15,1)))';
gaitParameters.stepLength.left = abs(data_openpose.scaling.factor*(data_openpose.pose.filt_data(events_openpose.lhs_frames,15,1) - data_openpose.pose.filt_data(events_openpose.lhs_frames,12,1)))';
%% calculate gait speed
gaitParameters.gaitSpeed = nanmean([gaitParameters.stepLength.left gaitParameters.stepLength.right])/mean([gaitParameters.stepTime.left gaitParameters.stepTime.right]);
%% calculate hip angles
jointAngles.sag_2D.LHip = atan2d(data_openpose.pose.filt_data(:,14,2)-data_openpose.pose.filt_data(:,13,2),data_openpose.pose.filt_data(:,14,1)-data_openpose.pose.filt_data(:,13,1)) + 90;
jointAngles.sag_2D.RHip = atan2d(data_openpose.pose.filt_data(:,11,2)-data_openpose.pose.filt_data(:,10,2),data_openpose.pose.filt_data(:,11,1)-data_openpose.pose.filt_data(:,10,1)) + 90;
%% calculate knee angles
jointAngles.sag_2D.LKnee = atan2d(data_openpose.pose.filt_data(:,13,2)-data_openpose.pose.filt_data(:,14,2),data_openpose.pose.filt_data(:,13,1)-data_openpose.pose.filt_data(:,14,1)) - atan2d(data_openpose.pose.filt_data(:,15,2)-data_openpose.pose.filt_data(:,14,2),data_openpose.pose.filt_data(:,15,1)-data_openpose.pose.filt_data(:,14,1)) - 180;
jointAngles.sag_2D.RKnee = atan2d(data_openpose.pose.filt_data(:,10,2)-data_openpose.pose.filt_data(:,11,2),data_openpose.pose.filt_data(:,10,1)-data_openpose.pose.filt_data(:,11,1)) - atan2d(data_openpose.pose.filt_data(:,12,2)-data_openpose.pose.filt_data(:,11,2),data_openpose.pose.filt_data(:,12,1)-data_openpose.pose.filt_data(:,11,1)) - 180;
%% calculate ankle angles
jointAngles.sag_2D.LAnkle = - ( atan2d(data_openpose.pose.filt_data(:,14,2)-data_openpose.pose.filt_data(:,15,2),data_openpose.pose.filt_data(:,14,1)-data_openpose.pose.filt_data(:,15,1)) - atan2d(data_openpose.pose.filt_data(:,20,2)-data_openpose.pose.filt_data(:,15,2),data_openpose.pose.filt_data(:,20,1)-data_openpose.pose.filt_data(:,15,1)) - 100 );
jointAngles.sag_2D.RAnkle = - ( atan2d(data_openpose.pose.filt_data(:,11,2)-data_openpose.pose.filt_data(:,12,2),data_openpose.pose.filt_data(:,11,1)-data_openpose.pose.filt_data(:,12,1)) - atan2d(data_openpose.pose.filt_data(:,23,2)-data_openpose.pose.filt_data(:,12,2),data_openpose.pose.filt_data(:,23,1)-data_openpose.pose.filt_data(:,12,1)) - 100 );
jointAngles.sag_2D.time = data_openpose.time;
%% save
save(fullfile(videoInfo.vid_openpose_path,[videoInfo.vid_openpose_name '_openpose.mat']),'gaitParameters','jointAngles','-append')
clear