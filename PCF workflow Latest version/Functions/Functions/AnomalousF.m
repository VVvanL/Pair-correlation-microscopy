function [parameterTable2, fitted_ACFa] = AnomalousF(A_avg,corrBins,SEM_ACF_results)

%  Decide if you want to use SEM_ACF_results for weighted fitting 
prompt = 'Do you want to use SEM_ACF_results for weighted fitting? (yes/no): ';
userChoice = input(prompt, 's');

numDatasets = size(A_avg, 2);  

parameterTable2 = table('Size', [numDatasets, 3], ...
                        'VariableTypes', {'double', 'double', 'double'}, ...
                        'VariableNames', {'a', 'D', 'G'});

fitted_ACFa = cell(numDatasets, 1);

for i = 1:numDatasets   

    ydata = A_avg(:, i);  
    tdata = corrBins;

    if strcmpi(userChoice, 'yes')
        % Perform weighted fitting using the provided SEM
        SEM = SEM_ACF_results{i}; 
        [a, D, G, f] = Fitting_Anomalous_G0(tdata, ydata, SEM);
    else
        % Default to unweighted fitting
        [a, D, G, f] = Fitting_Anomalous_G0(tdata, ydata);
    end
    
    parameterTable2(i, :) = {a, D, G};
    fitted_ACFa{i} = f;
    plotRawDataAndFittedCurve(tdata, ydata, f, i);
end

end 