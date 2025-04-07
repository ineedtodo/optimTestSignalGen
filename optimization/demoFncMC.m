% demoFncMC - Monte Carlo-based optimization for signal generation
%
% This function implements a Monte Carlo optimization approach to minimize 
% a given cost function by generating random signal parameters for the spring mass system. It iterates 
% through random samples and tracks the best solution found.
%
% Syntax:
%    [valueofCostFunction, signalData, errorEveryIter, dataEveryIter] = ...
%       demoFncMC(maxFun, nChanceoverPoints, costFunction, sim, ...
%                 startingValues, ts, minLengthofParts)
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
%
% Example:
%    maxFun = 100;
%    nChanceoverPoints = 5;
%    valueofCostFunction = demoFncMC(maxFun, nChanceoverPoints, ...
%                                   @myCostFunction, @mySimFunction, ...
%                                   startingValues, 0.01, 0.05);
%
% Dependencies:
%    Matlab release: R2021b or later
%    other m-files: objectiveFunction.m
%    MAT-files: none
%    Toolboxes: none
%
% This function is part of: Optimization-Based Signal Generator
%
%------------- BEGIN CODE ------------------------------------------------------
function [valueofCostFunction, signalData, errorEveryIter, dataEveryIter] = ...
    demoFncMC(maxFun, nChanceoverPoints, costFunction, sim, startingValues, ts, minLengthOfParts)
% Initialize error tracking and data storage
errorEveryIter = zeros(1, maxFun); % Allocate error vector
maxerr = 0; % Initialize max error as the lowest possible value
data = struct(); % Allocate the data structure

% Define vector sizes
nT = nChanceoverPoints; % Length of T vector 
nB = ceil(nT / 2); % Length of B vector 
nX = nB + 1; % Length of X vector 

% If starting values are provided, use them as initial data points
if ~isscalar(startingValues) 
    nStartingValues = length(startingValues(:, 1)); % Number of starting values
    for i = 1:nStartingValues
        T = startingValues(i, 1:nT); % Extract T values
        B = startingValues(i, nT + 1 : nB + nT); % Extract B values
        X = startingValues(i, nB + nT + 1 : nB + nX + nT); % Extract X values
        data.pls(:, i) = [T.'; B.'; X.']; % Store the combined data
        x = [T, B, X];
        
        % Evaluate cost function for the current input
        errorEveryIter(i) = objectiveFunction(x, nT, costFunction, sim, ts, minLengthOfParts); 
        
        % Update maximum error and corresponding data if better solution found
        if errorEveryIter(i) < maxerr
            maxerr = errorEveryIter(i);
            signalData = data.pls(:, i); % Store the best input so far
        end
    end
else
    nStartingValues = 0; % No starting values provided
end

% Generate new random samples until Maxfun evaluations are reached
for i = (nStartingValues + 1):maxFun 
    validT = false;
    % Generate a valid T vector that meets constraints
    while ~validT 
        T = minLengthOfParts + (1 - minLengthOfParts) * rand(1, nT); 
        validT = (sum(T) < (1 - minLengthOfParts));
    end
    
    % Generate random values for B and X within constraints
    B = randi(7, 1, nB); % Random integer values for B
    X = rand(1, nX);     % Random values for X
    
    % Store the generated values in the data structure
    data.pls(:, i) = [T.'; B.'; X.'];
    x = [T, B, X];

    % Evaluate cost function for the generated data
    errorEveryIter(i) = objectiveFunction(x, nT, costFunction, sim, ts, minLengthOfParts); 

    % Update maximum error and corresponding data if better solution found
    if errorEveryIter(i) < maxerr 
        maxerr = errorEveryIter(i); 
        signalData = data.pls(:, i); % Store the best input so far
    end
end

% Final outputs
dataEveryIter = data.pls; % Return all generated data
valueofCostFunction = maxerr; % Return the best cost function value found
end
