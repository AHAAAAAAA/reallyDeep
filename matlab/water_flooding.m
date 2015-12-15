function [ratio] = water_flooding(imagegray, gap)
	[w, h] = size(imagegray);
	obj = MyClass(imagegray);
	st = Stack(w, h);
	for i = 1 : 1 :  w
		for j = 1 : 1 :  h
			value = get(obj, i, j);
			if value > 0
				[tl, th, area] = water_filling_itr(obj, st, w, h, i, j, gap);
				ratio = 1.0 * area / (th - tl); 
			end
		end
	end 
end 
