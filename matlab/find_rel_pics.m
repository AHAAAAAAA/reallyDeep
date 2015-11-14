% returns indices of pics containing given class
function [rel_inds] = find_rel_pics(labels,class)
  rel_inds = find(any(any(labels==class)));
