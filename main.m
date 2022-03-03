%Clear the workspace to avoid rewriting issues
clear

%%%Choose files to process and folders for output.
%Data (text) filename and path
f = msgbox("Please select the data test file to run.")
waitfor(f);
[filename,path] = uigetfile;
% filename = '20200721-173548.txt';
% path = 'C:\Users\Sophie Gobeil\Documents\McFarlane Lab\Data\OKR\20-07-21\';
file = strcat(path,filename);

%Future saved excel results filename and path
f = msgbox("Please open the folder where you would like to save the outputted Excel file and figures.")
waitfor(f);
saved_path = uigetdir;
saved_path = strcat(saved_path,'\');
saved_filename = erase(filename, '.txt');
saved_filename = strcat(saved_filename,'.xlsx');
%saved_path = 'C:\Users\Sophie Gobeil\Documents\McFarlane Lab\Data\OKR\20-07-14';
saved_file = strcat(saved_path,saved_filename);

%Future saved figures filename and path
figure_filename = erase(filename, '.txt');
figure_path = saved_path;
figure_file = strcat(figure_path,figure_filename);

%Excel input info filename and path
f = msgbox("Please open the Excel file with the input info.")
waitfor(f);
[input_filename,input_path] = uigetfile;
%input_path = 'C:\Users\Sophie Gobeil\Documents\McFarlane Lab\Data\OKR\OKR Data Processing\OKRDataProcessing\Data\';
%input_filename = 'InputInfo.xlsx';
input_file = strcat(input_path,input_filename);

%%%Import information from the Info excel file into variables 
[STIM_DIREC,GENOTYPE,DATE_RECORD,BAND_NUM,STIM_VEL,FRAME_RATE,ANGLE_WINDOW,...
    VEL_WINDOW,ACCEL_WINDOW,BUFFER,DOB,AGE] = importInfo(input_file);

%%%Import the eye position data from a .txt file (.phi must be converted to
%%%.txt) and smooth it using a moving average
data = importData(file,ANGLE_WINDOW); 


%%%Preview the angle data and select usable ranges.
%Plot the data (smoothed)
figure_name = strcat(figure_filename, ' Raw Angle Data');
fig = figure('Name', figure_name, 'NumberTitle', 'off');
Left = plot(data(:,1), data(:,4), 'Color', 'r');
hold on
Right = plot(data(:,1), data(:,5), 'Color', 'k');
title(figure_name)
xlabel('Time (s)')
ylabel('Angle (deg)')
legend('Left eye', 'Right eye')
ylim([-100, 100])
if exist(strcat(figure_path,figure_name,'.png'), 'file') == 2
    delete(strcat(figure_path,figure_name,'.png'));
end
saveas(fig, strcat(figure_path, figure_name), 'png')
movegui('west');

%Prompt the user to enter the usable ranges for left and right eyes (range
%where an OKR is seen)
prompt = {'Start time (s)', 'End time (s)'};
dlgtitle = 'OKR Usable Range Time Brackets';
dims = [1 100; 1 100];
output = inputdlg(prompt,dlgtitle,dims);    
start_time = str2double(output{1,1});
end_time = str2double(output{2,1});

%Close the raw angle data figure
close

%Select from the angle data matrix only the usable ranges (in other
%words, the range containing a recognizable OKR)
data = usableRange(start_time,end_time,data,FRAME_RATE);

%%%Calculate instantaneous angular velocity and acceleration (both eyes)
%%%from the smoothed angle data, and smooth them in turn.
[inst_ang_vel, inst_ang_acc] = angularVelAccel(data,VEL_WINDOW,ACCEL_WINDOW);

%%%Calculate the average velocity from the smoothed instantaneous angular
%%%velocity.
[left_avg_ang_vel, right_avg_ang_vel] = calculateAvgVel(inst_ang_vel(:, 4:5));

%%%Calculate the instantaneous gain at each time point.
inst_ang_vel(:,6:7) = calculateInstGain(inst_ang_vel(:,4:5), STIM_VEL);

%%%Find the time points that bracket the slow phases (different for each
%%%eye)
%Isolate the time brackets for the left eye slow phase using the angle
%data. Prompt user for a ratio to use to calculate the prominence threshold
%of the local minima and maxima, then show them the resulting graph.
%Continue prompting the user and refreshing the graph until they state that they
%are submitting their final answer.
repeat = 'no';
while strcmp(repeat,'no')
    [slow_phase_timebrackets_left, repeat] = slowPhaseBrackets(data(:, [1,4]), STIM_DIREC, "Left");
end
%Close the left eye min max figure
close
%Isolate the time brackets for the right eye slow phase using the angle data
repeat = 'no';
while strcmp(repeat,'no')
    [slow_phase_timebrackets_right, repeat] = slowPhaseBrackets(data(:, [1,5]), STIM_DIREC, "Right");
end
%Close the right eye min max figure
close

%%%Collect all slow phase data in one matrix. 
% slow_phase_matrix column 1:
% left eye time vector (s); column 2: right eye time vector (s); column 3:
% left eye angles (deg); column 4: right eye angles (deg); column 5: left
% eye instantaneous velocity (deg/s); column 6: right eye instantaneous
% velocity (deg/s); column7: left eye steady state instantaneous velocity;
% column 8: right eye steady state instantaneous velocity; 
% column 9: left eye instantaneous acceleration
% (deg/s^2); column 10: right eye instantaenous acceleration (deg/s^2)

%Create a matrix with continuous time for the fused slow phase data segments.
temp_time_left = continuousTime(slow_phase_timebrackets_left, data(:,1), FRAME_RATE);
temp_time_right = continuousTime(slow_phase_timebrackets_right, data(:,1), FRAME_RATE);
%Initialize a matrix using the number of rows of the longest time vector.
%Make sure to include the correct number of columns too.
if length(temp_time_left) >= length(temp_time_right)
    slow_phase_matrix(1:length(temp_time_left),1:8) = NaN;
else 
    slow_phase_matrix(1:length(temp_time_right),1:8) = NaN;
end
%Add the continuous time vectors for each eye
slow_phase_matrix(1:length(temp_time_left),1) = temp_time_left;
slow_phase_matrix(1:length(temp_time_right),2) = temp_time_right;
%Left and right eye angles
slow_phase_matrix(1:length(temp_time_left),3) = slowPhaseFilter(data(:,[1,4]),slow_phase_timebrackets_left);
slow_phase_matrix(1:length(temp_time_right),4) = slowPhaseFilter(data(:,[1,5]),slow_phase_timebrackets_right);
%Left and right eye instantaneous velocity
slow_phase_matrix(1:length(temp_time_left),5) = slowPhaseFilter(inst_ang_vel(:,[1,4]),slow_phase_timebrackets_left);
slow_phase_matrix(1:length(temp_time_right),6) = slowPhaseFilter(inst_ang_vel(:,[1,5]),slow_phase_timebrackets_right);
%Left and right eye steady state instantaneous velocity
slow_phase_matrix(1:length(temp_time_left),7) = steadyStateSlowPhase(inst_ang_vel(:,[1,4]),slow_phase_timebrackets_left, BUFFER);
slow_phase_matrix(1:length(temp_time_right),8) = steadyStateSlowPhase(inst_ang_vel(:,[1,5]),slow_phase_timebrackets_right, BUFFER);
%Left and right eye instantaneous acceleration
slow_phase_matrix(1:length(temp_time_left),9) = slowPhaseFilter(inst_ang_acc(:,[1,4]),slow_phase_timebrackets_left);
slow_phase_matrix(1:length(temp_time_right),10) = slowPhaseFilter(inst_ang_acc(:,[1,5]),slow_phase_timebrackets_right);

%%%Calculate the average slow phase steady state angular velocity.
[slow_avg_ang_vel_left, slow_avg_ang_vel_right] = calculateAvgVel(slow_phase_matrix(:, 7:8));

%%%Calculate the average slow phase gain.
slow_avg_gain_left = slow_avg_ang_vel_left / STIM_VEL;
slow_avg_gain_right = slow_avg_ang_vel_right / STIM_VEL;

%%%Calculate the average ocular range.
[avg_ocular_range_left] = calculateAvgOcRng(data(:,[1,4]),slow_phase_timebrackets_left);
[avg_ocular_range_right] = calculateAvgOcRng(data(:,[1,5]),slow_phase_timebrackets_right);



[fig,figure_name] = generatePlot(data(:,1), data(:,4), inst_ang_vel(:,1), inst_ang_vel(:,4), ...
    inst_ang_acc(:,1), inst_ang_acc(:,4), figure_filename, ' Left Smoothed Angle, Velocity, and Acceleration');
if exist(strcat(figure_path,figure_name,'.png'), 'file') == 2
        delete(strcat(figure_path,figure_name,'.png'));
end
saveas(fig, strcat(figure_path,figure_name), 'png')
%Close the figure
close

[fig,figure_name] = generatePlot(slow_phase_matrix(:,1), slow_phase_matrix(:,3), slow_phase_matrix(:,1), slow_phase_matrix(:,5), ...
    slow_phase_matrix(:,1), slow_phase_matrix(:,9), figure_filename, ' Slow Phase Left Eye Data');
if exist(strcat(figure_path,figure_name,'.png'), 'file') == 2
        delete(strcat(figure_path,figure_name,'.png'));
end
saveas(fig, strcat(figure_path,figure_name), 'png')
%Close the figure
%close

[fig,figure_name] = generatePlot(slow_phase_matrix(:,1), slow_phase_matrix(:,3), slow_phase_matrix(:,1), slow_phase_matrix(:,7), ...
    slow_phase_matrix(:,1), slow_phase_matrix(:,9), figure_filename, ' Slow Phase Left Eye Data, Steady State Velocity');
if exist(strcat(figure_path,figure_name,'.png'), 'file') == 2
        delete(strcat(figure_path,figure_name,'.png'));
end
saveas(fig, strcat(figure_path,figure_name), 'png')
%Close the figure
%close

[fig,figure_name] = generatePlot(data(:,1), data(:,5), inst_ang_vel(:,1), inst_ang_vel(:,5), ...
    inst_ang_acc(:,1), inst_ang_acc(:,5), figure_filename, ' Right Smoothed Angle, Velocity, and Acceleration');
if exist(strcat(figure_path,figure_name,'.png'), 'file') == 2
        delete(strcat(figure_path,figure_name,'.png'));
end
saveas(fig, strcat(figure_path,figure_name), 'png')
%Close the figure
close

[fig,figure_name] = generatePlot(slow_phase_matrix(:,2), slow_phase_matrix(:,4), slow_phase_matrix(:,2), slow_phase_matrix(:,6), ...
    slow_phase_matrix(:,2), slow_phase_matrix(:,10), figure_filename, ' Slow Phase Right Eye Data');
if exist(strcat(figure_path,figure_name,'.png'), 'file') == 2
        delete(strcat(figure_path,figure_name,'.png'));
end
saveas(fig, strcat(figure_path,figure_name), 'png')
%Close the figure
%close

[fig,figure_name] = generatePlot(slow_phase_matrix(:,2), slow_phase_matrix(:,4), slow_phase_matrix(:,2), slow_phase_matrix(:,8), ...
    slow_phase_matrix(:,2), slow_phase_matrix(:,10), figure_filename, ' Slow Phase Right Eye Data, Steady State Velocity');
if exist(strcat(figure_path,figure_name,'.png'), 'file') == 2
        delete(strcat(figure_path,figure_name,'.png'));
end
saveas(fig, strcat(figure_path,figure_name), 'png')
%Close the figure
%close

figure_name = strcat(figure_filename, ' Slow Phase Angle Data');
fig = figure('Name', figure_name, 'NumberTitle', 'off');
Left = plot(slow_phase_matrix(:,1), slow_phase_matrix(:,3), 'Color', 'r');
hold on
Right = plot(slow_phase_matrix(:,2), slow_phase_matrix(:,4), 'Color', 'k');
title(figure_name)
xlabel('Time (s)')
ylabel('Angle (deg)')
legend('Left eye', 'Right eye')
ylim([-50, 50])
if exist(strcat(figure_path,figure_name,'.png'), 'file') == 2
    delete(strcat(figure_path,figure_name,'.png'));
end
    saveas(fig, strcat(figure_path, figure_name), 'png')
%Close the figure
close

range = strcat(num2str(start_time), '-',num2str(end_time));
date_proc = datetime('today');
summary = {DATE_RECORD; date_proc; GENOTYPE; DOB; AGE; STIM_VEL; STIM_DIREC; BAND_NUM; ANGLE_WINDOW; VEL_WINDOW;...
    ACCEL_WINDOW; BUFFER; range; slow_avg_ang_vel_left; slow_avg_ang_vel_right; ...
    slow_avg_gain_left; slow_avg_gain_right; avg_ocular_range_left; avg_ocular_range_right};
writeFile(data, inst_ang_vel, inst_ang_acc, slow_phase_matrix, summary, saved_file)

