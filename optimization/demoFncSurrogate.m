% demoFncSurrogate - Surrogate-based optimization for signal generation
%
% This function applies surrogate optimization for the spring mass system to minimize a given cost 
% function by optimizing signal parameters. It efficiently explores the 
% parameter space using a surrogate model.
%
% Syntax:
%    [valueofCostFunction, signalData, errorEveryIter, dataEveryIter] = ...
%       demoFncSurrogate(maxFun, nChanceoverPoints, costFunction, sim, ...
%                       startingValues, ts, minLengthofParts)
%
% Inputs:
%    maxFun             - Maximum number of function evaluations
%                         (double scalar)
%    nChanceoverPoints  - Number of changeover points in the signal
%                         (double scalar)
%    costFunction       - Function handle for the cost function
%                         (function handle)
%    sim                - Simulation function handle
%                         (function handle)
%    startingValues     - Initial values for T, B, and X (optional)
%                         (double N x K)
%    ts                 - Sampling time for interpolation
%                         (double scalar)
%    minLengthofParts   - Minimum length constraint for segments
%                         (double scalar)
%
% Outputs:
%    valueofCostFunction - The best (lowest) cost function value found
%                          (double scalar)
%    signalData          - Parameters (T, B, X) that achieved the best result
%                          (double 1 x K)
%    errorEveryIter      - Vector storing the error at each iteration
%                          (double 1 x maxFun)
%    dataEveryIter       - All generated data during the optimization
%                          (double K x maxFun)
%
% Example:
%    maxFun = 100;
%    nChanceoverPoints = 5;
%    valueofCostFunction = demoFncSurrogate(maxFun, nChanceoverPoints, ...
%                                           @myCostFunction, @mySimFunction, ...
%                                           startingValues, 0.01, 0.05);
%
% Dependencies:
%    Matlab release: R2021b or later
%    other m-files: objectiveFunction.m
%    MAT-files: none
%    Toolboxes: global Optimization Toolbox Parallel Computing Toolbox (not
%    necessary)
%
% This function is part of: Optimization-Based Signal Generator
%
%------------- BEGIN CODE ------------------------------------------------------
function [valueofCostFunction, signalData, errorEveryIter, dataEveryIter] = ...
    demoFncSurrogate(maxFun, nChanceoverPoints, costFunction, sim, startingValues, ts, minLengthofParts)

% Define vector sizes for T (time points), B (control points), and X (signal values)
nT = nChanceoverPoints; % Length of T vector
nB = ceil(nT / 2); % Length of B vector
nX = nB + 1; % Length of X vector

% Define inequality constraint (A * x <= b)
A = [ones(1, nT), zeros(1, nX + nB)]; % Ensures sum of T values is limited
b = 1 - minLengthofParts - eps; % Upper limit for the sum of T values

% Define lower and upper bounds for the variables
lb = [zeros(1, nT) + minLengthofParts, ones(1, nB), zeros(1, nX)]; % Lower bounds for T, B, X
ub = [zeros(1, nT) + b, ones(1, nB) * 7, ones(1, nX)]; % Upper bounds for T, B, X

intcon = []; % No integer constraints are required

% Define the objective function (cost function)
fun = @(x) objectiveFunction(x, nT, costFunction, sim, ts, minLengthofParts); 

% Set optimization options based on the presence of starting values
if isscalar(startingValues) % No starting values provided
    options = optimoptions('surrogateopt', 'MaxFunctionEvaluations', maxFun, ...
                           'UseParallel', true, 'PlotFcn', [], ...
                           'MinSurrogatePoints', 30, 'Display', 'iter'); 
else % Starting values are provided
    options = optimoptions('surrogateopt', 'InitialPoints', startingValues, ...
                           'MaxFunctionEvaluations', maxFun, 'UseParallel', true, ...
                           'PlotFcn', [], 'MinSurrogatePoints', 30, 'Display', 'iter');
end

% Perform the surrogate optimization
[signalData, valueofCostFunction, ~, ~, result] = surrogateopt(fun, lb, ub, intcon, A, b, [], [], options); 

% Extract optimization results
errorEveryIter = result.Fval; % Record error values for each iteration
dataEveryIter = result.X; % Record data points for each iteration
end