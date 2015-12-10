function [imgtrn, deptrn, lbltrn] = preprocess(dataset)
    load(dataset);
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
    imgtrn = [];
    deptrn = [];
    lbltrn = [];
    length(trn_inds)
    length(tst_inds)
    
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
                imgtrn = [imgtrn; [matrix_gray(obj_inds)]];
                deptrn = [deptrn; depths_trn(ind_kk)];
                lbltrn = [lbltrn; labels_trn(ind_kk)];
            end
        end
    end
    
    
