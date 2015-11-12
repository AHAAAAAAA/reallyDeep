% the simplest thing I can think of

C = 894;

for c = 1:C
  [imgs_trn, dpts_trn, lbls_trn] = get_dataset(images_trn, depths_trn, labels_trn, c);
  I = length(imgs_trn(1,1,1,:));
  avg_depths = zeros(I, 1);
  for i=1:I
    avg_depths(i) = extract_object_depth(dpts_trn(:,:,i), lbls_trn(:,:,i), 1);
  end
  % TODO:
  % reshape inputs into array of size (640*480*3 + 640*480 + 640*480) x I
  % run mvregress on input, ^, and avg_depths as output
  % test regression on _tst datasets
end
