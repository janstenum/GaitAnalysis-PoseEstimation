function OpenPoseGaitAnalysis_front

[videoInfo] = process_openpose_trackPerson_addition_front();

correctLegID_openpose_front(videoInfo);

gapFill_openpose_front(videoInfo);

findEvents_openpose_front(videoInfo);

calc_depthChange_front(videoInfo);

calculate_gaitParameters_front(videoInfo);