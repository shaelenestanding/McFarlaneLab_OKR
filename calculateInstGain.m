function inst_gain = calculateInstGain(inst_ang_vel, stim_vel)
%calculateInstGain Summary of this function goes here
%   Input:
%   inst_ang_vel: a N x 2 matrix of the instantaneous angular velocities
%   you want to use to compute gain. column 1: left eye; column 2: right
%   eye
%   stim_velocity: the stimulus velocity in deg/s
%
%   Output:
%   inst_gain: an N x 2 matrix of the instantaneous gain. column 1: left
%   eye; coumn 2: right eye
        
        %Convert all NaNs to zeros
        inst_ang_vel(isnan(inst_ang_vel)) = 0;
        
        %Initialize a inst_gain matrix
        inst_gain = zeros(length(inst_ang_vel),2);
        
        %Calculate gain and add to the matrix
        inst_gain(:, 1) = inst_ang_vel(:, 1) .* (1/stim_vel);
        inst_gain(:, 2) = inst_ang_vel(:, 2) .* (1/stim_vel);
        
        %Convert all zeros back to NaN
        inst_gain(inst_gain == 0) = NaN;
        
end

