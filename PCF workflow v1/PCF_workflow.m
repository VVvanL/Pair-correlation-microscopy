%% Julissa Sanchez Velasquez, Ashleigh Solano, Elizabeth Hinde - Oct 20,2023
%
% PCF_workflow.m - Code for performing and fitting pair correlation functions 
% Last update: 10/2023
%__________________________________________________________________________
%
% OUTPUT
%
% PDF file containing intensity carpets 
% corrBins:          Correlation time
% A_avg:             A matrix containing the average ACFs
% pCF_mean:          A matrix containing the average pCFs
% SEM_ACF_results:   Standard error of the mean from the ACF carpets 
% parameterTable:    Table containing the fitting parameters (diffusion coefficient and amplitude) 
%                    If a one component model was used, the variables names
%                    correspond to D = diffusion coefficient, G = amplitude
%                    If a two component model was used, D = diffusion coefficient of the first component, 
%                    G = amplitude of the first component, E = diffusion coefficient of the second component, 
%                    H = amplitude of the second component 
%                    *The units for the diffusion coefficient are given in nm2/s
% fitted_ACF:        A matrix containing the fitted ACF curves
% parameterTable2:   Table containing the fitting parameters after using an anomalous diffusion model, a = anomalous
%                    factor, D = diffusion coefficient, G = amplitude
% fitted_ACFa:       A matrix containing the fitted ACF curves from a fitting using an anomalous diffusion model
% fitted_pCFa:       A matrix containing the fitted pCF curves from a fitting using a one-component model function 
% parameterTable_pCF Table containing the fitting parameters after using a one-component model to fit the pCF
%                    D = diffusion coefficient (nm2/s), G = amplitude.
% fitted_pCF:        A matrix containing the fitted pCF curves from a fitting using a Gaussian function 
% nPeakTable:        Table containing the translocation time (first column) and amplitude (second column)
% Adit_fvalues_pcf:  A matrix containing the additional fitted pCF curves using optimized starting values from the curveFitter toolbox 
% nPeakTable2:       Table containing the translocation time (first column) and amplitude (second column) from the additional pCF fitting

%% Step 1. Define the folder with all MATLAB functions

selected_folder = uigetdir('Select the folder containing the functions');
selected_path = genpath(selected_folder);
addpath(selected_path);


%% Step 2. Open TIFF files
%This code will store all matrices together in a vertical cell array and store the correspodning file name 

[Images,FileName,PathName] = opentif();


%% Step 3. Visualize intensity carpets before detrending

Images1 = Images;
binsize = 100;     % periods to average 
skip_crop = true;
[av_lines1] = carpet_processing(Images1,binsize,skip_crop);

smoothing = true;  % If you want to smooth the carpet write 'true', otherwise write 'false'
pdf = true; 
pdfFileName='Enter File name';
plot_intensity(av_lines1,FileName,smoothing,pdfFileName, pdf)


%% Step 4. Detrend data 

binsize = 2000;
method = 3; 
images = Images; 

[images_detrended] = detrend_batch(images, binsize, method);


%% Step 5. Remove first 20,000 rows and average columns each 100 lines for plotting

Images = images_detrended;
binsize = 100;                 % periods to average 
skip_crop = false;             %If you want to crop write 'false', otherwise write 'true'
[av_lines,cropped_images] = carpet_processing(Images,binsize,skip_crop);


%% Step 6. Visualize intensity carpets after detrending

smoothing = true;              %If you want to smooth the carpet write 'true', otherwise write 'false'
pdf = true; 
pdfFileName='Enter File name';
plot_intensity(av_lines,FileName,smoothing,pdfFileName, pdf)


%% Step 7. Indicate the first and last columns to be analyzed for the ACF or pCF
close all % close all figures of carpets 

% READ: Create empty matrices to enter manually the first (mfirstCol) and last columns (mlastCol) to be analyzed
% (add manually the first and last columns to be analyzed in these matrices)
rows     = 1;
cols     = 1; 
mfirstCol = zeros(rows, cols);
mlastCol  = zeros(rows, cols);


%% Step 8. Get input parameters and calculate pCF (ACF or pCF at a varied distance) for multiple files at once

radius = 0;                      % Set the value to 0 to get the ACF
sampleFreq = 616;                % Change the sampling frequency if necessary 
ReverseOrder = false;            % write 'true' for performing pCF in the reverse order, write 'false' to perfom the 
                                 % pCF in the direction of the acquisition 

[XCF_ret, XCF_av, all_corrBins]=pcf_batch(cropped_images,radius,mfirstCol,mlastCol,sampleFreq,ReverseOrder);

corrBins = all_corrBins{1,1};

A_avg = cell2mat(XCF_av);        % Activate this line to get the 'A_avg' table that will be needed to fit the ACF data
%pCF_mean = cell2mat(XCF_av);    % Activate this line to get the 'pCF_mean' table will be needed to fit the pCF data
                                 % Switch accordingly


%% Step 9. Obtain s.e.m. for each ACF carpet (values will be needed for the fitting procedure if weightening is being considered)

SEM_ACF_results = cell(size(XCF_ret));

for i = 1:numel(XCF_ret)
    % Calculate the standard error of the mean for each column 
    SEM_values = std(XCF_ret{i}, 0, 2) / sqrt(size(XCF_ret{i}, 2));
    SEM_ACF_results{i} = SEM_values;
end

SEM_ACF_results=SEM_ACF_results';


%% Step 10. Visualize ACF before fitting

%  READ: This subsection can be run to review the quality of the data. 
%  Avoid taking into account ACF curves that do not meet an established criterion. For example, discard samples 
%  that display strong oscillatory patterns in the tail region. Oscillatory patterns can be observed as a result 
%  of the protein repeatedly entering and leaving the observation volume. Oscillatory patterns can also result 
%  from periodic laser fluctuations and electronic noise, periodic fluctuations of the optical path, 
%  and regular fluctuations of the background that affect the fluorescence.

numColumns = size(A_avg, 2);

for i = 1:numColumns
    ACF = A_avg(:, i);  
    figure;
    plotACF(corrBins, ACF);
    title(['ACF sample', num2str(i)]);
end


%% Step 11. Fit the ACF to model functions
%
%  READ: Run the following subsections to fit the ACF to either one-component or two-omponent model function 
%  for a 3D Gaussian PSF or to fit the ACF to an anomalous diffusion model. 
%  Decide if the fitting will be performed using the weighting method, answering yes or no in the command window 
%  (the code implements a weighting by the standard error of the mean (s.e.m.) of the correlation function.

%  IMPORTANT: To solve the diffusion coefficient and amplitude based on either a one or two-component model 
%  for a 3D Gaussian PSF, we apply a Nelder-Mead Simplex algorithm implemented in the MATLAB function fminsearch.
%  This algorithm uses an initial guess to match the measured set of these variables across the data until a minimized 
%  value of the objective equation is achieved. We recommend using the default values for the unknown parameters, 
%  evaluate the fitted curves, and then modify the values if needed. The fitting codes can be found in the subfolder 
% 'Fittting pCF codes' (if you want to change the starting values).
%
%% Fit to either one component or two component model function for a 3D Gaussian PSF

% Handles for different fitting methods
fittingMethods = {
    @Fitting_G0,                      % One Component Model
    @Fitting_two_components           % Two Component Model
};

% Choose a fitting method
choice = menu('Select a fitting method:', 'One Component Model', 'Two Component Model');
selectedFittingMethod = fittingMethods{choice};

% Decide if you want to use SEM_ACF_results for weighted fitting 
prompt = 'Do you want to use SEM_ACF_results for weighted fitting? (yes/no): ';
userChoice = input(prompt, 's');

numDatasets = size(A_avg, 2); 
results = struct('D', [], 'G', [], 'E', [], 'H', [], 'f', []);

for i = 1:numDatasets   
    ydata = A_avg(:, i);  
    tdata = corrBins;

    if strcmpi(userChoice, 'yes')
        % Perform weighted fitting using the provided SEM
        SEM = SEM_ACF_results{i}; 
        
        try
            [D, G, E, H, f] = selectedFittingMethod(tdata, ydata, SEM);
        catch
            try
                [D, G, f] = selectedFittingMethod(tdata, ydata, SEM);
                E = NaN;
                H = NaN;
            catch
                [D, G, f] = selectedFittingMethod(tdata, ydata, SEM);
                E = NaN;
                H = NaN;
            end
        end
    else
        % Default to unweighted fitting
        try
            [D, G, E, H, f] = selectedFittingMethod(tdata, ydata);
        catch
            try
                [D, G, f] = selectedFittingMethod(tdata, ydata);
                E = NaN;
                H = NaN;
            catch
                [D, G, f] = selectedFittingMethod(tdata, ydata);
                E = NaN;
                H = NaN;
            end
        end
    end

    f_values{i} = f;

    results(i).D = D;
    results(i).G = G;
    results(i).E = E;
    results(i).H = H;
    
    plotRawDataAndFittedCurve(tdata, ydata, f, i);
end

parameterTable = struct2table(results);
parameterTable = parameterTable(:, {'D', 'G', 'E', 'H', 'f'});


%% Step 11.1. Get fitted data for one-component model
%  Run this subsection only if a one-component model was chosen.

fitted_ACF = cell2mat(f_values');
fitted_ACF = transpose(fitted_ACF);


%% Step 11.2. Get fitted data for two-component model
%  Run this subsection only if a two-component model was chosen.

fitted_ACF = cell2mat(f_values);


%% Step 12. Fit ACF to anomalous diffusion 

%  Decide if you want to use SEM_ACF_results for weighted fitting 
prompt = 'Do you want to use SEM_ACF_results for weighted fitting? (yes/no): ';
userChoice = input(prompt, 's');

numDatasets = size(A_avg, 2);  

parameterTable2 = table('Size', [numDatasets, 3], ...
                        'VariableTypes', {'double', 'double', 'double'}, ...
                        'VariableNames', {'a', 'D', 'G'});

fitted_ACFa = cell(numDatasets, 1);

for i = 1:numDatasets   

    ydata = A_avg(:, i);  
    tdata = corrBins;

    if strcmpi(userChoice, 'yes')
        % Perform weighted fitting using the provided SEM
        SEM = SEM_ACF_results{i}; 
        [a, D, G, f] = Fitting_Anomalous_G0(tdata, ydata, SEM);
    else
        % Default to unweighted fitting
        [a, D, G, f] = Fitting_Anomalous_G0(tdata, ydata);
    end
    
    parameterTable2(i, :) = {a, D, G};
    fitted_ACFa{i} = f;
    plotRawDataAndFittedCurve(tdata, ydata, f, i);
end

%% Step 12.1. Get fitted data for anomalous diffusion 
%  Run this subsection only if an anomalous diffusion model was chosen.

fitted_ACFa = cell2mat(fitted_ACFa);
fitted_ACFa = transpose(fitted_ACFa);


%% Step 13. Fit pCF data to a one-component model for a 3D Gaussian PSF 

% READ: Specify the distance in nm (d) in the command window. e.g., if pCF12 is being calculated, 
% then d = pixel size * 12. Pixel size should be in nm too.

numDatasets = size(pCF_mean, 2);  

parameterTable_pCF = table('Size', [numDatasets, 2], ...
                        'VariableTypes', {'double', 'double'}, ...
                        'VariableNames', {'D', 'G'});

fitted_pCFa = cell(numDatasets, 1);

d = input('Enter the value of d: ');  
                                    
for i = 1:numDatasets   

    ydata = pCF_mean(:, i);  
    tdata = corrBins;
   
    [D, G, f] = Fitting_pCF(tdata, ydata, d);
    
    parameterTable_pCF(i, :) = {D, G};
    fitted_pCFa{i} = f;
    plotRawDataAndFittedCurve(tdata, ydata, f, i);
end


%% Step 13.1. Get fitted data after fitting the pCF to a model function 

fitted_pCFa = cell2mat(fitted_pCFa);
fitted_pCFa = transpose(fitted_pCFa);


%% Step 14. Fit pCF data to a Gaussian 

% READ: This subsection will fit the pCF to a Gaussian model using the fit function in MATLAB. 
% Consider that if two molecular species differ in diffusion coefficient by more than a decade, 
% they will appear as separate peaks in the pCF profile (10.1016/j.bpj.2009.04.048). 
% Hence, indicate if the fit will be performed using either one or two-term Gaussian models 
% answering gauss1 or gauss2 in the command window. If no answer is provided, the code will fit the pCF to 
% a one-term Gaussian model. We recommend using one Gaussian model, visualizing the fitting, 
% and deciding if the data requires a two-term Gaussian model.

numColumns = size(pCF_mean, 2);  
numTimePoints = 256;  

% Create a matrix to store fitted pCF values
fitted_pCF = zeros(numTimePoints, numColumns);

% Choose the fitting method 
fitType = input('Enter the fit type (e.g., gauss1 or gauss2) [default: gauss1]: ', 's');

if isempty(fitType)
    fitType = 'gauss1';
end

for i = 1:numColumns
    ydata = pCF_mean(:, i);  
    tdata = corrBins;        
    f = fit(log10(tdata), ydata, fitType);
    f_values = f(log10(tdata));
    fitted_pCF(:, i) = f_values;
end


%% Step 15. Plot raw pCF and fitted data, get peak values

numColumns = size(fitted_pCF, 2);  
peakTable = table();
for i = 1:numColumns
    f = fitted_pCF(:, i);  
    tdata = corrBins;        
    figure;  
    [y_pk, x_pk] = plotFittedCurves(tdata, pCF_mean(:, i), f);
    
    peakTable = [peakTable; table(x_pk, y_pk)];
end

%% Step 16. Create a new table with the 'x_pk' values in a linear scale

nPeakTable = peakTable;
nPeakTable.x_pk = 10.^nPeakTable.x_pk;

disp(nPeakTable);


%% Step 17. Fit using optimized starting values 

%READ:

% The fit function in MATLAB uses default starting values and constraint bounds. 
% The default options usually produce an excellent fit; however, if the fit is not adequate, 
% you can specify suitable starting values, especially for the centroid (location), 
% using the MATLAB Curve Fitting Toolbox (a complete users guide can be found at 
% https://au.mathworks.com/help/pdf_doc/curvefit/index.html).
% The code generated by this toolbox can then be inserted in this subsection (Step 18) using optimized starting values. 
% By running Steps 17-20, the code will generate tables for the additional fitted values and parameters.

% We're showing an example about how to get individual pCFs for the new fitting
% The indices in the example correspond to the pCF profiles (from the pCF_mean matrix) we want to fit again

pCF_Cell1=pCF_mean(:,1);
pCF_Cell2=pCF_mean(:,2);
pCF_Cell3=pCF_mean(:,3);

Adit_pCF=table(pCF_Cell1,pCF_Cell2,pCF_Cell3);

Adit_pCF=table2array(Adit_pCF);

%% Step 18. Indicate StartPoints obtained from the curveFitter toolbox

%1
ft = fittype( 'gauss1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0];
opts.StartPoint = [1.17610462104778e-05 -1.5172 0.503];
[f1] = fit(log10(corrBins),pCF_Cell1,ft,opts);

%2
ft2 = fittype( 'gauss1' );
opts2 = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts2.Display = 'Off';
opts2.Lower = [-Inf -Inf 0];
opts2.StartPoint = [1.33403624195885e-05 -1.05 0.58];
[f2] = fit(log10(corrBins),pCF_Cell2,ft2,opts2);

%3
ft3 = fittype( 'gauss1' );
opts3 = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts3.Display = 'Off';
opts3.Lower = [-Inf -Inf 0];
opts3.StartPoint = [1.95698191304568e-05 -1.65 0.551];
[f3] = fit(log10(corrBins),pCF_Cell3,ft3,opts3);


%% Step 19. Get additional f-values

numDatasets = 3; %Indicate the number of new data sets being evluated. Change accordingly

Adit_fvalues_pcf = zeros(length(corrBins), numDatasets);

for i = 1:numDatasets
    variableName = ['f', num2str(i)];  
    f = eval(variableName);  
    f = f(log10(corrBins));
   
    Adit_fvalues_pcf(:, i) = f;
end


%% Step 20. Plot the fitting and get new peak values

numDatasets = 3; %Indicate the number of new data sets being evluated. Change accordingly
peakTable2 = table();

for i = 1:numDatasets
    f = Adit_fvalues_pcf(:, i); 
    figure;  
    [y_pk, x_pk] = plotFittedCurves(corrBins, Adit_pCF(:, i), f);
    
    peakTable2 = [peakTable2; table(x_pk, y_pk)];
end

nPeakTable2 = peakTable2;
nPeakTable2.x_pk = 10.^nPeakTable2.x_pk;
disp(nPeakTable2);
