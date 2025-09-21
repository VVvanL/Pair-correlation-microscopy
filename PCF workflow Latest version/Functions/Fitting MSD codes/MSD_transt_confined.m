function [D,tc,L,f]=MSD_transt_confined(time,msd)
  % Inital guess for parameters:
  tc0     = 0.0005;          %time spend inside the confinement zone
  w0      = 0.260;           %waist radius PSF
  L0      = 0.050;           %size of the confinement zone
  D0      = 0.1;             %diffussion coefficient #1 unknown parameter in um2/s

  theta0  = [tc0;w0;L0;D0];

  y       = @(theta,time) model(theta,time);
  SSECF   = @(theta) sum((msd-y(theta,time)).^2);
  [theta] = fminsearch(SSECF, theta0); 

  tc      = theta(1);
  w       = theta(2);
  L       = theta(3);
  D       = theta(4);
 
  %Generate y-values
  f = y(theta,time);

  %Plotting
  plot(time,msd,'o','MarkerSize',3,'MarkerFaceColor','#171717','color','#171717')
  hold on
  plot(time,f,'LineWidth',3,"Color",'#ff0000');
  hold off


function y = model(theta,time)
  tc    = theta(1);
  w     = theta(2);
  L     = theta(3);
  D     = theta(4);

  y    = ((L.^2)./3).*(1-exp(-(time/tc)))+4.*D.*time+w.^2;

end

end