function [lcl_mins, lcl_maxs] = findLocalMinsMaxs(vector, prom_thresh)
%findLocalMinMaxs Finds the local minima and maxima in a vector according
%to a specified prominence threshold.
%   Input as follows:  
%   vector: the vector of values you want to search for minima
%   prom_thresh: the minimum prominence for local minima
%   Output:
%   Two vectors of the same size as the input vector, containing logical
%   values. 1 indicates the location of a local min or max.
    
    lcl_mins = islocalmin(vector, 'MinProminence', prom_thresh);
    lcl_maxs = islocalmax(vector, 'MinProminence', prom_thresh);
end

