% get bounding box for object in lab_img with label label_val
function [obj_inds,obj_x_inds,obj_y_inds,n_pix,obj_dx,obj_dy,obj_pres] = extract_obj(lab_img,label_val)
    [obj_y_inds,obj_x_inds] = find(lab_img==label_val);
    [obj_inds] = find(lab_img==label_val);
    if ((isempty(obj_x_inds))||(isempty(obj_y_inds)))
        obj_pres = 0;
        n_pix = 0;
        obj_dx = 0;
        obj_dy = 0;
    else
        obj_pres = 1;
        n_pix = length(obj_inds);
        obj_dx = max(obj_x_inds)-min(obj_x_inds);
        obj_dy = max(obj_y_inds)-min(obj_y_inds);
    end
