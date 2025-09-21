function [parameterTable_pCF,fitted_pCFa] = OneCompPCF(pCF_mean,corrBins)

numDatasets = size(pCF_mean, 2);  

parameterTable_pCF = table('Size', [numDatasets, 2], ...
                        'VariableTypes', {'double', 'double'}, ...
                        'VariableNames', {'D', 'G'});

fitted_pCFa = cell(numDatasets, 1);

d = input('Enter the value of d: ');  
                                    
for i = 1:numDatasets   

    ydata = pCF_mean(:, i);  
    tdata = corrBins;
   
    [D, G, f] = Fitting_pCF(tdata, ydata, d);
    
    parameterTable_pCF(i, :) = {D, G};
    fitted_pCFa{i} = f;
    plotRawDataAndFittedCurve(tdata, ydata, f, i);
end

end