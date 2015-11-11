% finds the average depth of the object in the depth image
function [avg_depth] = extract_object_depth(depth, labels, class)
  d = depth .* (labels == class);
  avg_depth = sum(d)/sum(labels == class);
end
