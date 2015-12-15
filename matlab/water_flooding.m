function [lo, hi] = water_flooding(imagegray, gap)
	lo = 255;
	hi = 0;
	[w, h] = size(imagegray);
	obj = MyClass(imagegray);
	st = Stack(w, h);
	for i = 1 : w
		for j = 1 : h
			i
			j
			value = get(obj, i, j);
			if value > 0
				[tl, th] = water_filling_itr(obj, st, w, h, i, j, gap);
				lo = min(tl, lo);
				hi = max(th, hi);
			end
		end
	end 
end 
