%%
clear,clc,close('all')
% load ../data/dev_dataset.mat
load /home/aanderson/Documents/MATLAB/dev_dataset.mat
%%
tic

n_classes = length(names);
n_class_f = 9;% number of classifier features
n_base_f = 2; % number of base features
train_error = zeros(1, n_classes);
train_baseline = zeros(1, n_classes);
test_error = zeros(1, n_classes);
test_baseline = zeros(1, n_classes);
sigma_base_vec = zeros(1,n_classes);
sigma_class_vec = zeros(1,n_classes);
beta_class_arr = zeros(n_class_f,n_classes);
beta_base_arr = zeros(n_base_f,n_classes);
% var_class_arr
% var_base_arr


for class = 1:n_classes
  [img_trn, dep_trn, lbl_trn] = preprocess(images_trn, depths_trn, labels_trn, class);
  [img_tst, dep_tst, lbl_tst] = preprocess(images_tst, depths_tst, labels_tst, class);
  try
    [avg_depth_trn, y_trn_pred, y_trn_bsl_pred, avg_depth_tst, y_tst_pred, y_tst_bsl_pred, beta_class, beta_base, sigma_class, sigma_base, var_class, var_base] = deep_regress_cov(img_trn, dep_trn, lbl_trn, img_tst, dep_tst, lbl_tst);
    train_error(class) = norm(avg_depth_trn - y_trn_pred);
    train_baseline(class) = norm(avg_depth_trn - y_trn_bsl_pred);
    test_error(class) = norm(avg_depth_tst - y_tst_pred);
    test_baseline(class) = norm(avg_depth_tst - y_tst_bsl_pred);
    sigma_base_vec(class) = sigma_base;
    sigma_class_vec(class) = sigma_class;
    beta_class_arr(:,class) = beta_class;
    beta_base_arr(:,class) = beta_base;
    var_class_arr{class} = var_class;
    var_base_arr{class} = var_base;
  catch
    train_error(class) = NaN;
    train_baseline(class) = NaN;
    test_error(class) = NaN;
    test_baseline(class) = NaN;
    sigma_base_vec(class) = NaN;
    sigma_class_vec(class) = NaN;
    beta_class_arr(:,class) = NaN*ones(n_class_f,1);
    beta_base_arr(:,class) = NaN*ones(n_base_f,1);
    var_class_arr{class} = NaN;
    var_base_arr{class} = NaN;
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
% Sigma Out
figure(3)
clf(3)
hold all
plot(class_vec(isfinite(test_error)),sqrt(sigma_base_vec(isfinite(test_error))))
plot(class_vec(isfinite(test_error)),sqrt(sigma_class_vec(isfinite(test_error))))
hold off
grid('on')
legend('Baseline','Custom')
xlabel('Class Index')
ylabel('Prediction Std Dev (m)')
title('Std Dev Comparison')
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
