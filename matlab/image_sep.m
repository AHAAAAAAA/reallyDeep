
se_er = strel('disk',10);
se_di = strel('disk',8);
tic
mat_z_er = imerode(matrix_z,se_er);
mat_z_di = imdilate(mat_z_er,se_di);
CC = bwconncomp(mat_z_di);
matrix_z1 = zeros(480,640);
for ii = 1:CC.NumObjects
    ind_ii = CC.PixelIdxList{ii};
    matrix_z1(ind_ii) = ii;
end
toc
%
figure(3)
clf(3)
% matrix_z
subplot(2,2,1)
imagesc(matrix_z)
subplot(2,2,2)
imagesc(mat_z_er)
subplot(2,2,3)
imagesc(mat_z_di)
subplot(2,2,4)
imagesc(matrix_z1)