% train regression for given object class and evaluate on test datasets
% provided

function [] = deep_regress(class, images_trn, depths_trn, labels_trn, images_tst, depths_tst, labels_tst)

% extract data subsets
[imgs_trn, dpts_trn, lbls_trn] = get_dataset(images_trn, depths_trn, labels_trn, class);
[imgs_tst, dpts_tst, lbls_tst] = get_dataset(images_tst, depths_tst, labels_tst, class);

% parameters--TODO: convert (some? all?) these to function parameters with default values
er_r = 10; % Image erode filter radius
di_r = 8; % Image dialation filter radius
n_pix_thresh = 1000; % minimum number of pixels to accept for training
dist_thresh = 3.5; % maximum distance to accept for training
c_points = 10; % number of corners to detect
do_obj_separation = true;

im_x_mid = 640/2;
im_y_mid = 480/2;

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

% build feature vectors
loop_count_trn = 0;
for ii=1:length(imgs_trn)
    matrix_z = lbls_trn(:,:,ii)==class_ind;
    image_gray = rgb2gray(imgs_trn(:,:,:,ii));

    if do_obj_separation
      % Erode and dilate to isolate separate object instances
      se_er = strel('disk',er_r);
      se_di = strel('disk',di_r);

      mat_z_er = imerode(matrix_z,se_er);
      mat_z_di = imdilate(mat_z_er,se_di);

      CC = bwconncomp(mat_z_di);
    else
      CC = struct('NumObjects', 1, 'PixelIdxList', {find(matrix_z)});
    end

    for kk = 1:CC.NumObjects
        ind_kk = CC.PixelIdxList{kk};
        matrix_ziso = zeros(480,640);
        matrix_ziso(ind_kk) = 1;

        [obj_inds,obj_x_inds,obj_y_inds,n_pix,obj_dx,obj_dy,obj_pres] = extract_obj(matrix_ziso,1);
        avg_depth = extract_object_depth(dpts_trn(:,:,ii),matrix_ziso,1);

        if((avg_depth<dist_thresh) && (n_pix>n_pix_thresh))
            % Currently Unused Grayscale Image for Feature Extraction
            %matrix_gray = image_gray .* matrix_ziso;
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


end
