function [f_values,parameterTable] = ACF_fit(A_avg,corrBins,SEM_ACF_results)

% Handles for different fitting methods
fittingMethods = {
    @Fitting_G0,                      % One Component Model
    @Fitting_two_components           % Two Component Model
};

% Choose a fitting method
choice = menu('Select a fitting method:', 'One Component Model', 'Two Component Model');
selectedFittingMethod = fittingMethods{choice};

% Decide if you want to use SEM_ACF_results for weighted fitting 
prompt = 'Do you want to use SEM_ACF_results for weighted fitting? (yes/no): ';
userChoice = input(prompt, 's');

numDatasets = size(A_avg, 2); 
results = struct('D', [], 'G', [], 'E', [], 'H', [], 'f', []);

for i = 1:numDatasets   
    ydata = A_avg(:, i);  
    tdata = corrBins;

    if strcmpi(userChoice, 'yes')
        % Perform weighted fitting using the provided SEM
        SEM = SEM_ACF_results{i}; 
        
        try
            [D, G, E, H, f] = selectedFittingMethod(tdata, ydata, SEM);
        catch
            try
                [D, G, f] = selectedFittingMethod(tdata, ydata, SEM);
                E = NaN;
                H = NaN;
            catch
                [D, G, f] = selectedFittingMethod(tdata, ydata, SEM);
                E = NaN;
                H = NaN;
            end
        end
    else
        % Default to unweighted fitting
        try
            [D, G, E, H, f] = selectedFittingMethod(tdata, ydata);
        catch
            try
                [D, G, f] = selectedFittingMethod(tdata, ydata);
                E = NaN;
                H = NaN;
            catch
                [D, G, f] = selectedFittingMethod(tdata, ydata);
                E = NaN;
                H = NaN;
            end
        end
    end

    f_values{i} = f;

    results(i).D = D;
    results(i).G = G;
    results(i).E = E;
    results(i).H = H;
    
    plotRawDataAndFittedCurve(tdata, ydata, f, i);
end

parameterTable = struct2table(results,'AsArray', true);
parameterTable = parameterTable(:, {'D', 'G', 'E', 'H', 'f'});



end
