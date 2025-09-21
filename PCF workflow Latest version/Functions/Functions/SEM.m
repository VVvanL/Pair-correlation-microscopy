function SEM_ACF_results = SEM(XCF_ret)

SEM_ACF_results = cell(size(XCF_ret));

for i = 1:numel(XCF_ret)
    % Calculate the standard error of the mean for each column 
    SEM_values = std(XCF_ret{i}, 0, 2) / sqrt(size(XCF_ret{i}, 2));
    SEM_ACF_results{i} = SEM_values;
end

SEM_ACF_results=SEM_ACF_results';

end
