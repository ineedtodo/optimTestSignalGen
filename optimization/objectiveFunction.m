% objectiveFunction - Evaluates the performance of a signal using a given cost function
%
% This function evaluates a signal for a closed-loop system. It uses the input 
% parameter `x` for the signal generator while ensuring that constraints are 
% satisfied. The generated signal is then used with the simulation function, 
% and its performance is assessed using a specified cost function.
%
% If you wish to use a different simulation function, consider the following outputs:
% - obj: Output of the cost function evaluating the signal's performance.
%
% Syntax:
%    obj = objectiveFunction(x, nT, costfunction, sim, ts, minLengthofParts)
%
% Inputs:
%    x                    - Input vector containing values for T, B, and X
%                            (double 1 x N)
%    nT                   - Number of elements in the T vector
%                            (integer scalar)
%    costfunction          - Function handle to compute the performance metric
%                            (function handle)
%    sim                   - Simulation function handle that returns system outputs
%                            (function handle)
%    ts                    - Sampling interval for interpolated signal values
%                            (double scalar, value in (0, 1))
%    minLengthofParts      - Minimum length constraint for individual segments
%                            (double scalar, value in (0, 1))
%
% Outputs:
%    obj                   - Output of the cost function evaluating the signal's performance
%                            (double scalar)
%
% Example:
%    x = [0.2, 0.3, 0.1, 1, 2, 0, 0.5, 1];
%    obj = objectiveFunction(x, 3, @myCostFunction, @mySimFunction, 0.001, 0.05);
%
% Dependencies:
%    Matlab release: R2021b or later
%    other m-files: signalGenerator.m 
%    MAT-files: none
%    Toolboxes: none
%
% This function is part of: Optimization-Based Signal Generator
%
%------------- BEGIN CODE ------------------------------------------------------
function obj = objectiveFunction(x, nT, costfunction, sim, ts, minLengthofParts)
%% Building the inputs for the signal generator
nB = ceil(nT / 2);     % Number of elements for the B vector (half of NT, rounded up)
nX = nB + 1;           % Number of elements for the X vector
T = x(1:nT);           % Extract the T vector from the input array
B = x((nT + 1):(nB + nT));     % Extract the B vector
X = x((nB + nT + 1):(nX + nB + nT)); % Extract the X vector

%% Safety checks
% Ensuring T values are non-negative
if min(T) < 0
    T = abs(T); 
    warning('tVector < 0, check lower boundaries')
end

% Ensuring the sum of T values does not exceed the allowed limit
while sum(T) >= (1 - minLengthofParts)
    for j = 1:length(T)
        T(j) = max(T(j) * (1 - minLengthofParts), minLengthofParts);
    end
    warning('Sum of tVector is too large, check linear boundaries')
end

% Ensuring B values are within acceptable limits
if max(B) > 7
    B = B * 0.1; % Scale down the B vector if its values are too large
    warning('bVector > 7, check upper boundaries')
end
if min(B) < 1
    warning('bVector < 1, check lower boundaries')
    for i = 1:length(B)
        if B(i) < 1
            B(i) = 1; % Correct B values below the lower limit
        end
    end
end

% Ensuring X values are within the range [0, 1]
if min(X) < 0
    warning('xVector < 0, check lower boundaries')
    X = abs(X); % Correct negative values by taking the absolute value
end
if max(X) > 1
    warning('xVector > 1, check upper boundaries')
    for i = 1:length(X)
        if X(i) > 1
            X(i) = 1; % Cap values exceeding the upper limit
        end
    end
end

% Generate the input data for the simulation
pardata = signalGenerator(T, B, X, "isPlot", false, "isStat", true, 'Ts', ts);

% Run the simulation with the generated input data
[y_in, y_out] = sim(pardata);

% Evaluate the cost using the provided cost function
obj = costfunction(y_in, y_out);
end