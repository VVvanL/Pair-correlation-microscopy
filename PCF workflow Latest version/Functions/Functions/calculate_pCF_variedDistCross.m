function [distanceNames,corrBins,pCF_average_data] = calculate_pCF_variedDistCross(cropped_images_CH1,cropped_images_CH2,mfirstCol,mlastCol,sampleFreq,ReverseOrder)

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

end