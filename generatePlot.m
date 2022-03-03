function [fig,figure_name] = generatePlot(angle_x, angle_y, vel_x, vel_y, accel_x, accel_y, figure_filename, label)
%generatePlot Generate a plot of angle, velocity, and acceleration data.
%   Input:

    figure_name = strcat(figure_filename,label);
    fig = figure('Name', figure_name, 'NumberTitle', 'off');
    Angle = plot(angle_x, angle_y, 'Color', 'r');
    hold on
    Velocity = plot(vel_x, vel_y, 'Color', 'b');
    hold on
    Acceleration = plot(accel_x, accel_y, 'Color', 'm');
    title(figure_name)
    xlabel('Time (s)')
    legend('Angle (deg)', 'Velocity (deg/s)', 'Acceleration (deg/s^2)')
    ylim([-100, 100])
end

