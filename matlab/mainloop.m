load ../data/dev_dataset.mat

n_classes = length(names);
train_error = zeros(1, n_classes);
train_baseline = zeros(1, n_classes);
test_error = zeros(1, n_classes);
test_baseline = zeros(1, n_classes);

for class = 1:n_classes
  [img_trn, dep_trn, lbl_trn] = preprocess(images_trn, depths_trn, labels_trn, class);
  [img_tst, dep_tst, lbl_tst] = preprocess(images_tst, depths_tst, labels_tst, class);
  try
    [avg_depth_trn, y_trn_pred, y_trn_bsl_pred, avg_depth_tst, y_tst_pred, y_tst_bsl_pred] = deep_regress(img_trn, dep_trn, lbl_trn, img_tst, dep_tst, lbl_tst);
    train_error(class) = norm(avg_depth_trn - y_trn_pred);
    train_baseline(class) = norm(avg_depth_trn - y_trn_bsl_pred);
    test_error(class) = norm(avg_depth_tst - y_tst_pred);
    test_baseline(class) = norm(avg_depth_tst - y_tst_bsl_pred);
  catch
    train_error(class) = NaN;
    train_baseline(class) = NaN;
    test_error(class) = NaN;
    test_baseline(class) = NaN;
  end
end
