function [img_out, dep_out, lbl_out] = preprocess(images, depths, labels, class_ind)
    er_r = 10; % Image erode filter radius
    di_r = 8; % Image dialation filter radius
    n_pix_thresh = 1000; % minimum number of pixels to accept for training
    dist_thresh = 3.5; % maximum distance to accept for training

    % get indices of images in training and test sets
    trn_inds = find_rel_pics(labels,class_ind);
    img_out = [];
    dep_out = [];
    lbl_out = [];

    for ii=1:length(trn_inds)
        jj = trn_inds(ii);
        matrix_z = labels(:,:,jj)==class_ind;
        image_gray = rgb2gray(images(:,:,:,jj));

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
        for kk = 1:CC.NumObjects
            matrix_ziso = zeros(size(labels(:,:,jj)));
            matrix_ziso(CC.PixelIdxList{kk}) = 1;
            img_out = cat(4, img_out, images(:,:,:,jj));
            dep_out = cat(3, dep_out, depths(:,:,jj));
            lbl_out = cat(3, lbl_out, matrix_ziso);
        end
    end
