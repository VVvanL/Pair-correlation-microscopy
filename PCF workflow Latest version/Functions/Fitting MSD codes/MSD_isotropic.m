function [D,f]=MSD_isotropic(time,msd)
  % Inital guess for parameters:
  D0      = 0.1;         %diffussion coefficient in um2/s
  w0      = 0.260;       %waist radius PSF
  theta0  = [D0;w0];

  y       = @(theta,time) model(theta,time);
  SSECF   = @(theta) sum((msd-y(theta,time)).^2);
  [theta] = fminsearch(SSECF, theta0); 

  D       = theta(1);
  w       = theta(2);
 
  %Generate y-values
  f = y(theta,time);

  %Plotting
  plot(time,msd,'o','MarkerSize',3,'MarkerFaceColor','#171717','color','#171717')
  hold on
  plot(time,f,'LineWidth',3,"Color",'#ff0000');
  hold off
  
function y = model(theta,time)
  D  = theta(1);
  w  = theta(2);

  y = 4.*D.*time+(w.^2);
end

end