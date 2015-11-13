%%
clear,clc,close('all')
load('dev_dataset.mat')
%%
clc
class_type = 'chair';
% Find the index
for ii = 1:length(names)
    if (strcmp(names(ii),class_type)==1)
        class_ind = ii;
    end
end
trn_inds = find_rel_pics(labels_trn,class_ind);
length(trn_inds)
tst_inds = find_rel_pics(labels_tst,class_ind);
length(tst_inds)
%
npix_trn = [];
dx_trn = [];
dy_trn = [];
x_trn = [];
y_trn = [];
avg_depth_trn = [];
%
for ii=1:length(trn_inds)
    jj = trn_inds(ii);
    [obj_x_inds,obj_y_inds,n_pix,obj_dx,obj_dy,obj_pres] = extract_obj(labels_trn(:,:,jj),class_ind);
    avg_depth = extract_object_depth(depths_trn(:,:,jj),labels_trn(:,:,jj),class_ind);
    obj_x_mid = mean(obj_x_inds);
    obj_y_mid = mean(obj_y_inds);
    % Append!
    npix_trn = [npix_trn, n_pix];
    dx_trn = [dx_trn, obj_dx];
    dy_trn = [dy_trn, obj_dy];
    x_trn = [x_trn, obj_x_mid];
    y_trn = [y_trn, obj_y_mid];
    avg_depth_trn = [avg_depth_trn, avg_depth];
end
%
npix_trn = npix_trn.';
dx_trn = dx_trn.';
dy_trn = dy_trn.';
x_trn = x_trn.';
y_trn = y_trn.';
avg_depth_trn = avg_depth_trn.';
x_in = [npix_trn, dx_trn, dy_trn, x_trn, y_trn];
y_lab = avg_depth_trn;
[beta,sigma] = mvregress(x_in,y_lab);
y_pred = x_in*beta;
[y_lab_sort,i_sort] = sort(y_lab);
y_pred_sort = y_pred(i_sort);
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
err_trn = abs(y_pred-y_lab); 
plot(err_trn(i_sort))
xlabel('Observation Index')
ylabel('Error in m')
title_val = ['Training Error: ',class_type];
title(title_val)
grid('on')
boldify
%
npix_tst = [];
dx_tst = [];
dy_tst = [];
x_tst = [];
y_tst = [];
avg_depth_tst = [];
%
for ii=1:length(tst_inds)
    jj = tst_inds(ii);
    [obj_x_inds,obj_y_inds,n_pix,obj_dx,obj_dy,obj_pres] = extract_obj(labels_tst(:,:,jj),class_ind);
    avg_depth = extract_object_depth(depths_tst(:,:,jj),labels_tst(:,:,jj),class_ind);
    obj_x_mid = mean(obj_x_inds);
    obj_y_mid = mean(obj_y_inds);
    % Append!
    npix_tst = [npix_tst, n_pix];
    dx_tst = [dx_tst, obj_dx];
    dy_tst = [dy_tst, obj_dy];
    x_tst = [x_tst, obj_x_mid];
    y_tst = [y_tst, obj_y_mid];
    avg_depth_tst = [avg_depth_tst, avg_depth];
end
%
npix_tst = npix_tst.';
dx_tst = dx_tst.';
dy_tst = dy_tst.';
x_tst = x_tst.';
y_tst = y_tst.';
avg_depth_tst = avg_depth_tst.';
x_tst = [npix_tst, dx_tst, dy_tst, x_tst, y_tst];
y_tst = avg_depth_tst;
y_pred_tst = x_tst*beta;
[y_tst_sort,i_sort] = sort(y_tst);
y_pred_tst_sort = y_pred_tst(i_sort);
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
