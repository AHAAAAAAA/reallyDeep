% the simplest thing I can think of

C = 894;

for c = 1:C
  [imgs_trn, dpts_trn, lbls_trn] = get_dataset(images_trn, depths_trn, labels_trn, c);
  I = length(imgs_trn(1,1,1,:));
  avg_depths = zeros(I, 1);
  for i=1:I
    avg_depths(i) = extract_object_depth(dpts_trn(:,:,i), lbls_trn(:,:,i), 1);
  end
  inputs = [reshape(imgs_trn, 640*480*3, []); reshape(lbls_trn, 640*480, [])]; % 640*480*4 x I
  [beta, Sigma] = mvregress(inputs', avg_depths);

  % test regression on _tst datasets
  [imgs_tst, dpts_tst, lbls_tst] = get_dataset(images_tst, depths_tst, labels_tst, c);
  I = length(imgs_tst(1,1,1,:));
  avg_depths = zeros(I, 1);
  for i=1:I
    avg_depths(i) = extract_object_depth(dpts_tst(:,:,i), lbls_tst(:,:,i), 1);
  end
  inputs = [reshape(imgs_tst, 640*480*3, []); reshape(lbls_tst, 640*480, [])]; % 640*480*4 x I
  err = beta'*inputs - avg_depths;
  break;
end
