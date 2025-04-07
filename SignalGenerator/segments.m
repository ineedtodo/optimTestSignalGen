% segments - Generates a predefined signal segment based on an index value
%
% This function constructs a segment of a signal using various mathematical 
% functions (e.g., linear, polynomial, exponential). The segment type is 
% determined by the provided index.
%
% Syntax:  
%    [t, x] = segments(i, nKnots)
%
% Inputs:
%    i      - Index value specifying the segment type
%              (integer scalar, value in [1, 7], default = random integer)
%    nKnots - Number of points for the generated segment 
%              (integer scalar, default = 20)
%
% Outputs:
%    t - Time vector for the segment 
%        (double 1 x N, values in [0, 1])
%    x - Signal values corresponding to the time vector 
%        (double 1 x N, values in [0, 1])
%
% Example: 
%    [t, x] = segments(3, 50); % Generates an exponential segment with 50 points
%    plot(t, x); % Visualize the generated segment
%
% Segment Types:
%    i = 1 : Linear ramp function
%    i = 2 : Sine function (f(0)=0, f(1)=1)
%    i = 3 : Exponential function (f(0)=0, f(1)=1)
%    i = 4 : Quadratic polynomial (f(0)=0, f(1)=1)
%    i = 5 : Fourth-degree polynomial (f(0)=0, f(1)=1)
%    i = 6 : Sixth-degree polynomial (f(0)=0, f(1)=1)
%    i = 7 : Eighth-degree polynomial (f(0)=0, f(1)=1)
%
%
% Dependencies:
%    Matlab release: 2021b
%    other m-files: none
%    MAT-files: none
%    Toolboxes: none
%
%
% This function is part of: Optimization-Based Signal Generator
%
%------------- BEGIN CODE ------------------------------------------------------
function [t,x] = segments(i,nKnots)
arguments
    i (1,1) {mustBePositive} = ceil(rand(1) * 7) % Random integer between 1 and 7 if not provided
    nKnots (1,1) {mustBePositive} = 20 % Default number of points for the segment
end

% Ensure 'i' is an integer to avoid mixed-integer optimization issues
if ~isinteger(i)
    i = round(i);
end

% Safety check to ensure 'i' is within the valid range [1, 7]
if i < 1 || i > 7
   warning('Index out of range! Assigning random value between 1 and 7.')
   i = ceil(rand(1) * 7);
end

% Initialize the time vector with values between 0 and 1
t = linspace(0, 1, nKnots);

% Select the appropriate segment type based on the index value
switch(i)
    case 1
        x = t; % Linear ramp function
    case 2
        x = sin(pi/2 * t); % Sine function, ensuring f(0)=0 & f(1)=1
    case 3
        x = (1 - exp(t)) / (1 - exp(1)); % Exponential function, ensuring f(0)=0 & f(1)=1
    case 4
        x = t.^2; % Quadratic polynomial, ensuring f(0)=0 & f(1)=1
    case 5
        x = -3*t.^4 + 4*t.^3; % Fourth-degree polynomial, ensuring f(0)=0 & f(1)=1
    case 6
        x = 10*t.^6 - 24*t.^5 + 15*t.^4; % Sixth-degree polynomial, ensuring f(0)=0 & f(1)=1
    case 7
        x = -35*t.^8 + 120*t.^7 - 140*t.^6 + 56*t.^5; % Eighth-degree polynomial, ensuring f(0)=0 & f(1)=1
    otherwise % Extra safety measure in case of unexpected values
        x = t;
end

end