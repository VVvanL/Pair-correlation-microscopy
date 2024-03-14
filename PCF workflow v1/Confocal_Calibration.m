%% Julissa Sanchez Velasquez, Ashleigh Solano, Elizabeth Hinde - Oct 20,2023
%__________________________________________________________________________
% Confocal_Calibration.m - Code for performing and fitting the ACF to get the PSF dimensions 
% Last update: 10/2023
%__________________________________________________________________________
%
% OUTPUT
%
% corrBins:         Correlation time
% SP_FCS:           Average ACF from single point FCS data
% w:                Radius in the focal plane e^(-2)
% f:                Fitted ACF data 
% z:                Axial e^(-2) beam dimension 

%% Step 1. Define the folder with all MATLAB functions
selected_folder = uigetdir('Select the folder containing the functions');
selected_path = genpath(selected_folder);
addpath(selected_path);

%% Step 2. Open CSV file
%  These lines of code will open .csv files and delete the first two columns since only 
%  the third column contains the fluctuations in fluorescence intensity.

[fileName, pathName] = uigetfile('*.csv');
SP = csvread(fullfile(pathName, fileName));
SP(:,1:2) = [];
SP={SP};

%% Step 3. Calculate FCS and get fitting parameters
%  The sampling frequency is set for a pixel dwell time of 10 μs (10,000 cycles per second), change this value accordingly. 

[corrBins, SP_FCS, w, f, z] = SinglePointFCS(SP,100000);

