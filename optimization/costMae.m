% costMae - Computes the negative mean absolute error between input and output signals
%
% This function calculates the Mean Absolute Error (MAE) between two signals
% and returns its negative value. It is commonly used as an objective function 
% for optimization, where minimizing MAE corresponds to maximizing the objective.
%
% Syntax:
%    obj = costMae(y_in, y_out)
%
% Inputs:
%    y_in  - Reference input signal 
%            (double 1 x N)
%    y_out - Measured output signal 
%            (double 1 x N)
%
% Outputs:
%    obj   - Negative MAE value (to be maximized in optimization)
%            (double scalar)
%
% Example:
%    y_in = [1, 2, 3, 4, 5];
%    y_out = [1.1, 1.9, 3.1, 3.8, 5.2];
%    obj = costMae(y_in, y_out);
%
% Dependencies:
%    Matlab release: R2021b or later
%    other m-files: none
%    MAT-files: none
%    Toolboxes: none
%
% This function is part of: Optimization-Based Signal Generator
%
%------------- BEGIN CODE ------------------------------------------------------

function obj = costMae(y_in, y_out)
    obj = -mean(abs(y_in - y_out));  % Negative Mean Absolute Error as the objective
end