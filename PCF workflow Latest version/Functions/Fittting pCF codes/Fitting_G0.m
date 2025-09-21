function [D,G,f]=Fitting_G0(tdata,ydata,SEM)

% Specify the data
tdata=(tdata)';          %xdata, tau values in the equation
ydata=(ydata)';          %ydata

if exist('SEM', 'var')
    SEM = SEM';
else
end

% Check if SEM is provided as an input argument
    if nargin < 3 || isempty(SEM)
        % Default to unweighted fitting if SEM is not provided or empty
        SEM = [];
    end

% Inital guess for parameters:
D0     = 0.01e6;        %diffussion coefficient unknown parameter in nm^2/s (e.g., 1 um2/s)
G0     = 0.000519;      %1/N, 0.01 if N=100
theta0 = [D0;G0];
 
% Create anonymous function:
fvec = @(theta,tdata) modelvec(theta,tdata);

   % Define the sum of squared errors function
    if ~isempty(SEM)
        % If SEM is provided, include it in the weighted SSECF function
        % Assuming you have 'w' defined appropriately for weighted fitting
        w = 1 ./ (SEM.^2); % Calculate weights from SEM
        %w=SEM;
        SSECF = @(theta) sum(w .* ((ydata - fvec(theta, tdata)).^2));
    else
        % Default to unweighted fitting
        SSECF = @(theta) sum((ydata - fvec(theta, tdata)).^2);
    end

% Perform the fitting

[theta] = fminsearch(SSECF, theta0); 
D  = theta(1);
G  = theta(2);
%Generate y-values
f = fvec(theta,tdata);

%Get residuals
residuals = ydata - f;

%Check fit:
subplot(4,1,1:3)
semilogx(tdata,ydata,'.')
hold on
tplot = logspace(log10(tdata(1)),log10(tdata(end)));
semilogx(tplot,fvec(theta,tplot),'LineWidth',1.5,"Color",[1 0 0]);
hold off
xlabel('tau')
legend('ACF','Fitted function')
subplot(4,1,4)
plot(residuals)

function yvec = modelvec(theta,tdata)
    % Vector of y model for a vector of time values:
    yvec = zeros(size(tdata));
    for i = 1:length(tdata)
        yvec(i) = model(theta,tdata(i));
    end
end

function y = model(theta,tdata)
%parameters
D=theta(1);
G=theta(2);
Aoff = 0.000006;
z0=780;           %in nm, half length of the confocal volume along the optical axis
w=260;            %waist radious in nm
d=0;                %Distance between pixels (in nm)

% Equation:one component anomalous diffusion 
y=Aoff + (G).*(1/(1+((4.*D.*tdata)/(w.^2)))).*(1/sqrt(1+((4.*D.*tdata)/((w.^2).*((z0/w).^2))))).*exp(-(d^2)/((w.^2)+(4.*D.*tdata)));
end
 


end