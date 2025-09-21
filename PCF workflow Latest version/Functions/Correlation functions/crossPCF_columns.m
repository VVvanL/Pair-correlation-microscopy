function [corrResult,corrBins]=crossPCF_columns(carpet1,carpet2,radius,firstCol,lastCol,sampleFreq,ReverseOrder)
%Initialise parameters
%Ensure that there are no NaN in carpet by setting them to equal zero =>
%real data should not have NaNs but simulation data can at times
carpet1(isnan(carpet1))=0;
carpet2(isnan(carpet2))=0;

% get parameters
nrows = size(carpet1, 1);
ncols = size(carpet1, 2);
firstRow = 1;
firstCol;
lastRow = nrows;
lastCol;
colDist = radius;

N = min(size(carpet1, 1), lastRow) - firstRow + 1;
nu = floor(log(N) / log(2));
ntimes = 2^nu;  % truncat size of time axis to next lower power of two
lastRow = firstRow + ntimes - 1;


% checking input data
if(firstRow < 1 || firstRow > lastRow || lastRow > nrows)
    uiwait(msgbox('Please check first row and/or last row indexes!', 'Error', 'modal'));
    return;
end
if(firstCol < 1 || firstCol > lastCol || lastCol > ncols)
    uiwait(msgbox('Please check first column and/or last column indexes!', 'Error', 'modal'));
    return;
end

% get data
carpet1 = carpet1(firstRow:lastRow, :);
carpet2 = carpet2(firstRow:lastRow, :);
numrows = size(carpet1, 1);

numLags = numrows-1;
numCols = lastCol - firstCol - colDist + 1;

corrResult = zeros(numLags+1, size(carpet1, 2)); % include lag = zero

for ii=firstCol:lastCol
   
    % get col1 and col2 data to calculate correlation
    ind2 =  mod(ii+colDist,ncols);
    if(ind2 == 0)
        ind2 = ncols;
    end
    col1 = carpet1(:, ii);
    col2 = carpet2(:, ind2);
    
    if ReverseOrder
        temp = col1;
        col1 = col2;
        col2 = temp;
    end

    xcf = cal_corr1(col2, col1, numLags);
    
    corrResult(:, ii) = xcf;
end

corrResultG0 = corrResult(1, :);

% averaging
sampleFreq = max(sampleFreq, 1);
timescale = 1.0 / sampleFreq;

isLog = 10;
if (isLog) 
    dx = exp(log(ntimes)/256);
    rbins = zeros(1,256);
    for ii = 1:256
        rbins(ii) = power(dx, ii); 
        if(rbins(ii) > ntimes)
            rbins(ii) = ntimes;
        end
    end
    bins = floor(rbins);
    ubins = unique(bins);
    
    avgResult = zeros(length(ubins), size(corrResult, 2));
    avgResult(1, :) = corrResult(2, :);
    for ii=2:length(ubins)
        avgResult(ii, :) = mean(corrResult(ubins(ii-1)+1:ubins(ii), :), 1); 
    end
    %interpolation
    corrResult = zeros(length(rbins), size(corrResult, 2));
    for ii=1:size(corrResult, 2)
        corrResult(:, ii) = interp1(ubins, avgResult(:, ii), rbins);
    end
    
    corrResult(isnan(corrResult)) = 0 ;
    corrBins = rbins' * timescale;
    
end

dis_img = corrResult;
colormap(jet);
imagesc(dis_img);
colorbar();

%[ytickvec, yticklabel] = cal_yaxis_labels(isLog, corrBins);
%set(gca,'YTick',ytickvec);
%set(gca,'YTickLabel', yticklabel);
%if(isLog)
%    yl = 'Logarithmic tau';
%end
%ylabel(yl);
