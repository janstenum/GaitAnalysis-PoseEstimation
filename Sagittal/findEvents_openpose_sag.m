function findEvents_openpose_sag(videoInfo)
clearvars -except videoInfo
global cd name events_openpose time l r g check_events uiexit file path ...
    videoInfo data_openpose event_axes event_plot hCursor frame
% file = sprintf('%s%s',output_name,'_openpose.mat');
% path = output_path;
% name = output_name;
%%
frame = [];
events_openpose = [];
load(fullfile(videoInfo.vid_openpose_path,[videoInfo.vid_openpose_name '_openpose.mat']),'data_openpose')
time = data_openpose.time;

l = data_openpose.pose.filt_data(:,15,1)-data_openpose.pose.filt_data(:,9,1);
r = data_openpose.pose.filt_data(:,12,1)-data_openpose.pose.filt_data(:,9,1);
% l = data_openpose.filt_data.LAnkle(:,1)-data_openpose.filt_data.MidHip(:,1);
% r = data_openpose.filt_data.RAnkle(:,1)-data_openpose.filt_data.MidHip(:,1);

[pks_lhs,locs_lhs] = findpeaks(l); [pks_lto,locs_lto] = findpeaks(-l);
[pks_rhs,locs_rhs] = findpeaks(r); [pks_rto,locs_rto] = findpeaks(-r);

events_openpose.lhs_frames = reshape(locs_lhs,[],1); events_openpose.lto_frames = reshape(locs_lto,[],1);
events_openpose.rhs_frames = reshape(locs_rhs,[],1); events_openpose.rto_frames = reshape(locs_rto,[],1);
%%
check_events = figure; set(check_events,'WindowStyle','docked'); uiexit = false;
event_axes = subplot(3,3,[1 2 4 5 7 8]); hold on; brush on
event_plot.hL = plot(event_axes,time,l,'-b','DisplayName','Left');
event_plot.hR = plot(event_axes,time,r,'-c','DisplayName','Right');
event_plot.hLHS = plot(event_axes,time(events_openpose.lhs_frames),l(events_openpose.lhs_frames),'ok','DisplayName','LHS');
event_plot.hRHS = plot(event_axes,time(events_openpose.rhs_frames),r(events_openpose.rhs_frames),'or','DisplayName','RHS');
event_plot.hLTO = plot(event_axes,time(events_openpose.lto_frames),l(events_openpose.lto_frames),'sk','DisplayName','LTO');
event_plot.hRTO = plot(event_axes,time(events_openpose.rto_frames),r(events_openpose.rto_frames),'sr','DisplayName','RTO');
event_axes.XLabel.String = 'Time (s)';
event_axes.YLabel.String = 'Horizontal distance between ankle and pelvis (pixels)';
event_axes.Title.String = videoInfo.vid_openpose_name; event_axes.Title.Interpreter = 'none';
% legend('left','right','LHS','RHS','LTO','RTO','location','northeast');
legend(event_axes,'location','northeast','fontsize',6);
g = datacursormode(check_events);

uicontrol(check_events,'style','togglebutton','String','Show/hide left',...
    'units','normalized','Position',[.75 .55 0.1 0.05],'Callback',@tggl_left); % toggle left data
uicontrol(check_events,'style','togglebutton','String','Show/hide right',...
    'units','normalized','Position',[.85 .55 0.1 0.05],'Callback',@tggl_right); % toggle left data
uicontrol(check_events,'style','pushbutton','String','Delete Events',...
   'units','normalized','Position',[.75 .45 0.2 0.05],'Callback',@deleteHere); % pushbutton to delete events
uicontrol(check_events,'style','pushbutton','String','Create Heel-Strike',...
   'units','normalized','Position',[.75 .35 0.2 0.05],'Callback',@hsCreateHere); % pushbutton to create hs events
uicontrol(check_events,'style','pushbutton','String','Create Toe-Off',...
   'units','normalized','Position',[.75 .25 0.2 0.05],'Callback',@toCreateHere); % pushbutton to create to events

uicontrol(check_events,'style','togglebutton','String','Brush',...
   'units','normalized','Position',[.64 .55 0.08 0.05],'Callback',@tgglBrush); % pushbutton to create to events
uicontrol(check_events,'style','togglebutton','String','Cursor',...
   'units','normalized','Position',[.64 .5 0.08 0.05],'Callback',@tgglCursor); % pushbutton to create to events
uicontrol(check_events,'style','togglebutton','String','Zoom',...
   'units','normalized','Position',[.64 .45 0.08 0.05],'Callback',@tgglZoom); % pushbutton to create to events

uicontrol(check_events,'style','pushbutton','String','Summary',...
    'units','normalized','Position',[.75 .15 .2 .05],'Callback',@summ); % pushbutton to create a summary plot 

uicontrol(check_events,'style','pushbutton','String','Save',...
    'units','normalized','units','normalized','Position',[.75 .05 .2 .05],'Callback',@saveHere); % pushbutton to save events
% uicontrol(check_events,'style','pushbutton','String','Close',...
%     'units','normalized','units','normalized','Position',[.75 .1 .2 .05],'Callback',@closeHere); % pushbutton to close fig and go to next subject in "for" loop   
% uicontrol(check_events,'style','pushbutton','String','Exit',...
%     'units','normalized','units','normalized','Position',[.1 .02 .1 .05],'Callback',@exitHere); % pushbutton to exit events function

uiwait(check_events)
end
%% "Toggle Left" togglebutton
function tggl_left(source,events)
global event_plot
show_l = get(source,'value'); % toogle to either make opposite force trace visible or invisible
if show_l == 1
set([event_plot.hL event_plot.hLHS event_plot.hLTO],'visible','off'); 
else
set([event_plot.hL event_plot.hLHS event_plot.hLTO],'visible','on'); 
end
end
%% "Toggle Right" togglebutton
function tggl_right(source,events)
global event_plot
show_r = get(source,'value'); % toogle to either make opposite force trace visible or invisible
if show_r == 1
set([event_plot.hR event_plot.hRHS event_plot.hRTO],'visible','off'); 
else
set([event_plot.hR event_plot.hRHS event_plot.hRTO],'visible','on'); 
end
end
%% "Delete" pushbutton
function deleteHere(source,event)
global event_plot events_openpose time l r

if ~isempty(get(event_plot.hLHS,'BrushData')) || ~isempty(get(event_plot.hLTO,'BrushData')) || ~isempty(get(event_plot.hRHS,'BrushData')) || ~isempty(get(event_plot.hRTO,'BrushData')) % check that user has brushed data
lhsBrush = logical(get(event_plot.hLHS,'BrushData')); 
if true(logical(sum(lhsBrush))) % check if user has brushed lhs events
events_openpose.lhs_frames(lhsBrush) = []; % delete brushed lhs events
end
rhsBrush = logical(get(event_plot.hRHS,'BrushData')); 
if true(logical(sum(rhsBrush))) % check if user has brushed rhs events
events_openpose.rhs_frames(rhsBrush) = []; % delete brushed rhs events
end

ltoBrush = logical(get(event_plot.hLTO,'BrushData')); 
if true(logical(sum(ltoBrush))) % check if user has brushed lto events
events_openpose.lto_frames(ltoBrush) = []; % delete brushed lto events
end
rtoBrush = logical(get(event_plot.hRTO,'BrushData')); 
if true(logical(sum(rtoBrush))) % check if user has brushed rto events
events_openpose.rto_frames(rtoBrush) = []; % delete brushed rto events
end

rePlot_events
end
end
%% "Create Heel-Strike" pushbutton
function hsCreateHere(~,event)
global events_openpose time l r g event_plot

if ~isempty(getCursorInfo(g)) % check that user has used data cursor
s = getCursorInfo(g);
lhsNew = nan(length(s),1); rhsNew = nan(length(s),1);
for u = 1:length(s) % 'for loop' for every data cursor   
if isequaln(s(u).Target.YData,l')
lhsNew(u) = s(u).DataIndex;  
elseif isequaln(s(u).Target.YData,r')
rhsNew(u) = s(u).DataIndex;  
end
end
lhsNew(isnan(lhsNew)) = []; rhsNew(isnan(rhsNew)) = [];

for v = 1:length(lhsNew) % remove event from the existing vector with events so to ensure that events are not counted more than once
events_openpose.lhs_frames(events_openpose.lhs_frames == lhsNew(v)) = [];
end
for v = 1:length(rhsNew) % remove event from the existing vector with events so to ensure that events are not counted more than once
events_openpose.rhs_frames(events_openpose.rhs_frames == rhsNew(v)) = [];
end

events_openpose.lhs_frames = sort([events_openpose.lhs_frames; lhsNew]); % add new events to vector with events
events_openpose.rhs_frames = sort([events_openpose.rhs_frames; rhsNew]); % add new events to vector with events

rePlot_events
end
end
%% "Create Heel-Strike" pushbutton
function toCreateHere(~,event)
global events_openpose time l r g event_plot

if ~isempty(getCursorInfo(g)) % check that user has used data cursor
s = getCursorInfo(g);
ltoNew = nan(length(s),1); rtoNew = nan(length(s),1);
for u = 1:length(s) % 'for loop' for every data cursor   
if isequaln(s(u).Target.YData,l')
ltoNew(u) = s(u).DataIndex;  
elseif isequaln(s(u).Target.YData,r')
rtoNew(u) = s(u).DataIndex;  
end
end
ltoNew(isnan(ltoNew)) = []; rtoNew(isnan(rtoNew)) = [];

for v = 1:length(ltoNew) % remove event from the existing vector with events so to ensure that events are not counted more than once
events_openpose.lto_frames(events_openpose.lto_frames == ltoNew(v)) = [];
end
for v = 1:length(rtoNew) % remove event from the existing vector with events so to ensure that events are not counted more than once
events_openpose.rto_frames(events_openpose.rto_frames == rtoNew(v)) = [];
end

events_openpose.lto_frames = sort([events_openpose.lto_frames; ltoNew]); % add new events to vector with events
events_openpose.rto_frames = sort([events_openpose.rto_frames; rtoNew]); % add new events to vector with events

rePlot_events
end
end
%% "Brush" toggle
function tgglBrush(source,event)
brush on
end
%% "Cursor" toggle
function tgglCursor(source,event)
datacursormode on
end
%% "Zoom" toggle
function tgglZoom(source,event)
zoom on
end
%% "Save" pushbutton
function saveHere(source,event)
global events_openpose check_events videoInfo
save(fullfile(videoInfo.vid_openpose_path,[videoInfo.vid_openpose_name '_openpose.mat']),'events_openpose','-append')    
close(check_events)
end
%% "Close" pushbutton
function closeHere(source,event)
global check_events
close(check_events)
end
%% "Exit" pushbutton
function exitHere(source,event)
global check_events uiexit
uiresume(check_events)
uiexit = true;
end
%% "Summary Plot" pushbutton
function summ(source,events)
global events_openpose time l r videoInfo  kinLHSAlign kinLTOAlign summEvents summPlotLeft_hsAlign summPlotRight_hsAlign summPlotLeft_toAlign summPlotRight_toAlign
summFig = figure;set(summFig,'WindowStyle','docked');

noTraceLHS = length(events_openpose.lhs_frames)-1;
noTraceLTO = length(events_openpose.lto_frames)-1;

kinLHSAlign = nan(100,length(events_openpose.lhs_frames)-1); % matrix for re-sampled ankle markers kinematics aligned to hs
kinLTOAlign = nan(100,length(events_openpose.lto_frames)-1); % matrix for re-sampled ankle markers kinematics aligned to to

for t = 1:noTraceLHS
kinLHSAlign(:,t) = interp1(time(events_openpose.lhs_frames(t):events_openpose.lhs_frames(t+1)), l(events_openpose.lhs_frames(t):events_openpose.lhs_frames(t+1)), linspace(time(events_openpose.lhs_frames(t)),time(events_openpose.lhs_frames(t+1)),100),'pchip');   
end

for t = 1:noTraceLTO
kinLTOAlign(:,t) = interp1(time(events_openpose.lto_frames(t):events_openpose.lto_frames(t+1)), l(events_openpose.lto_frames(t):events_openpose.lto_frames(t+1)), linspace(time(events_openpose.lto_frames(t)),time(events_openpose.lto_frames(t+1)),100),'pchip');   
end

noTraceRHS = length(events_openpose.rhs_frames)-1;
noTraceRTO = length(events_openpose.rto_frames)-1;

kinRHSAlign = nan(100,length(events_openpose.rhs_frames)-1); % matrix for re-sampled ankle markers kinematics aligned to hs
kinRTOAlign = nan(100,length(events_openpose.rto_frames)-1); % matrix for re-sampled ankle markers kinematics aligned to to

for t = 1:noTraceRHS
kinRHSAlign(:,t) = interp1(time(events_openpose.rhs_frames(t):events_openpose.rhs_frames(t+1)), r(events_openpose.rhs_frames(t):events_openpose.rhs_frames(t+1)), linspace(time(events_openpose.rhs_frames(t)),time(events_openpose.rhs_frames(t+1)),100),'pchip');   
end

for t = 1:noTraceRTO
kinRTOAlign(:,t) = interp1(time(events_openpose.rto_frames(t):events_openpose.rto_frames(t+1)), r(events_openpose.rto_frames(t):events_openpose.rto_frames(t+1)), linspace(time(events_openpose.rto_frames(t)),time(events_openpose.rto_frames(t+1)),100),'pchip');   
end

uicontrol(summFig,'Style','popup','String',{'Align at HS','Align at TO'},'Position',[20 40 140 50],'callback',@summEventsHere)
subplot(2,1,1),hold on
summPlotLeft_hsAlign=plot(linspace(0,100,100),kinLHSAlign,'-b');
summPlotLeft_toAlign=plot(linspace(0,100,100),kinLTOAlign,'--b');set(summPlotLeft_toAlign,'visible','off'); 
xlabel('Gait cycle(%)'),ylabel('Horizontal distance between ankle and pelvis (pixels)')
title([videoInfo.vid_openpose_name ': Left'],'interpreter','none')
subplot(2,1,2),hold on
summPlotRight_hsAlign=plot(linspace(0,100,100),kinRHSAlign,'-c');set(summPlotRight_hsAlign,'visible','on'); 
summPlotRight_toAlign=plot(linspace(0,100,100),kinRTOAlign,'--c');set(summPlotRight_toAlign,'visible','off'); 
xlabel('Gait cycle (%)'),ylabel('Horizontal distance between ankle and pelvis (pixels)')
title([videoInfo.vid_openpose_name ': Right'],'interpreter','none')
set(summFig,'units','normalized','outerposition',[0 0 1 1]); zoom on; 
summEvents = 1;

end
%%
function summEventsHere(source,events)
global  summEvents summPlotLeft_hsAlign summPlotRight_hsAlign summPlotLeft_toAlign summPlotRight_toAlign
summEvents = get(source,'Value');
if summEvents == 1
subplot(2,1,1),set(summPlotLeft_hsAlign,'visible','on'); set(summPlotLeft_toAlign,'visible','off'); 
subplot(2,1,2),set(summPlotRight_hsAlign,'visible','on');  set(summPlotRight_toAlign,'visible','off'); 
else
subplot(2,1,1),set(summPlotLeft_toAlign,'visible','on'); set(summPlotLeft_hsAlign,'visible','off');
subplot(2,1,2),set(summPlotRight_toAlign,'visible','on'); set(summPlotRight_hsAlign,'visible','off');
end
end
%% "Re-plot" events
function rePlot_events(source,events)
global event_axes event_plot time l r events_openpose

delete(event_plot.hL);delete(event_plot.hR);delete(event_plot.hLHS);delete(event_plot.hLTO);delete(event_plot.hRHS);delete(event_plot.hRTO)% delete plot of events
event_plot.hL = plot(event_axes,time,l,'-b','DisplayName','Left');
event_plot.hR = plot(event_axes,time,r,'-c','DisplayName','Right');
event_plot.hLHS = plot(event_axes,time(events_openpose.lhs_frames),l(events_openpose.lhs_frames),'ok','DisplayName','LHS');
event_plot.hRHS = plot(event_axes,time(events_openpose.rhs_frames),r(events_openpose.rhs_frames),'or','DisplayName','RHS');
event_plot.hLTO = plot(event_axes,time(events_openpose.lto_frames),l(events_openpose.lto_frames),'sk','DisplayName','LTO');
event_plot.hRTO = plot(event_axes,time(events_openpose.rto_frames),r(events_openpose.rto_frames),'sr','DisplayName','RTO');

end