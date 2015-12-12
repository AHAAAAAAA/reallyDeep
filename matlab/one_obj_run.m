%%
clear,clc,close('all')
% load ../data/dev_dataset.mat
load /home/aanderson/Documents/MATLAB/dev_dataset.mat
%%
clc
class_type = 'column';
c_points = 8;
er_r = 6; % Image erode filter radius
di_r = 5; % Image dialation filter radius
n_pix_thresh = 1000; % minimum number of pixels to accept for training
dist_thresh = 5; % maximum distance to accept for training
do_corners = true;
tic

% Find the index
class = namesToIds(class_type);

% Pre-proc
tic
[img_trn, dep_trn, lbl_trn] = preprocess_par(images_trn, depths_trn, labels_trn, class,er_r,di_r);
[img_tst, dep_tst, lbl_tst] = preprocess_par(images_tst, depths_tst, labels_tst, class,er_r,di_r);
% Big Data Call
[avg_depth_trn, y_trn_pred, y_trn_bsl_pred, avg_depth_tst, y_tst_pred,...
 y_tst_bsl_pred, beta_class, beta_base, beta_stat, sigma_base, var_base,...
 mdl_out,trn_sort,tst_sort,x_in,x_in_tst,feat_str]...
 = deep_regress_cov(...
 img_trn, dep_trn, lbl_trn, img_tst, dep_tst,...
 lbl_tst,n_pix_thresh,dist_thresh,c_points,do_corners);
% 
clc
toc
train_error = (avg_depth_trn - y_trn_pred);
train_baseline = (avg_depth_trn - y_trn_bsl_pred);
test_error = (avg_depth_tst - y_tst_pred);
test_baseline = (avg_depth_tst - y_tst_bsl_pred);
trn_len = length(avg_depth_trn)
tst_len = length(avg_depth_tst)
trn_er = mean(abs(train_error))
trn_bas = mean(abs(train_baseline))
tst_er = mean(abs(test_error))
tst_base = mean(abs(test_baseline))

%% Training Results
figure(1)
clf(1)
subplot(2,1,1)
hold all
plot(avg_depth_trn)
errorbar(y_trn_bsl_pred,std(y_trn_bsl_pred)*ones(size(y_trn_bsl_pred)),'.')
errorbar(y_trn_pred,std(y_trn_pred)*ones(size(y_trn_pred)),'.')
legend('Truth','Baseline','Classifier')
xlabel('Observation Index')
ylabel('Distance in m')
title_val = ['Training Label vs. Predictions: ',class_type];
title(title_val)
grid('on')
hold off
boldify
subplot(2,1,2)
hold all
plot(abs(train_baseline))
plot(abs(train_error))
xlabel('Observation Index')
ylabel('Absolute Value of Error in m')
legend('Baseline','Classifier');
title_val = ['Training Error: ',class_type];
title(title_val)
grid('on')
hold off
boldify

%% Testing Results
figure(2)
clf(2)
subplot(2,1,1)
hold all
plot(avg_depth_tst)
errorbar(y_tst_bsl_pred,std(y_tst_bsl_pred)*ones(size(y_tst_bsl_pred)),'.')
errorbar(y_tst_pred,std(y_tst_pred)*ones(size(y_tst_pred)),'.')
legend('Truth','Baseline','Classifier')
xlabel('Observation Index')
ylabel('Distance in m')
title_val = ['Training Label vs. Predictions: ',class_type];
title(title_val)
grid('on')
hold off
boldify
subplot(2,1,2)
hold all
plot(abs(test_baseline))
plot(abs(test_error))
xlabel('Observation Index')
ylabel('Absolute Value of Error in m')
legend('Baseline','Classifier');
title_val = ['Training Error: ',class_type];
title(title_val)
grid('on')
hold off
boldify

%% Feature Analysis
[dum_val,f_best] = min(beta_stat);
[dum_val,f_worst] = max(beta_stat);
% f_best = 6;
figure(3)
clf(3)
subplot(2,3,1)
plot(avg_depth_trn)
xlabel('Observation Index')
ylabel('Distance in m')
title_val = ['Training Distance: ',class_type];
title(title_val)
grid('on')
subplot(2,3,2)
plot(x_in(trn_sort,f_best),'.')
xlabel('Observation Index')
ylabel('Feature Value')
title_val = ['Best Feature index: ',feat_str{f_best}];
title(title_val)
grid('on')
subplot(2,3,3)
plot(x_in(trn_sort,f_worst),'.')
xlabel('Observation Index')
ylabel('Feature Value')
title_val = ['Worst Feature index: ',feat_str{f_worst}];
title(title_val)
grid('on')
subplot(2,3,4)
plot(avg_depth_tst)
xlabel('Observation Index')
ylabel('Distance in m')
title_val = ['Testing Distance: ',class_type];
title(title_val)
grid('on')
subplot(2,3,5)
plot(x_in_tst(tst_sort,f_best),'.')
xlabel('Observation Index')
ylabel('Feature Value')
title_val = ['Best Feature index: ',feat_str{f_best}];
title(title_val)
grid('on')
subplot(2,3,6)
plot(x_in_tst(tst_sort,f_worst),'.')
xlabel('Observation Index')
ylabel('Feature Value')
title_val = ['Worst Feature index: ',feat_str{f_worst}];
title(title_val)
grid('on')
clc
mdl_out
feat_stat_sig = find(beta_stat<0.1);
feat_str{feat_stat_sig}