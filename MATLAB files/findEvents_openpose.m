function findEvents_openpose(output_name)
clearvars -except output_name
global cd name hL hLHS hLTO hR hRHS hRTO events_openpose time l r g check_events uiexit file
file = sprintf('%s%s',output_name,'_openpose.mat');
cd = pwd;
name = output_name;
%%
events_openpose = [];
load(fullfile(cd,file),'data_openpose')
time = data_openpose.time;

l = data_openpose.filt_data(:,15,1)-data_openpose.filt_data(:,9,1);
r = data_openpose.filt_data(:,12,1)-data_openpose.filt_data(:,9,1);

[pks_lhs,locs_lhs] = findpeaks(l); [pks_lto,locs_lto] = findpeaks(-l);
[pks_rhs,locs_rhs] = findpeaks(r); [pks_rto,locs_rto] = findpeaks(-r);

events_openpose.lhs_frames = locs_lhs'; events_openpose.lto_frames = locs_lto';
events_openpose.rhs_frames = locs_rhs'; events_openpose.rto_frames = locs_rto';
%%
check_events = figure; set(check_events,'WindowStyle','docked'); uiexit = false;
subplot(1,3,[1 2]); hold on; brush on
hL = plot(time,l,'-k');
hR = plot(time,r,'-b');
hLHS = plot(time(events_openpose.lhs_frames),l(events_openpose.lhs_frames),'og');
hRHS = plot(time(events_openpose.rhs_frames),r(events_openpose.rhs_frames),'or');
hLTO = plot(time(events_openpose.lto_frames),l(events_openpose.lto_frames),'sg');
hRTO = plot(time(events_openpose.rto_frames),r(events_openpose.rto_frames),'sr');
xlabel('time (s)'),ylabel('horizontal distance between ankle and pelvis (pixels)')
title(name),legend('left','right','LHS','RHS','LTO','RTO','location','northeast');
g = datacursormode(check_events);

uicontrol(gcf,'style','togglebutton','String','Show/hide left',...
    'units','normalized','Position',[.75 .9 0.1 0.05],'Callback',@tggl_left); % toggle left data
uicontrol(gcf,'style','togglebutton','String','Show/hide right',...
    'units','normalized','Position',[.85 .9 0.1 0.05],'Callback',@tggl_right); % toggle left data
uicontrol(gcf,'style','pushbutton','String','Delete Events',...
   'units','normalized','Position',[.75 .8 0.2 0.05],'Callback',@deleteHere); % pushbutton to delete events
uicontrol(gcf,'style','pushbutton','String','Create Heel-Strike',...
   'units','normalized','Position',[.75 .65 0.2 0.05],'Callback',@hsCreateHere); % pushbutton to create hs events
uicontrol(gcf,'style','pushbutton','String','Create Toe-Off',...
   'units','normalized','Position',[.75 .55 0.2 0.05],'Callback',@toCreateHere); % pushbutton to create to events

uicontrol(gcf,'style','togglebutton','String','Brush',...
   'units','normalized','Position',[.64 .55 0.08 0.05],'Callback',@tgglBrush); % pushbutton to create to events
uicontrol(gcf,'style','togglebutton','String','Cursor',...
   'units','normalized','Position',[.64 .5 0.08 0.05],'Callback',@tgglCursor); % pushbutton to create to events
uicontrol(gcf,'style','togglebutton','String','Zoom',...
   'units','normalized','Position',[.64 .45 0.08 0.05],'Callback',@tgglZoom); % pushbutton to create to events

uicontrol(gcf,'style','pushbutton','String','Summary',...
    'units','normalized','Position',[.75 .4 .2 .05],'Callback',@summ); % pushbutton to create a summary plot 

uicontrol(gcf,'style','pushbutton','String','Save',...
    'units','normalized','units','normalized','Position',[.75 .2 .2 .05],'Callback',@saveHere); % pushbutton to save events
uicontrol(gcf,'style','pushbutton','String','Close',...
    'units','normalized','units','normalized','Position',[.75 .1 .2 .05],'Callback',@closeHere); % pushbutton to close fig and go to next subject in "for" loop   
uicontrol(gcf,'style','pushbutton','String','Exit',...
    'units','normalized','units','normalized','Position',[.1 .02 .1 .05],'Callback',@exitHere); % pushbutton to exit events function

uiwait(check_events)
end
%% "Toggle Left" togglebutton
function tggl_left(source,events)
global hL hLHS hLTO
show_l = get(source,'value'); % toogle to either make opposite force trace visible or invisible
if show_l == 1
set([hL hLHS hLTO],'visible','off'); 
else
set([hL hLHS hLTO],'visible','on'); 
end
end
%% "Toggle Right" togglebutton
function tggl_right(source,events)
global hR hRHS hRTO
show_r = get(source,'value'); % toogle to either make opposite force trace visible or invisible
if show_r == 1
set([hR hRHS hRTO],'visible','off'); 
else
set([hR hRHS hRTO],'visible','on'); 
end
end
%% "Delete" pushbutton
function deleteHere(source,event)
global hL hLHS hLTO hR hRHS hRTO events_openpose time l r

if ~isempty(get(hLHS,'BrushData')) || ~isempty(get(hLTO,'BrushData')) || ~isempty(get(hRHS,'BrushData')) || ~isempty(get(hRTO,'BrushData')) % check that user has brushed data
lhsBrush = logical(get(hLHS,'BrushData')); 
if true(logical(sum(lhsBrush))) % check if user has brushed lhs events
events_openpose.lhs_frames(lhsBrush) = []; % delete brushed lhs events
end
rhsBrush = logical(get(hRHS,'BrushData')); 
if true(logical(sum(rhsBrush))) % check if user has brushed rhs events
events_openpose.rhs_frames(rhsBrush) = []; % delete brushed rhs events
end

ltoBrush = logical(get(hLTO,'BrushData')); 
if true(logical(sum(ltoBrush))) % check if user has brushed lto events
events_openpose.lto_frames(ltoBrush) = []; % delete brushed lto events
end
rtoBrush = logical(get(hRTO,'BrushData')); 
if true(logical(sum(rtoBrush))) % check if user has brushed rto events
events_openpose.rto_frames(rtoBrush) = []; % delete brushed rto events
end

delete(hL);delete(hR);delete(hLHS);delete(hLTO);delete(hRHS);delete(hRTO)% delete plot of events
hL = plot(time,l,'-k');
hR = plot(time,r,'-b');
hLHS = plot(time(events_openpose.lhs_frames),l(events_openpose.lhs_frames),'og');
hRHS = plot(time(events_openpose.rhs_frames),r(events_openpose.rhs_frames),'or');
hLTO = plot(time(events_openpose.lto_frames),l(events_openpose.lto_frames),'sg');
hRTO = plot(time(events_openpose.rto_frames),r(events_openpose.rto_frames),'sr');
legend('left','right','LHS','RHS','LTO','RTO','location','northeast');
end
end
%% "Create Heel-Strike" pushbutton
function hsCreateHere(~,event)
global hL hLHS hLTO hR hRHS hRTO events_openpose time l r g

if ~isempty(getCursorInfo(g)) % check that user has used data cursor
s = getCursorInfo(g);
lhsNew = nan(length(s),1); rhsNew = nan(length(s),1);
for u = 1:length(s) % 'for loop' for every data cursor   
if s(u).Target.YData == l'
lhsNew(u) = s(u).DataIndex;  
elseif s(u).Target.YData == r'
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

events_openpose.lhs_frames = sort([events_openpose.lhs_frames lhsNew]); % add new events to vector with events
events_openpose.rhs_frames = sort([events_openpose.rhs_frames rhsNew]); % add new events to vector with events

delete(hL);delete(hR);delete(hLHS);delete(hLTO);delete(hRHS);delete(hRTO)% delete plot of events
hL = plot(time,l,'-k');
hR = plot(time,r,'-b');
hLHS = plot(time(events_openpose.lhs_frames),l(events_openpose.lhs_frames),'og');
hRHS = plot(time(events_openpose.rhs_frames),r(events_openpose.rhs_frames),'or');
hLTO = plot(time(events_openpose.lto_frames),l(events_openpose.lto_frames),'sg');
hRTO = plot(time(events_openpose.rto_frames),r(events_openpose.rto_frames),'sr');
legend('left','right','LHS','RHS','LTO','RTO','location','northeast');
end
end
%% "Create Heel-Strike" pushbutton
function toCreateHere(~,event)
global hL hLHS hLTO hR hRHS hRTO events_openpose time l r g

if ~isempty(getCursorInfo(g)) % check that user has used data cursor
s = getCursorInfo(g);
ltoNew = nan(length(s),1); rtoNew = nan(length(s),1);
for u = 1:length(s) % 'for loop' for every data cursor   
if s(u).Target.YData == l'
ltoNew(u) = s(u).DataIndex;  
elseif s(u).Target.YData == r'
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

events_openpose.lto_frames = sort([events_openpose.lto_frames ltoNew]); % add new events to vector with events
events_openpose.rto_frames = sort([events_openpose.rto_frames rtoNew]); % add new events to vector with events

delete(hL);delete(hR);delete(hLHS);delete(hLTO);delete(hRHS);delete(hRTO)% delete plot of events
hL = plot(time,l,'-k');
hR = plot(time,r,'-b');
hLHS = plot(time(events_openpose.lhs_frames),l(events_openpose.lhs_frames),'og');
hRHS = plot(time(events_openpose.rhs_frames),r(events_openpose.rhs_frames),'or');
hLTO = plot(time(events_openpose.lto_frames),l(events_openpose.lto_frames),'sg');
hRTO = plot(time(events_openpose.rto_frames),r(events_openpose.rto_frames),'sr');
legend('left','right','LHS','RHS','LTO','RTO','location','northeast');
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
global cd file events_openpose
save(fullfile(cd,file),'events_openpose','-append')    
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
global events_openpose time l r name  kinLHSAlign kinLTOAlign summEvents summPlotLeft_hsAlign summPlotRight_hsAlign summPlotLeft_toAlign summPlotRight_toAlign
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

uicontrol(gcf,'Style','popup','String',{'align at HS','align at TO'},'Position',[20 40 140 50],'callback',@summEventsHere)
subplot(2,1,1),hold on
summPlotLeft_hsAlign=plot(linspace(0,100,100),kinLHSAlign,'-k');
summPlotLeft_toAlign=plot(linspace(0,100,100),kinLTOAlign,'--k');set(summPlotLeft_toAlign,'visible','off'); 
xlabel('stride (%)'),ylabel('horizontal distance between ankle and pelvis (pixels)')
title([name ': left'])
subplot(2,1,2),hold on
summPlotRight_hsAlign=plot(linspace(0,100,100),kinRHSAlign,'-r');set(summPlotRight_hsAlign,'visible','on'); 
summPlotRight_toAlign=plot(linspace(0,100,100),kinRTOAlign,'--r');set(summPlotRight_toAlign,'visible','off'); 
xlabel('stride (%)'),ylabel('horizontal distance between ankle and pelvis (pixels)')
title([name ': right'])
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