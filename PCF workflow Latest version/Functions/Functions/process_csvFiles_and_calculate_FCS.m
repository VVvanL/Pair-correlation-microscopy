function [PCF_dim, fitted_data] = process_csvFiles_and_calculate_FCS(data_cell_array, sampleFreq)
    % Initialize output variables
    PCF_dim = table();
    fitted_data = cell(size(data_cell_array));

    % Loop through each cell in the data cell array
    for i = 1:numel(data_cell_array)
        SP = data_cell_array{i}; % Get the matrix from the cell

        % Reshape the data into a cell array of intensity carpets
        Images = {SP};

        % Call SinglePointFCS function
        [corrBins, SP_FCS, w, f, z] = SinglePointFCS(Images, sampleFreq);
  
        % Store f in cell array
        fitted_data{i} = f';

        % Append w and z to table
        table_wz_i = table(w, z);
        PCF_dim = [PCF_dim; table_wz_i];

    end
end