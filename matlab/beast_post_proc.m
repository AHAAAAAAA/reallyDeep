%%
clear,clc,close('all')
n_classes = 894;
n_class_f = 9;% number of classifier features
n_base_f = 2; % number of base features

c_points = 8;
er_r = 6; % Image erode filter radius
di_r = 5; % Image dialation filter radius
n_pix_thresh = 1000; % minimum number of pixels to accept for training
dist_thresh = inf; % maximum distance to accept for training
do_corners = true;

load('big_proc_rd.mat')
feat_str = {'bias','npix','dx','dy','x pos','y pos','1/dx','1/dy'};
feat_str{length(feat_str)+1} = 'num_corn';

%% Data Processing
class_vec = 1:n_classes;
% Training Error and Improvement
figure(1)
clf(1)
subplot(2,1,1)
hold all
plot(class_vec(isfinite(train_error)),train_baseline(isfinite(train_baseline)),'o-')
plot(class_vec(isfinite(train_error)),train_error(isfinite(train_error)),'x-')
hold off
grid('on')
legend('Baseline','Custom')
xlabel('Class Index')
ylabel('Norm of Error (m)')
title('Training Error')
subplot(2,1,2)
plot(class_vec(isfinite(train_error)),100*(train_baseline(isfinite(train_baseline))-train_error(isfinite(train_error)))./(train_baseline(isfinite(train_baseline))),'o-')
line([min(class_vec(isfinite(test_error))),max(class_vec(isfinite(test_error)))],[0,0],'Color',[1,0,0])
grid('on')
xlabel('Class Index')
ylabel('Percent Change')
title('Percent Improvement Over Baseline')
boldify
% Testing Error and Improvement
figure(2)
clf(2)
subplot(2,1,1)
hold all
plot(class_vec(isfinite(test_error)),test_baseline(isfinite(test_baseline)),'o-')
plot(class_vec(isfinite(test_error)),test_error(isfinite(test_error)),'x-')
hold off
grid('on')
legend('Baseline','Custom')
xlabel('Class Index')
ylabel('Norm of Error (m)')
title('Testing Error')
subplot(2,1,2)
plot(class_vec(isfinite(test_error)),100*(test_baseline(isfinite(test_baseline))-test_error(isfinite(test_error)))./(test_baseline(isfinite(test_baseline))),'o-')
line([min(class_vec(isfinite(test_error))),max(class_vec(isfinite(test_error)))],[0,0],'Color',[1,0,0])
ylim([-100,100])
grid('on')
xlabel('Class Index')
ylabel('Percent Change')
title('Percent Improvement Over Baseline')
boldify
% Histograms of Label Data
figure(3)
clf(3)
subplot(2,1,1)
hist(tot_trn_dist,100)
grid('on')
xlabel('Distance in m')
ylabel('Counts')
title('Training Data Histogram')
subplot(2,1,2)
hist(tot_tst_dist,30)
grid('on')
xlabel('Distance in m')
ylabel('Counts')
title('Testing Data Histogram')
boldify

% Beta Values for Baseline
val_ind = isfinite(test_error);
figure(4)
clf(4)
plot(class_vec(isfinite(test_error)),(beta_base_arr(:,val_ind)))
xlabel('Class Index')
ylabel('Beta Value')
title('Beta Values for Baseline')
grid('on')
boldify
% Beta Values for Custom Classifier
figure(5)
clf(5)
plot(class_vec(isfinite(test_error)),(beta_class_arr(:,val_ind)))
xlabel('Class Index')
ylabel('Beta Value')
title('Beta Values for Classifier')
grid('on')
boldify
%%
% Good and Bad Beta Values
figure(6)
clf(6)
subplot(2,2,1)
plot(class_vec(isfinite(train_error)),feat_best_vec(val_ind),'bx')
xlabel('Class Index')
ylabel('Feature Index')
title('Best Feature for each Class')
grid('on')
subplot(2,2,2)
hist(feat_best_vec(val_ind),1:n_class_f)
xlabel('Feature Index')
ylabel('Counts')
title('Best Feature Histogram')
subplot(2,2,3)
plot(class_vec(isfinite(train_error)),feat_worst_vec(val_ind),'bx')
xlabel('Class Index')
ylabel('Feature Index')
title('Worst Feature for each Class')
grid('on')
subplot(2,2,4)
hist(feat_worst_vec(val_ind),1:n_class_f)
xlabel('Feature Index')
ylabel('Counts')
title('Worst Feature Histogram')
boldify
feat_str
%
figure(7)
clf(7)
hist(tot_ft_stat_sig,1:n_class_f)
xlabel('Feature Index')
ylabel('Counts')
title('Statistically Significant Features Histogram')
grid('on')
boldify