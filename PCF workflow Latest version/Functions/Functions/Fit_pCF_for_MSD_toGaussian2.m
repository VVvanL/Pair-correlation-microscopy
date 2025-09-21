function pCF_values = Fit_pCF_for_MSD_toGaussian(pCF_average_data, corrBins, MatrixSize)

num_matrices = numel(pCF_average_data);
Peak_x = NaN(MatrixSize, 1); % Initialize array to store peak positions

for i = 1:num_matrices
    % Fit Gaussian to each element in the cell array
    f = fit(log10(corrBins), pCF_average_data{i}, 'gauss1');
    
    % Generate y values
    f_values = f(log10(corrBins));
    
    % Plot and find peaks
    [~, x_pk] = plotFittedCurves(corrBins, pCF_average_data{i}, f_values);
    
    % Store peak position if not empty
    if ~isempty(x_pk)
        Peak_x(i) = x_pk;
    end
end

% If the matrix has fewer values than expected, fill the rest with NaNs
if numel(Peak_x) < MatrixSize
    num_missing_values = MatrixSize - numel(Peak_x);
    Peak_x = [Peak_x; NaN(num_missing_values, 1)];
end

% Reshape the matrix to have dimensions specified by MatrixSize
pCF_values = reshape(Peak_x, MatrixSize, []);

end
