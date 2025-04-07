% coreGenerator - Generates a segmented signal with dynamic and static parts
%
% This function constructs a signal by combining static and dynamic segments.
% It aligns them with specified time intervals and values at each transition
% point. This is the core of the signalGenerator and should be used with the
% signalgenerator. Note that it has no safety mechanisms for incorrect inputs.
%
% Syntax:
%    [t_knots, x_knots, t_sd, x_sd, inter_t, inter_x] = coreGenerator(tVector, bVector, xVector, isStat, ts, nKnots)
%
% Inputs:
%    tVector - Time vector specifying segment durations
%              (double 1 x N, values in [0, 1])
%    bVector - Segment vector indicating which dynamic segments to use
%              (double 1 x K, values in [1, 7])
%    xVector - Value vector defining the signal's boundary values
%              (double 1 x L, values in [0, 1])
%    isStat  - Logical flag to indicate whether the signal starts with a
%              static segment (logical)
%    ts      - Sampling interval for interpolated signal values
%              (double scalar, value in (0, 1/ nKnots))
%    nKnots  - Number of points for each segment
%              (integer scalar)
%
% Outputs:
%    t_knots - Time values at key points of the generated signal
%              (double 1 x (N + 1) * nKnots-N)
%    x_knots - Signal values at the key points
%              (double 1 x (N + 1) * nKnots-N)
%    t_sd    - Time values at the defined changeover points
%              (double 1 x N + 2)
%    x_sd    - Signal values at these changeover points
%              (double 1 x N + 2)
%    inter_t - Interpolated time vector for finer resolution
%              (double 1 x ts^(-1)+1)
%    inter_x - Interpolated signal values for finer resolution
%              (double 1 x ts^(-1)+1)
%
% Example:
%    tVector = [0.2, 0.3, 0.3, 0.1];
%    bVector = [1, 2];
%    xVector = [0, 0.5, 1];
%    [t_knots, x_knots, t_sd, x_sd, inter_t, inter_x] = coreGenerator(tVector, bVector, xVector, true, 0.001, 20);
%
% Subfunctions: segments
%
% Dependencies:
%    Matlab release: R2021b or later
%    other m-files: segments
%    MAT-files: none
%    Toolboxes: none
%
% This function is part of: Optimization-Based Signal Generator
%
%------------- BEGIN CODE ------------------------------------------------------

function [t_knots, x_knots, t_sd, x_sd, inter_t, inter_x] = ...
    coreGenerator(tVector, bVector, xVector, isStat, ts, nKnots) %#codegen 
% Allocate memory
N = length(tVector); % Number of changeover points
inter_t = 0:ts:1; % Define the interpolation resolution

t_knots = zeros(1, (N + 1) * (nKnots - 1) + 1); % Time values for the entire signal
x_knots = zeros(size(t_knots)); % Signal values for the entire signal

x = zeros(1, N + 2); % Signal values at changeover points
x(1) = xVector(1); % First value at time 0
a = cumsum(tVector); % Cumulative sum to compute time points
t = [0, a(:)', 1]; % Constructing a usable time vector

% Block 2: Determining x values and building the function
i = 1; % Counter for total number of parts
j = 1; % Counter for number of dynamic parts
h = -1; % Counter for indexing calculations

while true % Infinite loop until a break condition is met
    if isStat == true % Stationary part starts
        x(i + 1) = x(i); % X remains the same
        t_b = linspace(0, 1, nKnots); % Generate knot time points
        x_b = ones(1, nKnots); % Create a vector of ones

        if i == 1 % Special handling for the first segment
            t_sc = t_b * (t(i + 1) - t(i)) + t(i); % Compute the corresponding time vector for this part
            x_sc = x(i) * x_b; % Generate x vector for this part
            t_knots(1:nKnots) = t_sc; % Store in the final vector
            x_knots(1:nKnots) = x_sc;
        else
            t_sc = t_b(2:end) * (t(i + 1) - t(i)) + t(i); % Exclude first value to avoid overlap
            x_sc = x(i) * x_b(2:end); % Adjust x values accordingly
            t_knots(nKnots + 1 + h * (nKnots - 1) : 2 * nKnots - 1 + h * (nKnots - 1)) = t_sc;
            x_knots(nKnots + 1 + h * (nKnots - 1) : 2 * nKnots - 1 + h * (nKnots - 1)) = x_sc;
        end
    
    else % Dynamic part starts
        if j == length(xVector) % Ensure x(i + 1) exists
            x(i + 1) = xVector(j);
        else
            x(i + 1) = xVector(j + 1);
        end
        [t_b, x_b] = segments(bVector(j), nKnots); % Generate dynamic part using the segments function

        if i == 1 % Special handling for the first segment
            t_sc = t_b * (t(i + 1) - t(i)) + t(i); % Compute time vector for this part
            x_sc = x(i) + (x(i + 1) - x(i)) * x_b; % Scale x_b to fit the signal
            t_knots(1:nKnots) = t_sc; % Store in the final vector
            x_knots(1:nKnots) = x_sc;
        else
            t_sc = t_b(2:end) * (t(i + 1) - t(i)) + t(i); % Exclude first value to avoid overlap
            x_sc = x(i) + (x(i + 1) - x(i)) * x_b(2:end); % Scale x_b accordingly
            t_knots(nKnots + 1 + h * (nKnots - 1) : 2 * nKnots - 1 + h * (nKnots - 1)) = t_sc;
            x_knots(nKnots + 1 + h * (nKnots - 1) : 2 * nKnots - 1 + h * (nKnots - 1)) = x_sc;
        end

        j = j + 1; % Increment dynamic parts counter
    end

    if t(i + 1) >= 1 % Break condition when time reaches or exceeds 1
        break;
    end

    isStat = ~isStat; % Alternate between stationary and dynamic parts
    i = i + 1; % Increment total parts counter
    h = h + 1; % Increment index counter
end

% Interpolate the knots
inter_x = interp1(t_knots, x_knots, inter_t);
t_sd = t;
x_sd = x;
end
