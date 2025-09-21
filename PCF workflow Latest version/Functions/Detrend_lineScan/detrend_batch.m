function [images_detrended] = detrend_batch(images, binsize, method)
%This function will create detrend an array with intensity linescan data
%in a batch 

num_images = size(images,1);
images_detrended = cell(num_images, 1);
for i = 1:num_images
    image_data= images{i,1};
    [datad] = detrend_line_optimized(image_data, binsize, method);
    images_detrended{i}= datad; 

end

