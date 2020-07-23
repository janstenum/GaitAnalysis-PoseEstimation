function correctLegID_openpose(output_name)
clearvars -except output_name
file = sprintf('%s%s',output_name,'_openpose.mat');
cd = pwd;
load(fullfile(cd,file),'data_openpose','videoInfo')
checkLegID(data_openpose,videoInfo,output_name)
end
%%
function [new_data] = checkLegID(d,v,n)
global frame corrected_data raw_data p name frames frameInfo check_fig vid data_openpose cursor_obj h1 h2 h3
check_fig = []; corrected_data = []; frame = []; frameInfo = []; frames = []; name = []; p = []; raw_data = []; vid = []; h1 = []; h2 = []; h3 = [];
frame = 1;
name = n;
raw_data = d.raw_data; % original data
frames = 1:length(d.time);
vid = v;
data_openpose = d;
corrected_data = d.raw_data;
frameInfo.frames_switch = false(1,length(frames)); frameInfo.frames_leftClear = false(1,length(frames)); frameInfo.frames_rightClear = false(1,length(frames));


check_fig = figure; set(check_fig,'WindowStyle','docked')

subplot(3,3,[1 2 4 5 7 8])
p = plot(squeeze(corrected_data(:,[12 15],1)),'.-'); zoom on; grid on
legend('right','left','location','northwest'); xlabel('frames'),ylabel('hor. position (pixel)');title(name)

set(gca,'xtick',frames)
  
uicontrol(check_fig,'style','pushbutton','String','Show Image',...
   'units','normalized','Position',[0.7 0.3 0.2 0.05],'Callback',@showImage); % pushbutton to show image

uicontrol(check_fig,'style','pushbutton','String','Switch left-right ID of legs',...
   'units','normalized','Position',[0.7 0.225 0.2 0.05],'Callback',@switchID); % pushbutton to switch
   
uicontrol(check_fig,'style','pushbutton','String','Clear left ID',...
   'units','normalized','Position',[0.7 0.15 0.1 0.05],'Callback',@clearLeft); % pushbutton to clear left leg ID

uicontrol(check_fig,'style','pushbutton','String','Restore left ID',...
   'units','normalized','Position',[0.7 0.1 0.1 0.05],'Callback',@restoreLeft); % pushbutton to restore left leg ID
   
uicontrol(check_fig,'style','pushbutton','String','Clear right ID',...
   'units','normalized','Position',[0.85 0.15 0.1 0.05],'Callback',@clearRight); % pushbutton to clear right leg ID

uicontrol(check_fig,'style','pushbutton','String','Restore right ID',...
   'units','normalized','Position',[0.85 0.1 0.1 0.05],'Callback',@restoreRight); % pushbutton to restore right leg ID

uicontrol(check_fig,'style','pushbutton','String','Restore entire data-series',...
   'units','normalized','Position',[0.7 0.025 0.2 0.05],'Callback',@restoreData); % pushbutton to restore entire data-series

uicontrol(check_fig,'style','pushbutton','String','Save',...
   'units','normalized','Position',[0.1 0.025 0.2 0.05],'Callback',@saveData); % pushbutton to save file

uicontrol(check_fig,'style','pushbutton','String','Zoom',...
   'units','normalized','Position',[0.65 0.55 0.1 0.05],'Callback',@zoomON); % pushbutton to zoom ON

uicontrol(check_fig,'style','pushbutton','String','Data tip',...
   'units','normalized','Position',[0.65 0.45 0.1 0.05],'Callback',@dataCursorON); % pushbutton to data cursor ON

datacursormode on;
cursor_obj = datacursormode(check_fig);

uiwait(check_fig)
end
%% "Show Image" pushbutton
function showImage(source,event)
global frame vid cursor_obj h1 h2 h3
delete([h1 h2 h3]);
subplot(3,3,3),hold on
if ~isempty(getCursorInfo(cursor_obj))
frame = getCursorInfo(cursor_obj);
frame = frame.Position(1);
h1=imshow(read(vid.vid_openpose,frame));
h3 = title(['Frame ' num2str(frame) ],'fontsize',7);
else
h2=text(0,.5,'You must select a frame to show image');
set(gca,'Visible','off')
end
end
%% "Switch" pushbutton
function switchID(source,event)
global frame corrected_data p name frames frameInfo cursor_obj
if ~isempty(getCursorInfo(cursor_obj))
frame = getCursorInfo(cursor_obj);
frame = frame.Position(1);
temp = corrected_data(frame,[10:12 23:25],:);
corrected_data(frame,[10:12 23:25],:) = corrected_data(frame,[13:15 20:22],:);
corrected_data(frame,[13:15 20:22],:) = temp;
subplot(3,3,[1 2 4 5 7 8]); delete(p)
p=plot(squeeze(corrected_data(:,[12 15],1)),'.-'); grid on; 
legend('right','left','location','northwest'); xlabel('frames'),ylabel('hor. position (pixel)');title(name)
set(gca,'xtick',frames)
frameInfo.frames_switch(frame) = ~frameInfo.frames_switch(frame);
else
errordlg('You must select a frame!')
end
end
%% "Clear left" pushbutton
function clearLeft(source,event)
global frame corrected_data p name frames frameInfo cursor_obj
if ~isempty(getCursorInfo(cursor_obj))
frame = getCursorInfo(cursor_obj);
frame = frame.Position(1);
corrected_data(frame,[13:15 20:22],:) = nan;
subplot(3,3,[1 2 4 5 7 8]),delete(p)
p=plot(squeeze(corrected_data(:,[12 15],1)),'.-'); grid on
legend('right','left','location','northwest'); xlabel('frames'),ylabel('hor. position (pixel)');title(name)
set(gca,'xtick',frames)
frameInfo.frames_leftClear(frame) = true;
else
errordlg('You must select a frame!')
end
end
%% "Restore left" pushbutton
function restoreLeft(source,event)
global frame corrected_data raw_data p name frames frameInfo cursor_obj
if ~isempty(getCursorInfo(cursor_obj))
frame = getCursorInfo(cursor_obj);
frame = frame.Position(1);
corrected_data(frame,[13:15 20:22],:) = raw_data(frame,[13:15 20:22],:);
subplot(3,3,[1 2 4 5 7 8]),delete(p)
p=plot(squeeze(corrected_data(:,[12 15],1)),'.-'); grid on
legend('right','left','location','northwest'); xlabel('frames'),ylabel('hor. position (pixel)');title(name)
set(gca,'xtick',frames)
frameInfo.frames_leftClear(frame) = false;
else
errordlg('You must select a frame!')
end
end
%% "Clear right" pushbutton
function clearRight(source,event)
global frame corrected_data p name frames frameInfo cursor_obj
if ~isempty(getCursorInfo(cursor_obj))
frame = getCursorInfo(cursor_obj);
frame = frame.Position(1);
corrected_data(frame,[10:12 23:25],:) = nan;
subplot(3,3,[1 2 4 5 7 8]),delete(p)
p=plot(squeeze(corrected_data(:,[12 15],1)),'.-'); grid on
legend('right','left','location','northwest'); xlabel('frames'),ylabel('hor. position (pixel)');title(name)
set(gca,'xtick',frames)
frameInfo.frames_rightClear(frame) = true;
else
errordlg('You must select a frame!')
end
end
%% "Restore right" pushbutton
function restoreRight(source,event)
global frame corrected_data raw_data p name frames frameInfo cursor_obj
if ~isempty(getCursorInfo(cursor_obj))
frame = getCursorInfo(cursor_obj);
frame = frame.Position(1);
corrected_data(frame,[10:12 23:25],:) = raw_data(frame,[10:12 23:25],:);
subplot(3,3,[1 2 4 5 7 8]),delete(p)
p=plot(squeeze(corrected_data(:,[12 15],1)),'.-'); grid on
legend('right','left','location','northwest'); xlabel('frames'),ylabel('hor. position (pixel)');title(name)
set(gca,'xtick',frames)
frameInfo.frames_rightClear(frame) = false;
else
errordlg('You must select a frame!')
end
end
%% "Restore entire data-series" pushbutton
function restoreData(source,event)
global corrected_data raw_data p name frames frameInfo
corrected_data(:,[10:15 20:25],:) = raw_data(:,[10:15 20:25],:);
subplot(3,3,[1 2 4 5 7 8]),delete(p)
p=plot(squeeze(corrected_data(:,[12 15],1)),'.-'); grid on
legend('right','left','location','northwest'); xlabel('frames'),ylabel('hor. position (pixel)');title(name)
set(gca,'xtick',frames)
frameInfo.frames_switch = false(1,length(frames)); frameInfo.frames_leftClear = false(1,length(frames)); frameInfo.frames_rightClear = false(1,length(frames));
end
%% "Save" pushbutton
function saveData(source,event)
global corrected_data name check_fig data_openpose frameInfo
cd = pwd; 
data_openpose.corrected_data = corrected_data;
save(fullfile(cd,[name '_openpose.mat']),'data_openpose','frameInfo','-append')
close(check_fig)
end
%% "Zoom" pushbutton
function zoomON(source,event)
zoom on
end
%% "Data tip" pushbutton
function dataCursorON(source,event) 
datacursormode on
end