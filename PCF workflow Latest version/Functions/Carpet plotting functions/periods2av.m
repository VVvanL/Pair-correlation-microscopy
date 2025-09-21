function [ret] = periods2av(data,binsize)
    %binsize = 100;
    nbins = floor(size(data, 1) / binsize);
    ret = [];
    if nbins < 10
        uiwait(msgbox('periods to average is too big!', 'Error', 'modal'));
        return;
    end
    
    ret = zeros(nbins, size(data, 2));
    for b = 1:nbins
        if mod(b, 10) == 0
            percent = floor(100 * b / nbins);
            msg = sprintf('Processed %d percent', percent);
            drawnow;
        end
        start_ind = (b-1)*binsize + 1;
        end_ind = b*binsize;
        end_ind = min(end_ind, size(data, 1));
        ret(b, :) = mean(data(start_ind:end_ind, :));
    end
   
