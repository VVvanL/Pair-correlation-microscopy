function peak_table = Fit_pCF_for_MSD_toGaussian(pCF_average_data,distanceNames,corrBins)

fitted_pCF_data = struct();
peak_values_data = struct();
numTimePoints = 256;  

for i = 1:numel(distanceNames)
    avg_pCF_data = pCF_average_data.(distanceNames{i});
    fitted_pCF = zeros(numTimePoints, numel(avg_pCF_data));
    peak_values = zeros(numel(avg_pCF_data), 2);             % Initialize peak values array

    for j = 1:numel(avg_pCF_data)
        ydata = avg_pCF_data{j};  
        tdata = corrBins;

        f = fit(log10(tdata), ydata, 'gauss1');

        f_values = f(log10(tdata));
        fitted_pCF(:, j) = f_values;

        [y_pk, x_pk] = findpeaks(f_values, log10(tdata));

        % Check for missing or negative peaks
        if isempty(y_pk) || any(y_pk < 0)
            peak_values(j, :) = [NaN, NaN];
        else
            peak_values(j, :) = [y_pk, x_pk];
        end
    end

    fitted_pCF_data.(distanceNames{i}) = fitted_pCF;
    peak_values_data.(distanceNames{i}) = peak_values;
end

% Remove the 'pCF0' dataset from the structure
% We ony need pCF0 to get the diffusion coefficient from the ACF

fitted_pCF_data = rmfield(fitted_pCF_data, 'pCF0');

table_data = cell(numel(distanceNames) - 1, 2);  % Subtract 1 to exclude 'pCF0'

for i = 2:numel(distanceNames)  % Start from index 2 to skip 'pCF0'
    peak_values = peak_values_data.(distanceNames{i});

    if any(isnan(peak_values(:, 2)))
        peak_string = 'NaN';  % If NaN values exist, represent as 'NaN'
    else
        peak_string = sprintf('%f, ', peak_values(:, 2));
        peak_string = peak_string(1:end-2);  
    end

    table_data{i - 1, 1} = distanceNames{i};
    table_data{i - 1, 2} = peak_string;
end

peak_table = cell2table(table_data, 'VariableNames', {'Distance', 'PeakPositions'});

disp(peak_table);

end