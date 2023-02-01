% function [trackPerson_inspect] = trackPerson_openpose_visual_inspection(data_input,conf,time_openpose,numberPersonsDetected_input,vid_openpose,trackPerson_manual_input,trackPerson_auto_input,output_name,bodyModel_input)
function [personTrack] = trackPerson_openpose_visual_inspection(data_openpose,videoInfo,frameInfo,openpose,personTrack)
global v frame data hp hl name numberPersonsDetected index_Lines subC h_manPick pickPersonFig h_showCurrentFrame pickPersonID ...
    anchorFrame anchorID h_anchorPushButton startTrackFrame endTrackFrame h_setStartTracking h_setEndTracking ...
    checkPoints h_checkPoints selectedCheckPoints ...
    h_currentFrame_popup h_currentFrame_slider noFrames h_currentFrame_edit hCursor h_image cursorID h_timeSeries_axes h_ankles_currentFrame ...
    h_image_axes autoTrack_personID seqFrames correct_ID_pushbutton h_correctID inspectionTrack_personID ...
    inspect_data_visual h_timeSeries_inspect h_legend_ankles h_conflict_checkPoints h_agree_checkPoints h_revertID ...
    trackPerson_auto trackPerson_inspect h_trackBox inspection_partialTrack_personID ...
    h_add_frame is_add_frame data_add_frame trackPerson_manual_input h_timeSeries_frame_to_frame_dist_axes ...
    h_frameToFrame_currentFrame dataJumps h_dataJumps index_Markers h_delete_startFrame h_delete_endFrame h_deleteID ...
    manualDeletedFrames h_title_image h_title_timeSeries_pos showTimeSeries_markers h_autoTrack_startFrame h_autoTrack_endFrame h_forward h_backward ...
    inspect_data poseModel noLandmarks trackPerson inspection_keypoints h_uicontrol hp_color pose personTrack
pose = openpose.pose;
poseModel = openpose.pose;
% bodyModel = bodyModel_input;
switch poseModel.bodyModel
    case 'BODY_25'
        index_Lines = {'LWrist'; 'LElbow';'LShoulder'; 'Neck'; 'LEye'; 'LEar'; 'LEye'; 'REye'; 'REar'; 'REye'; 'Neck'; ...
            'RShoulder'; 'RElbow'; 'RWrist'; ...
            'RElbow';'RShoulder'; 'Neck'; 'MidHip'; 'RHip'; 'RKnee'; 'RAnkle'; 'RHeel'; ...
            'RBigToe'; 'RSmallToe'; 'RAnkle'; 'RKnee'; 'RHip'; 'MidHip'; 'LHip'; 'LKnee'; ...
            'LAnkle'; 'LHeel'; 'LBigToe'; 'LSmallToe'};
        index_Lines = [8 7 6 2 17 19 17 16 18 16 2 3 4 5 4 3 2 9 10 11 12 25 23 24 12 11 10 9 13 14 15 22 20 21];
    case 'BODY_21'
        index_Lines = [19 17 1 16 18 18 16 16 1 1 2 2 3 3 4 4 5 5 4 4 3 3 2 2 6 6 7 7 8 8 7 7 6 6 2 2 9 9 10 10 11 11 12 12 11 11 10 10 9 9 13 13 14 14 15];
end

inspection_keypoints = {'MidHip'};
inspection_keypoints = [9];

trackPerson_auto.tracked_data = personTrack.trackPerson_auto.data_personTracked;


data = data_openpose.pose.data_raw;
numberPersonsDetected = frameInfo.numberPersonsDetected;
% numberPersonsDetected = numberPersonsDetected_input;
subC = {'r','b','c','m','g','y','w','k'};
hp_color.tracked = {[1 0 0],[213 94 0]/256,[204 121 167]/256,[230 159 0]/256};
hp_color.notTracked = {[1 1 1]};%{[86 180 233]/256};
v = videoInfo.vid_openpose;
% index_Lines = [7 8 7 6 2 6 2 3 3 4 4 5 4 3 2 3 2 9 9 10 10 11 11 12 12 25 25 23 23 24 24 12 12 11 11 10 9 10 9 13 13 14 14 15 15 22 22 20 20 21 21 15];

noFrames = data_openpose.noFiles;
% [maxPersonsDetected noFrames noKeyPoints noDim] = size(data);
manualTrackedPersonIndex = nan(noFrames,1);
frame = personTrack.trackPerson_manual_input.saved_startTrackFrame;
name = videoInfo.vid_openpose_name;
pickPersonID = 1;
anchorFrame = [];
anchorID = [];
startTrackFrame = personTrack.trackPerson_manual_input.saved_startTrackFrame;
endTrackFrame = personTrack.trackPerson_manual_input.saved_endTrackFrame;
seqFrames = startTrackFrame:endTrackFrame;
noFrames_inspection = length(personTrack.trackPerson_manual_input.saved_startTrackFrame:personTrack.trackPerson_manual_input.saved_endTrackFrame);
checkPoints = [];
selectedCheckPoints = [];
cursorID = [];
autoTrack_personID = personTrack.trackPerson_auto.autoTrack_personID;
correct_ID_pushbutton = '?';
inspectionTrack_personID = personTrack.trackPerson_auto.autoTrack_personID;
inspection_partialTrack_personID = nan(noFrames,noLandmarks);

inspect_data_visual = personTrack.trackPerson_auto.data_personTracked(:,inspection_keypoints,1);
% for k = 1:length(inspection_keypoints)
% % eval(['inspect_data_visual.' inspection_keypoints{k} ' = getfield(personTrack.trackPerson_auto.data_personTracked,''' inspection_keypoints{k} ''');'])
% inspect_data_visual(k,:) = squeeze(data(personTrack.trackPerson_auto.autoTrack_personID,inspection_keypoints(k),:,1));
% end; clearvars k

% trackPerson_auto = trackPerson_auto_input;

h_add_frame = cell(noFrames,1);
is_add_frame = false(noFrames,1);
data_add_frame = cell(noFrames,1);

switch poseModel.bodyModel
    case 'BODY_25'
        index_Markers = openpose.pose.keypoints;
        index_Markers = 1:25;
    case 'BODY_21'
        index_Markers = openpose.pose.keypoints;
end
% index_Markers = [9:15];

inspect_data = personTrack.trackPerson_auto.data_personTracked;
% inspect_data = trackPerson_auto_input.tracked_data;

pickPersonFig = figure; set(pickPersonFig,'WindowStyle','docked'); hold on

h_uicontrol.grayRadioButton = uicontrol(pickPersonFig,'Style','checkbox','String','Gray','Value',1,'fontunits','normalized','fontsize',.7,...
                  'units','normalized','Position',[.01 .225 .05 .025],'Callback',@grayScale);

h_image_axes = subplot(4,8,[5:8 13:16 21:24]);hold on; set(h_image_axes,'fontunits','normalized')
if h_uicontrol.grayRadioButton.Value == 0
h_image = imshow(read(v,frame),'InitialMagnification','fit','Parent',h_image_axes);
elseif h_uicontrol.grayRadioButton.Value == 1
h_image = imshow(rgb2gray(read(v,frame)),'InitialMagnification','fit','Parent',h_image_axes);    
end

h_timeSeries_frame_to_frame_dist_axes = subplot(4,8,[25:28]);hold on,set(h_timeSeries_frame_to_frame_dist_axes,'fontunits','normalized','fontsize',.15,'color','none','XLim',[startTrackFrame endTrackFrame])
calcDataJumps
h_timeSeries_axes = subplot(4,8,[1:4 9:12 17:20]);hold on,set(h_timeSeries_axes,'fontunits','normalized','fontsize',.037,'color','none','XLim',[startTrackFrame endTrackFrame])
plotInspection_timeSeries
linkaxes([h_timeSeries_frame_to_frame_dist_axes h_timeSeries_axes],'x')

manualDeletedFrames = false(noFrames,1);
showTimeSeries_markers = [12 15];
h_agree_checkPoints = [];
h_conflict_checkPoints = [];


hp = cell(numberPersonsDetected(frame),1);
hp_legend = nan(numberPersonsDetected(frame),1);
hp_legend_labels = cell(numberPersonsDetected(frame),1);
for i = 1:numberPersonsDetected(frame)
% t = [];
% t = nan(length(index_Lines),2);
%     for j = 1:length(index_Lines)
%         eval(['t(j,:) = [data.frame_' num2str(frame) '.person_' num2str(i) '.' index_Lines{j} '(1),data.frame_' num2str(frame) '.person_' num2str(i) '.' index_Lines{j} '(2)];'])
%     end
t = squeeze(data(i,frame,index_Lines,:));

if i == inspectionTrack_personID(frame)
    hp{i} = plot(h_image_axes,t(:,1),t(:,2),'.-','color',hp_color.tracked{1},'markersize',8,'linewidth',2,'DisplayName',['ID ' num2str(i)]); 
else
    hp{i} = plot(h_image_axes,t(:,1),t(:,2),'.-','color',hp_color.notTracked{1},'markersize',8,'linewidth',2,'DisplayName',['ID ' num2str(i)]); 
end
% hp{i} = plot(h_image_axes,t(:,1),t(:,2),'.-','color',subC{i},'markersize',8,'linewidth',2,'DisplayName',['ID ' num2str(i)]);
end; clearvars i 
title(h_image_axes,name,'interpreter','none','fontunits','normalized','fontsize',.07)

if ~isnan(inspectionTrack_personID(frame))
h_trackBox = rectangle(h_image_axes,'Position',[min(hp{inspectionTrack_personID(frame)}.XData) min(hp{inspectionTrack_personID(frame)}.YData)  range(hp{inspectionTrack_personID(frame)}.XData) range(hp{inspectionTrack_personID(frame)}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);
end



h_uicontrol.select_inspectionKeypoints = uicontrol(pickPersonFig,'Style','listbox','String',openpose.pose.keypoints,...
    'Value',[9],'min',0,'max',2,'fontunits','points','fontsize',5,'units','normalized','Position',[.01 .9 .06 .1],'Callback',@select_inspectKeypoints);

h_currentFrame_slider = uicontrol(pickPersonFig,'style','slider','Min',startTrackFrame,'Max',endTrackFrame,'SliderStep',[1/noFrames_inspection 10/noFrames_inspection],'Value',frame,...
   'units','normalized','Position',[0.52 0.3 0.2 0.05],'Callback',@currentFrame_slider); % choose frame
h_currentFrame_popup = uicontrol(pickPersonFig,'style','popupmenu','string',num2cell(seqFrames) ,'Value',frame-startTrackFrame+1,'fontunits','normalized','fontsize',.4,...
   'units','normalized','Position',[0.73 0.35 0.09 0.05],'Callback',@currentFrame_popup); % choose frame
h_currentFrame_popup.Visible = 'off';
h_currentFrame_edit = uicontrol(pickPersonFig,'style','edit','string',num2str(frame),'fontunits','normalized','fontsize',.4,...
   'units','normalized','Position',[0.73 0.3 0.05 0.05],'Callback',@currentFrame_edit); % choose frame
h_showCurrentFrame = annotation(pickPersonFig,'textbox','String',['Frame: ' num2str(frame)], 'Position', [0.52 0.3 0.2 0.05],'edgecolor',[1 1 1],'fontunits','normalized','fontsize',.03);
h_showCurrentFrame.Visible = 'off';

h_manPick = uicontrol(pickPersonFig,'style','popupmenu','String',num2cell(1:numberPersonsDetected(frame)),'value',pickPersonID,'fontunits','normalized','fontsize',.5,...
   'units','normalized','Position',[0.9 0.55 0.1 0.05],'Callback',@pickPerson); % choose frame
h_manPick.Visible = 'off';
% annotation(pickPersonFig,'textbox','String','Pick Person ID', 'Position', [0.9 0.59 0.2 0.05],'edgecolor',[1 1 1],'fontunits','normalized','fontsize',.02);


h_correctID = uicontrol(pickPersonFig,'style','pushbutton','string',['Correct: ID ' num2str(autoTrack_personID(frame)) ' to ' num2str(correct_ID_pushbutton)],'fontunits','normalized','fontsize',.4,...
    'units','normalized','Position',[0.52 0.2 0.15 0.05],'Callback',@correctID);
h_revertID = uicontrol(pickPersonFig,'style','pushbutton','string',['Revert ID of current frame'],'fontunits','normalized','fontsize',.4,...
    'units','normalized','Position',[0.52 0.15 0.15 0.05],'Callback',@revertID);
h_revertAllID = uicontrol(pickPersonFig,'style','pushbutton','string',['Revert all IDs'],'fontunits','normalized','fontsize',.4,...
    'units','normalized','Position',[0.52 0.1 0.15 0.05],'Callback',@revertAllID);

h_delete_set_currentFrame = uicontrol(pickPersonFig,'style','pushbutton','string','Set current frame for deletion','fontunits','normalized','fontsize',.7,...
    'units','normalized','Position',[.685 .2 .15 .025],'callback',@setCurrentFrameDelete);
h_delete_set_startFrame = uicontrol(pickPersonFig,'style','pushbutton','string','Set start','fontunits','normalized','fontsize',.7,...
    'units','normalized','Position',[.685 .175 .075 .025],'callback',@setStartFrameDelete);
h_delete_set_EndFrame = uicontrol(pickPersonFig,'style','pushbutton','string','Set end','fontunits','normalized','fontsize',.7,...
    'units','normalized','Position',[.76 .175 .075 .025],'callback',@setEndFrameDelete);
h_delete_startFrame = uicontrol(pickPersonFig,'style','edit','string','Start Frame','fontunits','normalized','fontsize',.7,...
    'units','normalized','Position',[.685 .15 .075 .025]);
h_delete_endFrame = uicontrol(pickPersonFig,'style','edit','string','End Frame','fontunits','normalized','fontsize',.7,...
    'units','normalized','Position',[.76 .15 .075 .025]);
h_deleteID = uicontrol(pickPersonFig,'style','pushbutton','string','Delete ID','fontunits','normalized','fontsize',.4,...
    'units','normalized','Position',[.685 .1 .15 .05],'Callback',@deleteID);

h_forward = uicontrol(pickPersonFig,'Style','radiobutton','String','Forward','Value',1,'fontunits','normalized','fontsize',.7,...
                  'units','normalized','Position',[.85 .225 .1 .025],'Callback',@forwardAutoTrack);
h_backward = uicontrol(pickPersonFig,'Style','radiobutton','String','Backward','Value',0,'fontunits','normalized','fontsize',.7,...
                  'units','normalized','Position',[.85 .2 .1 .025],'Callback',@backwardAutoTrack);
h_autoTrack_set_startFrame = uicontrol(pickPersonFig,'style','pushbutton','string','Set start','fontunits','normalized','fontsize',.7,...
    'units','normalized','Position',[.85 .175 .075 .025],'callback',@setStartFrameAutoTrack);
h_autoTrack_set_EndFrame = uicontrol(pickPersonFig,'style','pushbutton','string','Set end','fontunits','normalized','fontsize',.7,...
    'units','normalized','Position',[.925 .175 .075 .025],'callback',@setEndFrameAutoTrack);
h_autoTrack_startFrame = uicontrol(pickPersonFig,'style','edit','string','Start Frame','fontunits','normalized','fontsize',.7,...
    'units','normalized','Position',[.85 .15 .075 .025]);
h_autoTrack_endFrame = uicontrol(pickPersonFig,'style','edit','string','End Frame','fontunits','normalized','fontsize',.7,...
    'units','normalized','Position',[.925 .15 .075 .025]);
h_autoTrack = uicontrol(pickPersonFig,'style','pushbutton','string','Auto Track','fontunits','normalized','fontsize',.4,...
    'units','normalized','Position',[.85 .1 .15 .05],'Callback',@autoTrack);

h_partialPersonTrack = uicontrol(pickPersonFig,'style','pushbutton','string','Partial Tracking','fontunits','normalized','fontsize',.4,...
    'units','normalized','Position',[0.85 0.3 0.15 0.05],'Callback',@partialPersonTrack);
h_saveCont = uicontrol(pickPersonFig,'style','pushbutton','string','Save and Continue','fontunits','normalized','fontsize',.4,...
    'units','normalized','Position',[0.685 0.0 0.15 0.05],'Callback',@saveCont);

hCursor = datacursormode(pickPersonFig); set(hCursor,'UpdateFcn',@myCursor);
datacursormode on

h_zoom_on = uicontrol(pickPersonFig,'style','pushbutton','string','Zoom','fontunits','normalized','fontsize',.3,...
    'units','normalized','Position',[.01 .3 .05 .05],'Callback',@zoomOn);
h_cursor_on = uicontrol(pickPersonFig,'style','pushbutton','string','Cursor','fontunits','normalized','fontsize',.3,...
    'units','normalized','Position',[.01 .35 .05 .05],'Callback',@cursorOn);
h_pan_on = uicontrol(pickPersonFig,'style','pushbutton','string','Pan','fontunits','normalized','fontsize',.3,...
    'units','normalized','Position',[.01 .4 .05 .05],'Callback',@panOn);

uiwait(pickPersonFig)
end
%% "Forward" radiobutton
function forwardAutoTrack(source,event)
global h_forward h_backward
h_forward.Value = 1;
h_backward.Value = 0;
end
%% "Backward" radiobutton
function backwardAutoTrack(source,event)
global h_forward h_backward
h_forward.Value = 0;
h_backward.Value = 1;
end
%% "Set start (frame for auto tracking)" pushbutton
function setStartFrameAutoTrack(source,event)
global h_autoTrack_startFrame frame
h_autoTrack_startFrame.String = num2str(frame);
end
%% "Set end (frame for auto tracking)" pushbutton
function setEndFrameAutoTrack(source,event)
global h_autoTrack_endFrame frame
h_autoTrack_endFrame.String = num2str(frame);
end
%% "Auto Track" pushbutton
function autoTrack(source,event)
global h_forward h_backward h_autoTrack_startFrame h_autoTrack_endFrame data inspectionTrack_personID numberPersonsDetected ...
    startTrackFrame endTrackFrame h_timeSeries_inspect h_timeSeries_axes inspect_data_visual ...
    dataJumps h_dataJumps manualDeletedFrames showTimeSeries_markers index_Markers inspect_data noLandmarks ...
    h_title_timeSeries_pos frame h_correctID h_trackBox h_image_axes hp subC pose poseModel inspection_keypoints noFrames

if any(startTrackFrame:endTrackFrame == str2double(h_autoTrack_startFrame.String)) && any(startTrackFrame:endTrackFrame == str2double(h_autoTrack_endFrame.String)) ...
    && str2double(h_autoTrack_startFrame.String) <= str2double(h_autoTrack_endFrame.String)

if h_forward.Value == 1
    promptAutoTrack = questdlg(['Are you sure you want to auto track forward from frame ' h_autoTrack_startFrame.String ' to ' h_autoTrack_endFrame.String '?'],'Auto track person ID','Yes','No',2);
elseif h_backward.Value == 1
    promptAutoTrack = questdlg(['Are you sure you want to auto track backward from frame ' h_autoTrack_endFrame.String ' to ' h_autoTrack_startFrame.String '?'],'Auto track person ID','Yes','No',2);
end
if strcmp(promptAutoTrack,'Yes')


if h_forward.Value == 1


    autoTrackStartFrame = str2double(h_autoTrack_startFrame.String);
    autoTrackEndFrame = str2double(h_autoTrack_endFrame.String);

%     noFrames = length(startTrackFrame:endTrackFrame);
%     tracked_data = nan(noFrames,noLandmarks,2);
%     tracked_data(autoTrackStartFrame,:,:) = data(inspectionTrack_personID(autoTrackStartFrame),autoTrackStartFrame,:,:);
    autoTrack_personID = nan(noFrames,1);
    autoTrack_personID(autoTrackStartFrame) = inspectionTrack_personID(autoTrackStartFrame);

%     prev_anchor = nan(length(index_Markers),2);
%     for k = 1:length(index_Markers)
%                 eval(['prev_anchor(' num2str(k) ',:) = inspect_data.' index_Markers{k} '(autoTrackStartFrame,:);'])
%         %         eval(['prev_anchor(' num2str(k) ',:) = data_openpose.data_raw.frame_' num2str(personTrack.trackPerson_manual_input.saved_anchorFrame) '.person_' num2str(personTrack.trackPerson_manual_input.saved_anchorID) '.' index_Markers{k} ';'])
%     end; clearvars k
    prev_anchor = data(inspectionTrack_personID(autoTrackStartFrame),autoTrackStartFrame,:,:);
    for i = autoTrackStartFrame+1:autoTrackEndFrame
        if ~manualDeletedFrames(i)
        noPersonsDetected_frame = numberPersonsDetected(i);
            if noPersonsDetected_frame ~= 0
            dist_prev_anchor = nan(noPersonsDetected_frame,1);
            next_anchor_ID = [];
                for j = 1:noPersonsDetected_frame
%                 temp_dist_prev_anchor = nan(length(index_Markers),2);
%                 for k = 1:length(index_Markers)
%                     eval(['temp_dist_prev_anchor(' num2str(k) ',:) =  data.frame_' num2str(i) '.person_' num2str(j) '.' index_Markers{k} ';'])
%                 end; clearvars k
% 
%                 dist_prev_anchor(j) = nanmean(sqrt(sum((prev_anchor-temp_dist_prev_anchor).^2,2)));
                    dist_prev_anchor(j) = nanmean(sqrt(sum(squeeze(prev_anchor(:,:,index_Markers,:) - data(j,i,index_Markers,:)).^2,2)));    
                end

                if all(isnan(dist_prev_anchor))% if the auto-track keypoints yield no data, then use all keypoints to auto-track
                for j = 1:noPersonsDetected_frame 
%                 temp_dist_prev_anchor = nan(length(pose.keypoints),2);
%                  for k = 1:length(pose.keypoints)
%                       eval(['temp_dist_prev_anchor(' num2str(k) ',:) =  data.frame_' num2str(i) '.person_' num2str(j) '.' poseModel.keypoints{k} ';'])
%                  end; clearvars k
            
%                 dist_prev_anchor(j) = nanmean(sqrt(sum((prev_anchor-temp_dist_prev_anchor).^2,2)));
                    dist_prev_anchor(j) = nanmean(sqrt(sum(squeeze(prev_anchor(:,:,:,:) - data(j,i,:,:)).^2,2)));    
                    end    
                end

                if any(~isnan(dist_prev_anchor))
                [M I] = min(dist_prev_anchor);
                    if isnan(M)

                    else
                        next_anchor_ID = I;
                    end

                tracked_data(i,:,:) = data(next_anchor_ID,i,:,:);

%                 prev_anchor = nan(length(index_Markers),2);
%                 for k = 1:length(index_Markers)
%                             eval(['prev_anchor(' num2str(k) ',:) = data.frame_' num2str(i) '.person_' num2str(next_anchor_ID) '.' poseModel.keypoints{k} ';'])
%                     %         eval(['prev_anchor(' num2str(k) ',:) = data_openpose.data_raw.frame_' num2str(personTrack.trackPerson_manual_input.saved_anchorFrame) '.person_' num2str(personTrack.trackPerson_manual_input.saved_anchorID) '.' index_Markers{k} ';'])
%                 end; clearvars k
                prev_anchor = data(next_anchor_ID,i,:,:);

                autoTrack_personID(i) = I;
                else

                end



            else

            end
        end
    end
    inspectionTrack_personID(autoTrackStartFrame:autoTrackEndFrame) = autoTrack_personID(autoTrackStartFrame:autoTrackEndFrame);
   
    
elseif h_backward.Value == 1
   
    autoTrackStartFrame = str2double(h_autoTrack_startFrame.String);
    autoTrackEndFrame = str2double(h_autoTrack_endFrame.String);

%     noFrames = length(startTrackFrame:endTrackFrame);
%     tracked_data = nan(noFrames,noLandmarks,2);
%     tracked_data(autoTrackEndFrame,:,:) = data(inspectionTrack_personID(autoTrackEndFrame),autoTrackEndFrame,:,:);
    autoTrack_personID = nan(noFrames,1);
    autoTrack_personID(autoTrackEndFrame) = inspectionTrack_personID(autoTrackEndFrame);

%     prev_anchor = nan(length(index_Markers),2);
%     for k = 1:length(index_Markers)
%         eval(['prev_anchor(' num2str(k) ',:) = inspect_data.' index_Markers{k} '(autoTrackStartFrame,:);'])
%     end; clearvars k
    prev_anchor = data(inspectionTrack_personID(autoTrackEndFrame),autoTrackEndFrame,:,:);
    for i = flip(autoTrackStartFrame:autoTrackEndFrame-1)
           if ~manualDeletedFrames(i)
        noPersonsDetected_frame = numberPersonsDetected(i);
            if noPersonsDetected_frame ~= 0
            dist_prev_anchor = nan(noPersonsDetected_frame,1);
            next_anchor_ID = [];
                for j = 1:noPersonsDetected_frame
%                 temp_dist_prev_anchor = nan(length(index_Markers),2);
%                 for k = 1:length(index_Markers)
%                     eval(['temp_dist_prev_anchor(' num2str(k) ',:) =  data.frame_' num2str(i) '.person_' num2str(j) '.' index_Markers{k} ';'])
%                 end; clearvars k
% 
%                 dist_prev_anchor(j) = nanmean(sqrt(sum((prev_anchor-temp_dist_prev_anchor).^2,2)));
                    dist_prev_anchor(j) = nanmean(sqrt(sum(squeeze(prev_anchor(:,:,index_Markers,:) - data(j,i,index_Markers,:)).^2,2)));    
                end

                if all(isnan(dist_prev_anchor))% if the auto-track keypoints yield no data, then use all keypoints to auto-track
                for j = 1:noPersonsDetected_frame 
%                 temp_dist_prev_anchor = nan(length(pose.keypoints),2);
%                  for k = 1:length(pose.keypoints)
%                       eval(['temp_dist_prev_anchor(' num2str(k) ',:) =  data.frame_' num2str(i) '.person_' num2str(j) '.' poseModel.keypoints{k} ';'])
%                  end; clearvars k
%             
%                 dist_prev_anchor(j) = nanmean(sqrt(sum((prev_anchor-temp_dist_prev_anchor).^2,2)));
                    dist_prev_anchor(j) = nanmean(sqrt(sum(squeeze(prev_anchor(:,:,:,:) - data(j,i,:,:)).^2,2)));    
                    end    
                end

                if any(~isnan(dist_prev_anchor))
                [M I] = min(dist_prev_anchor);
                    if isnan(M)

                    else
                        next_anchor_ID = I;
                    end

                tracked_data(i,:,:) = data(next_anchor_ID,i,:,:);

%                 prev_anchor = nan(length(index_Markers),2);
%                 for k = 1:length(index_Markers)
%                             eval(['prev_anchor(' num2str(k) ',:) = data.frame_' num2str(i) '.person_' num2str(next_anchor_ID) '.' poseModel.keypoints{k} ';'])
%                     %         eval(['prev_anchor(' num2str(k) ',:) = data_openpose.data_raw.frame_' num2str(personTrack.trackPerson_manual_input.saved_anchorFrame) '.person_' num2str(personTrack.trackPerson_manual_input.saved_anchorID) '.' index_Markers{k} ';'])
%                 end; clearvars k
                prev_anchor = data(next_anchor_ID,i,:,:);

                autoTrack_personID(i) = I;
                else

                end



            else

            end
        end
    end
    inspectionTrack_personID(autoTrackStartFrame:autoTrackEndFrame) = autoTrack_personID(autoTrackStartFrame:autoTrackEndFrame);
     
end



%     for k = 1:length(inspection_keypoints)
%         for j = autoTrackStartFrame:autoTrackEndFrame
%             if ~isnan(inspectionTrack_personID(j))
%             eval(['inspect_data_visual.' inspection_keypoints{k} '(j,:) = [data.frame_' num2str(j) '.person_' num2str(inspectionTrack_personID(j)) '.' inspection_keypoints{k} '(1),data.frame_' num2str(j) '.person_' num2str(inspectionTrack_personID(j)) '.' inspection_keypoints{k} '(2)];'])
%             else
%             eval(['inspect_data_visual.' inspection_keypoints{k} '(j,:) = nan(1,2);'])
%             end
%         end; clearvars j
%     end; clearvars k
% 
%     for i = 1:poseModel.noKeypoints
%         for j = autoTrackStartFrame:autoTrackEndFrame
%             if ~isnan(inspectionTrack_personID(j))
%             eval(['inspect_data.' poseModel.keypoints{i} '(j,:) = [data.frame_' num2str(j) '.person_' num2str(inspectionTrack_personID(j)) '.' poseModel.keypoints{i} '(1),data.frame_' num2str(j) '.person_' num2str(inspectionTrack_personID(j)) '.' poseModel.keypoints{i} '(2)];'])
%             else
%             eval(['inspect_data.' poseModel.keypoints{i} '(j,:) = nan(1,2);'])                
%             end
%         end; clearvars j
%     end; clearvars i



for j = autoTrackStartFrame:autoTrackEndFrame
    if ~isnan(inspectionTrack_personID(j))
        inspect_data_visual(j,:) = data(inspectionTrack_personID(j),j,inspection_keypoints,1);
        inspect_data(j,:,:) = data(inspectionTrack_personID(j),j,:,:);
    else
        inspect_data_visual(j,:) = nan;
        inspect_data(j,:,:) = nan;
    end
end

    calcDataJumps
    plotInspection_timeSeries

% for i = 1:length(showTimeSeries_markers)
%    h_timeSeries_inspect(i).YData(autoTrackStartFrame:autoTrackEndFrame) = tracked_data(autoTrackStartFrame:autoTrackEndFrame,showTimeSeries_markers(i),1);
% end

% dataJumps(2:end) = nanmean(sqrt(nansum(diff(inspect_data,1,1).^2,3)),2);
% h_dataJumps.YData = dataJumps;

end

% h_title_timeSeries_pos.String = ['Frame ' num2str(frame) ': tracked ID ' num2str(inspectionTrack_personID(frame))]; h_title_timeSeries_pos.Color = subC{inspectionTrack_personID(frame)};

h_correctID.String = ['Correct: ID ' num2str(inspectionTrack_personID(frame)) ' to ?'];

plotPersons
% delete(h_trackBox);
% if ~isnan(inspectionTrack_personID(frame))
% h_trackBox = rectangle(h_image_axes,'Position',[min(hp{inspectionTrack_personID(frame)}.XData) min(hp{inspectionTrack_personID(frame)}.YData)  range(hp{inspectionTrack_personID(frame)}.XData) range(hp{inspectionTrack_personID(frame)}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);
% end


else
    errordlg('You must choose an appropriate interval of frames in which to auto track person ID','Interval error');
end

end
%% "Set current frame for deletion" pushbutton
function setCurrentFrameDelete(source,event)
global h_delete_startFrame h_delete_endFrame frame
h_delete_startFrame.String = num2str(frame);
h_delete_endFrame.String = num2str(frame);
end
%% "Set start (frame for deletion" pushbutton
function setStartFrameDelete(source,event)
global h_delete_startFrame frame
h_delete_startFrame.String = num2str(frame);
end
%% "Set end (frame for deletion" pushbutton
function setEndFrameDelete(source,event)
global h_delete_startFrame h_delete_endFrame frame
h_delete_endFrame.String = num2str(frame);
end
%% "Delete ID" pushbutton
function deleteID(source,event)
global h_delete_startFrame h_delete_endFrame h_deleteID startTrackFrame endTrackFrame inspectionTrack_personID manualDeletedFrames ...
    frame h_timeSeries_axes autoTrack_personID subC h_trackBox h_image_axes hp name h_title_image h_title_timeSeries_pos ...
    showTimeSeries_markers inspect_data_visual h_timeSeries_inspect inspect_data dataJumps h_dataJumps inspection_keypoints poseModel
startDeleteFrame = h_delete_startFrame.String;
endDeleteFrame = h_delete_endFrame.String;

if any(startTrackFrame:endTrackFrame == str2double(startDeleteFrame)) && any(startTrackFrame:endTrackFrame == str2double(endDeleteFrame)) ...
    && str2double(startDeleteFrame) <= str2double(endDeleteFrame)
    
    promptDelete = 'Yes';

    if str2double(startDeleteFrame) < str2double(endDeleteFrame)
    promptDelete = questdlg(['Are you sure you want to delete IDs of frames ' startDeleteFrame ' to ' endDeleteFrame '?'],'Delete frames','Yes','No',2);
    end
    
    if strcmp(promptDelete,'Yes')
    startDeleteFrame = str2double(startDeleteFrame);
    endDeleteFrame = str2double(endDeleteFrame);

    inspectionTrack_personID(startDeleteFrame:endDeleteFrame) = nan;
    manualDeletedFrames(startDeleteFrame:endDeleteFrame) = true;
    
   
%     for k = 1:length(inspection_keypoints)
%         for j = startDeleteFrame:endDeleteFrame
%             eval(['inspect_data_visual.' inspection_keypoints{k} '(j,:) = nan(1,2);'])
%         end; clearvars j
%     end; clearvars k
    inspect_data_visual(startDeleteFrame:endDeleteFrame,:) = nan;

%     for i = 1:poseModel.noKeypoints
%         for j = startDeleteFrame:endDeleteFrame
%         eval(['inspect_data.' poseModel.keypoints{i} '(j,:) = nan(1,2);'])
%         end; clearvars j
%     end; clearvars i
    inspect_data(startDeleteFrame:endDeleteFrame,:,:) = nan;
    

    calcDataJumps
    plotInspection_timeSeries
    plotPersons
%     for i = 1:length(showTimeSeries_markers)
%     h_timeSeries_inspect(i).YData = inspect_data_visual(:,i);
%     end
    
    if isnan(inspectionTrack_personID(frame))
    delete(h_trackBox);
    end
    
%     if ~manualDeletedFrames(frame)
%     h_title_image.String = name;
%     elseif manualDeletedFrames(frame)
%     h_title_image.String = [name ' [Person ID manually deleted]'];
%     end
    
%     if ~isnan(inspectionTrack_personID(frame))
%     h_title_timeSeries_pos.String = ['Frame ' num2str(frame) ': tracked ID ' num2str(inspectionTrack_personID(frame))]; h_title_timeSeries_pos.Color = subC{inspectionTrack_personID(frame)};
%     else
%     h_title_timeSeries_pos.String = ['Frame ' num2str(frame) ': no tracked ID']; h_title_timeSeries_pos.Color = [.5 .5 .5];
%     end
    end
    
%     dataJumps(2:end) = nanmean(sqrt(nansum(diff(inspect_data,1,1).^2,3)),2);
%     h_dataJumps.YData = dataJumps;
    
else
   errordlg('You must choose an appropriate interval of frames in which to delete person IDs','Interval error');
end

end
%% "My Cursor"
function output_txt = myCursor(obj,event_obj)
global hp numberPersonsDetected frame pickPersonID h_manPick pickPersonFig hCursor cursorID h_image h_image_axes h_timeSeries_axes h_manPick ...
    trackPerson_manual_input hl v data index_Lines subC name autoTrack_personID h_timeSeries_inspect_currentFrame h_currentFrame_slider h_currentFrame_popup ...
    h_currentFrame_edit h_showCurrentFrame startTrackFrame correct_ID_pushbutton h_correctID inspectionTrack_personID h_trackBox ...
    h_timeSeries_frame_to_frame_dist_axes h_frameToFrame_currentFrame manualDeletedFrames is_add_frame h_add_frame data_add_frame ...
    h_title_image h_title_timeSeries_pos endTrackFrame
% Display the position of the data cursor 
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

if event_obj.Target.Parent == h_image_axes 

    if strcmp(event_obj.Target.Type,'line')
    cursorData = [event_obj.Target.XData; event_obj.Target.YData];
    selectedID = false(numberPersonsDetected(frame),1);
        for i = 1:numberPersonsDetected(frame)
            selectedID(i) = isequaln([hp{i}.XData; hp{i}.YData],cursorData);
        end
    pickPersonID = find(selectedID);
    output_txt = ['ID ' num2str(pickPersonID)'];
    cursorID = pickPersonID;
    h_manPick.Value = pickPersonID;
    correct_ID_pushbutton = pickPersonID;
    h_correctID.String = ['Correct: ID ' num2str(inspectionTrack_personID(frame)) ' to ' num2str(correct_ID_pushbutton)];
    elseif strcmp(event_obj.Target.Type,'image')
    output_txt = {'You cannot select image'};
    cursorID = nan;
    correct_ID_pushbutton = '?';
    h_correctID.String = ['Correct: ID ' num2str(inspectionTrack_personID(frame)) ' to ' num2str(correct_ID_pushbutton)];
    end
  
elseif event_obj.Target.Parent == h_timeSeries_axes || event_obj.Target.Parent == h_timeSeries_frame_to_frame_dist_axes
        if event_obj.Position(1) >= startTrackFrame && event_obj.Position(1) <= endTrackFrame
        frame = event_obj.Position(1);
        output_txt = {['Frame ' num2str(frame) ': tracked ID ' num2str(autoTrack_personID(frame))]};
        for j = 1:length(hp);delete(hp{j});end
        delete(h_trackBox);
   
        framesPartialTrack = find(~cellfun(@isempty,h_add_frame));
        for j = 1:length(framesPartialTrack); delete(h_add_frame{framesPartialTrack(j)});end
        
        displayFrame
        plotPersons
     
%         if ~isnan(inspectionTrack_personID(frame))
%         h_trackBox = rectangle(h_image_axes,'Position',[min(hp{inspectionTrack_personID(frame)}.XData) min(hp{inspectionTrack_personID(frame)}.YData)  range(hp{inspectionTrack_personID(frame)}.XData) range(hp{inspectionTrack_personID(frame)}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);
%         end
        
        if is_add_frame(frame)
        delete(h_add_frame{frame})
        h_add_frame{frame} = plot(h_image_axes,reshape(data_add_frame{frame}(:,:,1),[1 prod(size(data_add_frame{frame}(:,:,1)))]),...
                    reshape(data_add_frame{frame}(:,:,2),[1 prod(size(data_add_frame{frame}(:,:,2)))]),...
                   'o','color',[.9 .9 .9],'markersize',4,'linewidth',2,'DisplayName',['Part. Track ' num2str(frame)]);
        end
        
%         if ~manualDeletedFrames(frame)
%         h_title_image.String = name;
%         elseif manualDeletedFrames(frame)
%         h_title_image.String = [name ' [Person ID manually deleted]'];
%         end
        
%         if ~isnan(inspectionTrack_personID(frame))
%         h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame)],'color',[.2 .2 .2],'fontunits','normalized','fontsize',.05);
%         % h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame) ': tracked ID ' num2str(inspectionTrack_personID(frame))],'color',subC{inspectionTrack_personID(frame)},'fontunits','normalized','fontsize',.05);
%         else
%         h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame) ': no tracked ID'],'color',[.5 .5 .5],'fontunits','normalized','fontsize',.05);
%         end
        
        h_frameToFrame_currentFrame.Position = [frame-0.5 min(get(h_timeSeries_frame_to_frame_dist_axes,'YLim')) 1 range(get(h_timeSeries_frame_to_frame_dist_axes,'YLim'))];

        
        h_timeSeries_inspect_currentFrame.Position = [frame-0.5 min(get(h_timeSeries_axes,'YLim')) 1 range(get(h_timeSeries_axes,'YLim'))];

        if pickPersonID > numberPersonsDetected(frame); pickPersonID = numberPersonsDetected(frame); end
        h_manPick.String = num2cell(1:numberPersonsDetected(frame));
        h_manPick.Value = pickPersonID;

        h_currentFrame_slider.Value = frame;
        h_currentFrame_popup.Value = frame-startTrackFrame+1;
        h_currentFrame_edit.String = num2str(frame);
        h_showCurrentFrame.String = ['Frame: ' num2str(frame)];
        correct_ID_pushbutton = '?';
        h_correctID.String = ['Correct: ID ' num2str(inspectionTrack_personID(frame)) ' to ' num2str(correct_ID_pushbutton)];
        else
            output_txt = {};
        end
        
        if ~isempty(hCursor.CurrentCursor)
        hCursor.removeDataCursor(hCursor.CurrentCursor)
         
        end
end

end
%% "Current Frame" slider
function currentFrame_slider(source,event)
global v frame data hp hl name numberPersonsDetected index_Lines subC h_manPick pickPersonFig h_showCurrentFrame pickPersonID h_currentFrame_popup h_currentFrame_slider h_currentFrame_edit h_image h_timeSeries_inspect_currentFrame h_timeSeries_axes h_timeSeries_inspect_currentFrame trackPerson_manual_input ...
    startTrackFrame autoTrack_personID correct_ID_pushbutton h_correctID inspectionTrack_personID hCursor h_trackBox h_image_axes ...
    h_add_frame is_add_frame data_add_frame h_frameToFrame_currentFrame h_timeSeries_frame_to_frame_dist_axes ...
    manualDeletedFrames h_title_image h_title_timeSeries_pos endTrackFrame
if round(event.Source.Value) >= startTrackFrame && round(event.Source.Value) <= endTrackFrame
frame = round(event.Source.Value);
for j = 1:length(hp);delete(hp{j});end
delete(h_trackBox);
framesPartialTrack = find(~cellfun(@isempty,h_add_frame));
for j = 1:length(framesPartialTrack); delete(h_add_frame{framesPartialTrack(j)});end

displayFrame
plotPersons
% h_image = imshow(read(v,frame),'InitialMagnification','fit','Parent',h_image_axes);
% hp = cell(numberPersonsDetected(frame),1);
% hp_legend = nan(numberPersonsDetected(frame),1);
% % hp_legend_labels = cell(numberPersonsDetected(frame),1);
% for i = 1:numberPersonsDetected(frame)
% t = squeeze(data(i,frame,index_Lines,:));
% hp{i} = plot(h_image_axes,t(:,1),t(:,2),'.-','color',subC{i},'markersize',8,'linewidth',2,'DisplayName',['ID ' num2str(i)]);
% hp_legend(i) = hp{i};
% end

% if ~isnan(inspectionTrack_personID(frame))
% h_trackBox = rectangle(h_image_axes,'Position',[min(hp{inspectionTrack_personID(frame)}.XData) min(hp{inspectionTrack_personID(frame)}.YData)  range(hp{inspectionTrack_personID(frame)}.XData) range(hp{inspectionTrack_personID(frame)}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);
% end

if is_add_frame(frame)
delete(h_add_frame{frame})
h_add_frame{frame} = plot(h_image_axes,reshape(data_add_frame{frame}(:,:,1),[1 prod(size(data_add_frame{frame}(:,:,1)))]),...
            reshape(data_add_frame{frame}(:,:,2),[1 prod(size(data_add_frame{frame}(:,:,2)))]),...
           'o','color',[.9 .9 .9],'markersize',4,'linewidth',2,'DisplayName',['Part. Track ' num2str(frame)]);
end


% if ~manualDeletedFrames(frame)
% h_title_image.String = name;
% elseif manualDeletedFrames(frame)
% h_title_image.String = [name ' [Person ID manually deleted]'];
% end

if ~isnan(inspectionTrack_personID(frame))
h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame)],'color',[.2 .2 .2],'fontunits','normalized','fontsize',.05);
% h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame) ': tracked ID ' num2str(inspectionTrack_personID(frame))],'color',subC{inspectionTrack_personID(frame)},'fontunits','normalized','fontsize',.05);
else
h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame) ': no tracked ID'],'color',[.5 .5 .5],'fontunits','normalized','fontsize',.05);
end
h_frameToFrame_currentFrame.Position = [frame-0.5 min(get(h_timeSeries_frame_to_frame_dist_axes,'YLim')) 1 range(get(h_timeSeries_frame_to_frame_dist_axes,'YLim'))];

h_timeSeries_inspect_currentFrame.Position = [frame-0.5 min(get(h_timeSeries_axes,'YLim')) 1 range(get(h_timeSeries_axes,'YLim'))];
% h_obj = get(h_timeSeries_axes,'Children');set(h_timeSeries_axes,'Children',[h_obj(1:end-1); h_obj(end)]);

if pickPersonID > numberPersonsDetected(frame); pickPersonID = numberPersonsDetected(frame); end
h_manPick.String = num2cell(1:numberPersonsDetected(frame));
h_manPick.Value = pickPersonID;

h_currentFrame_slider.Value = frame;
h_currentFrame_popup.Value = frame-startTrackFrame+1;
h_currentFrame_edit.String = num2str(frame);
h_showCurrentFrame.String = ['Frame: ' num2str(frame)];

correct_ID_pushbutton = '?';
h_correctID.String = ['Correct: ID ' num2str(inspectionTrack_personID(frame)) ' to ' num2str(correct_ID_pushbutton)];

if ~isempty(hCursor.CurrentCursor)
    hCursor.removeDataCursor(hCursor.CurrentCursor)
end
end
end
%% "Current Frame" popupmenu
function currentFrame_popup(source,event)
global v frame data hp hl name numberPersonsDetected index_Lines subC h_manPick pickPersonFig h_showCurrentFrame pickPersonID h_currentFrame_popup h_currentFrame_slider h_currentFrame_edit h_image h_timeSeries_inspect_currentFrame h_timeSeries_axes h_timeSeries_inspect_currentFrame trackPerson_manual_input ...
    startTrackFrame autoTrack_personID seqFrames correct_ID_pushbutton h_correctID inspectionTrack_personID hCursor h_trackBox h_image_axes ...
    h_frameToFrame_currentFrame h_timeSeries_frame_to_frame_dist_axes manualDeletedFrames is_add_frame h_add_frame data_add_frame ...
    h_title_image h_title_timeSeries_pos

if seqFrames(round(event.Source.Value)) >= trackPerson_manual_input.saved_startTrackFrame && seqFrames(round(event.Source.Value)) <= trackPerson_manual_input.saved_endTrackFrame
frame = seqFrames(round(event.Source.Value));
for j = 1:length(hp);delete(hp{j});end
delete(h_trackBox);
framesPartialTrack = find(~cellfun(@isempty,h_add_frame));
for j = 1:length(framesPartialTrack); delete(h_add_frame{framesPartialTrack(j)});end

displayFrame
plotPersons
% h_image = imshow(read(v,frame),'InitialMagnification','fit','Parent',h_image_axes);
% 
% hp = cell(numberPersonsDetected(frame),1);
% hp_legend = nan(numberPersonsDetected(frame),1);
% hp_legend_labels = cell(numberPersonsDetected(frame),1);
% for i = 1:numberPersonsDetected(frame)
% t = squeeze(data(i,frame,index_Lines,:));
% hp{i} = plot(h_image_axes,t(:,1),t(:,2),'.-','color',subC{i},'markersize',8,'linewidth',2,'DisplayName',['ID ' num2str(i)]);
% hp_legend(i) = hp{i};
% end    
% 
% if ~isnan(inspectionTrack_personID(frame))
% h_trackBox = rectangle(h_image_axes,'Position',[min(hp{inspectionTrack_personID(frame)}.XData) min(hp{inspectionTrack_personID(frame)}.YData)  range(hp{inspectionTrack_personID(frame)}.XData) range(hp{inspectionTrack_personID(frame)}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);
% end

if is_add_frame(frame)
delete(h_add_frame{frame})
h_add_frame{frame} = plot(h_image_axes,reshape(data_add_frame{frame}(:,:,1),[1 prod(size(data_add_frame{frame}(:,:,1)))]),...
            reshape(data_add_frame{frame}(:,:,2),[1 prod(size(data_add_frame{frame}(:,:,2)))]),...
           'o','color',[.9 .9 .9],'markersize',4,'linewidth',2,'DisplayName',['Part. Track ' num2str(frame)]);
end

if ~manualDeletedFrames(frame)
h_title_image.String = name;
elseif manualDeletedFrames(frame)
h_title_image.String = [name ' [Person ID manually deleted]'];
end

if ~isnan(inspectionTrack_personID(frame))
h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame)],'color',[.2 .2 .2],'fontunits','normalized','fontsize',.05);
% h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame) ': tracked ID ' num2str(inspectionTrack_personID(frame))],'color',subC{inspectionTrack_personID(frame)},'fontunits','normalized','fontsize',.05);
else
h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame) ': no tracked ID'],'color',[.5 .5 .5],'fontunits','normalized','fontsize',.05);
end

h_frameToFrame_currentFrame.Position = [frame-0.5 min(get(h_timeSeries_frame_to_frame_dist_axes,'YLim')) 1 range(get(h_timeSeries_frame_to_frame_dist_axes,'YLim'))];

h_timeSeries_inspect_currentFrame.Position = [frame-0.5 min(get(h_timeSeries_axes,'YLim')) 1 range(get(h_timeSeries_axes,'YLim'))];
% h_obj = get(h_timeSeries_axes,'Children');set(h_timeSeries_axes,'Children',[h_obj(1:end-1); h_obj(end)]);

if pickPersonID > numberPersonsDetected(frame); pickPersonID = numberPersonsDetected(frame); end
h_manPick.String = num2cell(1:numberPersonsDetected(frame));
h_manPick.Value = pickPersonID;

h_currentFrame_slider.Value = frame;
h_currentFrame_popup.Value = frame-startTrackFrame+1;
h_currentFrame_edit.String = num2str(frame);
h_showCurrentFrame.String = ['Frame: ' num2str(frame)];

correct_ID_pushbutton = '?';
h_correctID.String = ['Correct: ID ' num2str(inspectionTrack_personID(frame)) ' to ' num2str(correct_ID_pushbutton)];

if ~isempty(hCursor.CurrentCursor)
    hCursor.removeDataCursor(hCursor.CurrentCursor)
end

end
end
%% "Current Frame" edit
function currentFrame_edit(source,event)
global v frame data hp hl name numberPersonsDetected index_Lines subC h_manPick pickPersonFig h_showCurrentFrame pickPersonID h_currentFrame_popup h_currentFrame_slider h_currentFrame_edit h_image h_timeSeries_inspect_currentFrame h_timeSeries_axes h_timeSeries_inspect_currentFrame trackPerson_manual_input ...
    startTrackFrame autoTrack_personID endTrackFrame correct_ID_pushbutton h_correctID inspectionTrack_personID hCursor h_trackBox h_image_axes ...
    h_frameToFrame_currentFrame h_timeSeries_frame_to_frame_dist_axes manualDeletedFrames is_add_frame h_add_frame data_add_frame ...
    h_title_image h_title_timeSeries_pos
frame_input = event.Source.String;
if any(startTrackFrame:endTrackFrame == str2double(frame_input))
frame = str2double(frame_input);
    
for j = 1:length(hp);delete(hp{j});end
delete(h_trackBox);
framesPartialTrack = find(~cellfun(@isempty,h_add_frame));
for j = 1:length(framesPartialTrack); delete(h_add_frame{framesPartialTrack(j)});end

displayFrame
plotPersons
% h_image = imshow(read(v,frame),'InitialMagnification','fit','Parent',h_image_axes);
% 
% hp = cell(numberPersonsDetected(frame),1);
% hp_legend = nan(numberPersonsDetected(frame),1);
% hp_legend_labels = cell(numberPersonsDetected(frame),1);
% for i = 1:numberPersonsDetected(frame)
% t = squeeze(data(i,frame,index_Lines,:));
% hp{i} = plot(h_image_axes,t(:,1),t(:,2),'.-','color',subC{i},'markersize',8,'linewidth',2,'DisplayName',['ID ' num2str(i)]);
% hp_legend(i) = hp{i};
% end    
% if ~isnan(inspectionTrack_personID(frame))
% h_trackBox = rectangle(h_image_axes,'Position',[min(hp{inspectionTrack_personID(frame)}.XData) min(hp{inspectionTrack_personID(frame)}.YData)  range(hp{inspectionTrack_personID(frame)}.XData) range(hp{inspectionTrack_personID(frame)}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);
% end

if is_add_frame(frame)
delete(h_add_frame{frame})
h_add_frame{frame} = plot(h_image_axes,reshape(data_add_frame{frame}(:,:,1),[1 prod(size(data_add_frame{frame}(:,:,1)))]),...
            reshape(data_add_frame{frame}(:,:,2),[1 prod(size(data_add_frame{frame}(:,:,2)))]),...
           'o','color',[.9 .9 .9],'markersize',4,'linewidth',2,'DisplayName',['Part. Track ' num2str(frame)]);
end

% if ~manualDeletedFrames(frame)
% h_title_image.String = name;
% elseif manualDeletedFrames(frame)
% h_title_image.String = [name ' [Person ID manually deleted]'];
% end
% 
% if ~isnan(inspectionTrack_personID(frame))
% h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame)],'color',[.2 .2 .2],'fontunits','normalized','fontsize',.05);
% % h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame) ': tracked ID ' num2str(inspectionTrack_personID(frame))],'color',subC{inspectionTrack_personID(frame)},'fontunits','normalized','fontsize',.05);
% else
% h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame) ': no tracked ID'],'color',[.5 .5 .5],'fontunits','normalized','fontsize',.05);
% end

h_timeSeries_inspect_currentFrame.Position = [frame-0.5 min(get(h_timeSeries_axes,'YLim')) 1 range(get(h_timeSeries_axes,'YLim'))];
% h_obj = get(h_timeSeries_axes,'Children');set(h_timeSeries_axes,'Children',[h_obj(1:end-1); h_obj(end)]);

if pickPersonID > numberPersonsDetected(frame); pickPersonID = numberPersonsDetected(frame); end
h_manPick.String = num2cell(1:numberPersonsDetected(frame));
h_manPick.Value = pickPersonID;

h_currentFrame_slider.Value = frame;
h_currentFrame_popup.Value = frame-startTrackFrame+1;
h_currentFrame_edit.String = num2str(frame);
h_showCurrentFrame.String = ['Frame: ' num2str(frame)];
h_frameToFrame_currentFrame.Position = [frame-0.5 min(get(h_timeSeries_frame_to_frame_dist_axes,'YLim')) 1 range(get(h_timeSeries_frame_to_frame_dist_axes,'YLim'))];
    


correct_ID_pushbutton = '?';
h_correctID.String = ['Correct: ID ' num2str(inspectionTrack_personID(frame)) ' to ' num2str(correct_ID_pushbutton)];

if ~isempty(hCursor.CurrentCursor)
    hCursor.removeDataCursor(hCursor.CurrentCursor)
end

else
   errordlg(['You must input a valid frame number: ' num2str(startTrackFrame) ' to ' num2str(endTrackFrame)],'Non-frame number entered') 
end

end
%% "Pick Person" popupmenu
function pickPerson(source,event)
global manualTrackedPersonIndex frame data pickPersonID hCursor output_txt pickPersonFig hl hp h_image v numberPersonsDetected hp_legend hp_legend_labels index_Lines subC cursorID ...
    correct_ID_pushbutton h_correctID autoTrack_personID inspectionTrack_personID
% manualTrackedPersonIndex(frame) = event.Source.Value;
pickPersonID = event.Source.Value;

% if isnumeric(cursorID) && cursorID ~= pickPersonID
% delete(hl),for j = 1:length(hp);delete(hp{j});end
% delete(h_image)
% % subplot(2,4,[1:3 5:7]),hold on
% h_image = imshow(read(v,frame),'InitialMagnification','fit','Parent',h_image_axes);
% hp = cell(numberPersonsDetected(frame),1);
% hp_legend = nan(numberPersonsDetected(frame),1);
% hp_legend_labels = cell(numberPersonsDetected(frame),1);
% for i = 1:numberPersonsDetected(frame)
% t = squeeze(data(i,frame,index_Lines,:));
% hp{i} = plot(h_image_axes,t(:,1),t(:,2),'.-','color',subC{i},'markersize',8,'linewidth',2);
% hp_legend(i) = hp{i};
% hp_legend_labels{i} = ['ID ' num2str(i)];
% end    
% 
% hl = legend(h_image_axes,hp_legend,hp_legend_labels,'position',[0.92 0.7 0.06 0.0349],'orientation','vertical');
% end
correct_ID_pushbutton = pickPersonID;
h_correctID.String = ['Correct: ID ' num2str(inspectionTrack_personID(frame)) ' to ' num2str(correct_ID_pushbutton)];
end
%% "Correct ID" pushbutton
function correctID(source,event)
global frame correct_ID_pushbutton inspectionTrack_personID inspect_data_visual data h_timeSeries_inspect h_timeSeries_axes subC ...
    h_conflict_checkPoints h_agree_checkPoints h_legend_ankles h_correctID h_trackBox h_image_axes hp ...
    h_dataJumps dataJumps index_Markers manualDeletedFrames name h_title_image h_title_timeSeries_pos autoTrack_personID ...
    showTimeSeries_markers inspect_data inspection_keypoints poseModel
if correct_ID_pushbutton == '?'
    errordlg('You must select a Person ID to correct',['No person ID selected for frame ' num2str(frame)])
    
else 
    inspectionTrack_personID(frame) = correct_ID_pushbutton;
    
%     for i = 1:length(inspection_keypoints)
%         eval(['inspect_data_visual.' inspection_keypoints{i} '(frame,:) = [data.frame_' num2str(frame) '.person_' num2str(inspectionTrack_personID(frame)) '.' inspection_keypoints{i} '(1),data.frame_' num2str(frame) '.person_' num2str(inspectionTrack_personID(frame)) '.' inspection_keypoints{i} '(2)];'])
%     end; clearvars i
    inspect_data_visual(frame,:) = squeeze(data(correct_ID_pushbutton,frame,inspection_keypoints,1));
    
%     for i = 1:poseModel.noKeypoints
%         eval(['inspect_data.' poseModel.keypoints{i} '(frame,:) = [data.frame_' num2str(frame) '.person_' num2str(inspectionTrack_personID(frame)) '.' poseModel.keypoints{i} '(1),data.frame_' num2str(frame) '.person_' num2str(inspectionTrack_personID(frame)) '.' poseModel.keypoints{i} '(2)];'])
%     end
    inspect_data(frame,:,:) = squeeze(data(correct_ID_pushbutton,frame,:,:));

    calcDataJumps
    plotInspection_timeSeries
    plotPersons
%     for i = 1:length(showTimeSeries_markers)
%     h_timeSeries_inspect(i).YData = inspect_data_visual(:,i);
%     end
    
%     h_title_timeSeries_pos.String = ['Frame ' num2str(frame) ': tracked ID ' num2str(inspectionTrack_personID(frame))]; h_title_timeSeries_pos.Color = subC{inspectionTrack_personID(frame)};

    h_correctID.String = ['Correct: ID ' num2str(inspectionTrack_personID(frame)) ' to ' num2str(correct_ID_pushbutton)];
   
%     delete(h_trackBox);
%     if ~isnan(inspectionTrack_personID(frame))
%     h_trackBox = rectangle(h_image_axes,'Position',[min(hp{inspectionTrack_personID(frame)}.XData) min(hp{inspectionTrack_personID(frame)}.YData)  range(hp{inspectionTrack_personID(frame)}.XData) range(hp{inspectionTrack_personID(frame)}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);
%     end
%     dataJumps(2:end) = nanmean(sqrt(nansum(diff(inspect_data,1,1).^2,3)),2);
%     h_dataJumps.YData = dataJumps;
    
    if manualDeletedFrames(frame)
        manualDeletedFrames(frame) = false;
    end
    
%     if ~manualDeletedFrames(frame)
%     h_title_image.String = name;
%     elseif manualDeletedFrames(frame)
%     h_title_image.String = [name ' [Person ID manually deleted]'];
%     end
    
end

end
%% "Revert ID" pushbutton
function revertID(source,event)
global frame correct_ID_pushbutton inspectionTrack_personID inspect_data_visual data h_timeSeries_inspect h_timeSeries_axes subC ...
    h_conflict_checkPoints h_agree_checkPoints h_legend_ankles h_correctID autoTrack_personID h_trackBox h_image_axes hp ...
    dataJumps h_dataJumps index_Markers manualDeletedFrames name h_title_image h_title_timeSeries_pos showTimeSeries_markers ...
    inspect_data inspection_partialTrack_personID data_add_frame h_add_frame is_add_frame poseModel inspection_keypoints

    inspectionTrack_personID(frame) = autoTrack_personID(frame);

%     for i = 1:length(inspection_keypoints)
%         eval(['inspect_data_visual.' inspection_keypoints{i} '(frame,:) = [data.frame_' num2str(frame) '.person_' num2str(inspectionTrack_personID(frame)) '.' inspection_keypoints{i} '(1),data.frame_' num2str(frame) '.person_' num2str(inspectionTrack_personID(frame)) '.' inspection_keypoints{i} '(2)];'])
%     end; clearvars i
%     
%     for i = 1:poseModel.noKeypoints
%         eval(['inspect_data.' poseModel.keypoints{i} '(frame,:) = [data.frame_' num2str(frame) '.person_' num2str(inspectionTrack_personID(frame)) '.' poseModel.keypoints{i} '(1),data.frame_' num2str(frame) '.person_' num2str(inspectionTrack_personID(frame)) '.' poseModel.keypoints{i} '(2)];'])
%     end
    
    inspect_data_visual(frame,:) = squeeze(data(autoTrack_personID(frame),frame,inspection_keypoints,1));
    inspect_data(frame,:,:) = squeeze(data(autoTrack_personID(frame),frame,:,:));

    if is_add_frame(frame)
    inspection_partialTrack_personID(frame) = nan;
    data_add_frame{frame} = [];
    delete(h_add_frame{frame})
    is_add_frame(frame) = false;
    end

    
    calcDataJumps
    plotInspection_timeSeries
    plotPersons
%     for i = 1:length(showTimeSeries_markers)
%     h_timeSeries_inspect(i).YData = inspect_data_visual(:,i);
%     end
    
%     if ~isnan(inspectionTrack_personID(frame))
%     h_title_timeSeries_pos.String = ['Frame ' num2str(frame) ': tracked ID ' num2str(inspectionTrack_personID(frame))]; h_title_timeSeries_pos.Color = subC{inspectionTrack_personID(frame)};
%     else
%     h_title_timeSeries_pos.String = ['Frame ' num2str(frame) ': no tracked ID']; h_title_timeSeries_pos.Color = [.5 .5 .5];
%     end

    correct_ID_pushbutton = '?';
    h_correctID.String = ['Correct: ID ' num2str(autoTrack_personID(frame)) ' to ' num2str(correct_ID_pushbutton)];
   
    delete(h_trackBox);
    if ~isnan(inspectionTrack_personID(frame))
    h_trackBox = rectangle(h_image_axes,'Position',[min(hp{inspectionTrack_personID(frame)}.XData) min(hp{inspectionTrack_personID(frame)}.YData)  range(hp{inspectionTrack_personID(frame)}.XData) range(hp{inspectionTrack_personID(frame)}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);
    end
    
    if manualDeletedFrames(frame)
        manualDeletedFrames(frame) = false;
    end
    
%     if ~manualDeletedFrames(frame)
%     h_title_image.String = name;
%     elseif manualDeletedFrames(frame)
%     h_title_image.String = [name ' [Person ID manually deleted]'];
%     end
    
%     dataJumps(2:end) = nanmean(sqrt(nansum(diff(inspect_data,1,1).^2,3)),2);
%     h_dataJumps.YData = dataJumps;
    
end
%% "Revert all IDs" pushbutton
function revertAllID(source,event)
global frame correct_ID_pushbutton inspectionTrack_personID inspect_data_visual data h_timeSeries_inspect h_timeSeries_axes subC ...
    h_conflict_checkPoints h_agree_checkPoints h_legend_ankles h_correctID autoTrack_personID trackPerson_auto h_trackBox h_image_axes hp ...
    dataJumps h_dataJumps index_Markers manualDeletedFrames name h_title_image h_title_timeSeries_pos showTimeSeries_markers ...
    inspect_data inspection_partialTrack_personID data_add_frame is_add_frame h_add_frame noFrames noLandmarks ...
    inspection_keypoints startTrackFrame endTrackFrame poseModel

    answer = questdlg('Are you sure you want to revert all IDs?','Revert all IDs','Yes','No',2);
    
    if strcmp(answer,'Yes')
    inspectionTrack_personID = autoTrack_personID;
    
%     for k = 1:length(inspection_keypoints)
%         for j = startTrackFrame:endTrackFrame
%             eval(['inspect_data_visual.' inspection_keypoints{k} '(j,:) = [data.frame_' num2str(j) '.person_' num2str(inspectionTrack_personID(j)) '.' inspection_keypoints{k} '(1),data.frame_' num2str(j) '.person_' num2str(inspectionTrack_personID(j)) '.' inspection_keypoints{k} '(2)];'])
%         end; clearvars j
%     end; clearvars k
% 
%     for i = 1:poseModel.noKeypoints
%         for j = startTrackFrame:endTrackFrame
%         eval(['inspect_data.' poseModel.keypoints{i} '(j,:) = [data.frame_' num2str(j) '.person_' num2str(inspectionTrack_personID(j)) '.' poseModel.keypoints{i} '(1),data.frame_' num2str(j) '.person_' num2str(inspectionTrack_personID(j)) '.' poseModel.keypoints{i} '(2)];'])
%         end; clearvars j
%     end; clearvars i
    
    inspect_data_visual = trackPerson_auto.tracked_data(:,inspection_keypoints,1);
    inspect_data = trackPerson_auto.tracked_data;
    
    
    inspection_partialTrack_personID = nan(noFrames,noLandmarks);
    data_add_frame = cell(noFrames,1);
    delete(h_add_frame{frame})
    h_add_frame = cell(noFrames,1);
    is_add_frame = false(noFrames,1);
    
    calcDataJumps
    plotInspection_timeSeries
    plotPersons
%     for i = 1:length(showTimeSeries_markers)
%     h_timeSeries_inspect(i).YData = inspect_data_visual(:,i);
%     end
    
%     if ~isnan(inspectionTrack_personID(frame))
%     h_title_timeSeries_pos.String = ['Frame ' num2str(frame) ': tracked ID ' num2str(inspectionTrack_personID(frame))]; h_title_timeSeries_pos.Color = subC{inspectionTrack_personID(frame)};
%     else
%     h_title_timeSeries_pos.String = ['Frame ' num2str(frame) ': no tracked ID']; h_title_timeSeries_pos.Color = [.5 .5 .5];
%     end
    
    correct_ID_pushbutton = '?';
    h_correctID.String = ['Correct: ID ' num2str(autoTrack_personID(frame)) ' to ' num2str(correct_ID_pushbutton)];
   
    delete(h_trackBox);
    if ~isnan(inspectionTrack_personID(frame))
    h_trackBox = rectangle(h_image_axes,'Position',[min(hp{inspectionTrack_personID(frame)}.XData) min(hp{inspectionTrack_personID(frame)}.YData)  range(hp{inspectionTrack_personID(frame)}.XData) range(hp{inspectionTrack_personID(frame)}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);
    manualDeletedFrames(frame) = false;
%     h_title_image.String = name;
    end    
%     dataJumps(2:end) = nanmean(sqrt(nansum(diff(inspect_data,1,1).^2,3)),2);
%     h_dataJumps.YData = dataJumps;
    end

end
%% "Partial Person Tracking" pushbutton
function partialPersonTrack(source,event)
global frame v numberPersonsDetected data index_Lines subC inspectionTrack_personID name hp_partial_track ...
    h_brush partialPersonTrackFig index_Lines h_image_axes_partial_track h_partial noLandmarks
partialPersonTrackFig = figure; set(partialPersonTrackFig,'WindowStyle','docked'); hold on

h_image_axes_partial_track = subplot(3,2,[1:4]);hold on
h_image_partial_track = imshow(read(v,frame),'InitialMagnification','fit');

hp_partial_track = cell(numberPersonsDetected(frame),1);
hp_legend_partial_track = nan(numberPersonsDetected(frame),1);
% hp_legend_labels_partial_track = cell(numberPersonsDetected(frame),1);
for i = 1:numberPersonsDetected(frame)
t = squeeze(data(i,frame,index_Lines,:));
hp_partial_track{i} = plot(t(:,1),t(:,2),'.-','color',subC{i},'markersize',8,'linewidth',2,'DisplayName',['ID ' num2str(i)]);
hp_legend_partial_track(i) = hp_partial_track{i};
% hp_legend_labels_partial_track{i} = ['ID ' num2str(i)];
end  


hl_partial = legend([hp_legend_partial_track],'position',[0.90 0.7 0.06 0.0349],'orientation','vertical','color',[.8 .8 .8]);title([name ': Frame ' num2str(frame)],'interpreter','none','fontsize',10);

h_trackBox = rectangle(h_image_axes_partial_track,'Position',[min(hp_partial_track{inspectionTrack_personID(frame)}.XData) min(hp_partial_track{inspectionTrack_personID(frame)}.YData)  range(hp_partial_track{inspectionTrack_personID(frame)}.XData) range(hp_partial_track{inspectionTrack_personID(frame)}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);


h_brush = brush(partialPersonTrackFig); brush on
h_brush.Color = [0 0 0];

h_pickPartialKeypoints = uicontrol(partialPersonTrackFig,'style','pushbutton','string','Pick Keypoints (Partial Person Tracking)','fontsize',8,...
    'units','normalized','Position',[0.2 .3 0.25 0.05],'Callback',@pickPartialKeypoints);
h_deletePartialKeypoints = uicontrol(partialPersonTrackFig,'style','pushbutton','string','Delete Keypoints (Partial Person Tracking)','fontsize',8,...
    'units','normalized','Position',[0.5 .3 0.3 0.05],'Callback',@deletePartialKeypoints);
h_zoom_pushbutton = uicontrol(partialPersonTrackFig,'style','pushbutton','string','Zoom','fontsize',8,...
    'units','normalized','Position',[0.1 .5 0.1 0.05],'Callback',@zoomOn);
h_brush_pushbutton = uicontrol(partialPersonTrackFig,'style','pushbutton','string','Brush','fontsize',8,...
    'units','normalized','Position',[0.1 .7 0.1 0.05],'Callback',@brushOn);
h_pan_pushbutton = uicontrol(partialPersonTrackFig,'style','pushbutton','string','Pan','fontsize',8,...
    'units','normalized','Position',[0.1 .6 0.1 0.05],'Callback',@panOn);
h_saveReturn = uicontrol(partialPersonTrackFig,'style','pushbutton','string','Save and Return to Visual Inspection','fontsize',8,...
    'units','normalized','Position',[.2 .1 0.25 .05],'Callback',@saveReturn);

h_partial = cell(0,1);
end
function pickPartialKeypoints(source,events)
global hp_partial_track frame inspectionTrack_personID h_brush numberPersonsDetected partialPersonTrackFig index_Lines ...
    inspectionTrack_personID inspection_partialTrack_personID data h_image_axes_partial_track h_partial
nonTrackedIDs = 1:numberPersonsDetected(frame);
nonTrackedIDs(inspectionTrack_personID(frame)) = [];
checkTrack = false(length(nonTrackedIDs),1);
for i = 1:length(checkTrack)
    checkTrack(i) = any(logical(hp_partial_track{nonTrackedIDs(i)}.BrushData));
end
if ~any(checkTrack) || sum(checkTrack) > 1
   errordlg('You must brush keypoints from a single otherwise non-tracked person ID','Error in keypoint selection') 
elseif sum(checkTrack) == 1
    partialTrackedID = nonTrackedIDs(find(checkTrack));
    selectedKeypoints = unique(index_Lines(logical(hp_partial_track{partialTrackedID}.BrushData)));
    inspection_partialTrack_personID(frame,selectedKeypoints) = partialTrackedID;
    
    h_partial{end+1} = plot(h_image_axes_partial_track,squeeze(data(partialTrackedID,frame,selectedKeypoints,1)),squeeze(data(partialTrackedID,frame,selectedKeypoints,2)),'o','color',[.9 .9 .9],'markersize',4,'linewidth',2,'DisplayName','Part. Person Track');

end
end
function deletePartialKeypoints(source,events)
global hp_partial_track frame inspectionTrack_personID h_brush numberPersonsDetected partialPersonTrackFig index_Lines ...
    inspectionTrack_personID inspection_partialTrack_personID data h_image_axes_partial_track h_partial
nonTrackedIDs = 1:numberPersonsDetected(frame);
nonTrackedIDs(inspectionTrack_personID(frame)) = [];
checkTrack = false(length(nonTrackedIDs),1);
for i = 1:length(checkTrack)
    checkTrack(i) = any(logical(hp_partial_track{nonTrackedIDs(i)}.BrushData));
end
if ~any(checkTrack) || sum(checkTrack) > 1
   errordlg('You must brush keypoints from a single otherwise non-tracked person ID','Error in keypoint selection') 
elseif sum(checkTrack) == 1
    partialTrackedID = nonTrackedIDs(find(checkTrack));
    selectedKeypoints = unique(index_Lines(logical(hp_partial_track{partialTrackedID}.BrushData)));
    inspection_partialTrack_personID(frame,selectedKeypoints) = nan;
    
    for i = 1:length(h_partial)
      
      if isvalid(h_partial{i})
        
      if ~isempty(intersect(h_partial{i}.XData,unique(hp_partial_track{nonTrackedIDs(checkTrack)}.XData(((logical(hp_partial_track{nonTrackedIDs(checkTrack)}.BrushData)))))))
        [val,pos] = intersect(h_partial{i}.XData,unique(hp_partial_track{nonTrackedIDs(checkTrack)}.XData(((logical(hp_partial_track{nonTrackedIDs(checkTrack)}.BrushData))))));
        h_partial{i}.XData(pos) = [];
        h_partial{i}.YData(pos) = [];
        if isempty(h_partial{i}.XData)
            delete(h_partial{i})
        end
      end
      
      end
      
    end

    
end
end
function zoomOn(source,event)
zoom on
end
function brushOn(source,event)
brush on
end
function panOn(source,event)
pan on
end
function cursorOn(source,event)
datacursormode on
end
function saveReturn(source,event)
global partialPersonTrackFig data frame inspection_partialTrack_personID h_image_axes ...
    h_add_frame is_add_frame data_add_frame noLandmarks
close(partialPersonTrackFig)

if any(~isnan(inspection_partialTrack_personID(frame,:)))
    add_personID_markers = unique(inspection_partialTrack_personID(frame,:)); add_personID_markers(isnan(add_personID_markers)) = [];
    temp_data = nan(length(add_personID_markers),noLandmarks,2);
    for i = 1:length(add_personID_markers)
        temp_data(i,inspection_partialTrack_personID(frame,:) == add_personID_markers(i),:) = squeeze(data(add_personID_markers(i),frame,inspection_partialTrack_personID(frame,:) == add_personID_markers(i),:));
    end
    data_add_frame{frame} = temp_data;
    h_add_frame{frame} = plot(h_image_axes,reshape(data_add_frame{frame}(:,:,1),[1 prod(size(data_add_frame{frame}(:,:,1)))]),...
            reshape(data_add_frame{frame}(:,:,2),[1 prod(size(data_add_frame{frame}(:,:,2)))]),...
           'o','color',[.9 .9 .9],'markersize',4,'linewidth',2,'DisplayName',['Part. Track ' num2str(frame)]);
       is_add_frame(frame) = true;

end

end
%% "Save and Continue" pushbutton
function saveCont(source,event)
global inspectionTrack_personID pickPersonFig trackPerson_inspect inspection_partialTrack_personID data_add_frame personTrack
personTrack.trackPerson_inspect.inspectionTrack_personID = inspectionTrack_personID;
% trackPerson_inspect.partialTrack_personID = inspection_partialTrack_personID;
% trackPerson_inspect.partialTrack_data = data_add_frame;
close(pickPersonFig)
end
%% "Calc data jumps"
function calcDataJumps(source,events)
global noFrames dataJumps inspect_data index_Markers ...
    h_timeSeries_frame_to_frame_dist_axes startTrackFrame endTrackFrame ...
    h_dataJumps h_frameToFrame_currentFrame frame

delete(h_dataJumps)
delete(h_frameToFrame_currentFrame)
dataJumps = nan(noFrames,1);
% temp = nan(length(index_Markers),length(2:noFrames));
% for j = 1:length(index_Markers)
% eval(['temp(j,:) = sqrt(sum(diff(inspect_data.' index_Markers{j} ',1,1).^2,2));'])
%     %     for k = 2:noFrames
% %        eval(['temp(j,k) = sqrt(sum((inspect_data.' index_Markers{j} '(' num2str(k) '-1,:) - inspect_data.' index_Markers{j} '(' num2str(k) ',:)).^2));'])
% %     end 
% end
% dataJumps = nanmean(temp,1);  
dataJumps(2:end) = nanmean(sqrt(nansum(diff(inspect_data,1,1).^2,3)),2);

h_dataJumps = plot(h_timeSeries_frame_to_frame_dist_axes,dataJumps,'color',[.5 .5 .5]);
h_frameToFrame_currentFrame = rectangle(h_timeSeries_frame_to_frame_dist_axes,'Position',[frame-0.5 min(get(h_timeSeries_frame_to_frame_dist_axes,'YLim')) 1 range(get(h_timeSeries_frame_to_frame_dist_axes,'YLim'))],'edgecolor',[.7 .7 .7],'facecolor',[.7 .7 .7],'linewidth',.2);
uistack(h_frameToFrame_currentFrame,'bottom')
xlabel(h_timeSeries_frame_to_frame_dist_axes,'Frame','fontunits','normalized','fontsize',.15)
ylabel(h_timeSeries_frame_to_frame_dist_axes,{'Mean frame-to-frame','pixel distance'},'fontunits','normalized','fontsize',.15)

end
%% "Gray-scale" radiobutton
function grayScale(source,event)
global h_uicontrol hp
% if h_grayRadioButton.Value == 1
% h_grayRadioButton.Value = 0;
% elseif h_grayRadioButton.Value == 0;
% h_grayRadioButton.Value = 1;
% end
for i = 1:length(hp)
delete(hp{i})
end; clearvars i
displayFrame
plotPersons

end
%% 'Show image'
function displayFrame(source,event)
global h_image_axes h_image v frame h_uicontrol
delete(h_image)
if h_uicontrol.grayRadioButton.Value == 0
h_image = imshow(read(v,frame),'InitialMagnification','fit','Parent',h_image_axes);
elseif h_uicontrol.grayRadioButton.Value == 1
h_image = imshow(rgb2gray(read(v,frame)),'InitialMagnification','fit','Parent',h_image_axes);    
end
end
%% "Plot persons"
function plotPersons(source,event)
global hp numberPersonsDetected frame h_image_axes index_Lines data v subC ...
    inspectionTrack_personID h_trackBox hp_color
for i = 1:length(hp)
delete(hp{i})
end; clearvars i

hp = cell(numberPersonsDetected(frame),1);
hp_legend = nan(numberPersonsDetected(frame),1);
hp_legend_labels = cell(numberPersonsDetected(frame),1);
for i = 1:numberPersonsDetected(frame)
% t = [];
% t = nan(length(index_Lines),2);
%     for j = 1:length(index_Lines)
%         eval(['t(j,:) = [data.frame_' num2str(frame) '.person_' num2str(i) '.' index_Lines{j} '(1),data.frame_' num2str(frame) '.person_' num2str(i) '.' index_Lines{j} '(2)];'])
%     end
t = squeeze(data(i,frame,index_Lines,:));

if i == inspectionTrack_personID(frame)
    hp{i} = plot(h_image_axes,t(:,1),t(:,2),'.-','color',hp_color.tracked{1},'markersize',8,'linewidth',2,'DisplayName',['ID ' num2str(i)]); 
else
    hp{i} = plot(h_image_axes,t(:,1),t(:,2),'.-','color',hp_color.notTracked{1},'markersize',8,'linewidth',2,'DisplayName',['ID ' num2str(i)]); 
end    
% hp{i} = plot(h_image_axes,t(:,1),t(:,2),'.-','color',subC{i},'markersize',8,'linewidth',2,'DisplayName',['ID ' num2str(i)]);
end; clearvars i 
% legend(h_image_axes,'position',[0.1448 0.3 0.4 0.0349],'orientation','horizontal');
% title(name,'interpreter','none')

delete(h_trackBox);
if ~isnan(inspectionTrack_personID(frame))
h_trackBox = rectangle(h_image_axes,'Position',[min(hp{inspectionTrack_personID(frame)}.XData) min(hp{inspectionTrack_personID(frame)}.YData)  range(hp{inspectionTrack_personID(frame)}.XData) range(hp{inspectionTrack_personID(frame)}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);
end

end
%% "plot inspection time-series"
function plotInspection_timeSeries(source,event)
global h_timeSeries_axes startTrackFrame endTrackFrame h_timeSeries_inspect ...
    inspection_keypoints inspect_data_visual h_timeSeries_inspect_currentFrame frame ...
    inspectionTrack_personID h_title_timeSeries_pos subC pose


for i = 1:length(h_timeSeries_inspect)
    delete(h_timeSeries_inspect{i})
end; clearvars i
delete(h_timeSeries_inspect_currentFrame)
h_timeSeries_inspect = cell(length(inspection_keypoints),1);
for i = 1:length(inspection_keypoints)
% eval(['h_timeSeries_inspect{i} = plot(h_timeSeries_axes,inspect_data_visual.' inspection_keypoints{i} '(:,1),''color'',[.5 .5 .5],''DisplayName'',''' inspection_keypoints{i} ''');'])
h_timeSeries_inspect{i} = plot(h_timeSeries_axes,inspect_data_visual(:,i),'color',[.5 .5 .5],'DisplayName',[pose.keypoints{inspection_keypoints(i)}]);
end; clearvars i
h_timeSeries_inspect_currentFrame = rectangle(h_timeSeries_axes,'Position',[frame-0.5 min(get(h_timeSeries_axes,'YLim')) 1 range(get(h_timeSeries_axes,'YLim'))],'edgecolor',[.7 .7 .7],'facecolor',[.7 .7 .7],'linewidth',.2);
uistack(h_timeSeries_inspect_currentFrame,'bottom')

% delete(h_timeSeries_inspect);
% h_timeSeries_inspect = plot(h_timeSeries_axes,inspect_data_visual,'.-','markersize',7,'DisplayName',['Ankle']);
% set(h_timeSeries_inspect(1),'DisplayName','Right Ankle'); set(h_timeSeries_inspect(2),'DisplayName','Left Ankle');
% set(h_timeSeries_inspect(1),'color',[0 114 178]/256); set(h_timeSeries_inspect(2),'color',[213 94 0]/256); 

xlabel(h_timeSeries_axes,'Frame','fontunits','normalized','fontsize',.04)
ylabel(h_timeSeries_axes,'Horizontal pixel position','fontunits','normalized','fontsize',.04)
legend(h_timeSeries_axes,'location','best','orientation','vertical','fontsize',5);

if ~isnan(inspectionTrack_personID(frame))
h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame)],'color',[.2 .2 .2],'fontunits','normalized','fontsize',.05);
% h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame) ': tracked ID ' num2str(inspectionTrack_personID(frame))],'color',subC{inspectionTrack_personID(frame)},'fontunits','normalized','fontsize',.05);
else
h_title_timeSeries_pos = title(h_timeSeries_axes,['Frame ' num2str(frame) ': no tracked ID'],'color',[.5 .5 .5],'fontunits','normalized','fontsize',.05);
end

end
%% 'select inspection keypoints'
function select_inspectKeypoints(source,events)
global inspection_keypoints poseModel inspect_data_visual personTrack ...
    startTrackFrame endTrackFrame inspectionTrack_personID data inspect_data
% inspection_keypoints = {};
% for i = 1:length(source.Value)
% inspection_keypoints{i} = poseModel.keypoints{source.Value(i)};
% end; clearvars i
inspection_keypoints = [];
inspection_keypoints = source.Value;

inspect_data_visual = [];
inspect_data_visual =  inspect_data(:,inspection_keypoints,1);

% for k = 1:length(inspection_keypoints)
%     for j = startTrackFrame:endTrackFrame
%         eval(['inspect_data_visual.' inspection_keypoints{k} '(j,:) = [data.frame_' num2str(j) '.person_' num2str(inspectionTrack_personID(j)) '.' inspection_keypoints{k} '(1),data.frame_' num2str(j) '.person_' num2str(inspectionTrack_personID(j)) '.' inspection_keypoints{k} '(2)];'])
%     end; clearvars j
% end; clearvars k

plotInspection_timeSeries


end
