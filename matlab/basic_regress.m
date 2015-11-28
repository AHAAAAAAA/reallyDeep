%%
%clear
clc
close('all')

load('../data/dev_dataset.mat')
addpath(genpath('./SparseFiltering/'))
try
  do_sparse_filtering;
  sf_features = 20;
catch
  do_sparse_filtering=false;
end

class_type = 'chair';
c_points = 8;
tic

% Find the index
class_ind = namesToIds(class_type);

% get indices of images in training and test sets
trn_inds = find_rel_pics(labels_trn,class_ind);
length(trn_inds)
tst_inds = find_rel_pics(labels_tst,class_ind);
length(tst_inds)

% trn_inds = trn_inds(1:125);
% tst_inds = tst_inds(1:50);
c_points = 10;
im_x_mid = 640/2;
im_y_mid = 480/2;
%
% Feature Training Extraction
npix_trn = [];
dx_trn = [];
dy_trn = [];
x_trn = [];
y_trn = [];
cn_trn = [];
cx_trn = [];
cy_trn = [];

% Label Training Extraction
avg_depth_trn = [];

if do_sparse_filtering
    img_lin_trn = double(reshape(images_trn, 3*640*480, []));
    img_lin_tst = double(reshape(images_tst, 3*640*480, []));
    lbl_lin_trn = double(reshape(labels_trn, 640*480, []));
    lbl_lin_tst = double(reshape(labels_tst, 640*480, []));

    sf_mtx = sparseFiltering(sf_features, [img_lin_trn; lbl_lin_trn==class_ind]);
end

for ii=1:length(trn_inds)
    ii/length(trn_inds)*100
    jj = trn_inds(ii);
    % find image bounding box and centroid
    [obj_inds,obj_x_inds,obj_y_inds,n_pix,obj_dx,obj_dy,obj_pres] = extract_obj(labels_trn(:,:,jj),class_ind);
    avg_depth = extract_object_depth(depths_trn(:,:,jj),labels_trn(:,:,jj),class_ind);
    obj_x_mid = mean(obj_x_inds);
    obj_y_mid = mean(obj_y_inds);

    % mask out image in grayscale
    image_gray = rgb2gray(images_trn(:,:,:,jj));
%     matrix_z = image_gray .* (labels_trn(:,:,jj)==class_ind);
    matrix_z = zeros(480,640);
    matrix_z(obj_inds) = 1;
    %
    % center object
    x_shift = round(obj_x_mid-im_x_mid);
    y_shift = round(obj_y_mid-im_y_mid);
    mat_shift = circshift(matrix_z,[-y_shift,-x_shift]);

    % find corners
    C = corner(mat_shift,c_points);
    Cn = corner(mat_shift);
    Cn = size(Cn,1);

    % C check
    c_diff = c_points-size(C,1);
    C_fix = [C; zeros(c_diff,2)];

    % Append!
    npix_trn = [npix_trn; n_pix];
    dx_trn = [dx_trn; obj_dx];
    dy_trn = [dy_trn; obj_dy];
    x_trn = [x_trn; obj_x_mid];
    y_trn = [y_trn; obj_y_mid];
    cn_trn = [cn_trn; Cn];
    cx_trn = [cx_trn; (C_fix(:,1)).'];
    cy_trn = [cy_trn; (C_fix(:,2)).'];
    avg_depth_trn = [avg_depth_trn; avg_depth];
end
clc
toc

% collect all inputs together; TODO: should we add a bias term?
% x_in = [npix_trn, dx_trn, dy_trn, x_trn, y_trn, cn_trn, cx_trn, cy_trn];
x_in = [npix_trn, dx_trn, dy_trn, x_trn, y_trn, tan(dx_trn/2), tan(dy_trn/2)];
% x_in = [npix_trn, dx_trn, dy_trn, cn_trn, cx_trn, cy_trn];
% x_in = [npix_trn, dx_trn, dy_trn, x_trn, y_trn];%, cn_trn, cx_trn, cy_trn];
y_lab = avg_depth_trn;

% run the regression
[beta,sigma] = mvregress(x_in,y_lab);
y_pred = x_in*beta;
[y_lab_sort,i_sort] = sort(y_lab);
y_pred_sort = y_pred(i_sort);

% plot results
figure(1)
clf(1)

subplot(2,1,1)
hold all
plot(y_lab_sort)
plot(y_pred_sort,'.')
legend('Label','Prediction')
xlabel('Observation Index')
ylabel('Distance in m')
title_val = ['Training Label vs. Predicted: ',class_type];
title(title_val)
grid('on')

subplot(2,1,2)
hold all
err_trn = abs(y_pred-y_lab); 
plot(err_trn(i_sort))
xlabel('Observation Index')
ylabel('Error in m')
title_val = ['Training Error: ',class_type];
title(title_val)
grid('on')
boldify

% Testing Stage
% Feature Testing Extraction
npix_tst = [];
dx_tst = [];
dy_tst = [];
x_tst = [];
y_tst = [];
cn_tst = [];
cx_tst = [];
cy_tst = [];
% Label Testing Extraction
avg_depth_tst = [];

for ii=1:length(tst_inds)
    ii/length(tst_inds)*100
    jj = tst_inds(ii);
    [obj_inds,obj_x_inds,obj_y_inds,n_pix,obj_dx,obj_dy,obj_pres] = extract_obj(labels_tst(:,:,jj),class_ind);
    avg_depth = extract_object_depth(depths_tst(:,:,jj),labels_tst(:,:,jj),class_ind);
    obj_x_mid = mean(obj_x_inds);
    obj_y_mid = mean(obj_y_inds);
    % Append!

    % mask out image in grayscale
    image_gray = rgb2gray(images_tst(:,:,:,jj));
%     matrix_z = image_gray .* (labels_tst(:,:,jj)==class_ind);
    matrix_z = zeros(480,640);
    matrix_z(obj_inds) = 1;    

    % center object
    x_shift = round(obj_x_mid-im_x_mid);
    y_shift = round(obj_y_mid-im_y_mid);
    mat_shift = circshift(matrix_z,[-y_shift,-x_shift]);

    % find corners
    C = corner(mat_shift,c_points);
    Cn = corner(mat_shift);
    Cn = size(Cn,1);

    % C check
    c_diff = c_points-size(C,1);
    C_fix = [C; zeros(c_diff,2)];

    % Append!
    npix_tst = [npix_tst, n_pix];
    dx_tst = [dx_tst, obj_dx];
    dy_tst = [dy_tst, obj_dy];
    x_tst = [x_tst, obj_x_mid];
    y_tst = [y_tst, obj_y_mid];
    cn_tst = [cn_tst; Cn];
    cx_tst = [cx_tst; (C_fix(:,1)).'];
    cy_tst = [cy_tst; (C_fix(:,2)).'];
    avg_depth_tst = [avg_depth_tst, avg_depth];
end
clc
toc

npix_tst = npix_tst.';
dx_tst = dx_tst.';
dy_tst = dy_tst.';
x_tst = x_tst.';
y_tst = y_tst.';
avg_depth_tst = avg_depth_tst.';
% x_tst = [npix_tst, dx_tst, dy_tst, x_tst, y_tst, cn_tst, cx_tst, cy_tst];
x_tst = [npix_tst, dx_tst, dy_tst, x_tst, y_tst, tan(dx_tst/2), tan(dy_tst/2)];
y_tst = avg_depth_tst;

% do prediction
y_pred_tst = x_tst*beta;
[y_tst_sort,i_sort] = sort(y_tst);
y_pred_tst_sort = y_pred_tst(i_sort);

% plot results
figure(2)
clf(2)

subplot(2,1,1)
hold all
plot(y_tst_sort)
plot(y_pred_tst_sort,'.')
legend('Label','Prediction')
xlabel('Observation Index')
ylabel('Distance in m')
title_val = ['Testing Label vs. Predicted: ',class_type];
title(title_val)
grid('on')

subplot(2,1,2)
err_tst = abs(y_pred_tst-y_tst); 
plot(err_tst(i_sort))
xlabel('Observation Index')
ylabel('Error in m')
title_val = ['Testing Error: ',class_type];
title(title_val)
grid('on')
boldify

mean(err_trn)
mean(err_tst)
