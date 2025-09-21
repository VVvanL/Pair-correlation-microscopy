function [data_cell_array, file_names, folder_path] = open_csvFiles()
    % Ask the user to select multiple CSV files
    [file_paths, folder_path] = uigetfile('*.csv', 'Select CSV files', 'MultiSelect', 'on');
    if isequal(file_paths, 0)
        disp('No files selected. Exiting...');
        data_cell_array = [];
        file_names = [];
        return;
    end

    % If only one file is selected, convert it to a cell array
    if ~iscell(file_paths)
        file_paths = {file_paths};
    end

    % Initialize cell arrays to store the second column of each CSV file
    num_files = length(file_paths);
    data_cell_array = cell(num_files, 1);
    file_names = cell(num_files, 1);

    % Loop through each selected CSV file and extract the second column
    for i = 1:num_files
        file_path = fullfile(folder_path, file_paths{i});
        data = readmatrix(file_path); % Read the CSV file
        % Delete the first two columns
        data(:,1:2) = [];
        data_cell_array{i} = data; % Store modified data in cell array
        [~, file_names{i}, ~] = fileparts(file_paths{i}); % Get file name
    end

    % Display the content of the cell array
    disp('Data stored in cell array (with first two columns deleted):');
    disp(data_cell_array);
end
