function [ predicted_tct, predicted_cpu, MSE, RMSE ] = training_error( observed_cpu, observed_tct, fitresult )

%TRAINING_ERROR finds the mean square error
% between predicted values and observed values

% observed_cpu = sort(observed_cpu);

coeffvals = coeffvalues(fitresult);

predicted_cpu = observed_cpu;

for i = 1:size(observed_cpu,1)
    predicted_tct(i,1) = coeffvals(1)*exp(coeffvals(2)*observed_cpu(i)) + coeffvals(3)*exp(coeffvals(4)*observed_cpu(i));
end

MSE = mean((observed_tct - predicted_tct).^2);   % Mean Squared Error
RMSE = sqrt(mean((observed_tct - predicted_tct).^2));  % Root Mean Squared Error

end

