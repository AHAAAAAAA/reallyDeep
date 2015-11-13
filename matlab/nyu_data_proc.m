%%
clear,clc,close('all')
load('dev_dataset.mat')
%%
clc
image_ind = 1;
label_val = 234;
scale = 20;
image_val = images_trn(:,:,:,image_ind);
image_gray = rgb2gray(image_val);
image_gray = downsample(image_gray,scale);
image_gray = downsample(image_gray.',scale);
image_gray = image_gray.';
depth_val = depths_trn(:,:,image_ind);
lab_img = labels_trn(:,:,image_ind);
[obj_x_inds,obj_y_inds,n_pix,obj_dx,obj_dy,obj_pres] = extract_obj(lab_img,label_val);
matrix_z = zeros(480,640);
for i = 1:n_pix
    matrix_z(obj_y_inds(i),obj_x_inds(i)) = 1;
end
im_x_mid = 640/2;
im_y_mid = 480/2;
obj_x_mid = mean(obj_x_inds);
obj_y_mid = mean(obj_y_inds);
x_shift = round(obj_x_mid-im_x_mid);
y_shift = round(obj_y_mid-im_y_mid);
mat_shift = circshift(matrix_z,[-y_shift,-x_shift]);
avg_depth = extract_object_depth(depth_val,lab_img,label_val);
figure(1)
clf(1)
subplot(3,2,1)
imagesc(image_val)
subplot(3,2,2)
imagesc(image_gray)
subplot(3,2,3)
imagesc(lab_img)
subplot(3,2,4)
imagesc(depth_val)
subplot(3,2,5)
imagesc(matrix_z)
subplot(3,2,6)
imagesc(mat_shift)
names(label_val)
obj_dx
obj_dy
n_pix
avg_depth