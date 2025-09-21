function [corrBins, SP_FCS] = SinglePointFCS(SP,sampleFreq)

%Calculate ACF, fit the data, and get fitted parameters

rows         = 1;
cols         = 1; 
radius       = 0; 
sampleFreq; 
ReverseOrder = false; 

% Check the length of SP
SP_length = length(SP);

% Generate mfirstCol and mlastCol filled with ones based on the length of SP
mfirstCol = ones(SP_length, 1);
mlastCol = ones(SP_length, 1);

[XCF_ret, XCF_av, all_corrBins]=pcf_batch(SP,radius,mfirstCol,mlastCol,sampleFreq,ReverseOrder);

corrBins = all_corrBins{1,1};

SP_FCS = XCF_av;   % Get average ACF profile

end




