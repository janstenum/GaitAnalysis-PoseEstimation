% function  trackPerson_auto = trackPerson_openpose_automatic_tracking(data,conf,time_openpose,numberPersonsDetected,trackPerson_manual_input,bodyModel_input)
function  personTrack = trackPerson_openpose_automatic_tracking(data_openpose,videoInfo,frameInfo,openpose,personTrack)
global personTrack
trackedFrames = personTrack.trackPerson_manual_input.saved_startTrackFrame:personTrack.trackPerson_manual_input.saved_endTrackFrame;
no_trackedFrames = length(trackedFrames);
noFrames = data_openpose.noFiles;

switch openpose.pose.bodyModel;
    case 'BODY_25'
        index_Markers = openpose.pose.keypoints;
        index_Markers = 1:25;
    case 'BODY_21'
        index_Markers = openpose.pose.keypoints;
end

data = data_openpose.pose.data_raw;
tracked_data = nan(noFrames,openpose.pose.noKeypoints,2);
tracked_data(personTrack.trackPerson_manual_input.saved_anchorFrame,:,:) = data(personTrack.trackPerson_manual_input.saved_anchorID,personTrack.trackPerson_manual_input.saved_anchorFrame,:,:);

% for i = 1:pose.noKeypoints
%     eval(['personTrack.trackPerson_auto.data_personTracked.' pose.keypoints{i} ' = nan(' num2str(noFrames) ',2);' ])
% %         for j = trackedFrames(1):trackedFrames(2)
%             eval(['personTrack.trackPerson_auto.data_personTracked.' pose.keypoints{i} '(' num2str(personTrack.trackPerson_manual_input.saved_anchorFrame) ',:) = data_openpose.data_raw.frame_' num2str(personTrack.trackPerson_manual_input.saved_anchorFrame) '.person_' num2str(personTrack.trackPerson_manual_input.saved_anchorID) '.' pose.keypoints{i} ';' ])
% %         end; clearvars j
% end; clearvars i

personTrack.trackPerson_auto.autoTrack_personID = nan(noFrames,1);
personTrack.trackPerson_auto.autoTrack_personID(personTrack.trackPerson_manual_input.saved_anchorFrame) = personTrack.trackPerson_manual_input.saved_anchorID;

% index_Markers = [9:15];
%% forward tracking (relative to anchor point)
prev_anchor = data(personTrack.trackPerson_manual_input.saved_anchorID,personTrack.trackPerson_manual_input.saved_anchorFrame,:,:);

% for i = 1:pose.noKeypoints
% %     eval(['prev_anchor.' pose.keypoints{i} ' = nan(' num2str(noFrames) ',2);' ])
% %         for j = trackedFrames(1):trackedFrames(2)
%             eval(['prev_anchor.' pose.keypoints{i} ' = data_openpose.data_raw.frame_' num2str(personTrack.trackPerson_manual_input.saved_anchorFrame) '.person_' num2str(personTrack.trackPerson_manual_input.saved_anchorID) '.' pose.keypoints{i} ';' ])
% %         end; clearvars j
% end; clearvars i

% prev_anchor = nan(length(index_Markers),2);
% for k = 1:length(index_Markers)
%     eval(['prev_anchor(' num2str(k) ',:) = data_openpose.data_raw.frame_' num2str(personTrack.trackPerson_manual_input.saved_anchorFrame) '.person_' num2str(personTrack.trackPerson_manual_input.saved_anchorID) '.' index_Markers{k} ';'])
% end; clearvars k

for i = personTrack.trackPerson_manual_input.saved_anchorFrame+1:personTrack.trackPerson_manual_input.saved_endTrackFrame

noPersonsDetected_frame = frameInfo.numberPersonsDetected(i);
    if noPersonsDetected_frame ~= 0
    dist_prev_anchor = nan(noPersonsDetected_frame,1);
    next_anchor_ID = [];
        for j = 1:noPersonsDetected_frame
            
%             temp_dist_prev_anchor = nan(length(index_Markers),2);
%             for k = 1:length(index_Markers)
%                 eval(['temp_dist_prev_anchor(' num2str(k) ',:) =  data_openpose.data_raw.frame_' num2str(i) '.person_' num2str(j) '.' index_Markers{k} ';'])
%             end; clearvars k
            
%             dist_prev_anchor(j) = nanmean(sqrt(sum(squeeze(prev_anchor(:,:,index_Markers,:) - data(j,i,index_Markers,:)).^2,2)));
%             dist_prev_anchor(j) = nanmean(sqrt(sum((prev_anchor-temp_dist_prev_anchor).^2,2)));
        end

        if all(isnan(dist_prev_anchor)) % if the auto-track keypoints yield no data, then use all keypoints to auto-track
            for j = 1:noPersonsDetected_frame
            
%             temp_dist_prev_anchor = nan(length(pose.keypoints),2);
%             for k = 1:length(pose.keypoints)
%                 eval(['temp_dist_prev_anchor(' num2str(k) ',:) =  data_openpose.data_raw.frame_' num2str(i) '.person_' num2str(j) '.' pose.keypoints{k} ';'])
%             end; clearvars k
            
            dist_prev_anchor(j) = nanmean(sqrt(sum(squeeze(prev_anchor(:,:,index_Markers,:) - data(j,i,index_Markers,:)).^2,2)));
%             dist_prev_anchor(j) = nanmean(sqrt(sum((prev_anchor-temp_dist_prev_anchor).^2,2)));
            
%                 dist_prev_anchor(j) = nanmean(sqrt(sum(squeeze(prev_anchor(:,:,:,:) - data(j,i,:,:)).^2,2)));
            end    
        end

        if any(~isnan(dist_prev_anchor)) % check that there is a candidate auto-tracked ID
        [M I] = min(dist_prev_anchor);
            if isnan(M)

            else
                next_anchor_ID = I;
            end

%         for k = 1:pose.noKeypoints
%             eval(['personTrack.trackPerson_auto.data_personTracked.' pose.keypoints{k} '(' num2str(i) ',:) = data_openpose.data_raw.frame_' num2str(i) '.person_' num2str(next_anchor_ID) '.' pose.keypoints{k} ';' ])
%         end; clearvars k
        tracked_data(i,:,:) = data(next_anchor_ID,i,:,:);


%         prev_anchor = nan(length(index_Markers),2);
%         for k = 1:length(index_Markers)
%             eval(['prev_anchor(' num2str(k) ',:) = data_openpose.data_raw.frame_' num2str(i) '.person_' num2str(next_anchor_ID) '.' index_Markers{k} ';'])
%         end; clearvars k
        prev_anchor = data(next_anchor_ID,i,:,:);

        personTrack.trackPerson_auto.autoTrack_personID(i) = I;
        else

        end



    else

    end
end
%% backward tracking (relative to anchor point)
prev_anchor = data(personTrack.trackPerson_manual_input.saved_anchorID,personTrack.trackPerson_manual_input.saved_anchorFrame,:,:);

% prev_anchor = nan(length(index_Markers),2);
% for k = 1:length(index_Markers)
%     eval(['prev_anchor(' num2str(k) ',:) = data_openpose.data_raw.frame_' num2str(personTrack.trackPerson_manual_input.saved_anchorFrame) '.person_' num2str(personTrack.trackPerson_manual_input.saved_anchorID) '.' index_Markers{k} ';'])
% end; clearvars k


for i = flip(personTrack.trackPerson_manual_input.saved_startTrackFrame:personTrack.trackPerson_manual_input.saved_anchorFrame-1)


noPersonsDetected_frame = frameInfo.numberPersonsDetected(i);
    if noPersonsDetected_frame ~= 0
    dist_prev_anchor = nan(noPersonsDetected_frame,1);
    next_anchor_ID = [];
        for j = 1:noPersonsDetected_frame
            
%             temp_dist_prev_anchor = nan(length(index_Markers),2);
%             for k = 1:length(index_Markers)
%                 eval(['temp_dist_prev_anchor(' num2str(k) ',:) =  data_openpose.data_raw.frame_' num2str(i) '.person_' num2str(j) '.' index_Markers{k} ';'])
%             end; clearvars k
            
            dist_prev_anchor(j) = nanmean(sqrt(sum(squeeze(prev_anchor(:,:,index_Markers,:) - data(j,i,index_Markers,:)).^2,2)));
%             dist_prev_anchor(j) = nanmean(sqrt(sum((prev_anchor-temp_dist_prev_anchor).^2,2)));
        end

        if all(isnan(dist_prev_anchor)) % if the auto-track keypoints yield no data, then use all keypoints to auto-track
            for j = 1:noPersonsDetected_frame
            
%             temp_dist_prev_anchor = nan(length(pose.keypoints),2);
%             for k = 1:length(pose.keypoints)
%                 eval(['temp_dist_prev_anchor(' num2str(k) ',:) =  data_openpose.data_raw.frame_' num2str(i) '.person_' num2str(j) '.' pose.keypoints{k} ';'])
%             end; clearvars k
            
            dist_prev_anchor(j) = nanmean(sqrt(sum(squeeze(prev_anchor(:,:,index_Markers,:) - data(j,i,index_Markers,:)).^2,2)));
%             dist_prev_anchor(j) = nanmean(sqrt(sum((prev_anchor-temp_dist_prev_anchor).^2,2)));
            
%                 dist_prev_anchor(j) = nanmean(sqrt(sum(squeeze(prev_anchor(:,:,:,:) - data(j,i,:,:)).^2,2)));
            end    
        end

        if any(~isnan(dist_prev_anchor)) % check that there is a candidate auto-tracked ID
        [M I] = min(dist_prev_anchor);
            if isnan(M)

            else
                next_anchor_ID = I;
            end

%         for k = 1:pose.noKeypoints
%             eval(['personTrack.trackPerson_auto.data_personTracked.' pose.keypoints{k} '(' num2str(i) ',:) = data_openpose.data_raw.frame_' num2str(i) '.person_' num2str(next_anchor_ID) '.' pose.keypoints{k} ';' ])
%         end; clearvars k
        tracked_data(i,:,:) = data(next_anchor_ID,i,:,:);


%         prev_anchor = nan(length(index_Markers),2);
%         for k = 1:length(index_Markers)
%             eval(['prev_anchor(' num2str(k) ',:) = data_openpose.data_raw.frame_' num2str(i) '.person_' num2str(next_anchor_ID) '.' index_Markers{k} ';'])
%         end; clearvars k
        prev_anchor = data(next_anchor_ID,i,:,:);

        personTrack.trackPerson_auto.autoTrack_personID(i) = I;
        else

        end

    else

    end    
    
    
% noPersonsDetected_frame = numberPersonsDetected(i);
%     if noPersonsDetected_frame ~= 0
%     dist_prev_anchor = nan(noPersonsDetected_frame,1);
%     next_anchor_ID = [];
%         for j = 1:noPersonsDetected_frame
%             dist_prev_anchor(j) = nanmean(sqrt(sum(squeeze(prev_anchor(:,:,index_Markers,:) - data(j,i,index_Markers,:)).^2,2)));
%         end
%         
%         if all(isnan(dist_prev_anchor))
%             for j = 1:noPersonsDetected_frame
%                 dist_prev_anchor(j) = nanmean(sqrt(sum(squeeze(prev_anchor(:,:,:,:) - data(j,i,:,:)).^2,2)));
%             end    
%         end
%         
%     if any(~isnan(dist_prev_anchor))
%     [M I] = min(dist_prev_anchor);
%         if isnan(M)
% 
%         else
%             next_anchor_ID = I;
%         end
%     tracked_data(i,:,:) = data(next_anchor_ID,i,:,:);
% 
%     prev_anchor = data(next_anchor_ID,i,:,:);
% 
%     autoTrack_personID(i) = I;
%     else
% 
%     end
% 
%     else
% 
%     end
    
end
personTrack.trackPerson_auto.data_personTracked = tracked_data;
% trackPerson_auto.autoTrack_personID = autoTrack_personID;
% trackPerson_auto.tracked_data = tracked_data;
end