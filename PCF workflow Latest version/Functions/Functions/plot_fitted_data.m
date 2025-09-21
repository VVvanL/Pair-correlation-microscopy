function plot_fitted_data(SP_FCS, fitted_data, corrBins)
    % Loop through each cell in SP_FCS and fitted_data
    for i = 1:numel(SP_FCS)
        figure;
        % Plot the data for the current cell
        plot(log10(corrBins), SP_FCS{i}, 'o', 'MarkerSize', 2, 'MarkerFaceColor', '#171717', 'color', '#171717');
        hold on;
        plot(log10(corrBins), fitted_data{i}, 'LineWidth', 2.5, 'Color', [1 0 0]);
        hold off;

        % Customize plot labels and legend
        xlabel('log time(s)');
        legend('SP FCS', 'Fitted Data');

        % Add title
        title(['Dataset ', num2str(i)]);

    end
end
