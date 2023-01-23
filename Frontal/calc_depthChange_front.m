function calc_depthChange_front(videoInfo)
clearvars -except videoInfo
global frame initialFrame_fig h_image_axes h_image h_currentFrame NumFrames data_openpose setDistEdit setDistEdit noFiles

load(fullfile(videoInfo.vid_openpose_path,[videoInfo.vid_openpose_name '_openpose.mat']))

if isfield(frameInfo,'trackPerson_manual_input')
frame = frameInfo.trackPerson_manual_input.saved_startTrackFrame;
NumFrames = frameInfo.trackPerson_manual_input.saved_startTrackFrame:frameInfo.trackPerson_manual_input.saved_endTrackFrame;
noFiles = length(NumFrames);
else
frame = 1;
NumFrames = 1:data_openpose.noFiles;
noFiles = data_openpose.noFiles
end

initialFrame_fig = figure; set(initialFrame_fig,'WindowStyle','docked')
h_image_axes = subplot(5,4,[1:16]);
h_image = imshow(read(videoInfo.vid_openpose,frame),'InitialMagnification','fit','Parent',h_image_axes); zoom on
h_image_axes.Title.String = [videoInfo.vid_openpose_name '; Frame ' num2str(frame)]; h_image_axes.Title.Interpreter = 'none';



uicontrol(initialFrame_fig,'style','pushbutton','String','Calculate Depth-Change and Save',...
   'units','normalized','Position',[0.1 0.025 0.3 0.05],'Callback',@calcDepthChange_save); % pushbutton to calculate scaling

h_currentFrame.slider = uicontrol(initialFrame_fig,'style','slider','Min',frame,'Max',NumFrames(end),'SliderStep',[1/noFiles 10/noFiles],'Value',frame,...
   'units','normalized','Position',[0.45 0.1 0.2 0.05],'Callback',@currentFrame_slider); % choose frame
 h_currentFrame.edit = uicontrol(initialFrame_fig,'style','edit','string',num2str(frame),'fontunits','normalized','fontsize',.4,...
   'units','normalized','Position',[0.45 0.15 0.2 0.05],'Callback',@currentFrame_edit); % choose frame

setDistEdit = uicontrol(initialFrame_fig,'style','edit','string','Reference depth (m)',...
    'units','normalized','Position',[.45 .025 .2 .05]);


uiwait(initialFrame_fig)
end
%% calc depth-change time-series and save
function calcDepthChange_save(source,event)
global data_openpose setDistEdit videoInfo frame initialFrame_fig

if str2double(setDistEdit.String) > 0

data_openpose.reference_depth = str2double(setDistEdit.String);
ANyq = videoInfo.vid_openpose.FrameRate/2;
Wn = 0.4/ANyq/.802;
[B,A] = butter(2,Wn,'low');
size_timeSeries = nanfiltfilt(B,A, sqrt( abs(diff(data_openpose.pose.corrected_data(:,[3 6],1),1,2)) .* abs(diff(data_openpose.pose.corrected_data(:,[2 9],2),1,2)) ) );
size_ratio_timeSeries = size_timeSeries / size_timeSeries(frame); % size ratio time-series
if strcmp(data_openpose.direction,'Away')
data_openpose.depth_change = ( data_openpose.reference_depth ./ size_ratio_timeSeries ) - data_openpose.reference_depth;
elseif strcmp(data_openpose.direction,'Toward')
data_openpose.depth_change = -( ( data_openpose.reference_depth ./ size_ratio_timeSeries ) - data_openpose.reference_depth );    
end

save(fullfile(videoInfo.vid_openpose_path,[videoInfo.vid_openpose_name '_openpose.mat']),'data_openpose','-append');
close(initialFrame_fig)
else
errordlg('Distance must be postive numeric value!')    
end

end
%% slider to change frame
function currentFrame_slider(source,event)
global h_image h_currentFrame videoInfo h_image_axes frame
frame = round(h_currentFrame.slider.Value);
h_currentFrame.edit.String = num2str(frame);
updateImage
end
%% editor to change frame
function currentFrame_edit(source,event)
global h_image h_currentFrame h_image_axes videoInfo frame NumFrames
frame_input = h_currentFrame.edit.String;
if any(NumFrames(1):NumFrames(end) == str2double(frame_input))
frame = str2num(frame_input);
h_currentFrame.slider.Value = round(str2num(h_currentFrame.edit.String));
updateImage
else
errordlg(['You must input a valid frame number: ' num2str(NumFrames(1)) ' to ' num2str(NumFrames(end))],'Non-frame number entered') 
end
end
%% update image
function updateImage(source,event)
global h_image videoInfo h_image_axes frame
delete(h_image) 
h_image_axes = subplot(5,4,[1:16]);
h_image = imshow(read(videoInfo.vid_openpose,frame),'InitialMagnification','fit','Parent',h_image_axes); zoom on
h_image_axes.Title.String = [videoInfo.vid_openpose_name '; Frame ' num2str(frame)]; h_image_axes.Title.Interpreter = 'none';
end
%% nanfiltfilt function
function Y = nanfiltfilt(B, A, X)
%  Y = NANFILTFILT(B, A, X) filters data X with NaNs by segmenting data
%  into pieces without NaNs.
[m n] = size(X);
if ~any(isnan(X(:)))
    Y = filtfilt(B,A,X);
    return
end
if ndims(X)<=2
    Y = nan(m,n);
    for i = 1:n
        x = X(:,i);
        if all(~isnan(x))
            Y(:,i) = filtfilt(B,A,x);
        else
            y = ~isnan(x);
            dy = diff(y);
            t1 = find(dy==1)+1;
            t2 = find(dy==-1);
            if ~isempty(t1) && ~isempty(t2)
                if t1(1)>t2(1)
                    t1 = [1; t1];
                end
                if (length(t1)>length(t2))
                    t2 = [t2; length(y)];
                end
                for j = 1:length(t1)
                    seg = x(t1(j):t2(j));
                    if length(seg) > 3*length(B)
                        Y(t1(j):t2(j),i) = filtfilt(B,A,seg);
                    else
                        Y(t1(j):t2(j),i) = seg;
                    end
                end
            elseif isempty(t1)
                seg = x(1:t2);
                Y(1:t2) = filtfilt(B,A,seg);
            elseif isempty(t2)
                seg = x(t1:end);
                Y(t1:end) = filtfilt(B,A,seg);
            end
        end
    end
end
end