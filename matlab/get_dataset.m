% pulls all data for a given class
%  creates a new label array that is simply 0/1 as to whether the pixel has the
%  class value of interest
function [imgs, dpts, lbls] = get_dataset(images, depths, labels, class)
  idcs = find(any(any(labels==class)));
  imgs = images(:,:,:,idcs);
  dpts = depths(:,:,idcs);
  lbls = labels(:,:,idcs)==class;
end
