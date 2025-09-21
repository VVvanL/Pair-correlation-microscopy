function varargout = cal_corr1(y1, y2, numLags)
% Calculate pair correlation. If y1 = y2 -> self-correlation
% [xcf, lags] = crosscorr(y1,y2)
% [xcf, lags] = crosscorr(y1,y2, numLags)
% Ref: crosscorr.m + SimFCS
% As same as the implementation of SimFCS, the size time axis is truncated to next lower power of two 
%   e.g. 100000-row data will be truncated to 66532-row data.
% Circular FFT then will be used to calculate the correlation (no zero padding is used)

if nargin < 2
    error(message('cal_corr: Not enought input argument'));
end

[rows,columns] = size(y1);

if ((rows ~= 1) && (columns ~= 1)) || (rows*columns < 2)
   error(message('cal_corr: NonVectorSeries1'))
end

[rows,columns] = size(y2);

if ((rows ~= 1) && (columns ~= 1)) || (rows*columns < 2)    
   error(message('cal_corr:NonVectorSeries2'))
else

end
%% 

rowSeries = (size(y1,1) == 1);

y1 = y1(:); % Ensure a column vector
y2 = y2(:); % Ensure a column vector

if(length(y1) ~= length(y2))
    error(message('cal_corr:NotSameLength'))
end

N = length(y1); % Sample size
defaultLags = 256; %

% Ensure numLags is a positive integer or set default:
if (nargin >= 3) && ~isempty(numLags)
   if numel(numLags) > 1
      error(message('cal_corr:NonScalarLags'))
   end
   
   if (round(numLags) ~= numLags) || (numLags <= 0)
      error(message('cal_corr:NonPositiveInteger'))
   end
   
   if numLags > (N-1)
      error(message('cal_corr:InputTooLarge'))
   end
   
else 
   numLags = min(defaultLags,N-1); % Default
end


y1 = double(y1);
y2 = double(y2);
D = N * mean(y1) * mean(y2); % normalize factor

y1 = y1-mean(y1);
y2 = y2-mean(y2);

nu = floor(log(N)/log(2));
nFFT = 2^nu;  %For FFTs to be performed efficiently, the size of the time axis is truncated to a power of two
F = fft([y1(:) y2(:)],nFFT); 

xcf = ifft(F(:,1).*conj(F(:,2)));   % <F1(t) x F2(t + tau)>
xcf = real(xcf) / D;
lags = (0:numLags)';

if rowSeries
      xcf = xcf';
      lags = lags';    
end

varargout = {xcf,lags};