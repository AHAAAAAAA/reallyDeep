% Load data
%load('../data/nyu_depth_data_labeled.mat');
load('../data/nyu_depth_v2_labeled.mat');

% Training/testing split
rng(42, 'twister');

N = size(images, 4);
test_size = floor(N/10);

testing = randsample(N, test_size);
training = setdiff(1:N, testing);
