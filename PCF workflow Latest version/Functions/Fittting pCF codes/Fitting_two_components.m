function [D,G,E,H,f] = Fitting_two_components(tdata,ydata,SEM)

    % Check if SEM is provided as an input argument
    if nargin < 3 || isempty(SEM)
        % Default to unweighted fitting if SEM is not provided or empty
        SEM = [];
    end

  % Inital guess for parameters:
  D0     = 20e6;         %diffussion coefficient #1 unknown parameter in nm^2/s (e.g., 1 um2/s)
  G0     = 0.00888;      %G0 #1 1/N, 0.02 if N=100
  E0     = 0.05e6;       %diffussion coefficient #2 unknown parameter in nm^2/s (e.g., 1 um2/s)
  H0     = 0.000099;     %G0 #2 (1/N, 0.02 if N=100)
  Aoff0  = 0;            % Offset
  theta0 = [D0;G0;E0;H0;Aoff0];

  y = @(theta,tdata) model(theta,tdata);

    % Define the sum of squared errors function
    if ~isempty(SEM)
        % If SEM is provided, include it in the weighted SSECF function
        % Assuming you have 'w' defined appropriately for weighted fitting
        w = 1 ./ (SEM.^2); % Calculate weights from SEM
        %w=SEM;
        SSECF = @(theta) sum(w .* ((ydata - y(theta, tdata)).^2));
    else
        % Default to unweighted fitting
        SSECF = @(theta) sum((ydata - y(theta, tdata)).^2);
    end

  % Perform the fitting
  
  [theta] = fminsearch(SSECF, theta0); 

  D  = theta(1);
  G  = theta(2);
  E  = theta(3);
  H  = theta(4);

  %Generate y-values
  f = y(theta,tdata);

  %Get residuals
  residuals = ydata - f;

  %Plotting
  subplot(4,1,1:3)
  semilogx(tdata,ydata,'o','MarkerSize',2,'MarkerFaceColor','#44bbfd','color','#44bbfd')
  hold on
  tplot = logspace(log10(tdata(1)),log10(tdata(end)));
  semilogx(tplot,model(theta,tplot),'LineWidth',3,"Color",'#ff3e5e');
  hold off
  subplot(4,1,4)
  plot(residuals,'LineWidth',1,'Color','#44bbfd')
  line(xlim(), [0,0], 'LineWidth', 0.5, 'Color', 'k');


function y = model(theta,t)
  D  = theta(1);
  G  = theta(2);
  E  = theta(3);
  H  = theta(4);
  Aoff = theta(5);           %Offset  
  y = pseudugauss(G,D,t) + pseudugauss(H,E,t) + Aoff;
end

function y = pseudugauss(G,D,t)
  w0 = 260;
  z0 = 780;
  d=0;
  s1 = 1./(1+4/w0.^2.*D.*t);
  s2 = 1./sqrt(1+4/z0^2*D.*t);
  s3 = exp(-(d^2)./(w0.^2+4.*D.*t));
  y = G*s1.*s2.*s3;
end

end