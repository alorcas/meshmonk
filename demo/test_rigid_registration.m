%% Demo rigid registration 

% Add MeshMonk's toolbox to the working path and setup current folder
addpath(genpath('path\to\meshmonk')) % Set to location of meshmonk

studypath = 'path\to\DemoFolder\';   % Set to location of demo material
cd(studypath);

%% Load face template (floating) and face (target)

floatingPath = [studypath '/Template.obj'];
[floatingPoints,floatingFaces] = read_vertices_and_faces_from_obj_file(floatingPath);
floatingFaces = uint32(floatingFaces-1); %-1 to make it compatible with C++ indexing
floatingPoints = single(floatingPoints);
floatingNormals = single(zeros(size(floatingPoints)));
% compute_normals(floatingPoints, floatingFaces, floatingNormals);
floatingFeatures = single([floatingPoints, floatingNormals]);
numFloatingElements = size(floatingFeatures,1);
floatingFlags = single(ones(numFloatingElements,1));
%DEBUG
floatingFlags(1:1000) = 0.0;
%END DEBUG
clear floatingPoints;

targetPath = [studypath '/demoFace.obj'];
[targetPoints,targetFaces] = read_vertices_and_faces_from_obj_file(targetPath);
targetPoints = single(targetPoints);
targetFaces = uint32(targetFaces-1);%-1 to make it compatible with C++ indexing
targetNormals = single(zeros(size(targetPoints)));
% compute_normals(targetPoints, targetFaces, targetNormals);
targetFeatures = single([targetPoints, targetNormals]); 
numTargetElements = size(targetFeatures,1);
targetFlags = single(ones(numTargetElements,1));
clear targetPoints;

%Set up resulting transformation matrix
transformationMatrix = single(eye(4,4));

%% Try the mexed pyramid_registration
%mex pyramid_registration.cpp -lmeshmonk

%# Set Parameters
numIterations = 80;
correspondencesSymmetric = true;
correspondencesNumNeighbours = 3;
correspondencesFlagThreshold = 0.9;
correspondencesEqualizePushPull = false;
inlierKappa = 12.0;
inlierUseOrientation = true;
useScaling = false;

rigid_registration(floatingFeatures, targetFeatures,...
                   floatingFaces, targetFaces,...
                   floatingFlags, targetFlags,...
                   transformationMatrix,...
                   numIterations,...
                   correspondencesSymmetric, correspondencesNumNeighbours,...
                   correspondencesFlagThreshold, correspondencesEqualizePushPull,...
                   inlierKappa, inlierUseOrientation,useScaling);
                            
%% Visualize
s = shape3D;
s.Vertices = floatingFeatures(:,1:3);
st = shape3D;
st.Vertices = targetFeatures(:,1:3);
v =viewer(s);    
viewer(st,v)
