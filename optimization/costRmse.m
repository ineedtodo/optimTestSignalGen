% costRmse - Computes the negative root mean square error between input and output signals
%
% This function calculates the RMSE (Root Mean Square Error) between two signals
% and returns its negative value. It is typically used as an objective function
% for optimization, where minimizing RMSE corresponds to maximizing the objective.
%
% Syntax:
%    obj = costRmse(y_in, y_out)
%
% Inputs:
%    y_in  - Reference input signal 
%            (double 1 x N)
%    y_out - Measured output signal 
%            (double 1 x N)
%
% Outputs:
%    obj   - Negative RMSE value (to be maximized in optimization)
%            (double scalar)
%
% Example:
%    y_in = [1, 2, 3, 4, 5];
%    y_out = [1.1, 1.9, 3.1, 3.8, 5.2];
%    obj = costRmse(y_in, y_out);
%
% Dependencies:
%    Matlab release: R2021b or later
%    other m-files: none
%    MAT-files: none
%    Toolboxes: none
%
% This function is part of: Optimization-Based Signal Generator
%
%------------- BEGIN CODE ---------------------------------------------------
function obj = costRmse(y_in, y_out)
    % Cost function definitions for optimization
    obj = -rms(y_in - y_out);  % Negative RMS error as the objective
end