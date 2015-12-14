function [lo, hi] = water_flooding(imagegray)
	lo = 255;
	hi = 0;
	[w, h] = size(imagegray);
	for i = 1 : w
		for j = 1 : h
		if imagegray(i, j) >= 0
			[tl, th] = water_filling_rec(imagegray, w, h, i, j);
			lo = min(tl, lo);
			hi = max(th, hi);
		end
	end 
end 
