load ../data/dev_dataset.mat

granu=20;

[X, Y, Z] = size(depths_trn);
[M, N, L] = size(depths_tst);


class_type = 'sofa';
class_ind = namesToIds(class_type);

% get indices of images in training and test sets
trn_inds = find_rel_pics(labels_trn,class_ind);
tst_inds = find_rel_pics(labels_tst,class_ind);
tst_not_inds = setdiff((1:L), tst_inds)

R = generate_feature_matrix(trn_inds, depths_trn, granu, X, Y);

[W, pc] = princomp(R);
R = generate_feature_matrix((1:L), depths_tst, granu, X, Y)

P=R * W;

P=P(:, 1:3);

save('g20sofaDev.mat', 'granu', 'class_type', 'class_ind', 'trn_inds', 'tst_inds', 'W', 'pc', 'P')

%plot(pc(1,:),pc(2,:),'.'); 
%title('{\bf PCA} by princomp'); xlabel('PC 1'); ylabel('PC 2')
