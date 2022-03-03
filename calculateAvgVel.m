function [left_avg_ang_vel, right_avg_ang_vel] = calculateAvgVel(vel_matrix)
%UNTITLED2 Summary of this function goes here
%   Input:
%   vel_matrix: an N x 2 matrix containing the left and right instantaneous
%   angular velocity vectors from which you want to calgulate average
%   velocity. column 1: left; column 2: right.
%
%   Output:
%   a 1 x 2 vector containing the left and right average angular velocities
%   as items 1 and 2.

    left_avg_ang_vel = mean(vel_matrix(:, 1), 'omitnan');
    right_avg_ang_vel = mean(vel_matrix(:, 2), 'omitnan');
   
end

