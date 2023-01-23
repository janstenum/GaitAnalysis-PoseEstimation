% function [trackPerson_manual_input] = trackPerson_openpose_manual_input(data_input,conf,time_openpose,numberPersonsDetected_input,vid_openpose,output_name,bodyModel_input)
function [personTrack] = trackPerson_openpose_manual_input(data_openpose,videoInfo,frameInfo,openpose)
global v frame data hp hl name numberPersonsDetected index_Lines subC h_manPick pickPersonFig h_showCurrentFrame pickPersonID ...
    anchorFrame anchorID h_anchorPushButton startTrackFrame endTrackFrame h_setStartTracking h_setEndTracking ...
    checkPoints h_checkPoints selectedCheckPoints trackPerson_manual_input ...
    h_currentFrame_popup h_currentFrame_slider noFrames h_currentFrame_edit hCursor h_image cursorID bodyModel ...
    h_manPickTitle image_axes h_grayRadioButton personTrack h_image_title


data = data_openpose.pose.data_raw;
numberPersonsDetected = frameInfo.numberPersonsDetected;
subC = {'r','b','c','m','g','k','y','w'};
v = videoInfo.vid_openpose;
% index_Lines = {[7 8],[7 6],[2 6],[2 3],[3 4],[4 5],[4 3],[2 3],[2 9],[9 10],[10 11],[11 12],[12 25],[25 23],[23 24],[24 12],[12 11],[11 10],[9 10],[9 13],[13 14],[14 15],[15 22],[22 20],[20 21],[21 15]}
%     ,[12 25],[12 23],[12 24],[15 22],[15 20],[15 21]};
bodyModel = openpose.pose.bodyModel;
% bodyModel = bodyModel_input;
switch bodyModel
    case 'BODY_25'
%         index_Lines = [7 8 7 6 2 6 2 3 3 4 4 5 4 3 2 3 2 9 9 10 10 11 11 12 12 25 25 23 23 24 24 12 12 11 11 10 9 10 9 13 13 14 14 15 15 22 22 20 20 21 21 15];
%         index_Lines = {'LElbow' 'LWrist'; 'LElbow' 'LShoulder'; 'Neck' 'LShoulder'; 'Neck' 'RShoulder'; 'RShoulder' 'RElbow'; 'RElbow' 'RWrist'; ...
%             'RElbow' 'RShoulder'; 'Neck' 'RShoulder'; 'Neck' 'MidHip'; 'MidHip' 'RHip'; 'RHip' 'RKnee'; 'RKnee' 'RAnkle'; 'RAnkle' 'RHeel'; 'RHeel' 'RBigToe'; ...
%             'RBigToe' 'RSmallToe'; 'RSmallToe' 'RAnkle'; 'RAnkle' 'RKnee'; 'RKnee' 'RHip'; 'RHip' 'MidHip'; 'MidHip' 'LHip'; 'LHip' 'LKnee'; 'LKnee' 'LAnkle'; ...
%             'LAnkle' 'LHeel'; 'LHeel' 'LBigToe'; 'LBigToe' 'LSmallToe'; 'LSmallToe' 'LAnkle'};
        index_Lines = {'LWrist'; 'LElbow';'LShoulder'; 'Neck'; 'LEye'; 'LEar'; 'LEye'; 'REye'; 'REar'; 'REye'; 'Neck'; ...
            'RShoulder'; 'RElbow'; 'RWrist'; ...
            'RElbow';'RShoulder'; 'Neck'; 'MidHip'; 'RHip'; 'RKnee'; 'RAnkle'; 'RHeel'; ...
            'RBigToe'; 'RSmallToe'; 'RAnkle'; 'RKnee'; 'RHip'; 'MidHip'; 'LHip'; 'LKnee'; ...
            'LAnkle'; 'LHeel'; 'LBigToe'; 'LSmallToe'};
        index_Lines = [8 7 6 2 17 19 17 16 18 16 2 3 4 5 4 3 2 9 10 11 12 25 23 24 12 11 10 9 13 14 15 22 20 21];
    case 'BODY_21'
        index_Lines = [19 17 1 16 18 18 16 16 1 1 2 2 3 3 4 4 5 5 4 4 3 3 2 2 6 6 7 7 8 8 7 7 6 6 2 2 9 9 10 10 11 11 12 12 11 11 10 10 9 9 13 13 14 14 15];
end

% maxPersonsDetected = max(frameInfo.numberPersonsDetected);
noFrames = data_openpose.noFiles;
% noKeyPoints = pose.noKeypoints;
% noDim = 2;
manualTrackedPersonIndex = nan(noFrames,1);
frame = 1;
name = videoInfo.vid_openpose_name;
pickPersonID = nan;
anchorFrame = [];
anchorID = [];
startTrackFrame = 1;
endTrackFrame = noFrames;
checkPoints = [];
selectedCheckPoints = [];
cursorID = [];
showImage_gray = 0;

pickPersonFig = figure; set(pickPersonFig,'WindowStyle','docked'); hold on
h_grayRadioButton = uicontrol(pickPersonFig,'Style','checkbox','String','Gray','Value',0,'fontunits','normalized','fontsize',.7,...
                  'units','normalized','Position',[.01 .225 .1 .025],'Callback',@grayScale);

text(.7,.65,'Frame','units','normalized')
image_axes = subplot(2,4,[1:3 5:7]);hold on
h_image = imshow(read(v,frame),'InitialMagnification','fit','Parent',image_axes);
% displayFrame
h_image_title = title([name ': Frame ' num2str(frame)],'interpreter','none');

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
hp{i} = plot(image_axes,t(:,1),t(:,2),'.-','color',subC{i},'markersize',8,'linewidth',2,'DisplayName',['ID ' num2str(i)]);
% hp_legend(i) = hp{i};
% hp_legend_labels{i} = ['ID ' num2str(i)];
end    
% legend(image_axes,'position',[0.1448 0.3 0.4 0.0349],'orientation','horizontal');
% hl = legend(hp_legend,hp_legend_labels,'location','southwest');
% hl = legend(hp_legend,hp_legend_labels,'position',[0.1448 0.3 0.4 0.0349],'orientation','horizontal');
% plotPersons





h_currentFrame_slider = uicontrol(pickPersonFig,'style','slider','Min',1,'Max',noFrames,'SliderStep',[1/noFrames 10/noFrames],'Value',frame,...
   'units','normalized','Position',[0.7 0.6 0.2 0.05],'Callback',@currentFrame_slider); % choose frame
% h_currentFrame_popup = uicontrol(pickPersonFig,'style','popupmenu','string', num2cell(1:noFrames) ,'Value',frame,...
%    'units','normalized','Position',[0.91 0.6 0.09 0.05],'Callback',@currentFrame_popup); % choose frame
h_currentFrame_edit = uicontrol(pickPersonFig,'style','edit','string',num2str(frame),...
   'units','normalized','Position',[0.91 0.6 0.05 0.03],'Callback',@currentFrame_edit); % choose frame
% h_showCurrentFrame = annotation(pickPersonFig,'textbox','String',['Frame: ' num2str(frame)], 'Position', [0.7 0.64 0.2 0.05],'edgecolor',[1 1 1]);

% h_manPick = uicontrol(pickPersonFig,'style','popupmenu','String',num2cell(1:numberPersonsDetected(frame)),'value',pickPersonID,...
%    'units','normalized','Position',[0.7 0.4 0.1 0.05],'Callback',@pickPerson); % choose frame
% h_manPick.Visible = 'off';
h_manPickTitle = annotation(pickPersonFig,'textbox','String','Pick Person ID', 'Position', [0.7 0.44 0.2 0.05],'edgecolor',[1 1 1]);
h_manPickTitle.Visible = 'off';

h_anchorPushButton = uicontrol(pickPersonFig,'style','pushbutton','String',['Set Anchor Point'],'fontsize',8,...
    'units','normalized','Position',[0.05 0.1 0.3 0.05],'Callback',@pickAnchor); % pick anchor point   

h_setStartTracking = uicontrol(pickPersonFig,'style','pushbutton','String',['Set start of tracking: frame ' num2str(startTrackFrame)],'fontsize',6,...
    'units','normalized','Position',[0.45 0.1 0.2 0.05],'Callback',@pickStartTrack); % pick first frame of trakcing

h_setEndTracking = uicontrol(pickPersonFig,'style','pushbutton','String',['Set end of tracking: frame ' num2str(endTrackFrame)],'fontsize',6,...
    'units','normalized','Position',[0.45 0.05 0.2 0.05],'Callback',@pickEndTrack); % pick last frame of trakcing

% h_checkPoints = uicontrol(pickPersonFig,'style','listbox','string',checkPoints,'fontsize',8,'max',2,'Value',selectedCheckPoints,...
%     'units','normalized','Position',[0.7 0.05 0.20 0.1],'Callback',@selectCheckPoints); % show check points and clear check points
% annotation(pickPersonFig,'textbox','String','Check Points', 'Position', [0.7 0.14 0.2 0.05],'edgecolor',[1 1 1]);
% 
% h_setCheckPoint = uicontrol(pickPersonFig,'style','pushbutton','string','Set Check Point','fontsize',6,...
%     'units','normalized','Position',[0.9 0.1 0.1 0.05],'Callback',@setCheckPoint);
% 
% h_deleteCheckPoint = uicontrol(pickPersonFig,'style','pushbutton','string','Delete Point','fontsize',6,...
%     'units','normalized','Position',[0.9 0.05 0.1 0.05],'Callback',@deleteCheckPoint);

h_saveContinue = uicontrol(pickPersonFig,'style','pushbutton','string','Save and Continue',...
    'units','normalized','Position',[0.7 0.85 0.2 0.05],'Callback',@saveContinue);

hCursor = datacursormode(pickPersonFig); set(hCursor,'UpdateFcn',@myCursor);
datacursormode on

uiwait(pickPersonFig)
end
%% "My Cursor"
function output_txt = myCursor(obj,event_obj)
global hp numberPersonsDetected frame pickPersonID h_manPick pickPersonFig hCursor cursorID
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

if strcmp(event_obj.Target.Type,'line')
    cursorData = [event_obj.Target.XData; event_obj.Target.YData];
    selectedID = false(numberPersonsDetected(frame),1);
    for i = 1:numberPersonsDetected(frame)
        selectedID(i) = isequaln([hp{i}.XData; hp{i}.YData],cursorData);
    end
    pickPersonID = find(selectedID);
    output_txt = ['ID ' num2str(pickPersonID)'];
    cursorID = pickPersonID;
%     h_manPick = uicontrol(pickPersonFig,'style','popupmenu','String',num2cell(1:numberPersonsDetected(frame)),'value',pickPersonID,...
%    'units','normalized','Position',[0.7 0.4 0.1 0.05],'Callback',@pickPerson); % choose frame
else
    output_txt = {'You must select a person (you cannot select image)'};
    cursorID = nan;
end

end
%% "Current Frame" slider
function currentFrame_slider(source,event)
global v frame data hp hl name numberPersonsDetected index_Lines subC h_manPick pickPersonFig h_showCurrentFrame pickPersonID h_currentFrame_popup h_currentFrame_slider noFrames h_currentFrame_edit h_image ...
    anchorFrame h_trackBox anchorID image_axes h_image_title
frame = round(event.Source.Value);
delete(hl),for j = 1:length(hp);delete(hp{j});end
subplot(2,4,[1:3 5:7]),hold on
delete(h_image)
displayFrame
% h_image = imshow(read(v,frame),'InitialMagnification','fit');
% hp = cell(numberPersonsDetected(frame),1);
% hp_legend = nan(numberPersonsDetected(frame),1);
% hp_legend_labels = cell(numberPersonsDetected(frame),1);
% for i = 1:numberPersonsDetected(frame)
% t = [];
% t = nan(length(index_Lines),2);
%     for j = 1:length(index_Lines)
%         eval(['t(j,:) = [-data.frame_' num2str(frame) '.person_' num2str(i) '.' index_Lines{j} '(1)+v.Width,-data.frame_' num2str(frame) '.person_' num2str(i) '.' index_Lines{j} '(2)+v.Height];'])
%     end
% %     t = squeeze(data(i,frame,index_Lines,:));
% hp{i} = plot(t(:,1),t(:,2),'.-','color',subC{i},'markersize',8,'linewidth',2);
% hp_legend(i) = hp{i};
% hp_legend_labels{i} = ['ID ' num2str(i)];
% end    
% 
% hl = legend(hp_legend,hp_legend_labels,'position',[0.1448 0.3 0.4 0.0349],'orientation','horizontal');
plotPersons

if frame == anchorFrame
h_trackBox = rectangle('Position',[min(hp{anchorID}.XData) min(hp{anchorID}.YData)  range(hp{anchorID}.XData) range(hp{anchorID}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);
end

% delete(h_manPick),delete(h_showCurrentFrame)
if pickPersonID > numberPersonsDetected(frame); pickPersonID = numberPersonsDetected(frame); end
% h_manPick = uicontrol(pickPersonFig,'style','popupmenu','String',num2cell(1:numberPersonsDetected(frame)),'value',pickPersonID,...
%    'units','normalized','Position',[0.7 0.4 0.1 0.05],'Callback',@pickPerson); % choose frame
% h_showCurrentFrame = annotation(pickPersonFig,'textbox','String',['Frame: ' num2str(frame)], 'Position', [0.7 0.64 0.2 0.05],'edgecolor',[1 1 1]);
h_image_title.String = [name ': Frame ' num2str(frame)];

delete(h_currentFrame_slider),delete(h_currentFrame_popup)
h_currentFrame_slider = uicontrol(pickPersonFig,'style','slider','Min',1,'Max',noFrames,'SliderStep',[1/noFrames 10/noFrames],'Value',frame,...
   'units','normalized','Position',[0.7 0.6 0.2 0.05],'Callback',@currentFrame_slider); % choose frame
% h_currentFrame_popup = uicontrol(pickPersonFig,'style','popupmenu','string', num2cell(1:noFrames) ,'Value',frame,...
%    'units','normalized','Position',[0.91 0.6 0.09 0.05],'Callback',@currentFrame_popup); % choose frame
% h_currentFrame_edit = uicontrol(pickPersonFig,'style','edit','string',num2str(frame),...
%    'units','normalized','Position',[0.91 0.57 0.05 0.03],'Callback',@currentFrame_edit); % choose frame
h_currentFrame_edit.String = num2str(frame);
end
%% "Current Frame" popupmenu
function currentFrame_popup(source,event)
global v frame data hp hl name numberPersonsDetected index_Lines subC h_manPick pickPersonFig h_showCurrentFrame pickPersonID h_currentFrame_popup h_currentFrame_slider noFrames h_currentFrame_edit h_image ...
    anchorFrame h_trackBox anchorID image_axes h_image_title
frame = round(event.Source.Value);
delete(hl),for j = 1:length(hp);delete(hp{j});end
subplot(2,4,[1:3 5:7]),hold on
delete(h_image)
displayFrame
h_image_title.String = [name ': Frame ' num2str(frame)];

% h_image = imshow(read(v,frame),'InitialMagnification','fit');
% hp = cell(numberPersonsDetected(frame),1);
% hp_legend = nan(numberPersonsDetected(frame),1);
% hp_legend_labels = cell(numberPersonsDetected(frame),1);
% for i = 1:numberPersonsDetected(frame)
% t = [];
% t = nan(length(index_Lines),2);
%     for j = 1:length(index_Lines)
%         eval(['t(j,:) = [-data.frame_' num2str(frame) '.person_' num2str(i) '.' index_Lines{j} '(1)+v.Width,-data.frame_' num2str(frame) '.person_' num2str(i) '.' index_Lines{j} '(2)+v.Height];'])
%     end
% % t = squeeze(data(i,frame,index_Lines,:));
% hp{i} = plot(t(:,1),t(:,2),'.-','color',subC{i},'markersize',8,'linewidth',2);
% hp_legend(i) = hp{i};
% hp_legend_labels{i} = ['ID ' num2str(i)];
% end    
% 
% hl = legend(hp_legend,hp_legend_labels,'position',[0.1448 0.3 0.4 0.0349],'orientation','horizontal');
plotPersons

if frame == anchorFrame
h_trackBox = rectangle('Position',[min(hp{anchorID}.XData) min(hp{anchorID}.YData)  range(hp{anchorID}.XData) range(hp{anchorID}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);
end

% delete(h_manPick),delete(h_showCurrentFrame)
if pickPersonID > numberPersonsDetected(frame); pickPersonID = numberPersonsDetected(frame); end
% h_manPick = uicontrol(pickPersonFig,'style','popupmenu','String',num2cell(1:numberPersonsDetected(frame)),'value',pickPersonID,...
%    'units','normalized','Position',[0.7 0.4 0.1 0.05],'Callback',@pickPerson); % choose frame
% h_showCurrentFrame = annotation(pickPersonFig,'textbox','String',['Frame: ' num2str(frame)], 'Position', [0.7 0.64 0.2 0.05],'edgecolor',[1 1 1]);

delete(h_currentFrame_slider),delete(h_currentFrame_popup)
h_currentFrame_slider = uicontrol(pickPersonFig,'style','slider','Min',1,'Max',noFrames,'SliderStep',[1/noFrames 10/noFrames],'Value',frame,...
   'units','normalized','Position',[0.7 0.6 0.2 0.05],'Callback',@currentFrame_slider); % choose frame
% h_currentFrame_popup = uicontrol(pickPersonFig,'style','popupmenu','string', num2cell(1:noFrames) ,'Value',frame,...
%    'units','normalized','Position',[0.91 0.6 0.09 0.05],'Callback',@currentFrame_popup); % choose frame
% h_currentFrame_edit = uicontrol(pickPersonFig,'style','edit','string',num2str(frame),...
%    'units','normalized','Position',[0.91 0.57 0.05 0.03],'Callback',@currentFrame_edit); % choose frame
h_currentFrame_edit.String = num2str(frame);
end
%% "Current Frame" edit
function currentFrame_edit(source,event)
global v frame data hp hl name numberPersonsDetected index_Lines subC h_manPick pickPersonFig h_showCurrentFrame pickPersonID h_currentFrame_popup h_currentFrame_slider noFrames h_currentFrame_edit h_image ...
    anchorFrame h_trackBox anchorID image_axes h_image_title
frame_input = event.Source.String;
if any(1:noFrames == str2double(frame_input))
frame = str2double(frame_input);
h_image_title.String = [name ': Frame ' num2str(frame)];
    
delete(hl),for j = 1:length(hp);delete(hp{j});end
subplot(2,4,[1:3 5:7]),hold on
delete(h_image)
displayFrame
% h_image = imshow(read(v,frame),'InitialMagnification','fit');
% hp = cell(numberPersonsDetected(frame),1);
% hp_legend = nan(numberPersonsDetected(frame),1);
% hp_legend_labels = cell(numberPersonsDetected(frame),1);
% for i = 1:numberPersonsDetected(frame)
% t = [];
% t = nan(length(index_Lines),2);
%     for j = 1:length(index_Lines)
%         eval(['t(j,:) = [-data.frame_' num2str(frame) '.person_' num2str(i) '.' index_Lines{j} '(1)+v.Width,-data.frame_' num2str(frame) '.person_' num2str(i) '.' index_Lines{j} '(2)+v.Height];'])
%     end
% % t = squeeze(data(i,frame,index_Lines,:));
% hp{i} = plot(t(:,1),t(:,2),'.-','color',subC{i},'markersize',8,'linewidth',2);
% hp_legend(i) = hp{i};
% hp_legend_labels{i} = ['ID ' num2str(i)];
% end    
% 
% hl = legend(hp_legend,hp_legend_labels,'position',[0.1448 0.3 0.4 0.0349],'orientation','horizontal');
plotPersons

if frame == anchorFrame
h_trackBox = rectangle('Position',[min(hp{anchorID}.XData) min(hp{anchorID}.YData)  range(hp{anchorID}.XData) range(hp{anchorID}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);
end

% delete(h_manPick),delete(h_showCurrentFrame)
if pickPersonID > numberPersonsDetected(frame); pickPersonID = numberPersonsDetected(frame); end
% h_manPick = uicontrol(pickPersonFig,'style','popupmenu','String',num2cell(1:numberPersonsDetected(frame)),'value',pickPersonID,...
%    'units','normalized','Position',[0.7 0.4 0.1 0.05],'Callback',@pickPerson); % choose frame
% h_showCurrentFrame = annotation(pickPersonFig,'textbox','String',['Frame: ' num2str(frame)], 'Position', [0.7 0.64 0.2 0.05],'edgecolor',[1 1 1]);

delete(h_currentFrame_slider),delete(h_currentFrame_popup)
h_currentFrame_slider = uicontrol(pickPersonFig,'style','slider','Min',1,'Max',noFrames,'SliderStep',[1/noFrames 10/noFrames],'Value',frame,...
   'units','normalized','Position',[0.7 0.6 0.2 0.05],'Callback',@currentFrame_slider); % choose frame
% h_currentFrame_popup = uicontrol(pickPersonFig,'style','popupmenu','string', num2cell(1:noFrames) ,'Value',frame,...
%    'units','normalized','Position',[0.91 0.6 0.09 0.05],'Callback',@currentFrame_popup); % choose frame
% h_currentFrame_edit = uicontrol(pickPersonFig,'style','edit','string',num2str(frame),...
%    'units','normalized','Position',[0.91 0.57 0.05 0.03],'Callback',@currentFrame_edit); % choose frame    
h_currentFrame_edit.String = num2str(frame);
    
else
   errordlg(['You must input a valid frame number: 1 to ' num2str(noFrames)],'Non-frame number entered') 
end

end
%% "Pick Person" popupmenu
function pickPerson(source,event)
global manualTrackedPersonIndex frame data pickPersonID hCursor output_txt pickPersonFig hl hp h_image v numberPersonsDetected hp_legend hp_legend_labels index_Lines subC cursorID ...
    image_axes
% manualTrackedPersonIndex(frame) = event.Source.Value;
pickPersonID = event.Source.Value;

if isnumeric(cursorID) && cursorID ~= pickPersonID
delete(hl),for j = 1:length(hp);delete(hp{j});end
subplot(2,4,[1:3 5:7]),hold on
delete(h_image)
displayFrame
% h_image = imshow(read(v,frame),'InitialMagnification','fit');
% hp = cell(numberPersonsDetected(frame),1);
% hp_legend = nan(numberPersonsDetected(frame),1);
% hp_legend_labels = cell(numberPersonsDetected(frame),1);
% for i = 1:numberPersonsDetected(frame)
% t = [];
% t = nan(length(index_Lines),2);
%     for j = 1:length(index_Lines)
%         eval(['t(j,:) = [-data.frame_' num2str(frame) '.person_' num2str(i) '.' index_Lines{j} '(1)+v.Width,-data.frame_' num2str(frame) '.person_' num2str(i) '.' index_Lines{j} '(2)+v.Height];'])
%     end
% % t = squeeze(data(i,frame,index_Lines,:));
% hp{i} = plot(t(:,1),t(:,2),'.-','color',subC{i},'markersize',8,'linewidth',2);
% hp_legend(i) = hp{i};
% hp_legend_labels{i} = ['ID ' num2str(i)];
% end    
% 
% hl = legend(hp_legend,hp_legend_labels,'position',[0.1448 0.3 0.4 0.0349],'orientation','horizontal');
plotPersons
end

end
%% "Pick Anchor" pushbutton
function pickAnchor(source,event)
global frame pickPersonID anchorFrame anchorID h_anchorPushButton pickPersonFig h_trackBox hp

if isnan(pickPersonID)
    errordlg('You must pick a person before setting an anchor','Person ID not set');
else
anchorFrame = frame;
anchorID = pickPersonID;

delete(h_anchorPushButton)
h_anchorPushButton = uicontrol(pickPersonFig,'style','pushbutton','String',['Set Anchor Point: Person ' num2str(anchorID) ' at frame ' num2str(anchorFrame)],'fontsize',8,...
    'units','normalized','Position',[0.05 0.1 0.3 0.05],'Callback',@pickAnchor); % pick anchor point 

h_trackBox = rectangle('Position',[min(hp{anchorID}.XData) min(hp{anchorID}.YData)  range(hp{anchorID}.XData) range(hp{anchorID}.YData)],'edgecolor',[.9 .9 .9],'linewidth',.2);
end

end
%% "Set start of tracking" pushbutton
function pickStartTrack(source,event)
global frame startTrackFrame h_setStartTracking pickPersonFig
startTrackFrame = frame;

delete(h_setStartTracking)
h_setStartTracking = uicontrol(pickPersonFig,'style','pushbutton','String',['Set start of tracking: frame ' num2str(startTrackFrame)],'fontsize',6,...
    'units','normalized','Position',[0.45 0.1 0.2 0.05],'Callback',@pickStartTrack); % pick first frame of trakcing
end

%% "Set end of tracking" pushbutton
function pickEndTrack(source,event)
global frame endTrackFrame h_setEndTracking pickPersonFig
endTrackFrame = frame;

delete(h_setEndTracking)
h_setEndTracking = uicontrol(pickPersonFig,'style','pushbutton','String',['Set start of tracking: frame ' num2str(endTrackFrame)],'fontsize',6,...
    'units','normalized','Position',[0.45 0.05 0.2 0.05],'Callback',@pickEndTrack); % pick first frame of trakcing
end
%% "Check Point" listbox
function selectCheckPoints(source,event)
global selectedCheckPoints
selectedCheckPoints = event.Source.Value;

end
%% "Set Check Point" pushbutton
function setCheckPoint(source,event)
global checkPoints frame pickPersonID h_checkPoints pickPersonFig selectedCheckPoints
if isempty(checkPoints)
checkPoints = [frame pickPersonID]; 
else
[nRow nCol] = size(checkPoints);
checkPoints(nRow+1,:) = [frame pickPersonID];
end

delete(h_checkPoints)
[nRow nCol] = size(checkPoints);
titleCheckPoints = cell(nRow,1);    
for i = 1:nRow
titleCheckPoints{i} = ['Person ' num2str(checkPoints(i,2)) ' at frame ' num2str(checkPoints(i,1))];
end
h_checkPoints = uicontrol(pickPersonFig,'style','listbox','string',titleCheckPoints,'fontsize',8,'max',2,'Value',selectedCheckPoints,...
    'units','normalized','Position',[0.7 0.05 0.20 0.1],'Callback',@selectCheckPoints);

end
%% Delete Check Point" pushbutton
function deleteCheckPoint(source,event)
global pickPersonFig h_checkPoints checkPoints selectedCheckPoints
checkPoints(selectedCheckPoints,:) = [];

delete(h_checkPoints)
[nRow nCol] = size(checkPoints);
titleCheckPoints = cell(nRow,1);    
for i = 1:nRow
titleCheckPoints{i} = ['Person ' num2str(checkPoints(i,2)) ' at frame ' num2str(checkPoints(i,1))];
end
selectedCheckPoints = [];
h_checkPoints = uicontrol(pickPersonFig,'style','listbox','string',titleCheckPoints,'fontsize',8,'max',2,'Value',selectedCheckPoints,...
    'units','normalized','Position',[0.7 0.05 0.20 0.1],'Callback',@selectCheckPoints);
end
%% "Save and Continue" Pushbutton
function saveContinue(source,event)
global anchorFrame anchorID startTrackFrame endTrackFrame checkPoints pickPersonFig ...
    personTrack
if isempty(anchorFrame)
    errordlg('You must select an anchor point to continue','No anchor point selected')
else
   personTrack.trackPerson_manual_input.saved_anchorFrame = anchorFrame;
   personTrack.trackPerson_manual_input.saved_anchorID = anchorID;
   personTrack.trackPerson_manual_input.saved_startTrackFrame = startTrackFrame;
   personTrack.trackPerson_manual_input.saved_endTrackFrame = endTrackFrame;
   personTrack.trackPerson_manual_input.saved_checkPoints = checkPoints;
   
   close(pickPersonFig)
end

end
%% "Gray-scale" radiobutton
function grayScale(source,event)
global h_grayRadioButton hp
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
global image_axes h_image v frame h_grayRadioButton
delete(h_image)
if h_grayRadioButton.Value == 0
h_image = imshow(read(v,frame),'InitialMagnification','fit','Parent',image_axes);
elseif h_grayRadioButton.Value == 1
h_image = imshow(rgb2gray(read(v,frame)),'InitialMagnification','fit','Parent',image_axes);    
end
end
%% "Plot persons"
function plotPersons(source,event)
global hp numberPersonsDetected frame image_axes index_Lines data v subC
for i = 1:length(hp)
delete(hp{i})
end; clearvars i
hp = cell(numberPersonsDetected(frame),1);
% hp_legend = nan(numberPersonsDetected(frame),1);
% hp_legend_labels = cell(numberPersonsDetected(frame),1);
for i = 1:numberPersonsDetected(frame)
% t = [];
% t = nan(length(index_Lines),2);
%     for j = 1:length(index_Lines)
%         eval(['t(j,:) = [data.frame_' num2str(frame) '.person_' num2str(i) '.' index_Lines{j} '(1),data.frame_' num2str(frame) '.person_' num2str(i) '.' index_Lines{j} '(2)];'])
%     end
t = squeeze(data(i,frame,index_Lines,:));
hp{i} = plot(image_axes,t(:,1),t(:,2),'.-','color',subC{i},'markersize',8,'linewidth',2,'DisplayName',['ID ' num2str(i)]);
% hp_legend(i) = hp{i};
% hp_legend_labels{i} = ['ID ' num2str(i)];
end    
% legend(image_axes,'position',[0.1448 0.3 0.4 0.0349],'orientation','horizontal');
% hl = legend(hp_legend,hp_legend_labels,'location','southwest');
% hl = legend(hp_legend,hp_legend_labels,'position',[0.1448 0.3 0.4 0.0349],'orientation','horizontal');

end