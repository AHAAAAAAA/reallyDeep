function [lo, hi] = water_filling_rec(obj, w, h, i, j, gap)
	lo = 255;
	hi = 0;
	if i > 0 && i <= w && j > 0 && j <= h && get(obj, i, j) > 0
		lo = min(lo, get(obj, i, j));
		hi = max(hi, get(obj, i, j));
		oldValue = get(obj, i, j);
		set(obj, i, j, 0);
		if j - 1 > 0 &&  oldValue + gap > get(obj, i, j - 1) && oldValue - gap < get(obj, i, j - 1) 
			[tl, th] = water_filling_rec(obj, w, h, i, j - 1, gap);
			lo = min(tl, lo);
			hi = max(hi, th);
		end
		if j + 1 <= h && oldValue + gap > get(obj, i, j + 1) && oldValue - gap < get(obj, i, j + 1) 
			[tl, th] = water_filling_rec(obj, w, h, i, j + 1, gap);
			lo = min(tl, lo);
			hi = max(hi, th);
		end
		if i - 1 > 0 && oldValue + gap > get(obj, i - 1, j) && oldValue - gap < get(obj, i - 1, j) 
			[tl, th] = water_filling_rec(obj, w, h, i - 1, j, gap);
			lo = min(tl, lo);
			hi = max(hi, th);
		end
		if i + 1 <= w && oldValue + gap > get(obj, i + 1, j) && oldValue - gap < get(obj, i + 1, j) 
			[tl, th] = water_filling_rec(obj, w, h, i + 1, j, gap);
			lo = min(tl, lo);
			hi = max(hi, th);
		end
	end
end 
