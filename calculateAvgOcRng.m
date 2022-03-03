function [avg_ocular_range] = calculateAvgOcRng(angle_matrix, slow_phase_timebrackets)
%calculateAvgOcRng Calculates the average range of eye movements during the slow phase of the OKR
%   Input:
%   angle_matrix = unprocessed (except for smoothing) angle data for one
%   eye. An N x 2 matrix. Column 1: time (s); column 2: angles for one eye
%   slow_phase_timebrackets: the start and end time points for the slow
%   phases.

%   Output: 
%   avg_ocular_range: the average ocular range of one eye during the OKR
    
    %Iterate through all rows of the angle matrix. When a time point that
    %matches a time bracket is reached, calculate the difference between
    %this local peak and the previous one, and add this measurement to the
    %ocular range vector. Then, find the average of all phasic ocular ranges.
    
    peak1 = angle_matrix(1,2);
    ocular_range_row = 1;
    for row = 1:length(angle_matrix)
        if ismember(angle_matrix(row,1),slow_phase_timebrackets)
            peak2 = angle_matrix(row,2);
            ocular_range(ocular_range_row) = abs(peak2-peak1);
            ocular_range_row = ocular_range_row + 1;
            peak1 = angle_matrix(row+1,2);
        end
    end

    avg_ocular_range = mean(ocular_range, 'omitnan');
        
end

