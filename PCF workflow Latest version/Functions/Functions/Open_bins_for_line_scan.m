function [data_cell_array, FileName] = Open_bins_for_line_scan(frame_size)
    [FileNames, PathName] = uigetfile('*.bin', 'Select binary files', 'MultiSelect', 'on');
    if ischar(FileNames) % If only one file is selected, convert it to a cell array
        FileNames = {FileNames};
    end
    
    num_files = numel(FileNames);
    data_cell_array = cell(1, num_files);
    FileName = cell(1, num_files); % Cell array to store file names
    
    for i = 1:num_files
        FileName{i} = FileNames{i}; % Store file name
        fileID = fopen(fullfile(PathName, FileNames{i}));
        data = fread(fileID, 'uint16');
        fclose(fileID);

        if rem(size(data, 1), frame_size^2) ~= 0
            data = data(3:size(data, 1), :);
        end

        len = frame_size;
        num = size(data, 1);
        n_frames = floor(num / frame_size);
        data = reshape(data, frame_size, n_frames);
        data_cell_array{i} = data';
    end
end
