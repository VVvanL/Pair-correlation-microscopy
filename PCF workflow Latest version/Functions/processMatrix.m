function av_edit = processMatrix(av)
    % Remove rows with NaN values
    av = av(~any(isnan(av), 2), :);

    % Remove rows where the first column has values greater than 0.23
    av = av(av(:, 1) <= 0.23, :);

    % Remove rows where the second column has values greater than 2.0
    av_edit = av(av(:, 2) <= 2.0, :);
end
