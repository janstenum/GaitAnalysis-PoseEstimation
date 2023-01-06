function OpenPoseGaitAnalysis_JS

[videoInfo] = process_openpose_trackPerson_addition_sag();

correctLegID_openpose_sag(videoInfo);

gapFill_filter_openpose_sag(videoInfo);

findEvents_openpose_sag(videoInfo);

extractScaling_openpose_sag(videoInfo);

calculate_gaitParameters_jointAngles_sag(videoInfo);