 % bring in the broad-scale alignment data for the livox
 refDataIn      = readtable('Y:\livox\georeferencing\GCPs_20220128_raw_OSGB.xlsx',...
    'Sheet', 'Livox Georeferencing - BNG');
refDataIn           = table2array(refDataIn(:,2:end));
[tform]             = estimateGeometricTransform3D(refDataIn(:,4:6),refDataIn(:,1:3),'rigid'); % transform one to two
[x,y,z]             = transformPointsForward(tform,ans1(:,1),ans1(:,2),ans1(:,3));
scan01_trans        = [x,y,z];
