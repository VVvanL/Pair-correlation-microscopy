function plotACF(corrBins,ACF)


plot(log10(corrBins),ACF,'o','MarkerSize',3,'MarkerFaceColor','#000080','color','#000080')

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