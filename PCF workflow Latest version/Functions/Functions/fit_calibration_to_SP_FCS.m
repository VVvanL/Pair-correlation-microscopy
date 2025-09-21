function [w_table, f_cell] = fit_calibration_to_SP_FCS(SP_FCS, tdata)
    % Initialize output variables
    w_table = table();
    f_cell = cell(size(SP_FCS));

    % Loop through each cell in the SP_FCS cell array
    for i = 1:numel(SP_FCS)
        % Get the matrix from the cell
        ydata = SP_FCS{i};

        % Call FitCalibration function
        [w, f] = FitCalibration(tdata, ydata);

        % Calculate z
        z = w * 3;

        % Store w and z in table
        w_table_i = table(w, z);
        w_table = [w_table; w_table_i];

        % Store f in cell array
        f_cell{i} = f';
    end
end
