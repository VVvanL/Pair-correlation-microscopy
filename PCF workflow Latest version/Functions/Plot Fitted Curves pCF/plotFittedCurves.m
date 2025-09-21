function [y_pk,x_pk] = plotFittedCurves(tdata,ydata,f)

plot(log10(tdata),ydata)
hold on
plot(log10(tdata),f,'LineWidth',2,'Color','#ff3e5e')
[y_pk,x_pk]=findpeaks(f,log10(tdata));
hold off