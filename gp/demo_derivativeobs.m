%DEMO_DERIVATIVEOBS  Regression problem demonstration with derivative 
%                    observations
%
%  Description
%    The regression problem consist of a data with one input variable,
%    two output variables with Gaussian noise; observations and 
%    derivative observations. The constructed model is full GP with
%    Gaussian likelihood.
%
%   The demo is organised in two parts:
%     1) data analysis without derivative observations
%     2) data analysis with derivative observations
%
%  See also  DEMO_REGRESSION1
%

% Copyright (c) 2010 Tuomas Nikoskinen
% Copyright (c) 2017 Jarno Vanhatalo

% This software is distributed under the GNU General Public 
% License (version 3 or later); please refer to the file 
% License.txt, included with the software, for details.

% Create the data
tp=5;                                  %number of training points -1
x=[-2:4/tp:2]';
y=sin(x).*cos(x).^2;                   % The underlying process
dy=cos(x).^3 - 2*sin(x).^2.*cos(x);    % Derivative of the process
ns=0.06;                               % noise standard deviation

% Add noise
y=y + ns*randn(size(y));
% derivative observations are also noisy
dy=dy + ns*randn(size(dy));           
% observation vector with derivative observations
y2=[y;dy];
x2 = [x zeros(size(x)) ; x ones(size(x)) ];

% test points
xt=[-3:0.05:3]';
xt2=[ xt zeros(size(xt))];
nt=length(xt);

%========================================================
% PART 1 GP model without derivative obs
%========================================================
disp('GP model without derivative obs')

% Covariance function
pl = prior_t();
pm = prior_sqrtt();
gpcf = gpcf_sexp('lengthScale', 0.5, 'magnSigma2', .5,...
                 'lengthScale_prior', pl, 'magnSigma2_prior', pm);
% Use default Gaussian likelihood
lik = lik_gaussian('sigma2', 0.06.^2, 'sigma2_prior', prior_fixed);
gp = gp_set('cf', gpcf, 'lik', lik);

% Set the options for the optimization
opt=optimset('TolFun',1e-3,'TolX',1e-3,'DerivativeCheck','on');
% Optimize with the scaled conjugate gradient method
gp=gp_optim(gp,x,y,'opt',opt);
% Do the prediction
[Eft, Varft] = gp_pred(gp, x, y, xt);

% PLOT THE DATA

figure
%m=shadedErrorBar(p,Eft(1:size(xt)),2*sqrt(Varft(1:size(xt))),{'k','lineWidth',2});
subplot(2,1,1)
m=plot(xt,Eft,'k','lineWidth',2);
hold on
plot(xt,Eft+2*sqrt(Varft),'k--')
hold on
m95=plot(xt,Eft-2*sqrt(Varft),'k--');
hold on
hav=plot(x, y(1:length(x)), 'ro','markerSize',7,'MarkerFaceColor','r');
hold on
h=plot(xt,sin(xt).*cos(xt).^2,'b--','lineWidth',2);
%legend([m.mainLine m.patch h hav],'prediction','95%','f(x)','observations');
legend([m m95 h hav],'prediction','95%','f(x)','observations');
title('GP without derivative observations')
xlabel('input x')
ylabel('output y')

%========================================================
% PART 2 GP model with derivative obs
%========================================================
disp('GP model with derivative obs')

% Option derivobs set so that the derivatives are in use
gp = gp_set('cf', gpcf, 'deriv', 2);

% Set the options for the optimization
opt=optimset('TolFun',1e-3,'TolX',1e-3,'DerivativeCheck','on');
% Optimize with the scaled conjugate gradient method
gp=gp_optim(gp,x2,y2,'opt',opt);
% Do the prediction
[Eft2, Varft2] = gp_pred(gp, x2, y2, xt2);
% Use predictions for function values only
Eft2=Eft2(1:nt);Varft2=Varft2(1:nt);

% PLOT THE DATA
% plot lines indicating the derivative

subplot(2,1,2)
m=plot(xt,Eft2,'k','lineWidth',2);
hold on
plot(xt,Eft2+2*sqrt(Varft2),'k--')
hold on
m95=plot(xt,Eft2-2*sqrt(Varft2),'k--');
hold on
hav=plot(x, y(1:length(x)), 'ro','markerSize',7,'MarkerFaceColor','r');
hold on
h=plot(xt,sin(xt).*cos(xt).^2,'b--','lineWidth',2);

xlabel('input x')
ylabel('output y')
title('GP with derivative observations')

i1=0;
a=0.1;
ddx=zeros(2*length(x),1);
ddy=zeros(2*length(x),1);
for i=1:length(x)
  i1=i1+1;
  ddx(i1)=x(i)-a;
  ddy(i1)=y(i)-a*dy(i);
  i1=i1+1;
  ddx(i1)=x(i)+a;
  ddy(i1)=y(i)+a*dy(i);
end

for i=1:2:length(ddx)
  hold on
  dhav=plot(ddx(i:i+1), ddy(i:i+1),'r','lineWidth',2);
end
legend([m m95 h hav dhav],'prediction','95%','f(x)','observations','der. obs.');

