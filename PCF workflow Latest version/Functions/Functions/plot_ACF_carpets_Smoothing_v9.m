function avgData_S_matrix = plot_ACF_carpets_Smoothing_v8(ACF_carpet)
    % Initialize variables
    numcols = 0; % Default number of columns
    
    % Get the filtered matrices
    filteredMatrices = filter_carpets(ACF_carpet);

    % Ask the user if they want to smooth the filtered carpets
    smoothChoice = questdlg('Do you want to smooth the filtered carpets?', 'Smoothing', 'Yes', 'No', 'No');

    % Initialize cell array for average data
    avgData_S = cell(size(filteredMatrices));

    % Check if the user wants to smooth
    if strcmp(smoothChoice, 'Yes')
        % Get smoothing parameters from the user
        prompt = {'Smoothing Type (1 for columns, 2 for surface):', 'Sigma:', 'Number of Columns:'};
        dlgtitle = 'Smoothing Parameters';
        dims = [1 50];
        definput = {'2', '1', '64'};
        params = inputdlg(prompt, dlgtitle, dims, definput);

        % Convert input parameters to numeric values
        type = str2double(params{1});
        sigma = str2double(params{2});
        numcols = str2double(params{3});

        % Check for valid input
        if isnan(type) || isnan(sigma) || isnan(numcols)
            uiwait(msgbox('Invalid input. Please enter numeric values for smoothing parameters.', 'Error', 'modal'));
            return;
        end

        % Process each filtered carpet
        for i = 1:numel(filteredMatrices)
            corrResult_S = filteredMatrices{i};

            % Apply smoothing to the filtered matrices
            corrResult_S = Smoothing(corrResult_S, type, sigma, numcols);

            % Truncate the result to the specified number of columns
            corrResult_S = corrResult_S(:, 1:numcols);

            % Plot the data in each cell
            figure;
            imagesc(corrResult_S);
            colormap(jet);
            colorbar();
            title(['Data in Cell ', num2str(i)]);

            % Calculate and store average data
            avgData_S{i} = mean(corrResult_S, 2);
        end
    else
        % Process each filtered carpet without smoothing
        for i = 1:numel(filteredMatrices)
            corrResult_S = filteredMatrices{i};

            % Plot the data in each cell without smoothing
            figure;
            imagesc(corrResult_S);
            colormap(jet);
            colorbar();
            title(['Data in Cell ', num2str(i)]);
        end
    end
    
    % Convert avgData_S to a matrix
    avgData_S_matrix = cell2mat(avgData_S);
end

function filteredMatrices = filter_carpets(ACF_carpet)
    % Initialize cell array to store filtered matrices
    filteredMatrices = cell(size(ACF_carpet));

    % Process each carpet
    for i = 1:numel(ACF_carpet)
        corrResult_S = ACF_carpet{i};

        % Find non-zero columns
        nonZeroColumns = any(corrResult_S ~= 0, 1);

        % Create a filtered matrix with non-zero columns
        filteredMatrices{i} = corrResult_S(:, nonZeroColumns);
    end
end
