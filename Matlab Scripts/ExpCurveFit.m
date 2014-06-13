% Process followed from NonLinearCurveFitProof.pdf which is a sample of
% Numerical Methods Using Matlab Fourth Edition
%clear all
%close all
%clc

%x = [0.0 1.0 2.0 3.0 4.0] ;  % independent variable quantities 
%y = [1.5 2.5 3.5 5.0 7.5] ;  % dependent variable quantities 
Y = log(y);
X = x ;

s_X = sum(X);
s_Y = sum(Y);

s_X_2 = sum(X.^2);
s_XY = sum(X.*Y);

N = length(X) ;
B = (s_XY-(s_X_2*(s_Y/s_X)))/(s_X-(s_X_2*N/s_X)) ;
A = (s_Y - N*B)/s_X;
C = exp(B);

xx = zeros(1,100) ;
yy = zeros(1,100) ;
jj=1;
span = (max(X)-min(X))/100;
for x_i = 0:span:max(X)
xx(jj) = x_i;
yy(jj) = C*exp(A*x_i);
jj=jj+1;
end

figure
hold on
plot(x,y,'kh')
plot(xx,yy)
hold off