function fitted_pCF = GaussianPCF(pCF_mean,corrBins)

numColumns = size(pCF_mean, 2);  
numTimePoints = 256;  

% Create a matrix to store fitted pCF values
fitted_pCF = zeros(numTimePoints, numColumns);

% Choose the fitting method 
fitType = input('Enter the fit type (e.g., gauss1 or gauss2) [default: gauss1]: ', 's');

if isempty(fitType)
    fitType = 'gauss1';
end

for i = 1:numColumns
    ydata = pCF_mean(:, i);  
    tdata = corrBins;        
    f = fit(log10(tdata), ydata, fitType);
    f_values = f(log10(tdata));
    fitted_pCF(:, i) = f_values;
end

end