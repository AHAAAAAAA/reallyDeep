function [lo, hi] = water_filling_itr(obj, st, w, h, I, J, gap)
	lo = 255;
	hi = 0;
	st.top = 0;

	origin = get(obj, I, J);
	lo = min(lo, origin);
	hi = max(hi, origin);
	set(obj, I, J, 0);
	push(st, I, J, 0, origin);
	while st.top > 0
		r = st.data(st.top, :);
		i = r(1);
		j = r(2);
		v = r(3);
		origin = r(4);

		if v == 4
			pop(st);
		else
			st.data(st.top, :) = [i, j, v + 1, origin];
			if v == 0
				i = i - 1;
			elseif v == 1
				j = j - 1;
			elseif v == 2
				i = i + 1;
			else 
				j = j + 1;
			end
			if i > 0 && i <= w && j > 0 && j <= h
				nbvalue = get(obj, i, j);
				if nbvalue > origin - gap && nbvalue < origin + gap 
					lo = min(lo, nbvalue);
					hi = max(hi, nbvalue);
					set(obj, i, j, 0);
					push(st, i, j, 0, nbvalue);
				end
			end
		end
	end	 
end 
