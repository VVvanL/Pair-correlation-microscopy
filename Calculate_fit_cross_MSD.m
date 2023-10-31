%% Julissa Sanchez Velasquez, Ashleigh Solano, Elizabeth Hinde - Oct 20,2023
%__________________________________________________________________________
% Calculate_and_Fit_cross_MSD.m - Code for calculating and fitting the mean square displacment (MSD)
% Last update: 10/2023
%__________________________________________________________________________
%
% INPUT
%
% 'cropped_images_CH1'      Cell array obtained using the code 'crossPCF_workflow.m'
% 'cropped_images_CH2'      Cell array obtained using the code 'crossPCF_workflow.m'
% 
% OUTPUT
%
% pCF_average_data:         Structure array containing average pCF data calculated at distances (in pixels) of
%                           0, 4, 8, 12, 16, 20, 24, 28, 32
% D_ACF:                    Matrix containing the diffusion coefficient obtained from fitting the ACF (pCF0)
%                           units: um2/s
% All_peaks_transformed:    Table containing the translocation times for each sample at each pCF distance
% MSD:                      Table containing MSD values
% D:                        Diffusion coefficient from fitting the MSD to a model function 
%                           units: um2/s
% f:                        Fitted MSD
% tc                        Time spend inside the confinement zone (s) if the MSD was fitted to either a transient confined or confined model
% L:                        Size of the confinement zone (um) if the MSD was fitted to either a transient confined or confined model
        
%% Step 1. Define the folder with all MATLAB functions

selected_folder = uigetdir('Select the folder containing the functions');
selected_path = genpath(selected_folder);
addpath(selected_path);

%% As Input this code will need 'cropped_images_CH1' and 'cropped_images_CH2' generated from the 'PCF_workflow.m code'

%% Step 2. Calculate pCF at a varied distance, stored the data into a structure array

mfirstCol = 1;        % First column to be analyzed
mlastCol  = 64;       % Last column to be analyzed
sampleFreq = 616;     % Change the sampling frequncy if necessary 
ReverseOrder = false; 

% Define the radii to calculate pCF for and corresponding names
radii = [0, 4, 8, 12, 16, 20, 24, 28, 32];
numRadii = numel(radii);
distanceNames = {'pCF0', 'pCF4', 'pCF8', 'pCF12', 'pCF16', 'pCF20', 'pCF24', 'pCF28', 'pCF32'};
numDatasets = numel(cropped_images_CH1);
pCF_average_data = cell(numRadii, 1);

% Loop through each radius
for r = 1:numRadii
    radius = radii(r);
    pCF_data = cell(numDatasets, 1);

    % Loop through each dataset
    for d = 1:numDatasets
        carpet1 = cropped_images_CH1{d};
        carpet2 = cropped_images_CH2{d};

        [corrResult,corrBins]=crossPCF_columns(carpet1,carpet2,radius,mfirstCol,mlastCol,sampleFreq,ReverseOrder);

        avg_corrResult = mean(corrResult, 2);
        pCF_data{d} = avg_corrResult;
    end
    pCF_average_data{r} = pCF_data;
end

pCF_average_data = cell2struct(pCF_average_data, distanceNames, 1);


%% Step 3. Get Diffusion coefficient from ACF

avg_pCF_data = pCF_average_data.pCF0;
D_values = cell(size(avg_pCF_data));

for i = 1:numel(avg_pCF_data)
    % Fit the data using the Fitting_two_components function
    [D, ~, ~, ~, ~] = Fitting_two_components(corrBins, avg_pCF_data{i});
    D_values{i} = D;
end

D_ACF = cell2mat(D_values);
D_ACF = D_ACF / 1e6;          %To obtain D values in um^2/s


%% Step 4. Fit pCF to a Gaussian and get peak table

fitted_pCF_data = struct();
peak_values_data = struct();
numTimePoints = 256;  

for i = 1:numel(distanceNames)
    avg_pCF_data = pCF_average_data.(distanceNames{i});
    fitted_pCF = zeros(numTimePoints, numel(avg_pCF_data));
    peak_values = zeros(numel(avg_pCF_data), 2);             % Initialize peak values array

    for j = 1:numel(avg_pCF_data)
        ydata = avg_pCF_data{j};  
        tdata = corrBins;

        f = fit(log10(tdata), ydata, 'gauss1');

        f_values = f(log10(tdata));
        fitted_pCF(:, j) = f_values;

        [y_pk, x_pk] = findpeaks(f_values, log10(tdata));

        % Check for missing or negative peaks
        if isempty(y_pk) || any(y_pk < 0)
            peak_values(j, :) = [NaN, NaN];
        else
            peak_values(j, :) = [y_pk, x_pk];
        end
    end

    fitted_pCF_data.(distanceNames{i}) = fitted_pCF;
    peak_values_data.(distanceNames{i}) = peak_values;
end

% Remove the 'pCF0' dataset from the structure
% We ony need pCF0 to get the diffusion coefficient from the ACF

fitted_pCF_data = rmfield(fitted_pCF_data, 'pCF0');

table_data = cell(numel(distanceNames) - 1, 2);  % Subtract 1 to exclude 'pCF0'

for i = 2:numel(distanceNames)  % Start from index 2 to skip 'pCF0'
    peak_values = peak_values_data.(distanceNames{i});

    if any(isnan(peak_values(:, 2)))
        peak_string = 'NaN';  % If NaN values exist, represent as 'NaN'
    else
        peak_string = sprintf('%f, ', peak_values(:, 2));
        peak_string = peak_string(1:end-2);  
    end

    table_data{i - 1, 1} = distanceNames{i};
    table_data{i - 1, 2} = peak_string;
end

peak_table = cell2table(table_data, 'VariableNames', {'Distance', 'PeakPositions'});

disp(peak_table);


%% Step 5. Extract peak values

targetDistances = {'pCF4', 'pCF8', 'pCF12', 'pCF16', 'pCF20', 'pCF24', 'pCF28', 'pCF32'};
all_pCF_values = cell(length(targetDistances), 1);

for i = 1:length(targetDistances)
    targetDistance = targetDistances{i};
    rowIndex = find(strcmp(peak_table.Distance, targetDistance));
    peak_string = peak_table.PeakPositions{rowIndex};
    
    if strcmp(peak_string, 'NaN')
        extracted_values = [];
    else
        peak_values = str2double(regexp(peak_string, '[-+]?\d*\.?\d+', 'match'));
        extracted_values = peak_values(:);
    end

    all_pCF_values{i} = extracted_values;

    % Create individual variables in the workspace (e.g., pCF4_values, pCF8_values)
    assignin('base', [targetDistance '_values'], extracted_values);
end

%% Before running Step 6. Be aware that if one of the 'pCF_values' matrix is empty (e.g., pCF4_values) you need add 'NaN' values to the matrix to keep the table 'All_peaks_transformed' in this order:
% 'pCF4', 'pCF8', 'pCF12', 'pCF16', 'pCF20', 'pCF24', 'pCF28', 'pCF32'


%% Step 6. Create a table with the peaks values  

All_peaks = horzcat(pCF4_values, pCF8_values,pCF12_values,pCF16_values,pCF20_values,pCF24_values,pCF28_values, ...
    pCF32_values);

% Transform values from a log scale to a linear scale
transformation_function = @(x) 10^x;

transformed_data = arrayfun(@(x) transformation_function(x), All_peaks, 'UniformOutput', false);
nan_indices = isnan(All_peaks);
transformed_data(nan_indices) = {NaN};
All_peaks_transformed = cell2mat(transformed_data); 
disp(All_peaks_transformed);


%% Step 7. Calculate MSD

MSD_values = zeros(size(All_peaks_transformed));

for col = 1:size(All_peaks_transformed, 2)
    % Calculate MSD based on the formula for each non-NaN value in the column
    MSD_values(:, col) = 2 * 3 * D_ACF .* All_peaks_transformed(:, col);
end

MSD = array2table(MSD_values);
disp(MSD);

%% READ

%  After running Step 7, export the MSD and peak tables ('MSD'  and  'All_peaks_transformed') into an editable spreadsheet such as Excel. 
%  Remove those values with unreasonable time values (i.e., MSD with peak values with long times (e.g., 0.5 or 1 s)). 
%  Subsequently, assign each peak to its respective MSD to create a two-column matrix (time, MSD). 
%  Import the new file (.csv) into MATLAB to proceed with the fitting.

%% Step 8. Import the manually curated MSD data (.csv)

%  READ: This code assumes that time is stored in the first column and MSD is stored in the second column

%Open CSV file
[fileName, pathName] = uigetfile('*.csv');
MSD_data = csvread(fullfile(pathName, fileName));

time=MSD_data(:,1);
MSD_values=MSD_data(:,2);

%% Step 9. Fit MSD data

% Prompt the user to select a fitting method
fitting_methods = {'MSD_isotropic', 'MSD_transt_confined', 'MSD_confined'};
choice = menu('Select a fitting method:', fitting_methods);

if choice == 0
    disp('No fitting method selected. Exiting.');
else
  
    msd = MSD_values;  % Load your MSD data
    
    selected_method = fitting_methods{choice};
    
    switch selected_method
        case 'MSD_isotropic'
            [D, f] = MSD_isotropic(time, msd);
            disp(['D = ' num2str(D)]);
        case 'MSD_transt_confined'
            [D, tc, L, f] = MSD_transt_confined(time, msd);
            disp(['D = ' num2str(D)]);
            disp(['tc = ' num2str(tc)]);
            disp(['L = ' num2str(L)]);
        case 'MSD_confined'
            [tc, L, f] = MSD_confined(time, msd);
            disp(['tc = ' num2str(tc)]);
            disp(['L = ' num2str(L)]);
    end
end
