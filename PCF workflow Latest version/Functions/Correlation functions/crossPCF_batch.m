function [XCF_ret, XCF_av, all_corrBins]=crossPCF_batch(image_CH1,image_CH2, radius,mfirstCol,mlastCol,sampleFreq,ReverseOrder)
% Images is a cell array with all the processed intensity carpets 
% mfirstCol is a linear vector 
% mlastCol  is a linear vector 
% sampleFreq = integer value 
% ReverseOrder, if true will do reverse order calcualtion, if false then regular calculation. 

length = size(image_CH1,1);
XCF_ret = cell(1,length);
XCF_av = cell(1, length);
all_corrBins = cell(1, length);

mfirstCol = mfirstCol(:);   % ensure vectorised 
mlastCol = mlastCol(:);     % ensure vectorised

for i = 1:length 
    carpet1 = image_CH1{i,1};
    carpet2 = image_CH2{i,1};
    firstCol = mfirstCol(i);
    lastCol = mlastCol(i);
    [corrResult,corrBins]=crossPCF_columns(carpet1,carpet2,radius,firstCol,lastCol,sampleFreq,ReverseOrder);

    XCF_ret{1,i} = corrResult; 
    all_corrBins{1,i} = corrBins;

    mean_corrResult= mean(corrResult, 2);
    XCF_av{1,i} =  mean_corrResult; 
    
end 