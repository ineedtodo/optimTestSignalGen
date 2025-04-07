% demo - Runs optimization for a spring-mass system using different methods
%
% This script demonstrates the usage of both Surrogate and Monte Carlo 
% optimization methods to tune test trajectories for a spring-mass system. The 
% optimization can be run using either method with configurable parameters 
% such as the number of crossover points, cost function, and time step.
%
% Configuration / Parameters: 
%    nChanceoverPoints - Number of change points in the signal (scalar)
%    ts                - Sampling time for signal interpolation (scalar, default = 1e-2)
%    OPT.plot          - If true, plots the optimization results (logical)
%    OPT.startingValues- If true, loads starting values from file (logical)
%    OPT.method        - Optimization method, either 'surrogate' or 'monteCarlo' (string)
%    OPT.cost          - Cost function, either 'mae' or 'rmse' (string)
%
% Results / Outputs:
%    Plot of the resulting signals if OPT.plot is enabled
%    Optimization results stored in variables (valueOfCostFunction, parameters, etc.)
%
%
% Dependencies:
%    Matlab release: R2021b or later
%    other m-files: signalGenerator, simSpringMassSystem, costMae, costRmse
%    MAT-files: startingValuesForSpringMassSystem.mat (if OPT.startingValues is true)
%    Toolboxes: none
%
% See also: signalGenerator, simSpringMassSystem, demoFncSurrogate, demoFncMC
%
% This function is part of: Optimization-Based Signal Generator
%
%------------- BEGIN CODE ------------------------------------------------------
% Set up project paths for necessary functions
currentFolder = fileparts(mfilename('fullpath'));
addpath(fullfile(currentFolder,'models'))
addpath(fullfile(currentFolder,'optimization'))
addpath(fullfile(currentFolder,'signalGenerator'))

% Define the number of change points in the signal
nChanceoverPoints = 4;

% Define the sampling time for signal interpolation (default = 1e-2)
ts = 1e-2;

% Options for plotting results and using predefined starting values
OPT.plot = true;
OPT.startingValues = false;
OPT.method = 'monteCarlo'; % member from {'surrogat', 'monteCarlo'};
OPT.cost = 'mae'; % member from {'mae', 'rmse'};



% Load starting values if the option is enabled
if OPT.startingValues
    load('startingValuesForSpringMassSystem.mat','StartingValues')
    A = StartingValues{nChanceoverPoints-2};  % Use the corresponding starting values
else
    A = 0;  % No starting values provided, defaults to zero
end

% Define the simulation function for the closed-loop system\% This function must output [y_in, y_out] as defined in 'How to Use'
sim = @(x) simSpringMassSystem(x, 1);

% Set maximum rate of change for the demo (based on 1-second duration assumption)
minLengthofParts = 0.05;
%minLengthofParts= maxRateOfChangeMapFnc(47);

% Define the cost function 
switch OPT.cost
    case 'mae'
        costFunction = @costMae;
    case 'rmse'        
        costFunction = @costRmse;
end

switch OPT.method
    case 'surrogat'
        % Run the Surrogate optimization with 100 iterations
        % maxRateOfChance = maxRateOfChanceDeterminationFnc(MaxRateOfChance);
        [valueOfCostFunction, parameters, valueOfCostFunctionEveryIter, dataEveryIter] = demoFncSurrogate(100, nChanceoverPoints, costFunction, sim, A, ts, minLengthofParts);
    case 'monteCarlo'
        % Run the Monte Carlo optimization with 50 iterations
        [valueOfCostFunction, parameters, valueOfCostFunctionEveryIter, dataEveryIter] = demoFncMC(100, nChanceoverPoints, costFunction, sim, A, ts, minLengthofParts);    
end

% Plot the resulting signals if the plotting option is enabled
if OPT.plot
    plotResults(parameters, nChanceoverPoints, sim, costFunction, ts);
end


