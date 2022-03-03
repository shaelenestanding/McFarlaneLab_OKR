function [phase_filtered_vector] = slowPhaseFilter(matrix, slow_phase_timebrackets)
%slowPhaseFilter Identifies the slow phase segments in a data set based on
%previously-identified timebrackets and outputs a vector containing all
%segments fused into one continuous vector.
%   Input:
%   matrix: an N x 2 matrix. column 1: time, column 2:
%   data in which you want to isolate the slow phase
%   slow_phase_timebrackets: a vector of peak time values between which are the
%   slow phases. The appropriate vector is outputted by slowPhaseBrackets.
%   stim_direction: what is the direction of the stimulus? write
%   'clockwise' or 'counter'
%
%   Output:
%   phase_filtered_angles: a N by 2 matrix containing data from the slow
%   phase of one eye position trace. Column 1: Time (s);
%   column 2: slow phase data
    
    %Initialize phase_filtered_matrix
    phase_filtered_vector = [0];
    phase_row = 1;
    filtered_row = 1;
    matrix_row = 1;
    while matrix_row <= length(matrix)
        if matrix(matrix_row,1) == slow_phase_timebrackets(phase_row)
            phase_row = phase_row+1;
            matrix_row = matrix_row+1;
            while matrix(matrix_row,1) ~= slow_phase_timebrackets(phase_row)
                phase_filtered_vector(filtered_row,1) = matrix(matrix_row,2);
                filtered_row = filtered_row+1;
                matrix_row = matrix_row+1;
            end
            phase_row = phase_row+1;
            %Stop running the loop once you reach the last peak in
            %slow_phase_timebrackets.
            if phase_row >= length(slow_phase_timebrackets)
                matrix_row = length(matrix)+1;
            end
        end
        matrix_row = matrix_row+1;
    end
                
%     figure(2)
%     x_values = phase_filtered_matrix(:,1);
%     y_values = phase_filtered_matrix(:,2);
%     plot(x_values,y_values)

end

