%% Julissa Sanchez Velasquez, Ashleigh Solano, Elizabeth Hinde - March,2024
%__________________________________________________________________________
% Confocal_Calibration.m - Code for performing and fitting the ACF to get the PSF dimensions 
% Last update: 3/2024
%__________________________________________________________________________
%
% OUTPUT
%
% corrBins:         Correlation time
% SP_FCS:           Average ACF from single point FCS data
% fitted_data:      Matrix contained fitted data for each single point FCS
% PCF_dim:          Table containing the PCF dimensions obtaines from each dataset


%% Step 1. Define the folder with all MATLAB functions
selected_folder = uigetdir('Select the folder containing the functions');
selected_path = genpath(selected_folder);
addpath(selected_path);

%% Step 2. Open CSV file
%  These lines of code will open .csv files and delete the first two columns since only 
%  the third column contains the fluctuations in fluorescence intensity.

[SP, fileName, pathName] = open_csvFiles();


%% Step 3. Calculate FCS and get fitting parameters
 %  The sampling frequency is set for a pixel dwell time of 4 μs (250,000 cycles per second), change this value accordingly. 

[corrBins, SP_FCS] = SinglePointFCS(SP,250000);
[PCF_dim, fitted_data] = fit_calibration_to_SP_FCS(SP_FCS, corrBins);
plot_fitted_data(SP_FCS, fitted_data, corrBins)
