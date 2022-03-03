function [STIM_DIREC,GENOTYPE,DATE_RECORD,BAND_NUM,STIM_VEL,FRAME_RATE,ANGLE_WINDOW,VEL_WINDOW,ACCEL_WINDOW,BUFFER,DOB,AGE] = importInfo(file)
%importInfo Assigns variables to input information from a pre-formatted Excel file.
%   The file is read into an array, then desired values in the right column are found based on
%   their name in the left column. Cells are either converted to numbers or
%   strings.
    
    array = readcell(file);
    STIM_DIREC = array(strcmp(array(:,1), 'Stimulus Direction'),:);
    STIM_DIREC = char(STIM_DIREC(1,2));
    DATE_RECORD = array(strcmp(array(:,1), 'Date of Recording (dd-MM-yyyy)'),:);
    DATE_RECORD = string(DATE_RECORD(1,2));
    GENOTYPE = array(strcmp(array(:,1), 'Genotype'),:);
    GENOTYPE = char(GENOTYPE(1,2));
    BAND_NUM = array(strcmp(array(:,1), 'Number of Bands'),:);
    BAND_NUM = cell2mat(BAND_NUM(1,2));
    STIM_VEL = array(strcmp(array(:,1), 'Stimulus Velocity (deg/s)'),:);
    STIM_VEL = cell2mat(STIM_VEL(1,2));
    FRAME_RATE = array(strcmp(array(:,1), 'Frame Rate (sec/frame)'),:);
    FRAME_RATE = cell2mat(FRAME_RATE(1,2));
    ANGLE_WINDOW = array(strcmp(array(:,1), 'Angle Moving Average'),:);
    ANGLE_WINDOW = cell2mat(ANGLE_WINDOW(1,2));
    VEL_WINDOW = array(strcmp(array(:,1), 'Instantaneous Angular Velocity Moving Average'),:);
    VEL_WINDOW = cell2mat(VEL_WINDOW(1,2));
    ACCEL_WINDOW = array(strcmp(array(:,1), 'Instantaneous Angular Acceleration Moving Average'),:);
    ACCEL_WINDOW = cell2mat(ACCEL_WINDOW(1,2));
    BUFFER = array(strcmp(array(:,1), 'Steady State Buffer'),:);
    BUFFER = cell2mat(BUFFER(1,2));
    DOB = array(strcmp(array(:,1), 'Date of Birth (dd-MM-yyyy)'),:);
    DOB = string(DOB(1,2));
    AGE = array(strcmp(array(:,1), 'Age (dpf)'),:);
    AGE = cell2mat(AGE(1,2));
end

