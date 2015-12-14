function [lo, hi] = water_flooding(imagegray, gap)
	lo = 255;
	hi = 0;
	[w, h] = size(imagegray);
	obj = MyClass(imagegray);
	for i = 1 : w
		for j = 1 : h
			[tl, th] = water_filling_rec(obj, w, h, i, j, gap);
			lo = min(tl, lo);
			hi = max(th, hi);
		end
	end 
end 
