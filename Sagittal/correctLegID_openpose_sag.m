function correctLegID_openpose_sag(videoInfo)
clearvars -except videoInfo
v = videoInfo;
global frame corrected_data personTracked_data frames frameInfo data_openpose ...
    h_slider h_frameBox h_axes_timeSeries h_image hCursor startTrackFrame endTrackFrame ...
    h_axes_image h_frameBox_ankleAngle h_axes_ankleAngle h_plot_timeSeries trackedFrames h_plot_ankleAngle noFrames_inspection ...
    bilateral_temp_fields videoInfo correctLegID_fig
correctLegID_fig = []; corrected_data = []; frame = []; frameInfo = []; frames = []; personTracked_data = [];
load(fullfile(v.vid_openpose_path,[v.vid_openpose_name '_openpose.mat']));
frames = 1:data_openpose.noFiles;
corrected_data = data_openpose.pose.data_personTracked_raw_reOriented;
frameInfo.frames_switch = false(1,length(frames)); frameInfo.frames_leftClear = false(1,length(frames)); frameInfo.frames_rightClear = false(1,length(frames));
frameInfo.frames_leftToesClear = false(1,length(frames)); frameInfo.frames_rightToesClear = false(1,length(frames));
% bilateral_temp_fields = {'Hip','Knee','Ankle','BigToe','SmallToe','Heel'};
bilateral_temp_fields = [10:12 23:25; 13:15 20:22];

if isfield(frameInfo,'trackPerson_manual_input')
startTrackFrame = frameInfo.trackPerson_manual_input.saved_startTrackFrame;
endTrackFrame = frameInfo.trackPerson_manual_input.saved_endTrackFrame;
else
startTrackFrame = 1;
endTrackFrame = data_openpose.noFiles;
end
trackedFrames = startTrackFrame:endTrackFrame;
noFrames_inspection = length(trackedFrames);
frame = startTrackFrame;
personTracked_data = data_openpose.pose.data_personTracked_raw_reOriented;

correctLegID_fig = figure; 
% set(correctLegID_fig,'WindowState','maximized')
set(correctLegID_fig,'WindowStyle','docked')

h_axes_timeSeries = subplot(4,8,[1:4 9:12 17:20]); grid on
h_plot_timeSeries = plot(h_axes_timeSeries,trackedFrames,corrected_data(trackedFrames,12,1),'c.-',...
    trackedFrames,corrected_data(trackedFrames,15,1),'b.-'); 
h_frameBox = rectangle(h_axes_timeSeries,'Position',[frame-0.5 min(h_axes_timeSeries.YLim) 1 range(h_axes_timeSeries.YLim)],'edgecolor',[.7 .7 .7],'facecolor',[.7 .7 .7],'linewidth',.2);
uistack(h_frameBox,'bottom')
legend(h_axes_timeSeries,'Right','Left','location','northwest'); 
% h_axes_timeSeries.XLabel.String = 'Frames';
h_axes_timeSeries.YLabel.String = 'Hor. position (pixel)';
h_axes_timeSeries.Title.String = videoInfo.vid_openpose_name; h_axes_timeSeries.Title.Interpreter = 'none';
h_axes_timeSeries.XTick = frames; h_axes_timeSeries.XTickLabel = [];

h_axes_ankleAngle = subplot(4,8,[25:28]); grid on
jointAngles = calcAnkleAngle(corrected_data);
h_plot_ankleAngle = plot(h_axes_ankleAngle,trackedFrames,jointAngles.sag_2D.RAnkle,'c.-',...
    trackedFrames,jointAngles.sag_2D.LAnkle,'b.-'); 
h_frameBox_ankleAngle = rectangle(h_axes_ankleAngle,'Position',[frame-0.5 min(h_axes_ankleAngle.YLim) 1 range(h_axes_ankleAngle.YLim)],'edgecolor',[.7 .7 .7],'facecolor',[.7 .7 .7],'linewidth',.2);
uistack(h_frameBox_ankleAngle,'bottom')
h_axes_ankleAngle.YLabel.String = 'Ankle angle (deg)';
h_axes_ankleAngle.XLabel.String = 'Frames';

linkaxes([h_axes_timeSeries h_axes_ankleAngle],'x')


h_axes_image = subplot(4,8,[5:8 13:16 21:24]);hold on
showImage

uicontrol(correctLegID_fig,'style','pushbutton','String','Switch left-right ID of legs',...
   'units','normalized','Position',[0.55 0.3 0.2 0.05],'Callback',@switchID); % pushbutton to switch
   
uicontrol(correctLegID_fig,'style','pushbutton','String','Delete left ID','foregroundcolor','b','backgroundcolor','w',...
   'units','normalized','Position',[0.55 0.2 0.1 0.05],'Callback',@clearLeft); % pushbutton to delete left leg ID

uicontrol(correctLegID_fig,'style','pushbutton','String','Restore left ID','foregroundcolor','b','backgroundcolor','w',...
   'units','normalized','Position',[0.55 0.15 0.1 0.05],'Callback',@restoreLeft); % pushbutton to restore left leg ID
   
uicontrol(correctLegID_fig,'style','pushbutton','String','Delete left toes','foregroundcolor','b','backgroundcolor','w',...
   'units','normalized','Position',[0.55 0.1 0.1 0.05],'Callback',@clearLeftToes); % pushbutton to delete left leg ID

uicontrol(correctLegID_fig,'style','pushbutton','String','Delete right ID','foregroundcolor','c','backgroundcolor','w',...
   'units','normalized','Position',[0.7 0.2 0.1 0.05],'Callback',@clearRight); % pushbutton to delete right leg ID

uicontrol(correctLegID_fig,'style','pushbutton','String','Restore right ID','foregroundcolor','c','backgroundcolor','w',...
   'units','normalized','Position',[0.7 0.15 0.1 0.05],'Callback',@restoreRight); % pushbutton to restore right leg ID

uicontrol(correctLegID_fig,'style','pushbutton','String','Delete right toes','foregroundcolor','c','backgroundcolor','w',...
   'units','normalized','Position',[0.7 0.1 0.1 0.05],'Callback',@clearRightToes); % pushbutton to delete right leg ID

uicontrol(correctLegID_fig,'style','pushbutton','String','Restore entire data-series',...
   'units','normalized','Position',[0.55 0.01 0.2 0.05],'Callback',@restoreData); % pushbutton to restore entire data-series

uicontrol(correctLegID_fig,'style','pushbutton','String','Save',...
   'units','normalized','Position',[0.01 0.01 0.1 0.05],'Callback',@saveData); % pushbutton to save file

uicontrol(correctLegID_fig,'style','pushbutton','String','Pan',...
   'units','normalized','Position',[0.01 0.4 0.06 0.05],'Callback',@panON); % pushbutton to data cursor ON

uicontrol(correctLegID_fig,'style','pushbutton','String','Zoom',...
   'units','normalized','Position',[0.01 0.3 0.06 0.05],'Callback',@zoomON); % pushbutton to zoom ON

uicontrol(correctLegID_fig,'style','pushbutton','String','Data tip',...
   'units','normalized','Position',[0.01 0.2 0.06 0.05],'Callback',@dataCursorON); % pushbutton to data cursor ON

h_slider = uicontrol(correctLegID_fig,'style','slider','Min',startTrackFrame,'Max',endTrackFrame,'SliderStep',[1/noFrames_inspection 10/noFrames_inspection],'Value',frame,...
   'units','normalized','Position',[0.12 0.27 0.39 0.05],'Callback',@currentFrame_slider); % choose frame
% h_slider = uicontrol(correctLegID_fig,'style','slider','Min',startTrackFrame,'Max',endTrackFrame,'SliderStep',[1/noFrames_inspection 10/noFrames_inspection],'Value',frame,...
%    'units','normalized','Position',[0.55 0.37 0.375 0.05],'Callback',@currentFrame_slider); % choose frame
hCursor = datacursormode(correctLegID_fig); set(hCursor,'UpdateFcn',@myCursor);
hCursor.DisplayStyle = 'window';
datacursormode on

uiwait(correctLegID_fig)
end
%% "My Cursor"
function output_txt = myCursor(obj,event_obj)
global h_axes_timeSeries startTrackFrame endTrackFrame frame hCursor h_image h_frameBox h_image ...
    h_axes_image h_slider h_axes_ankleAngle h_frameBox_ankleAngle frameInfo

if event_obj.Target.Parent == h_axes_timeSeries || event_obj.Target.Parent == h_axes_ankleAngle
if event_obj.Position(1) >= startTrackFrame && event_obj.Position(1) <= endTrackFrame
        frame = event_obj.Position(1);    
%         output_txt = {['Frame ' num2str(frame)]};
        output_txt = {};
        
showImage
h_frameBox.Position = [frame-0.5 min(h_axes_timeSeries.YLim) 1 range(h_axes_timeSeries.YLim)];
h_frameBox_ankleAngle.Position = [frame-0.5 min(h_axes_ankleAngle.YLim) 1 range(h_axes_ankleAngle.YLim)];
h_slider.Value = frame;
determineImageTitle
end
    
end

end
%% "Current Frame" slider
function currentFrame_slider(source,event)
global h_slider frame h_image h_frameBox h_axes_timeSeries h_image h_axes_image h_frameBox_ankleAngle ...
    h_axes_ankleAngle frameInfo

frame = round(event.Source.Value);
showImage
h_frameBox.Position = [frame-0.5 min(h_axes_timeSeries.YLim) 1 range(h_axes_timeSeries.YLim)];
% h_slider.Value = frame;
h_frameBox_ankleAngle.Position = [frame-0.5 min(h_axes_ankleAngle.YLim) 1 range(h_axes_ankleAngle.YLim)];
determineImageTitle
end

%% "Switch" pushbutton
function switchID(source,event)
global frame corrected_data frames frameInfo h_plot_timeSeries trackedFrames h_plot_ankleAngle h_image ...
    bilateral_temp_fields

% for i = 1:length(bilateral_temp_fields)
% eval(['temp = corrected_data.R' bilateral_temp_fields{i} '(' num2str(frame) ',:);'])
% eval(['corrected_data.R' bilateral_temp_fields{i} '(' num2str(frame) ',:) = corrected_data.L' bilateral_temp_fields{i} '(' num2str(frame) ',:);'])
% eval(['corrected_data.L' bilateral_temp_fields{i} '(' num2str(frame) ',:) = temp;'])
% end
temp = corrected_data(frame,[10:12 23:25],:);
corrected_data(frame,[10:12 23:25],:) = corrected_data(frame,[13:15 20:22],:);
corrected_data(frame,[13:15 20:22],:) = temp;

h_plot_timeSeries(1).YData = corrected_data(trackedFrames,[12],1);
h_plot_timeSeries(2).YData = corrected_data(trackedFrames,[15],1);

% h_plot_timeSeries(1).YData = corrected_data.RAnkle(trackedFrames,1);
% h_plot_timeSeries(2).YData = corrected_data.LAnkle(trackedFrames,1);

jointAngles = calcAnkleAngle(corrected_data);
h_plot_ankleAngle(1).YData = jointAngles.sag_2D.RAnkle;
h_plot_ankleAngle(2).YData = jointAngles.sag_2D.LAnkle;

frameInfo.frames_switch(frame) = ~frameInfo.frames_switch(frame);
determineImageTitle
end
%% "Delete left" pushbutton
function clearLeft(source,event)
global frame corrected_data frames frameInfo h_plot_timeSeries trackedFrames h_plot_ankleAngle h_image ...
    bilateral_temp_fields

% for i = 1:length(bilateral_temp_fields)
% eval(['corrected_data.L' bilateral_temp_fields{i} '(' num2str(frame) ',:) = nan;'])
% end
% eval(['h_plot_timeSeries(2).YData = corrected_data.LAnkle(trackedFrames,1);'])
corrected_data(frame,[13:15 20:22],:) = nan;
h_plot_timeSeries(1).YData = corrected_data(trackedFrames,[12],1);
h_plot_timeSeries(2).YData = corrected_data(trackedFrames,[15],1);

jointAngles = calcAnkleAngle(corrected_data);
h_plot_ankleAngle(1).YData = jointAngles.sag_2D.RAnkle;
h_plot_ankleAngle(2).YData = jointAngles.sag_2D.LAnkle;

frameInfo.frames_leftClear(frame) = true;
determineImageTitle
end
%% "Restore left" pushbutton
function restoreLeft(source,event)
global frame corrected_data personTracked_data frames frameInfo h_plot_timeSeries trackedFrames h_plot_ankleAngle ...
    h_image bilateral_temp_fields 

% for i = 1:length(bilateral_temp_fields)
% eval(['corrected_data.L' bilateral_temp_fields{i} '(' num2str(frame) ',:) =  personTracked_data.L' bilateral_temp_fields{i} '(' num2str(frame) ',:);'])
% end
% eval(['h_plot_timeSeries(2).YData = corrected_data.LAnkle(trackedFrames,1);'])
corrected_data(frame,[13:15 20:22],:) = personTracked_data(frame,[13:15 20:22],:);

h_plot_timeSeries(1).YData = corrected_data(trackedFrames,[12],1);
h_plot_timeSeries(2).YData = corrected_data(trackedFrames,[15],1);

jointAngles = calcAnkleAngle(corrected_data)
h_plot_ankleAngle(1).YData = jointAngles.sag_2D.RAnkle;
h_plot_ankleAngle(2).YData = jointAngles.sag_2D.LAnkle;

frameInfo.frames_leftClear(frame) = false;
frameInfo.frames_leftToesClear(frame) = false;
determineImageTitle
end
%% "Delete left toes" pushbutton
function clearLeftToes(source,event)
global frame corrected_data frames frameInfo h_plot_timeSeries trackedFrames h_plot_ankleAngle h_image

corrected_data(frame,[20:22],:) = nan;

h_plot_timeSeries(1).YData = corrected_data(trackedFrames,[12],1);
h_plot_timeSeries(2).YData = corrected_data(trackedFrames,[15],1);

jointAngles = calcAnkleAngle(corrected_data)
h_plot_ankleAngle(1).YData = jointAngles.sag_2D.RAnkle;
h_plot_ankleAngle(2).YData = jointAngles.sag_2D.LAnkle;

frameInfo.frames_leftToesClear(frame) = true;
determineImageTitle
end
%% "Delete right" pushbutton
function clearRight(source,event)
global frame corrected_data frames frameInfo h_plot_timeSeries trackedFrames h_plot_ankleAngle h_image ...
    bilateral_temp_fields

% for i = 1:length(bilateral_temp_fields)
% eval(['corrected_data.R' bilateral_temp_fields{i} '(' num2str(frame) ',:) = nan;'])
% end
% eval(['h_plot_timeSeries(1).YData = corrected_data.RAnkle(trackedFrames,1);'])
corrected_data(frame,[10:12 23:25],:) = nan;

h_plot_timeSeries(1).YData = corrected_data(trackedFrames,[12],1);
h_plot_timeSeries(2).YData = corrected_data(trackedFrames,[15],1);

jointAngles = calcAnkleAngle(corrected_data)
h_plot_ankleAngle(1).YData = jointAngles.sag_2D.RAnkle;
h_plot_ankleAngle(2).YData = jointAngles.sag_2D.LAnkle;

frameInfo.frames_rightClear(frame) = true;
determineImageTitle
end
%% "Restore right" pushbutton
function restoreRight(source,event)
global frame corrected_data personTracked_data frames frameInfo h_plot_timeSeries trackedFrames h_plot_ankleAngle ...
    h_image

% for i = 1:length(bilateral_temp_fields)
% eval(['corrected_data.R' bilateral_temp_fields{i} '(' num2str(frame) ',:) = personTracked_data.R' bilateral_temp_fields{i} '(' num2str(frame) ',:);'])
% end
% eval(['h_plot_timeSeries(1).YData = corrected_data.RAnkle(trackedFrames,1);'])
corrected_data(frame,[10:12 23:25],:) = personTracked_data(frame,[10:12 23:25],:);

h_plot_timeSeries(1).YData = corrected_data(trackedFrames,[12],1);
h_plot_timeSeries(2).YData = corrected_data(trackedFrames,[15],1);

jointAngles = calcAnkleAngle(corrected_data)
h_plot_ankleAngle(1).YData = jointAngles.sag_2D.RAnkle;
h_plot_ankleAngle(2).YData = jointAngles.sag_2D.LAnkle;

frameInfo.frames_rightClear(frame) = false;
frameInfo.frames_rightToesClear(frame) = false;
determineImageTitle
end
%% "Delete right toes" pushbutton
function clearRightToes(source,event)
global frame corrected_data frames frameInfo h_plot_timeSeries trackedFrames h_plot_ankleAngle h_image ...
    h_axes_ankleAngle

corrected_data(frame,[23:25],:) = nan;

h_plot_timeSeries(1).YData = corrected_data(trackedFrames,[12],1);
h_plot_timeSeries(2).YData = corrected_data(trackedFrames,[15],1);

jointAngles = calcAnkleAngle(corrected_data)
h_plot_ankleAngle(1).YData = jointAngles.sag_2D.RAnkle;
h_plot_ankleAngle(2).YData = jointAngles.sag_2D.LAnkle;

frameInfo.frames_rightToesClear(frame) = true;
determineImageTitle
end
%% "Restore entire data-series" pushbutton
function restoreData(source,event)
global corrected_data personTracked_data frames frameInfo h_plot_timeSeries trackedFrames h_plot_ankleAngle frame h_image ...
    bilateral_temp_fields

% for i = 1:length(bilateral_temp_fields)
% eval(['corrected_data.R' bilateral_temp_fields{i} '(' num2str(frame) ',:) =  personTracked_data.R' bilateral_temp_fields{i} '(' num2str(frame) ',:);'])
% eval(['corrected_data.L' bilateral_temp_fields{i} '(' num2str(frame) ',:) =  personTracked_data.L' bilateral_temp_fields{i} '(' num2str(frame) ',:);'])
% end
% eval(['h_plot_timeSeries(1).YData = corrected_data.RAnkle(trackedFrames,1);'])
% eval(['h_plot_timeSeries(2).YData = corrected_data.LAnkle(trackedFrames,1);'])
corrected_data(:,[10:15 20:25],:) = personTracked_data(:,[10:15 20:25],:);

h_plot_timeSeries(1).YData = corrected_data(trackedFrames,[12],1);
h_plot_timeSeries(2).YData = corrected_data(trackedFrames,[15],1);

jointAngles = calcAnkleAngle(corrected_data)
h_plot_ankleAngle(1).YData = jointAngles.sag_2D.RAnkle;
h_plot_ankleAngle(2).YData = jointAngles.sag_2D.LAnkle;

frameInfo.frames_switch = false(1,length(frames)); frameInfo.frames_leftClear = false(1,length(frames)); frameInfo.frames_rightClear = false(1,length(frames));
frameInfo.frames_leftToesClear = false(1,length(frames)); frameInfo.frames_rightToesClear = false(1,length(frames));
determineImageTitle
end
%% "Save" pushbutton
function saveData(source,event)
global corrected_data correctLegID_fig data_openpose frameInfo videoInfo
data_openpose.pose.corrected_data = corrected_data;
save(fullfile(videoInfo.vid_openpose_path,[videoInfo.vid_openpose_name '_openpose.mat']),'data_openpose','frameInfo','-append')
close(correctLegID_fig)
end
%% "Zoom" pushbutton
function zoomON(source,event)
zoom on
end
%% "Data tip" pushbutton
function dataCursorON(source,event) 
datacursormode on
end
%% "Pan" pushbutton
function panON(source,event)
pan on
end
%% Calc. ankle angle
function jointAngles = calcAnkleAngle(corrected_data)
global corrected_data trackedFrames
% jointAngles.sag_2D.LAnkle = - ( atan2d(corrected_data.LKnee(trackedFrames,2)-corrected_data.LAnkle(trackedFrames,2),corrected_data.LKnee(trackedFrames,1)-corrected_data.LAnkle(trackedFrames,1)) - atan2d(corrected_data.LBigToe(trackedFrames,2)-corrected_data.LAnkle(trackedFrames,2),corrected_data.LBigToe(trackedFrames,1)-corrected_data.LAnkle(trackedFrames,1)) - 90 );
% jointAngles.sag_2D.RAnkle = - ( atan2d(corrected_data.RKnee(trackedFrames,2)-corrected_data.RAnkle(trackedFrames,2),corrected_data.RKnee(trackedFrames,1)-corrected_data.RAnkle(trackedFrames,1)) - atan2d(corrected_data.RBigToe(trackedFrames,2)-corrected_data.RAnkle(trackedFrames,2),corrected_data.RBigToe(trackedFrames,1)-corrected_data.RAnkle(trackedFrames,1)) - 90 );
jointAngles.sag_2D.LAnkle = - ( atan2d(corrected_data(trackedFrames,14,2)-corrected_data(trackedFrames,15,2),corrected_data(trackedFrames,14,1)-corrected_data(trackedFrames,15,1)) - atan2d(corrected_data(trackedFrames,20,2)-corrected_data(trackedFrames,15,2),corrected_data(trackedFrames,20,1)-corrected_data(trackedFrames,15,1)) - 90 );
jointAngles.sag_2D.RAnkle = - ( atan2d(corrected_data(trackedFrames,11,2)-corrected_data(trackedFrames,12,2),corrected_data(trackedFrames,11,1)-corrected_data(trackedFrames,12,1)) - atan2d(corrected_data(trackedFrames,23,2)-corrected_data(trackedFrames,12,2),corrected_data(trackedFrames,23,1)-corrected_data(trackedFrames,12,1)) - 90 );
end
%% "Show Image" function
function showImage(source,event)
global frame videoInfo h_image h_axes_image
delete(h_image)
h_image = imshow(read(videoInfo.vid_openpose,frame),'InitialMagnification','fit','Parent',h_axes_image); 
h_axes_image.Title.String = ['Frame ' num2str(frame) ]; h_axes_image.Title.Interpreter = 'none';
determineImageTitle
end
%% determine image title
function determineImageTitle(source,event)
global h_axes_image frame frameInfo videoInfo

h_axes_image.Title.String = ['Frame ' num2str(frame) ];
if frameInfo.frames_switch(frame) == true
h_axes_image.Title.String(end+1:end+10) = '; Switched';
end
if frameInfo.frames_leftClear(frame) == true
h_axes_image.Title.String(end+1:end+13) = '; Left Delete';    
end
if frameInfo.frames_rightClear(frame) == true
h_axes_image.Title.String(end+1:end+14) = '; Right Delete';    
end
if frameInfo.frames_leftToesClear(frame) == true
h_axes_image.Title.String(end+1:end+18) = '; Left Toes Delete';    
end
if frameInfo.frames_rightToesClear(frame) == true
h_axes_image.Title.String(end+1:end+19) = '; Right Toes Delete';    
end

end