function [tc,L,f]=MSD_confined(time,msd)
  % Inital guess for parameters:
  tc0     = 0.0005;          %time spend inside the confinement zone
  w0      = 0.260;           %waist radius PSF
  L0      = 0.050;           %size of the confinement zone
  theta0  = [tc0;w0;L0];

  y       = @(theta,time) model(theta,time);
  SSECF   = @(theta) sum((msd-y(theta,time)).^2);
  [theta] = fminsearch(SSECF, theta0); 

  tc      = theta(1);
  w       = theta(2);
  L       = theta(3);
 
  %Generate y-values
  f = y(theta,time);
 
  %Plotting
  plot(time,msd,'o','MarkerSize',3,'MarkerFaceColor','#171717','color','#171717')
  hold on
  plot(time,f,'LineWidth',3,"Color",'#ff0000');
  hold off

function y = model(theta,time)
  tc   = theta(1);
  w    = theta(2);
  L    = theta(3);
  y    = ((L.^2)./3).*(1-exp(-time/tc))+w.^2;

end

end