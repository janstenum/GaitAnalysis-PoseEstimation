function OpenPoseGaitAnalysis_JS

output_name = process_openpose();

correctLegID_openpose(output_name);

gapFill_filter_openpose(output_name);

findEvents_openpose(output_name);

extractScaling_openpose(output_name);

calculate_gaitParameters_jointAngles(output_name);