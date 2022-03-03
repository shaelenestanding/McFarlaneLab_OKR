function desired_time = continuousTime(timebrackets, time, FRAME_RATE)
%fuseSegments Takes a matrix in which some rows of data (not time) have
%been replated with NaN and returns new continuous time vector
%   Input:
%   timebrackets: a vector containing the start and end time pairs for the
%   desired range(s) in one column
%   time: an N x 1 vector of time (uninterrupted by NaNs)
%   FRAME_RATE
%   
%   Output:
%   desired_time = An N x 1 matrix. A new time (s) vector representing time as continuous
%   though all the desired data in one continuous segment

    
    %Convert time values outside the timebrackets to NaN
    phase_row = 1;
    time_row = 1;
    while time_row <= length(time)
        if phase_row <= length(timebrackets) && time(time_row) == timebrackets(phase_row)
            time(time_row) = NaN;
            phase_row = phase_row+1;
            while time(time_row) ~= timebrackets(phase_row)
                time_row = time_row+1;
            end
            phase_row = phase_row+1;
        end
        time(time_row) = NaN;
        time_row = time_row+1;
    end
    
    %Initialize a new matrix
    desired_time = [0];
           
    %Put all non NaN rows from time into slow_phase_fused, making time
    %continuous. Remember that some frames are skipped so you cannot just
    %generate a vector with evenly-spaced points.
    filtered_row = 1;
    desired_row = 1;
    last_num = 0;
    curr_num = 0;
    %Scan all rows of phase_filtered_matrix for non-NaNs
    while filtered_row <= length(time)
        segment_row = 1;
        while ~isnan(time(filtered_row,1))
            %If this is the very first non-NaN row, subtract this time value
            %from all points in this segment.
            if desired_row == 1 && ~isnan(time(filtered_row,1))
               diff = time(filtered_row,1);
            %If this is the first non-NaN in this segment,
            %subtract the last time value of the previous segment
            %from all points in this segment. Add the frame rate
            %(sec/frame) to avoid repeating a time point.
            elseif segment_row == 1
                diff = time(filtered_row,1) - (last_num + FRAME_RATE);
            end
            desired_time(desired_row,1) = time(filtered_row,1) - diff;
            curr_num = desired_time(desired_row,1);
            filtered_row = filtered_row+1;
            desired_row = desired_row+1;
            segment_row = segment_row+1;
        end
        last_num = curr_num;
        filtered_row = filtered_row+1;
    end
end
