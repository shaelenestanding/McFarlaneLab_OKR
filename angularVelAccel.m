function [inst_ang_vel, inst_ang_acc] = angularVelAccel(data, VEL_WINDOW, ACCEL_WINDOW)
%UNTITLED7 Summary of this function goes here
%   Two variables are produced.
    %inst_ang_vel is a N x 7 matrix: Column 1: Time(s); column 2: Raw Left Eye
    %Angular Velocity (deg/s); column 3: Raw Right Eye Angular Velocity
    %(deg/s); column 4: Smoothed Left Eye Angular Velocity (rpm); column 5: Smoothed Right
    %Eye Angular Velocity (rpm); column 6: Gain
    %instantaneous angular acceleration matrix: Column 1: Time
    %(s) starting at T1 of velocity data; column 2: left eye in deg/s^2;
    %column 3: right eye in deg/s^2
   
    
    %%Instantaneous angular velocity:
    
    left_ang_diff = diff(data(:, 2));
    right_ang_diff = diff(data(:, 3));
    time_ang_diff = diff(data(:, 1));
    %Initialize instantaneous angular velocity matrix.
    inst_ang_vel = zeros(length(left_ang_diff), 7);
    inst_ang_vel(:, 1) = data(2:end, 1);
    for row = 1:length(left_ang_diff)
        inst_ang_vel(row, 2) = left_ang_diff(row, 1) / time_ang_diff(row, 1);
        inst_ang_vel(row, 3) = right_ang_diff(row, 1) / time_ang_diff(row, 1);
    end
    
    %Calculate instantaneous angular velocity from smoothed eye angle data
    left_ang_diff = diff(data(:, 4));
    right_ang_diff = diff(data(:, 5));
    time_ang_diff = diff(data(:, 1));
    %Initialize matrix
    temp = zeros(length(left_ang_diff), 2);
    for row = 1:length(left_ang_diff)
        temp(row, 1) = left_ang_diff(row, 1) / time_ang_diff(row, 1);
        temp(row, 2) = right_ang_diff(row, 1) / time_ang_diff(row, 1);
    end
    
    %Smooth instantaneous angular velocity that is calculated from smoothed
    %eye angle data and add to inst_ang_vel matrix.
    inst_ang_vel(:, 4:5) = movmean(temp(:, :), VEL_WINDOW);
    top_remove = (VEL_WINDOW-1)/2;
    bottom_remove = length(inst_ang_vel) - (VEL_WINDOW-1)/2 + 1;
    inst_ang_vel(1:top_remove, 4:5) = [NaN];
    inst_ang_vel(bottom_remove:end, 4:5) = [NaN];
    
    %%Instantaneous angular acceleration:
    
    left_vel_diff = diff(inst_ang_vel(:, 2));
    right_vel_diff = diff(inst_ang_vel(:, 3));
    time_vel_diff = diff(inst_ang_vel(:, 1));
    %Initialize instantaneous angular acceleration matrix. Column 1: Time
    %(s) starting at T1 of velocity data; column 2: raw left eye in deg/s^2;
    %column 3: raw right eye in deg/s^2; column 4:smoothed left eye; column
    %5; smoothed right eye
    inst_ang_acc = zeros(length(left_vel_diff), 5);
    inst_ang_acc(:, 1) = inst_ang_vel(2:end, 1);
    for row = 1:length(left_vel_diff)
        inst_ang_acc(row, 2) = left_vel_diff(row, 1) / time_vel_diff(row, 1);
        inst_ang_acc(row, 3) = right_vel_diff(row, 1) / time_vel_diff(row, 1);
    end
    
%     %Calculate instantaneous angular acceleration from the angular velocity
%     %calculated from the smoothed eye angle data
%     left_vel_diff = diff(temp(:, 1));
%     right_vel_diff = diff(temp(:, 2));
%     time_vel_diff = diff(inst_ang_vel(:, 1));
%     %Initialize matrix
%     temp = zeros(length(left_vel_diff), 2);
%     for row = 1:length(left_vel_diff)
%         temp(row, 1) = left_vel_diff(row, 1) / time_vel_diff(row, 1);
%         temp(row, 2) = right_vel_diff(row, 1) / time_vel_diff(row, 1);
%     end
    
    %Calculate instantaneous angular acceleration from the smoothed
    %angular velocity
    left_vel_diff = diff(inst_ang_vel(:, 4));
    right_vel_diff = diff(inst_ang_vel(:, 5));
    %Initialize matrix
    temp = zeros(length(left_vel_diff), 2);
    for row = 1:length(left_vel_diff)
        temp(row, 1) = left_vel_diff(row, 1) / time_vel_diff(row, 1);
        temp(row, 2) = right_vel_diff(row, 1) / time_vel_diff(row, 1);
    end
    
    %Smooth instantaneous angular acceleration that is calculated from
    %smoothed angular velocity data and add to inst_ang_vel matrix.
    inst_ang_acc(:, 4:5) = movmean(temp(:, :), ACCEL_WINDOW);
    top_remove = (ACCEL_WINDOW-1)/2;
    bottom_remove = length(inst_ang_vel) - (ACCEL_WINDOW-1)/2 + 1;
    inst_ang_acc(1:top_remove, 4:5) = [NaN];
    inst_ang_acc(bottom_remove:end, 4:5) = [NaN];

