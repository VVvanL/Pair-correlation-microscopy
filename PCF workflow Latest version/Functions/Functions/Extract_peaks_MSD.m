function all_pCF_values =Extract_peaks_MSD(peak_table)

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

end