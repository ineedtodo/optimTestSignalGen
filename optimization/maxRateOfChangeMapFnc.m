% maxRateOfChangeMapFnc - Computes the minimum length of parts based on the maximum rate of change
%
% This function calculates the minimum allowable length of parts for the
% signal Generator given a specified maximum rate of change of the closed loop system. The calculation is based on a fixed 
% scaling factor.
%
% Syntax:
%    minLengthofParts = maxRateOfChangeMapFnc(maxRateOfChance)
%
% Inputs:
%    maxRateOfChance - Maximum allowable rate of change 
%                      (double scalar)
%
% Outputs:
%    minLengthofParts - Computed minimum length of parts
%                       (double scalar)
%
% Example:
%    maxRate = 0.05;
%    minLength = maxRateOfChangeMapFnc(maxRate);
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

function [minLengthofParts] = maxRateOfChangeMapFnc(maxRateOfChance)
    minLengthofParts = 1/maxRateOfChance * 276480/117649;
end