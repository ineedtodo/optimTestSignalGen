% signalGenerator - Generates a segmented signal using predefined patterns
%
% This function constructs a piecewise-defined signal composed of static and 
% dynamic segments. It combines various segment types to generate a flexible 
% signal structure for testing, simulation, or modeling purposes.
%
% Syntax:  
%    par = signalGenerator(tVector, bVector, xVector, opt)
%
% Inputs:
%    tVector - Time vector describing segment durations 
%              (double N x 1, values in [0, 1], sum must be ≤ 1)
%    bVector - Segment vector specifying which dynamic segments to use
%              (double L x 1, values in [1, 7])
%    xVector - Value vector defining the signal's boundary values
%              (double K x 1, values in [0, 1])
%    opt     - Structure containing optional fields:
%              .isPlot - Enable/disable plotting of the generated signal
%                        (logical, default = true)
%              .Ts     - Sampling interval for interpolated signal values
%                        (double scalar, value in (0, 1/ nKnots))
%              .isStat - Flag to indicate whether the signal starts with a 
%                        static segment (logical, default = true)
%              .nKnots - Number of points for each segment 
%                        (integer scalar, default = 20)
%
% Outputs:
%    par - Structure containing the following fields:
%          .t_knots - Time values at key points of the generated signal
%                     (double 1 x (N + 1) * opt.nKnots-N)
%          .x_knots - Signal values at the key points
%                     (double 1 x (N + 1) * opt.nKnots-N)
%          .t_sd    - Time values at the defined changeover points
%                     (double 1 x N + 2)
%          .x_sd    - Signal values at these changeover points
%                     (double 1 x N + 2)
%          .inter_t - Interpolated time vector for finer resolution
%                     (double 1 x opt.Ts^(-1)+1)
%          .inter_x - Interpolated signal values for finer resolution
%                     (double 1 x opt.Ts^(-1)+1)
%
% Example: 
%    opt.isPlot = true;
%    opt.Ts = 0.001;
%    par = signalGenerator([0.2, 0.3, 0.4], [1, 3], [0, 0.5, 1], opt);
%
% Dependencies:
%    Matlab release: 2021b
%    Other m-files : coreGenerator, segments
%    MAT-files      : none
%    Toolboxes      : none
%
% This function is part of: Optimization-Based Signal Generator
%
%------------- BEGIN CODE ------------------------------------------------------
function par = signalGenerator(tVector, bVector, xVector, opt)
arguments
    tVector  (:,1)   double % Time vector, describes the duration until the next segment. Entries must be between 0 and 1, and their sum must be less than 1
    bVector   (:,1)   double % Segment vector, entries specify which of the 7 segment functions will be used in the dynamic parts
    xVector   (:,1)   double % Value vector, entries describe the value at the start and end of the signal, as well as the start and end of dynamic parts
    opt.isPlot         (1,1)   logical = true % Option to plot the generated signal
    opt.Ts             (1,1)   double = 0.001 % Fineness of the interpolation
    opt.isStat         (1,1)   logical = true % Option to evaluate static/dynamic segments
    opt.nKnots    {mustBePositive}=20  % Number of points on which the signal is evaluated
end

%% Input validation
if sum(tVector) > 1 % Ensures total time does not exceed 1
    warning('Sum of tVector is greater than 1, so it will be truncated at 1')
end
N = length(tVector); % Length of the time vector

% Determine dimensions of xVector and bVector based on whether the signal starts with a constant part
if opt.isStat == true 
    NB = ceil(N / 2); % Number of segments in static mode
    NX = NB + 1; % Number of points in xVector for static mode
else
    NB = floor(N / 2) + 1; % Number of segments in dynamic mode
    NX = NB + 1; % Number of points in xVector for dynamic mode
end

% Check if the length of xVector and bVector is correct
if NX > length(xVector)
    error('xVector is too short');
end
if NB > length(bVector)
    error('bVector is too short');
end
if NX < length(xVector)
    warning('xVector is too long; excess values may be unused');
end
if NB < length(bVector)
    warning('bVector is too long; excess values may be unused');
end

% Ensure valid ranges for input vectors
if ~all(tVector >= 0)
    error('Values of tVector must be greater than or equal to 0')
end
if ~all(xVector >= 0 & xVector <= 1)
    warning('Values of xVector must be between 0 and 1')
end
if ~all(bVector >= 1 & bVector <= 7)
    error('Values of bVector must be between 1 and 7')
end

%% Signal generation using coreGenerator
[t_knots, x_knots, t_sd, x_sd, inter_t, inter_x] = ...
    coreGenerator(tVector, bVector, xVector, opt.isStat, opt.Ts, opt.nKnots);

% Assigning generated signal values to the output structure
par.t_knots = t_knots; 
par.x_knots = x_knots;
par.t_sd = t_sd;
par.x_sd = x_sd;
par.inter_t = inter_t;
par.inter_x = inter_x;

%% Plotting
if opt.isPlot
    a = cumsum(tVector); % Cumulative sum for segment boundaries
    t = [0; a; 1];
    figure
    plot(par.t_knots, par.x_knots, 'x-', 'LineWidth', 1.2); % Plotting the generated signal
    hold on

    % Identify if the first segment is static
    if par.x_knots(2) - par.x_knots(1) == 0
        j_1 = 1;
    else
        j_1 = 2;
    end

    % Plot shaded areas for static and dynamic segments
    for j = j_1:2:N + 1
        area([t(j) t(j + 1)], [1 1], 'FaceColor', 'g', 'FaceAlpha', 0.3, 'LineStyle', 'none');
    end

    % Configure axis limits and labels
    ylim([0 1])
    xlim([0 t(end)])
    xlabel('t', 'Interpreter', 'latex')
    ylabel('$\chi(t)$', 'Interpreter', 'latex')
    grid on
    hold off
end
end
