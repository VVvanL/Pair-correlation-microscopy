function [av_lines,cropped_images] = carpet_processing(Images,binsize,skip_crop)
%CARPET_PROCESSING Processes a set of images by optionally cropping them and applying averaging.
%
%   Images: A cell array of input matrices (images)
%   skip_crop: A logical value indicating whether to skip cropping (true) or not (false)

% Check if skip_crop argument is provided, otherwise set it to false
if nargin < 2
    skip_crop = false;  % Default value is false (do not skip cropping)
end

num_images = length(Images);  % Get the number of matrices

if skip_crop
    cropped_images = Images;  % If skip_crop is true, keep the original images
else
    cropped_images = cell(num_images, 1);
    for i = 1:num_images
        cropped_images{i} = Images{i}(20001:end, :);
    end
end

% Create a new cell array to store the averaged matrices
av_lines = cell(num_images, 1);

for i = 1:num_images
    matrixd = cropped_images{i};  % Get the cropped matrix
    
    % Apply the Periods_to_average function to the cropped matrix
    av_matrix = periods2av(matrixd,binsize);  % Assuming the function works this way
    
    % Store the averaged matrix in the new cell array
    av_lines{i} = av_matrix;
end

end
