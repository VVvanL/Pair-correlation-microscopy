function [datad, datasm] = detrend_line_optimized(frames, binsize, method)
    if method ~= 3
        error('Only method 3 (moving average) is supported.');
    end
    
    %fprintf('Moving average\n');

    if nargin < 2
        error('Not enough input arguments.');
    end
    
    frames = double(frames);
    [n, width] = size(frames);
   
    if n <= 0
        error('Last frame to process must be larger than the first frame');
    end 
    datad = zeros(n , width);
    datasm = zeros(n, width);
  
    for i = 1 : width 
        xa = frames(:, i);
        [output, sdata] = detrend_ra_optimized(xa, binsize, method);
        datad(:, i) = output;
        datasm(:, i) = sdata;
    end
end

function [output, sdata] = detrend_ra_optimized(xa, binsize, method)
    n = numel(xa);
    m = binsize;
    data = xa;

    if m <= 2
        warning('binsize is too small');
    end

    mm = m / 2;
    
    ya = zeros(size(data));  % Initialize ya to the same size as data
    output = zeros(size(data));  % Initialize output to the same size as data
    
    if method == 3
        % ==== moving average ====
        
        for i = mm + 1 : n - mm - 1
            ya(i) = sum(data(i - mm : i + mm)) / m;
        end
        
        auxd = sum(data) / n;
        
        datax = data;
        datax(mm + 1 : n - mm - 1) = fix(datax(mm + 1 : n - mm - 1) - ya(mm + 1 : n - mm - 1) + auxd);
        
        % Update the values in the output array
        output = datax;
        
        % Update the values in the sdata array
        sdata = ya;
    end
end

