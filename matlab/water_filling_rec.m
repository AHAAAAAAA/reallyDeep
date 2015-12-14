function [lo, hi] = water_filling_rec(imagegray, w, h, i, j)
	lo = 255
	hi = 0
	if i > 0 && i <= w && j > 0 && j <= h && imagegray(i, j) > 0
		lo = min(lo, imagegray(i, j))
		hi = max(hi, imagegray(i, j))
		imagegray(i, j) = -1 
		[tl, th] = water_filling_rec(imagegray, w, h, i, j - 1)
		lo = min(tl, lo)
		hi = max(hi, th)
		[tl, th] = water_filling_rec(imagegray, w, h, i, j + 1)
		lo = min(tl, lo)
		hi = max(hi, th)
		[tl, th] = water_filling_rec(imagegray, w, h, i - 1, j)
		lo = min(tl, lo)
		hi = max(hi, th)
		[tl, th] = water_filling_rec(imagegray, w, h, i + 1, j)
		lo = min(tl, lo)
		hi = max(hi, th)
	end
end 
