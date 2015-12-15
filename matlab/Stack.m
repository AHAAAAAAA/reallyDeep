classdef Stack < handle
    properties (Access = public)
        data
		top
		len
    end
    methods
        function obj = Stack(w, h)
            obj.data = zeros(w * h, 4);
			obj.top = 0; 
			obj.len = h;
        end
		function push(obj, i, j, v, origin)
			obj.top = obj.top + 1;
			obj.data(obj.top, :) = [i, j, v, origin];
		end
		function pop(obj)
			obj.top = obj.top - 1;
		end
    end
end
