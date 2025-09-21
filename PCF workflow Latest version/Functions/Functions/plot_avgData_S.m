function plot_avgData_S(avgData_S, corrBins)
    % Check if the input is a matrix
    if ~ismatrix(avgData_S)
        error('Input must be a matrix.');
    end

    % Determine the number of cells (columns) in the matrix
    numCells = size(avgData_S, 2);

    % Process each column in avgData_S
    for i = 1:numCells
        % Plot log10(corrBins, avgData_S(:, i))
        figure;
        plot(log10(corrBins), avgData_S(:, i),'o','MarkerSize',3,'MarkerFaceColor','#000080','color','#000080');
        xlabel('Log time');
        ylabel('ACF');
        title(['Cell ', num2str(i)]);
    end
end
