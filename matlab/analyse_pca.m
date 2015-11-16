[x,y,z] = size(depths_trn)
R =[] % zeros(z, x * y);

class_type = 'sofa';
class_ind = namesToIds(class_type);

% get indices of images in training and test sets
trn_inds = find_rel_pics(labels_trn,class_ind);
length(trn_inds);
tst_inds = find_rel_pics(labels_tst,class_ind);
length(tst_inds);

for j=1:length(trn_inds)
    i=trn_inds(j);
    A = depths_trn(:, :, i);
    A = reshape(A, 1, x * y);
    R = [R;A];
end

[COEFF, SCORE, LATENT] = princomp(R);
