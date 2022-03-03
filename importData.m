function [data] = importData(file,ANGLE_WINDOW)
%importData Imports angle data from a .txt file that is in a specific
%format, and smooths the data before storing it in a matrix.
%   Input:
%   file: .txt file
%   ANGLE_WINDOW: the number of frames in the moving average window.
%   
%   Output:
%   data: an N x 5 matrix containing smoothed, complete angle data.
%   Column 1: time (s); column 2: raw (unsmoothed) left eye angles (deg);
%   column 3: raw right eye angles (deg); column 4: smoothed left eye
%   angles (deg); column 5: smoothed right eye angles (deg)
    
    %COLUMN_RIGHT_EYE = input("What column is the right eye data in? Enter an integer. This is usually 2.");
    %COLUMN_LEFT_EYE = input("What column is the left eye data in? Enter an integer. This is usually 1.");
    %COLUMN_TIME = input("What column is the time data in? Enter an integer. This is usually 11.");
    COLUMN_RIGHT_EYE = 2;
    COLUMN_LEFT_EYE = 1;
    COLUMN_TIME = 11;
    
    %Prompt the user for the name of their animal of interest.
    prompt = {'Enter the name of your animal of interest.'};
    dlgtitle = 'Animal of Interest';
    dims = [1 100];
    output = inputdlg(prompt,dlgtitle,dims);    
    aname = output{1,1};
    %aname = "s3fb2";
    
    
    %Initialize a matrix for your data.
    data = zeros(1, 1);
    %Initialize the current row that will be filled in the data matrix.
    row = 1;
    
    %While you haven't reached the end of the file, check if the current
    %line contains useful data (i.e. contains eye angles of the desired fish).
    %If so, extract the elements in the desired
    %columns (right eye, left eye, and time) and put them in columns 1, 2,
    %and 3 at the appropriate row of the data file. Then, delete every
    %second row of the matrix, which is a duplicate (no difference between
    %time to three decimal points)
    while data == 0
        %Open the text file and get the first line.
        fileID = fopen(file, 'r');
        line = fgetl(fileID);
        while feof(fileID) == 0 
            if strcmp(line(1:5), '  <Da') == 1 && contains(line, strcat("aname=","""", aname, """"))
                line = extractBetween(line, '"', '"');
                column = 1;
                for j = [COLUMN_TIME, COLUMN_LEFT_EYE, COLUMN_RIGHT_EYE]
                    data(row, column) = str2double(line{j, 1});
                    column = column + 1;

                end
            row = row + 1;
            end
            line = fgetl(fileID);
        end
        if data == 0
            prompt = {'No data was extracted from the file. This likely happened because the animal name you entered was not found in the data file. Please enter a valid name.'};
            dlgtitle = 'Animal of Interest';
            dims = [1 100];
            output = inputdlg(prompt,dlgtitle,dims);    
            aname = output{1,1};
        end
    end
            

    %Make every second row in data (redundant data points) equal to zero.
    %The last row in the .txt file appears to be already unique.
    for i = 2:2:length(data)-1
        data(i, :) = [0];
    end
    %Delete all rows of zeroes.
    data_nonzeros = nonzeros(data(2:end, :));
    data = [data(1, :); reshape(data_nonzeros, [], 3)];

    %Normalize angle data.
    data(:, 2) = data(:, 2) + 90;
    data(:, 3) = data(:, 3) - 90;

    
    %Smooth using moving average. Some points on both
    %ends of the vector must be removed to avoid distortions.
    data_smoothed = movmean(data(:, 2:3), ANGLE_WINDOW);
    data(:, 4:5) = data_smoothed;
    top_remove = (ANGLE_WINDOW-1)/2;
    bottom_remove = length(data) - (ANGLE_WINDOW-1)/2 + 1;
    data(1:top_remove, 4:5) = [NaN];
    data(bottom_remove:end, 4:5) = [NaN];
    
end

