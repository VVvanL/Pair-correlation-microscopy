function peakTable = plotGaussian(fitted_pCF,pCF_mean,corrBins)

numColumns = size(fitted_pCF, 2);  
peakTable = table();
for i = 1:numColumns
    f = fitted_pCF(:, i);  
    tdata = corrBins;        
    figure;  
    [y_pk, x_pk] = plotFittedCurves(tdata, pCF_mean(:, i), f);
    
    peakTable = [peakTable; table(x_pk, y_pk)];
end

end
