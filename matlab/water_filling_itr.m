function [lo, hi] = water_filling_itr(obj, st, w, h, I, J, gap)
	lo = 255;
	hi = 0;
	st.top = 0;

	oldvalue = get(obj, I, J);
	lo = min(lo, oldvalue);
	hi = max(hi, oldvalue);
	set(obj, I, J, 0);
	push(st, I, J, 0);
	while st.top > 0
		[i, j, v] = st.data(st.top, :);

		if v == 4
			pop(st);
		else
			st.data(st.top, :) = [i, j, v + 1];
			if v == 0
				i = i - 1
			elseif v == 1
				j = j - 1
			elseif v == 2
				i = i + 1
			else 
				j = j + 1
			end
			if i > 0 && i <= w && j > 0 && j <= h
				oldvalue = get(obj, i, j)
				if oldvalue > 0
					lo = min(lo, oldvalue);
					hi = max(hi, oldvalue);
					set(obj, i, j, 0);
					push(st, i, j, 0);
				end
			end
		end
	end	 
end 
