% simSpringMassSystem - Simulates a spring-mass-damper system with optional nonlinearity
%
% This function simulates a mechanical system with friction effects using 
% either a linear or nonlinear model. The system behavior is influenced by 
% control parameters and simulated over a defined time span.
%
% If you wish to use a different simulation function, consider the following outputs:
% - y_in and y_out: Minimum requirements for the optimization to function properly.
% - time_in and time_out: Used solely to improve plot accuracy.
% - u (Control Signal): Included for visualization purposes only.
%
% Syntax:
%    [y_in, y_out, time_in, time_out, u] = simSpringMassSystem(par, isNonLinear)
%
% Inputs:
%    par         - Structure containing interpolation data of a setpoint 
%                  .inter_t - Time points for signal generation
%                             (double 1 x K)
%                  .inter_x - Position values for signal generation
%                             (double 1 x K)
%    isNonLinear - Flag to select linear (false) or nonlinear (true) mode
%                  (logical)
%
% Outputs:
%    y_in        - System's input signal (position reference)
%                  (double 1 x N)
%    y_out       - System's output signal (measured position)
%                  (double 1 x N)
%    time_in     - Time vector corresponding to `y_in`
%                  (double 1 x N)
%    time_out    - Time vector corresponding to `y_out`
%                  (double 1 x N)
%    u           - Control signal used during the simulation
%                  (double 1 x N)
%
% Example:
%    params.inter_t = linspace(0, 1, 500); 
%    params.inter_x = rand(1, 500); 
%    [y_in, y_out, time_in, time_out, u] = simSpringMassSystem(params, true);
%
% Dependencies:
%    Matlab release: R2021b or later
%    other m-files: initMechSysWithFriction
%    MAT-files: none
%    Toolboxes: none
%
% This function is part of: Optimization-Based Signal Generator
%
%------------- BEGIN CODE ------------------------------------------------------
function [y_in, y_out, time_in, time_out, u] = simSpringMassSystem(par, isNonLinear)

T_SIM = 100; % Total simulation time in seconds
X_MAX = 1;   % Maximum position
X_MIN = 0;   % Minimum position

% Select simulation type: linear or nonlinear
if isNonLinear == false
    deadband = 0; % No deadband in the linear simulation
else
    deadband = 2e-2; % Deadband of 0.02 in the nonlinear simulation
end

% Selection of the friction handling method
% Options: 'freeze' (default) or 'deadZone'
ct = 'freeze';  

spr_traj = 4; % Defines the signal used in the simulation

% Create the simulation input values based on the provided parameters
simin = [(T_SIM * par.inter_t)', (X_MIN + (X_MAX - X_MIN) * par.inter_x)'];

% Initialize the mechanical system with the chosen parameters
[parSys, parControl] = initMechSysWithFriction(deadband, ...
    'isNonLinear', isNonLinear, ...
    'x0', simin(1, 2), ...
    'selectControlType', ct);

% Configure the simulation by setting variables in the Simulink workspace
in = Simulink.SimulationInput('systemMechanicalFriction');
in = in.setVariable('parControl', parControl);
in = in.setVariable('parSys', parSys);
in = in.setVariable('simin', simin);
in = in.setVariable('T_SIM', T_SIM);
in = in.setVariable('X_MAX', X_MAX);
in = in.setVariable('X_MIN', X_MIN);
in = in.setVariable('spr_traj', spr_traj);

% Run the simulation
sout = sim(in);

% Extract output data:
% - 'y_in' and 'y_out' are the system's input and output values
% only used for the Plotfunction
% - 'time_in' and 'time_out' are the corresponding time vectors
% - 'u' is the control signal
y_in = sout.simout.signals.values(:, 1);
y_out = sout.simout.signals.values(:, 4);
time_in = sout.simout.time/T_SIM;
time_out = sout.simout.time/T_SIM;
u = sout.simout.signals.values(:, 3);
end