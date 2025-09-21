function plotRawDataAndFittedCurve(tdata, ydata, f, i)
    figure;
    subplot(4, 1, 1:3)
    semilogx(tdata, ydata, 'o', 'MarkerSize', 2, 'MarkerFaceColor', '#44bbfd', 'color', '#44bbfd');
    hold on;
    semilogx(tdata, f, 'LineWidth', 3, 'Color', '#ff3e5e');
    hold off;
    title(['Dataset ', num2str(i)]);
    legend('Raw Data', 'Fitted Curve');
    xlabel('Time');
    ylabel('Value');
    
    subplot(4, 1, 4);
    plot(ydata - f, 'LineWidth', 1, 'Color', '#44bbfd');
    line(xlim(), [0, 0], 'LineWidth', 0.5, 'Color', 'k');
    xlabel('Time');
    ylabel('Residuals');

    % Get the current x-axis tick values
xticks = get(gca, 'XTick');

% Format the tick labels with 'e^' and '1' for negative values
xlabels = cell(size(xticks));
for i = 1:length(xticks)
    if xticks(i) < 0
        xlabels{i} = sprintf('1e%d', round(xticks(i)));
    else
        xlabels{i} = sprintf('%.0f', 10^xticks(i));
    end
end

% Set the modified x-axis tick labels
set(gca, 'XTickLabel', xlabels)

% Add a label to the x-axis
xlabel('x')
end
