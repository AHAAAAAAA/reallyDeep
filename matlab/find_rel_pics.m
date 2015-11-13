function [rel_inds] = find_rel_pics(labels,class)
    num_img = size(labels,3);
    rel_inds = [];
    for ii = 1:num_img
        if (sum(sum(ismember(labels(:,:,ii),class)))>0)
            rel_inds = [rel_inds, ii];
        end
    end