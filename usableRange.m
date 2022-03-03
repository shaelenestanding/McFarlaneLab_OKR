function data = usableRange(inex_start_time,inex_end_time,data,FRAME_RATE)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    
    %Find the exact time brackets for the desired range based on the
    %inexact user input.
	timebrackets = usableRangeTimebrackets(inex_start_time,inex_end_time,data(:,1));
    
    desired_time = continuousTime(timebrackets, data(:,1), FRAME_RATE);
    
    temp = zeros(1,5);
    desired_row = 1;
    row = 1;
    while row <= length(data)
        while data(row,1) > timebrackets(1,1) && data(row,1) < timebrackets(2,1)
            temp(desired_row,:) = data(row,:);
            row = row+1;
            desired_row = desired_row+1;
        end
        row = row+1;
    end
    
    temp(:,1) = desired_time;
    
    data = temp;
            
    
           
end

