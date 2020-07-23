function extractScaling_openpose(output_name)
clearvars -except output_name
global check_fig scaling cd data_openpose file length_dim
file = sprintf('%s%s',output_name,'_openpose.mat');
cd = pwd;
%%

length_dim = inputdlg('Distance (in meters) used for scaling: ');
length_dim = str2double(length_dim);
while isempty(length_dim) || isnan(length_dim) || length_dim <= 0
ed = errordlg('Distance must be postive numeric value!'); uiwait(ed)
length_dim = inputdlg('Distance (in meters) used for scaling: ');
length_dim = str2double(length_dim);
end    
    
check_fig = []; scaling = []; data_openpose = [];
load(fullfile(cd,file),'videoInfo','data_openpose')
v = videoInfo.vid_openpose;
check_fig = figure; set(check_fig,'WindowStyle','docked')
subplot(5,4,[1:16])
imshow(read(v,1)), zoom on
title([output_name '; distance = ' num2str(length_dim,'%02.2f') ' m'])

uicontrol(check_fig,'style','pushbutton','String','Calculate Scaling',...
   'units','normalized','Position',[0.1 0.025 0.2 0.05],'Callback',@calcScale); % pushbutton to calculate scaling

uicontrol(check_fig,'style','pushbutton','String','Zoom On',...
   'units','normalized','Position',[0.05 0.6 0.05 0.05],'Callback',@zooming); % pushbutton to zoom
uicontrol(check_fig,'style','pushbutton','String','Zoom On',...
   'units','normalized','Position',[.92 0.6 0.05 0.05],'Callback',@zooming); % pushbutton to zoom

uicontrol(check_fig,'style','pushbutton','String','Cursor On',...
   'units','normalized','Position',[0.05 0.5 0.05 0.05],'Callback',@cursorSet); % pushbutton to zoom
uicontrol(check_fig,'style','pushbutton','String','Cursor On',...
   'units','normalized','Position',[.92 0.5 0.05 0.05],'Callback',@cursorSet); % pushbutton to zoom

uicontrol(check_fig,'style','pushbutton','String','Save',...
   'units','normalized','Position',[0.8 0.025 0.2 0.05],'Callback',@saveData); % pushbutton to save file

uiwait(check_fig)
clear
end
%% "Calculate Scaling" pushbutton
function calcScale(source,event)
global check_fig scaling length_dim file
g = datacursormode(check_fig);
if ~isempty(getCursorInfo(g)) % check that user has used data cursor
cursor = getCursorInfo(g);
if length(cursor)== 2 % check that exactly 2 point are chosen
scaling.coordinates = [cursor(1).Position; cursor(2).Position];
length_pixels = abs([cursor(1).Position(1) - cursor(2).Position(1)]);
scaling.factor = length_dim/length_pixels;
title([file(1:end-13) '; distance = ' num2str(length_dim,'%02.2f') ' m; scaling = ' num2str(scaling.factor*1000,'%02.3f') ' mm/pixel'])
else
errordlg('You need to pick exactly 2 points!')  
end
else
errordlg('You need to use data cursor!')
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
global check_fig scaling cd data_openpose file
data_openpose.scaling = scaling;
save(fullfile(cd,file),'data_openpose','-append')
close(check_fig)
end