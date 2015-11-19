function R = generate_feature_matrix(inds, depths_trn, granu, X, Y)   
	R =zeros(length(inds), X * Y / (granu * granu));
	for j=1:length(inds)
		i=inds(j);
		A=zeros(X / granu, Y / granu);
		for x=1:granu:X
			for y=1:granu:Y
				A((x + granu - 1) / granu, (y + granu - 1) / granu) = mean2(depths_trn(x:x + granu - 1, y: y + granu - 1, i));	
			end
		end
		A = reshape(A, 1, X * Y / (granu * granu));
		R(j, :) = A;
	end
end
