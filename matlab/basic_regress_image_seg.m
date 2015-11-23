%%
clear,clc,close('all')
load('../data/dev_dataset.mat')
%%
clc
class_type = 'chair';
c_points = 8;
er_r = 10; % Image erode filter radius
di_r = 8; % Image dialation filter radius
n_pix_thresh = 1000; % minimum number of pixels to accept for training
dist_thresh = 3.5; % maximum distance to accept for training
tic

% Find the index
class_ind = namesToIds(class_type);

% get indices of images in training and test sets
trn_inds = find_rel_pics(labels_trn,class_ind);
tst_inds = find_rel_pics(labels_tst,class_ind);
length(trn_inds)
length(tst_inds)
if(isempty(trn_inds)||isempty(tst_inds))
    break
end
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

loop_count_trn = 0;
for ii=1:length(trn_inds)
    ii/length(trn_inds)*100
    jj = trn_inds(ii);
    matrix_z = zeros(480,640);
    matrix_z(labels_trn(:,:,jj)==class_ind) = 1; 
    image_gray = rgb2gray(images_trn(:,:,:,jj));
    % Build Errode/Dialate Objects
    se_er = strel('disk',er_r);
    se_di = strel('disk',di_r);
    % Errode image to get rid of small/skinny pixels
    mat_z_er = imerode(matrix_z,se_er);
    % Dilate image to build image backup
    mat_z_di = imdilate(mat_z_er,se_di);
    CC = 0;
    % Run connected component analysis
    CC = bwconncomp(mat_z_di);
    matrix_ziso = zeros(480,640);
    % Uncomment this to Disable Obj Separation
%     CC.NumObjects = 1;
    for kk = 1:CC.NumObjects
        % Comment this to Disable Obj Separation
        ind_kk = CC.PixelIdxList{kk};
        % Uncomment this to Disable Obj Separation
%         ind_kk = (labels_trn(:,:,jj)==class_ind);
        % Use kk as ind to only access 1 array in memory
        matrix_ziso(ind_kk) = kk;
        % So now just run our functions on the matrix_ziso and look for kk
        [obj_inds,obj_x_inds,obj_y_inds,n_pix,obj_dx,obj_dy,obj_pres] = extract_obj(matrix_ziso,kk);
        avg_depth = extract_object_depth(depths_trn(:,:,jj),matrix_ziso,kk);
        if((avg_depth<dist_thresh) && (n_pix>n_pix_thresh))
            % Currently Unused Grayscale Image for Feature Extraction
            matrix_gray = zeros(480,640);
            matrix_gray(obj_inds) = image_gray(obj_inds);
            loop_count_trn = loop_count_trn+1;
            obj_x_mid = mean(obj_x_inds);
            obj_y_mid = mean(obj_y_inds);
            % Append!
            npix_trn = [npix_trn; n_pix];
            dx_trn = [dx_trn; obj_dx];
            dy_trn = [dy_trn; obj_dy];
            x_trn = [x_trn; obj_x_mid];
            y_trn = [y_trn; obj_y_mid];
            avg_depth_trn = [avg_depth_trn; avg_depth];
        end
%             % center object
%             x_shift = round(obj_x_mid-im_x_mid);
%             y_shift = round(obj_y_mid-im_y_mid);
%             mat_shift = circshift(matrix_z,[-y_shift,-x_shift]);
% 
%             % find corners
%             C = corner(mat_shift,c_points);
%             Cn = corner(mat_shift);
%             Cn = size(Cn,1);
% 
%             % C check
%             c_diff = c_points-size(C,1);
%             C_fix = [C; zeros(c_diff,2)];
%             % Append!
%             cn_trn = [cn_trn; Cn];
%             cx_trn = [cx_trn; (C_fix(:,1)).'];
%             cy_trn = [cy_trn; (C_fix(:,2)).']; 
    end
end
clc
toc

% collect all inputs together; 
% Different inputs
% x_in = [npix_trn, dx_trn, dy_trn, x_trn, y_trn, cn_trn, cx_trn, cy_trn];
x_in = [npix_trn, dx_trn, dy_trn, x_trn, y_trn, tan(dx_trn/2), tan(dy_trn/2), ones(size(npix_trn))]; % final is bias term
% x_in = [npix_trn, dx_trn, dy_trn, tan(dx_trn/2), tan(dy_trn/2)];
% x_in = [npix_trn, tan(dx_trn/2), tan(dy_trn/2)];
% x_in = [npix_trn, dx_trn, dy_trn];

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
loop_count_tst = 0;
for ii=1:length(tst_inds)
    ii/length(tst_inds)*100
    jj = tst_inds(ii);
    matrix_z = zeros(480,640);
    matrix_z(labels_tst(:,:,jj)==class_ind) = 1; 
    image_gray = rgb2gray(images_tst(:,:,:,jj));
    % Make Errode and Dialation Objects
    se_er = strel('disk',er_r);
    se_di = strel('disk',di_r);
    % Errode to eliminate small/skinny segments
    mat_z_er = imerode(matrix_z,se_er);
    % Dilate to build remaining objects back up
    mat_z_di = imdilate(mat_z_er,se_di);
    CC = 0;
    % Run connected component analysis
    CC = bwconncomp(mat_z_di);
    matrix_ziso = zeros(480,640);
    % Uncomment this to Disable Obj Separation
%     CC.NumObjects = 1;
    for kk = 1:CC.NumObjects
        loop_count_tst = loop_count_tst+1;
        % Comment this to Disable Obj Separation
        ind_kk = CC.PixelIdxList{kk};
        % Uncomment this to Disable Obj Separation
%         ind_kk = (labels_tst(:,:,jj)==class_ind);
        matrix_ziso(ind_kk) = kk;
        [obj_inds,obj_x_inds,obj_y_inds,n_pix,obj_dx,obj_dy,obj_pres] = extract_obj(matrix_ziso,kk);
        avg_depth = extract_object_depth(depths_tst(:,:,jj),matrix_ziso,kk);
        obj_x_mid = mean(obj_x_inds);
        obj_y_mid = mean(obj_y_inds);
        % Currently Unused Grayscale Image for Feature Extraction
        matrix_gray = zeros(480,640);
        matrix_gray(obj_inds) = image_gray(obj_inds);
        % Append!
        npix_tst = [npix_tst; n_pix];
        dx_tst = [dx_tst; obj_dx];
        dy_tst = [dy_tst; obj_dy];
        x_tst = [x_tst; obj_x_mid];
        y_tst = [y_tst; obj_y_mid];
        avg_depth_tst = [avg_depth_tst; avg_depth];
%             % center object
%             x_shift = round(obj_x_mid-im_x_mid);
%             y_shift = round(obj_y_mid-im_y_mid);
%             mat_shift = circshift(matrix_z,[-y_shift,-x_shift]);
% 
%             % find corners
%             C = corner(mat_shift,c_points);
%             Cn = corner(mat_shift);
%             Cn = size(Cn,1);
% 
%             % C check
%             c_diff = c_points-size(C,1);
%             C_fix = [C; zeros(c_diff,2)];
%             % Append!
%             cn_tst = [cn_tst; Cn];
%             cx_tst = [cx_tst; (C_fix(:,1)).'];
%             cy_tst = [cy_tst; (C_fix(:,2)).']; 
    end
end
clc
toc
% Make sure your test features line up with your training features
% x_tst = [npix_tst, dx_tst, dy_tst, x_tst, y_tst, cn_tst, cx_tst, cy_tst];
x_in_tst = [npix_tst, dx_tst, dy_tst, x_tst, y_tst, tan(dx_tst/2), tan(dy_tst/2), ones(size(npix_tst))];
% x_in_tst = [npix_tst, dx_tst, dy_tst, tan(dx_tst/2), tan(dy_tst/2)];
% x_in_tst = [npix_tst, tan(dx_tst/2), tan(dy_tst/2)];
% x_in_tst = [npix_tst, dx_tst, dy_tst];
%
y_lab_tst = avg_depth_tst;
%
% do prediction
y_pred_tst = x_in_tst*beta;
[y_tst_sort,i_sort] = sort(y_lab_tst);
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
err_tst = abs(y_pred_tst-y_lab_tst); 
plot(err_tst(i_sort))
xlabel('Observation Index')
ylabel('Error in m')
title_val = ['Testing Error: ',class_type];
title(title_val)
grid('on')
boldify

% Some Info On Test Results
length(trn_inds)
loop_count_trn
mean(err_trn)
length(tst_inds)
loop_count_tst
mean(err_tst)
