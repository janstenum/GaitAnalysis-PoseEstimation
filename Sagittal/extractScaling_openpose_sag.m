function extractScaling_openpose_sag(videoInfo)
clearvars -except videoInfo
global scaling_fig scaling data_openpose length_dim setDistEdit h_image h_currentFrame_slider h_currentFrame_edit h_image_axes ...
    videoInfo
% file = sprintf('%s%s',output_name,'_openpose.mat');
% cd = output_path;
%%
% length_dim = inputdlg('Distance (in meters) used for scaling: ');
% length_dim = str2double(length_dim);
% while isempty(length_dim) || isnan(length_dim) || length_dim <= 0
% ed = errordlg('Distance must be postive numeric value!'); uiwait(ed)
% length_dim = inputdlg('Distance (in meters) used for scaling: ');
% length_dim = str2double(length_dim);
% end    
    
scaling_fig = []; scaling = []; data_openpose = [];
load(fullfile(videoInfo.vid_openpose_path,[videoInfo.vid_openpose_name '_openpose.mat']),'videoInfo','data_openpose')
% v = videoInfo.vid_openpose;
% v = VideoReader(fullfile(cd(1:end-(length(output_name(16:end))+10)),[output_name(1:14) '.mp4']));
NumFrames = data_openpose.noFiles;
% NumFrames = 21600;
scaling_fig = figure; set(scaling_fig,'WindowStyle','docked')
h_image_axes = subplot(5,4,[1:16]);
h_image = imshow(read(videoInfo.vid_openpose,1),'InitialMagnification','fit','Parent',h_image_axes); zoom on
h_image_axes.Title.String = [videoInfo.vid_openpose_name '; Frame 1']; h_image_axes.Title.Interpreter = 'none';

uicontrol(scaling_fig,'style','pushbutton','String','Calculate Scaling',...
   'units','normalized','Position',[0.1 0.025 0.2 0.05],'Callback',@calcScale); % pushbutton to calculate scaling

uicontrol(scaling_fig,'style','pushbutton','String','Zoom On',...
   'units','normalized','Position',[0.05 0.6 0.05 0.05],'Callback',@zooming); % pushbutton to zoom
uicontrol(scaling_fig,'style','pushbutton','String','Zoom On',...
   'units','normalized','Position',[.92 0.6 0.05 0.05],'Callback',@zooming); % pushbutton to zoom

uicontrol(scaling_fig,'style','pushbutton','String','Cursor On',...
   'units','normalized','Position',[0.05 0.5 0.05 0.05],'Callback',@cursorSet); % pushbutton to zoom
uicontrol(scaling_fig,'style','pushbutton','String','Cursor On',...
   'units','normalized','Position',[.92 0.5 0.05 0.05],'Callback',@cursorSet); % pushbutton to zoom

uicontrol(scaling_fig,'style','pushbutton','String','Save',...
   'units','normalized','Position',[0.8 0.025 0.2 0.05],'Callback',@saveData); % pushbutton to save file

length_dim = 'Distance_(m)';
setDistEdit = uicontrol(scaling_fig,'style','edit','string',length_dim,...
    'units','normalized','Position',[.45 .025 .2 .05]);

h_currentFrame_slider = uicontrol(scaling_fig,'style','slider','Min',1,'Max',NumFrames,'SliderStep',[1/NumFrames 10/NumFrames],'Value',1,...
   'units','normalized','Position',[0.45 0.1 0.2 0.05],'Callback',@currentFrame_slider); % choose frame
 h_currentFrame_edit = uicontrol(scaling_fig,'style','edit','string',num2str(1),'fontunits','normalized','fontsize',.4,...
   'units','normalized','Position',[0.45 0.15 0.2 0.05],'Callback',@currentFrame_edit); % choose frame
uiwait(scaling_fig)
clear
end
%% slider to change frame
function currentFrame_slider(source,event)
global h_image h_currentFrame_slider videoInfo h_currentFrame_edit h_image_axes
delete(h_image)  
h_image = imshow(read(videoInfo.vid_openpose,round(h_currentFrame_slider.Value)),'InitialMagnification','fit','Parent',h_image_axes); zoom on
h_image_axes.Title.String = [videoInfo.vid_openpose_name '; Frame ' num2str(round(h_currentFrame_slider.Value))]; h_image_axes.Title.Interpreter = 'none';
h_currentFrame_edit.String = num2str(round(h_currentFrame_slider.Value))
end
%% editor to change frame
function currentFrame_edit(source,event)
global h_image h_currentFrame_slider h_currentFrame_edit h_image_axes videoInfo
delete(h_image)  
h_image = imshow(read(videoInfo.vid_openpose,round(str2num(h_currentFrame_edit.String))),'InitialMagnification','fit','Parent',h_image_axes); zoom on
h_image_axes.Title.String = [videoInfo.vid_openpose_name '; Frame ' num2str(round(str2num(h_currentFrame_edit.String)))]; h_image_axes.Title.Interpreter = 'none';
h_currentFrame_slider.Value = round(str2num(h_currentFrame_edit.String));
% h_image = imshow(read(v,round(str2num(h_currentFrame_edit.String))));

end
%% "Calculate Scaling" pushbutton
function calcScale(source,event)
global scaling_fig scaling setDistEdit videoInfo
g = datacursormode(scaling_fig);
if str2double(setDistEdit.String) > 0
    length_dim = str2double(setDistEdit.String);
if ~isempty(getCursorInfo(g)) % check that user has used data cursor
cursor = getCursorInfo(g);
if length(cursor)== 2 % check that exactly 2 point are chosen
scaling.coordinates.First.X = cursor(1).Position(1); scaling.coordinates.First.Y = cursor(1).Position(2);
scaling.coordinates.Second.X = cursor(2).Position(1); scaling.coordinates.Second.Y = cursor(2).Position(2);
% length_pixels = abs([cursor(1).Position(1) - cursor(2).Position(1)]);
length_pixels = sqrt(sum(diff([cursor(1).Position; cursor(2).Position],1).^2));
scaling.factor = length_dim/length_pixels;
title([videoInfo.vid_openpose_name '; scaling = ' num2str(scaling.factor*1000,'%02.3f') ' mm/pixel'],'interpreter','none')
else
errordlg('You need to pick exactly 2 points!')  
end
else
errordlg('You need to use data cursor!')
end 
else
errordlg('Distance must be postive numeric value!')    
end
end
%% "Zoom" pushbutton
function zooming(source,event)
zoom on
end
%% "Cursor" pushbutton
function cursorSet(source,event)
datacursormode on
end
%% "Save" pushbutton
function saveData(source,event)
global scaling_fig scaling data_openpose videoInfo
data_openpose.scaling = scaling;
save(fullfile(videoInfo.vid_openpose_path,[videoInfo.vid_openpose_name '_openpose.mat']),'data_openpose','-append')
close(scaling_fig)
end