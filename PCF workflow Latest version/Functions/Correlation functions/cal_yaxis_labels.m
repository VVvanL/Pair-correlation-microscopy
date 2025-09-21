function [ytickvec, yticklabel] = cal_yaxis_labels(isLog, corrBins)
% calculate ytick labels to display

if(isLog)
    targets = [0.001, 0.01, 0.1, 1, 10];
    values = targets; % * sampleFreq;
    %values = values(values <= ntimes );
    targets = targets(1:numel(values));
    ytickvec = zeros(size(values));
    for ii = 1 : numel(values)
        v = values(ii);
        jj = 1;
        while(corrBins(jj) < v)
            jj = jj + 1;
        end
        ytickvec(ii) = jj;
    end
    yticklabel = strread(num2str(targets),'%s');
    
else
    ytickvec = 1:40:length(corrBins);
    values = corrBins(ytickvec)';
    yticklabel = strread(num2str(values),'%s');
end