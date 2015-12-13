%%
clear,clc,close('all')
% load ../data/dev_dataset.mat
load /home/aanderson/Documents/MATLAB/dev_dataset.mat
%%
tic

n_classes = length(names);
n_class_f = 9;% number of classifier features
n_base_f = 2; % number of base features

c_points = 8;
er_r = 6; % Image erode filter radius
di_r = 5; % Image dialation filter radius
n_pix_thresh = 1000; % minimum number of pixels to accept for training
dist_thresh = inf; % maximum distance to accept for training
do_corners = true;
use_pca = true;

train_error = zeros(1, n_classes);
train_baseline = zeros(1, n_classes);
test_error = zeros(1, n_classes);
test_baseline = zeros(1, n_classes);
sigma_base_vec = zeros(1,n_classes);
beta_class_arr = zeros(n_class_f,n_classes);
beta_base_arr = zeros(n_base_f,n_classes);
feat_worst_vec = zeros(1,n_classes);
sigma_base_vec = zeros(1,n_classes);

tot_trn_dist = [];
tot_tst_dist = [];
tot_ft_stat_sig = [];
% var_class_arr
% var_base_arr


for class = 1:n_classes
  [img_trn, dep_trn, lbl_trn] = preprocess_par(images_trn, depths_trn, labels_trn, class,er_r,di_r);
  [img_tst, dep_tst, lbl_tst] = preprocess_par(images_tst, depths_tst, labels_tst, class,er_r,di_r);
  if(size(lbl_trn,3) > n_class_f)
      try
        % Big Data Call
        [avg_depth_trn, y_trn_pred, y_trn_bsl_pred, avg_depth_tst, y_tst_pred,...
         y_tst_bsl_pred, beta_class, beta_base, beta_stat, sigma_base, var_base,...
         mdl_out,trn_sort,tst_sort,x_in,x_in_tst,feat_str]...
         = deep_regress_cov(...
         img_trn, dep_trn, lbl_trn, img_tst, dep_tst,...
         lbl_tst,n_pix_thresh,dist_thresh,c_points,do_corners, use_pca);

        train_error(class) = mean(abs(avg_depth_trn - y_trn_pred));
        train_baseline(class) = mean(abs(avg_depth_trn - y_trn_bsl_pred));
        test_error(class) = mean(abs(avg_depth_tst - y_tst_pred));
        test_baseline(class) = mean(abs(avg_depth_tst - y_tst_bsl_pred));

        sigma_base_vec(class) = sigma_base;
        beta_class_arr(:,class) = beta_class;
        beta_base_arr(:,class) = beta_base;
        var_base_arr{class} = var_base;
        [dum_val,f_best] = min(beta_stat);
        [dum_val,f_worst] = max(beta_stat);
        feat_best_vec(class) = f_best; 
        feat_worst_vec(class) = f_worst;
        feat_stat_sig{class} = find(beta_stat<0.1);
        tot_trn_dist = [tot_trn_dist; avg_depth_trn];
        tot_tst_dist = [tot_tst_dist; avg_depth_tst];
        tot_ft_stat_sig = [tot_ft_stat_sig; find(beta_stat<0.1)];

      catch
        train_error(class) = NaN;
        train_baseline(class) = NaN;
        test_error(class) = NaN;
        test_baseline(class) = NaN;
        sigma_base_vec(class) = NaN;
        beta_class_arr(:,class) = NaN*ones(n_class_f,1);
        beta_base_arr(:,class) = NaN*ones(n_base_f,1);
        var_base_arr{class} = NaN;
        feat_best_vec(class) = NaN; 
        feat_worst_vec(class) = NaN;
        feat_stat_sig{class} = NaN;
      end
  else
        train_error(class) = NaN;
        train_baseline(class) = NaN;
        test_error(class) = NaN;
        test_baseline(class) = NaN;
        sigma_base_vec(class) = NaN;
        beta_class_arr(:,class) = NaN*ones(n_class_f,1);
        beta_base_arr(:,class) = NaN*ones(n_base_f,1);
        var_base_arr{class} = NaN;
        feat_best_vec(class) = NaN; 
        feat_worst_vec(class) = NaN;
        feat_stat_sig{class} = NaN;
  end
end
toc

%% Data Processing
class_vec = 1:n_classes;
% Training Error and Improvement
figure(1)
clf(1)
subplot(2,1,1)
hold all
plot(class_vec(isfinite(train_error)),train_baseline(isfinite(train_baseline)))
plot(class_vec(isfinite(train_error)),train_error(isfinite(train_error)))
hold off
grid('on')
legend('Baseline','Custom')
xlabel('Class Index')
ylabel('Norm of Error (m)')
title('Training Error')
subplot(2,1,2)
plot(class_vec(isfinite(train_error)),100*(train_baseline(isfinite(train_baseline))-train_error(isfinite(train_error)))./(train_baseline(isfinite(train_baseline))))
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
plot(class_vec(isfinite(test_error)),test_baseline(isfinite(test_baseline)))
plot(class_vec(isfinite(test_error)),test_error(isfinite(test_error)))
hold off
grid('on')
legend('Baseline','Custom')
xlabel('Class Index')
ylabel('Norm of Error (m)')
title('Testing Error')
subplot(2,1,2)
plot(class_vec(isfinite(test_error)),100*(test_baseline(isfinite(test_baseline))-test_error(isfinite(test_error)))./(test_baseline(isfinite(test_baseline))))
line([min(class_vec(isfinite(test_error))),max(class_vec(isfinite(test_error)))],[0,0],'Color',[1,0,0])
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
xlabel('Distance in m')
ylabel('Counts')
title('Training Data Histogram')
subplot(2,1,2)
hist(tot_tst_dist,20)
xlabel('Distance in m')
ylabel('Counts')
title('Training Data Histogram')


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
