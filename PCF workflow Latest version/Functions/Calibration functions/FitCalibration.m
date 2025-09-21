function [w,f]=FitCalibration(tdata,ydata)

% Specify the data
tdata=(tdata)';          %time
ydata=(ydata)';          %ACF

% Inital guess for parameters:
G0      = 0.001;          
w0      = 0.260;          %Width of the 3D Gaussian observation volume
Aoff0   = 0; 
theta0 = [G0;w0;Aoff0];
 
% Create anonymous function:
fvec = @(theta,tdata) modelvec(theta,tdata);
SSECF = @(theta) sum((ydata - fvec(theta,tdata)).^2);
[theta] = fminsearch(SSECF, theta0); 

%D   = theta(1);
G   = theta(1);
w   = theta(2);
Aoff= theta(3);

%Generate y-values
f = fvec(theta,tdata);

%Get residuals
residuals = ydata - f;

%Check fit:
subplot(4,1,1:3)
semilogx(tdata,ydata,'o','MarkerSize',2,'MarkerFaceColor','#171717','color','#171717')
hold on
tplot = logspace(log10(tdata(1)),log10(tdata(end)));
semilogx(tplot,fvec(theta,tplot),'LineWidth',2.5,"Color",[1 0 0]);
hold off
xlabel('tau')
legend('ACF','Fitted curve')
subplot(4,1,4)
plot(residuals,'LineWidth',0.5,"Color",'#171717')

function yvec = modelvec(theta,tdata)
    % Vector of y model for a vector of time values:
    yvec = zeros(size(tdata));
    for i = 1:length(tdata)
        yvec(i) = model(theta,tdata(i));
    end
end

function y = model(theta,tdata)
%parameters
%D    = theta(1);
G    = theta(1);
w    = theta(2);
Aoff = theta(3);
D    = 440;              %Fluorescein' D (300 - 420 um2/s)
S    = 3;                %Structure factor
d    = 0;                %Distance between pixels

% Equation:one component anomalous diffusion 
y=Aoff + (G).*(1/(1+((4.*D.*tdata)/(w.^2)))).*(1/sqrt(1+((4.*D.*tdata)/((w.^2).*((S).^2))))).*exp(-(d^2)/((w.^2)+(4.*D.*tdata)));
end
 


end