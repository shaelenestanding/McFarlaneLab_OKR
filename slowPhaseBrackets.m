function [slow_phase_timebrackets, repeat] = slowPhaseBrackets(angles, STIM_DIREC, eye)
%slowPhaseBrackets Determines the time points bracketing the slow phases
%of the eye angle recording. Continues to prompt user for a ratio with
%which to calculate the prominence threshold until they are satisfied with
%the local minima and maxima that are identified
%   Input: 
%   angles: an N x 2 matrix of the complete (unfiltered)
%   time and angle data for one eye that you want to use. column 1: time
%   (s); column 2: angle (deg) 
%   stim_direc: stimulus direction. Requires a string input. Write
%   'counter' or 'clockwise'
%   eye: "Left" or "Right"
%
%   Output:
%   slow_phase_timebrackets: a vector containing the time points that
%   bracket the slow phases for the eye in question. Based on the stimulus
%   direction, the order of points will either be min,max,min,max,etc (if
%   counterclockwise) or max,min,max,min,etc (if clockwise). Each pair of
%   points represents one slow phase segment.
%   repeat (function): 'yes' or 'no'
    
    %Prompt the user to enter a ratio for the prominence threshold
    prompt = {'Enter the ratio (decimal) to use to find local minima and maxima.',...
            'Is this your final answer? (Enter "yes" or "no"'};
    dlgtitle = strcat('Prominence Threshold', {' '}, '(', eye, {' '}, 'Eye', ')');
    dims = [1 100; 1 100];
    output = inputdlg(prompt,dlgtitle,dims);    
    RATIO = str2double(output{1,1});
    repeat = lower(output{2,1});
    
    %If one of the entries was not valid, ask them to reenter input.
    entry1 = 0;
    entry2 = 0;
    while entry1 == 0 || entry2 == 0
        if isnumeric(RATIO) && ~isnan(RATIO) && RATIO>0
            entry1 = 1;
        end
        if strcmp(repeat,"yes") || strcmp(repeat,"no")
            entry2 = 1;
        end
        if entry1 == 0 || entry2 == 0
            prompt = {'One or both of your input values was invalid. Please try again. Enter the ratio (decimal) to use to find local minima and maxima.',...
                'Is this your final answer? (Enter "yes" or "no"'};
            dlgtitle = strcat('Prominence Threshold', {' '}, '(', eye, {' '}, 'Eye', ')');
            dims = [1 100; 1 100];
            output = inputdlg(prompt,dlgtitle,dims);
            RATIO = str2double(output{1,1});
            repeat = output{2,1};
        end
    end
        
    
    %Set the prominence threshold as a ratio to the difference between the
    %absolute maximum and minimum
    PROM_THRESH = RATIO .* abs(max(angles(:,2) - min(angles(:,2))));
    [lcl_mins, lcl_maxs] = findLocalMinsMaxs(angles(:,2), PROM_THRESH);
    
    if strcmp(STIM_DIREC,'counterclockwise')
        peak2 = lcl_mins;
        peak1 = lcl_maxs;
    elseif strcmp(STIM_DIREC,'clockwise')
        peak1 = lcl_mins;
        peak2 = lcl_maxs;
    end 
    
    time = angles(:,1);
    time_peak1 = time(peak1);
    time_peak2 = time(peak2);
    %Add 1 and 2 labels in a second column to help create the timebrackets
    time_peak1(:,2) = [1];
    time_peak2(:,2) = [2];
    slow_phase_timebrackets = [time_peak1;time_peak2];
    
    %Order the peak rows based on the first column
    slow_phase_timebrackets = sortrows(slow_phase_timebrackets);
    slow_phase_timebrackets = reshape(slow_phase_timebrackets,[],2);
    
    %Make sure the matrix starts with a peak1 and ends with a peak2
    if slow_phase_timebrackets(1,2) == 2
        slow_phase_timebrackets(1,:) = [];
    end
    if slow_phase_timebrackets(end,2) == 1
        slow_phase_timebrackets(end,:) = [];
    end
    
    slow_phase_timebrackets = reshape(slow_phase_timebrackets,[],2);
    slow_phase_timebrackets(:,2) = [];
    
    %Close open figure
    close
    
    %Create a figure identifying the local minima and maxima on the raw
    %angle data
    fig = figure('Name', strcat('Local Mins and Maxs', {' '}, eye), 'NumberTitle', 'off');
    x_values = angles(:,1);
    y_values = angles(:,2);
    plot(x_values,y_values, 'k', x_values(lcl_mins),y_values(lcl_mins),'r*', ...
        x_values(lcl_maxs),y_values(lcl_maxs),'g*')
    title(strcat('Local Mins and Maxs Identified with Ratio of ', {' '}, string(RATIO)));
    xlabel('Time (s)')
    ylabel('Angle (deg)')
    movegui('west');
end

