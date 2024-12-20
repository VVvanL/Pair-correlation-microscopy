%% Julissa Sanchez Velasquez, Ashleigh Solano, Elizabeth Hinde - March,2024
%__________________________________________________________________________
% Calculate_and_Fit_MSD.m - Code for calculating and fitting the mean square displacment (MSD)
% Last update: 02/2024
%__________________________________________________________________________
%
% INPUT
%
% 'cropped_images'          Cell array obtained using the code 'PCF_workflow.m'
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

%% As Input this code will need the 'cropped_images' files generated from the 'PCF_workflow.m code'

%% Step 2. Calculate pCF at a varied distance, stored the data into a structure array

mfirstCol    = 1;        % First column to be analyzed
mlastCol     = 64;       % Last column to be analyzed
sampleFreq   = 616;      % Change the sampling frequncy if necessary 
ReverseOrder = false;    

[distanceNames,corrBins,pCF_average_data] = calculate_pCF_variedDist(cropped_images,mfirstCol,mlastCol,sampleFreq,ReverseOrder);


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

pCF_distance = pCF_average_data.pCF32;
MatrixSize   = size(cropped_images,1);

pCF32_values  = Fit_pCF_for_MSD_toGaussian2(pCF_distance, corrBins, MatrixSize);


%% Step 5. Create a table with the peaks values  

All_peaks = horzcat(pCF4_values, pCF8_values,pCF12_values,pCF16_values,pCF20_values,pCF24_values,pCF28_values, ...
    pCF32_values);

% Transform values from a log scale to a linear scale
transformation_function = @(x) 10^x;

transformed_data = arrayfun(@(x) transformation_function(x), All_peaks, 'UniformOutput', false);
nan_indices = isnan(All_peaks);
transformed_data(nan_indices) = {NaN};
All_peaks_transformed = cell2mat(transformed_data); 
disp(All_peaks_transformed);


%% Step 6. Calculate MSD

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


%% Step 7. Import the manually curated MSD data (.csv)

%  READ: This code assumes that time is stored in the first column and MSD is stored in the second column

%Open CSV file
[fileName, pathName] = uigetfile('*.csv');
MSD_data = csvread(fullfile(pathName, fileName));

time=MSD_data(:,1);
MSD_values=MSD_data(:,2);


%% OPTIONAL: work with the generated data without modifications (not need to import)

MSD_raw = mergeColumns(All_peaks_transformed, MSD_values);
MSD_edit = processMatrix(MSD_raw);
time=MSD_edit(:,1);
MSD_values=MSD_edit(:,2);


%% Plot raw data

scatter(time,MSD_values,25,"filled",'color','#2D5F8A');


%% Step 8. Fit MSD data

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

%% Step 9. Plot Raw and fitted data

plot(time,MSD_values,'o','MarkerSize',2.5,'MarkerFaceColor','#44bbfd','color','#44bbfd');
hold on
plot(time,f,'LineWidth',2,'Color','#ff3e5e');
hold off
