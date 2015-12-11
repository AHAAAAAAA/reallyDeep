% train regression for given object class and evaluate on test datasets
% provided; the labels contain just 0/1 to only indicate the object of interest

function [avg_depth_trn, y_trn_pred, y_trn_bsl_pred, avg_depth_tst, y_tst_pred, y_tst_bsl_pred, beta_class, beta_base, sigma_class, sigma_base, var_class, var_base] = deep_regress_cov(images_trn, depths_trn, labels_trn, images_tst, depths_tst, labels_tst)

% parameters--TODO: convert (some? all?) these to function parameters with default values
er_r = 10; % Image erode filter radius
di_r = 8; % Image dialation filter radius
n_pix_thresh = 1000; % minimum number of pixels to accept for training
dist_thresh = 3.5; % maximum distance to accept for training
c_points = 5; % number of corners to detect
do_corners = true;

im_x_mid = 640/2;
im_y_mid = 480/2;

% Feature Training Extraction
npix_trn = [];   npix_tst = [];
dx_trn = [];     dx_tst = [];
dy_trn = [];     dy_tst = [];
dx_inv_trn = []; dx_inv_tst = [];
dy_inv_trn = []; dy_inv_tst = [];
x_trn = [];      x_tst = [];
y_trn = [];      y_tst = [];
cn_trn = [];     cn_tst = [];
cx_trn = [];     cx_tst = [];
cy_trn = [];     cy_tst = [];

% Label Training Extraction
avg_depth_trn = []; avg_depth_tst = [];

% build training feature vectors
loop_count_trn = 0;
for ii=1:size(images_trn, 4)
  image_gray = rgb2gray(images_trn(:,:,:,ii));

  [obj_inds,obj_x_inds,obj_y_inds,n_pix,obj_dx,obj_dy,obj_pres] = extract_obj(labels_trn(:,:,ii),1);
  avg_depth = extract_object_depth(depths_trn(:,:,ii),labels_trn(:,:,ii),1);

  if((avg_depth<dist_thresh) && (n_pix>n_pix_thresh))
    loop_count_trn = loop_count_trn+1;
    obj_x_mid = mean(obj_x_inds);
    obj_y_mid = mean(obj_y_inds);
    % Append!
    npix_trn = [npix_trn; n_pix];
    dx_trn = [dx_trn; obj_dx];
    dy_trn = [dy_trn; obj_dy];
    dx_inv_trn = [dx_inv_trn; 1/obj_dx];
    dy_inv_trn = [dy_inv_trn; 1/obj_dy];
    x_trn = [x_trn; obj_x_mid];
    y_trn = [y_trn; obj_y_mid];
    avg_depth_trn = [avg_depth_trn; avg_depth];

    if do_corners
      matrix_gray = zeros(480,640);
      matrix_gray(obj_inds) = image_gray(obj_inds);
      x_shift = round(obj_x_mid-im_x_mid);
      y_shift = round(obj_y_mid-im_y_mid);
      mat_shift = circshift(matrix_gray,[-y_shift,-x_shift]);
      % find corners
      C = corner(mat_shift);
      Cn = size(C,1);
      if Cn < c_points
        C = [C; zeros(c_points - Cn, 2)];
      else
        C = C(1:c_points,:);
      end

      % Append!
      cn_trn = [cn_trn; Cn];
      cx_trn = [cx_trn; (C(:,1)).'];
      cy_trn = [cy_trn; (C(:,2)).'];
    end
  end
end

% build testing feature vectors
loop_count_tst = 0;
for ii=1:size(images_tst, 4)
  image_gray = rgb2gray(images_tst(:,:,:,ii));

  [obj_inds,obj_x_inds,obj_y_inds,n_pix,obj_dx,obj_dy,obj_pres] = extract_obj(labels_tst(:,:,ii),1);
  avg_depth = extract_object_depth(depths_tst(:,:,ii),labels_tst(:,:,ii),1);

  if((avg_depth<dist_thresh) && (n_pix>n_pix_thresh))
    loop_count_tst = loop_count_tst+1;
    obj_x_mid = mean(obj_x_inds);
    obj_y_mid = mean(obj_y_inds);
    % Append!
    npix_tst = [npix_tst; n_pix];
    dx_tst = [dx_tst; obj_dx];
    dy_tst = [dy_tst; obj_dy];
    dx_inv_tst = [dx_inv_tst; 1/obj_dx];
    dy_inv_tst = [dy_inv_tst; 1/obj_dy];
    x_tst = [x_tst; obj_x_mid];
    y_tst = [y_tst; obj_y_mid];
    avg_depth_tst = [avg_depth_tst; avg_depth];

    if do_corners
      matrix_gray = zeros(480,640);
      matrix_gray(obj_inds) = image_gray(obj_inds);
      x_shift = round(obj_x_mid-im_x_mid);
      y_shift = round(obj_y_mid-im_y_mid);
      mat_shift = circshift(matrix_gray,[-y_shift,-x_shift]);
      % find corners
      C = corner(mat_shift);
      Cn = size(C,1);
      if Cn < c_points
        C = [C; zeros(c_points - Cn, 2)];
      else
        C = C(1:c_points,:);
      end

      % Append!
      cn_tst = [cn_tst; Cn];
      cx_tst = [cx_tst; (C(:,1)).'];
      cy_tst = [cy_tst; (C(:,2)).'];
    end
  end
end

x_baseline_trn = [dx_inv_trn, dy_inv_trn];
x_baseline_tst = [dx_inv_tst, dy_inv_tst];
x_in = [npix_trn, dx_trn, dy_trn, x_trn, y_trn, dx_inv_trn, dy_inv_trn, ones(size(npix_trn))]; % final is bias term
x_in_tst = [npix_tst, dx_tst, dy_tst, x_tst, y_tst, dx_inv_tst, dy_inv_tst, ones(size(npix_tst))]; % final is bias term
if do_corners
    x_in = [npix_trn, dx_trn, dy_trn, x_trn, y_trn, dx_inv_trn, dy_inv_trn, cn_trn, ones(size(npix_trn))]; % final is bias term
    x_in_tst = [npix_tst, dx_tst, dy_tst, x_tst, y_tst, dx_inv_tst, dy_inv_tst, cn_tst, ones(size(npix_tst))]; % final is bias term
end

[beta, sigma, resid, var_class] = mvregress(x_in, avg_depth_trn);
[beta_baseline, sigma_baseline, resid,var_base] = mvregress([dx_inv_trn, dy_inv_trn], avg_depth_trn);
y_trn_pred = x_in * beta;
y_trn_bsl_pred = x_baseline_trn * beta_baseline;

y_tst_pred = x_in_tst * beta;
y_tst_bsl_pred = x_baseline_tst * beta_baseline;
beta_class = beta;
beta_base = beta_baseline;
sigma_class = sigma;
sigma_base = sigma_baseline;
end
