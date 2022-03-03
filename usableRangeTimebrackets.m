function timebrackets = usableRangeTimebrackets(inex_start_time,inex_end_time,time)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    
    %Find exact start bracket
    row = 1;
    while time(row,1) <= inex_start_time
        row = row+1;
    end
    ex_start = time(row,1);
    %Find exact end bracket
    row = 1;
    while time(row,1) <= inex_end_time
        row = row+1;
    end
    ex_end = time(row-1,1);
    
    timebrackets = [ex_start;ex_end];
end

