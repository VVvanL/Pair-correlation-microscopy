function [corrResult]=Smoothing(corrResult,type,sigma,numcols)
type; %smooothing surface instead of columns
sigma;
numcols;
if(numcols < 1 || numcols > size(corrResult, 2))
    uiwait(msgbox('Number of columns is too small or too big!', 'Error', 'modal'));
    return;
end

if mod(numcols, 2) == 0 
    numcols = numcols + 1;
    if numcols > size(corrResult, 2)
        numcols = numcols - 2;
    end
end

if(type == 1)
    corrResult = imgaussfilt(corrResult, sigma, 'FilterSize',[numcols 1]);
else
    corrResult = imgaussfilt(corrResult, sigma, 'FilterSize',[numcols numcols]);
end


