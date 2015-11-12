% Run setup
setup

%%% variables in .mat file
% accelData
% depths
% images
% instances
% labels
% names
% namesTolds
% rawDepthFilenames
% rawDepths
% rawRgbFilenames
% scenes
% sceneTypes

%%% variables from setup
% N
% test_size
% testing
% training

rng(42, 'twister');

% take a tenth of each of the testing and training sets
dev_N = floor(N/10);
dev_tst  = randsample(testing, floor(test_size/10));
dev_trn = randsample(training, floor((N-test_size)/10));

accelData_tst = accelData(dev_tst);
depths_tst = depths(:,:,dev_tst);
images_tst = images(:,:,:,dev_tst);
instances_tst = instances(:,:,dev_tst);
labels_tst = labels(:,:,dev_tst);
rawDepthFilenames_tst = rawDepthFilenames(dev_tst);
rawDepths_tst = rawDepths(:,:,dev_tst);
rawRgbFilenames_tst = rawRgbFilenames(dev_tst);
scenes_tst = scenes(dev_tst);
sceneTypes_tst = sceneTypes(dev_tst);

accelData_trn = accelData(dev_trn);
depths_trn = depths(:,:,dev_trn);
images_trn = images(:,:,:,dev_trn);
instances_trn = instances(:,:,dev_trn);
labels_trn = labels(:,:,dev_trn);
rawDepthFilenames_trn = rawDepthFilenames(dev_trn);
rawDepths_trn = rawDepths(:,:,dev_trn);
rawRgbFilenames_trn = rawRgbFilenames(dev_trn);
scenes_trn = scenes(dev_trn);
sceneTypes_trn = sceneTypes(dev_trn);

save('dev_dataset.mat', 'accelData_tst', 'depths_tst', 'images_tst', 'instances_tst', 'labels_tst', 'rawDepthFilenames_tst', 'rawDepths_tst', 'rawRgbFilenames_tst', 'scenes_tst', 'sceneTypes_tst', 'accelData_trn', 'depths_trn', 'images_trn', 'instances_trn', 'labels_trn', 'rawDepthFilenames_trn', 'rawDepths_trn', 'rawRgbFilenames_trn', 'scenes_trn', 'sceneTypes_trn', 'names', 'namesToIds', 'dev_tst', 'dev_trn', '-v7');
