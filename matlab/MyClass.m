classdef (Sealed) MyClass < handle
	properties (Access = private)
		data
	end
	methods
		function obj = MyClass(x)
			obj.data = x;
		end
	end
	methods
		function r = get(obj, i, j)
			r = obj.data(i, j); 
		end
		function set(obj, i, j, val)
			obj.data(i, j) = val;
		end
	end
end
