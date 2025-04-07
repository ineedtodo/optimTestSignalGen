function [pSys, pCont] = initMechSysWithFriction(deadZone,opt)

arguments
    deadZone
    opt.isNonLinear = false;
    opt.x0 = [];
    opt.selectControlType {mustBeMember(opt.selectControlType, {'deadZone', 'freeze'})} = 'deadZone'
end


if isempty(opt.x0)
    opt.x0 = 0;
end

% mass in kg
pSys.m1 = 1; % -> to be positioned

% springs
pSys.c1 = 2;    % default 2
pSys.x1_rel = 0;

% dampers / viscous friction
pSys.rv = 4;    % default 3

% initial condition
pSys.x1_0 = opt.x0;

% Coulomb friction
pSys.rC1 = 1;

% Stiction coefficient
pSys.rH1 = 2;       % default 2
pSys.v0 = 0.01;

% limitation of the input force
pCont.u_max = 10e3; % a_max = 2 g

% PI Controller parameters
V = 25;  % default = 4
TI = 2; % 4; % default = 1

pCont.kp = V;
pCont.kI = V/TI;
pCont.Ts = 10e-3;



% Stiction tresshold
pSys.vStuck = 1e-5; % m/s

if ~opt.isNonLinear
    % Coulomb friction
    pSys.rC1 = 0;
    % Stiction coefficient
    pSys.rH1 = 0;
end

% Toleranzband des Integrators
pCont.ex_deadBand = deadZone;
% if opt.isNonLinear
%     pCont.ex_deadBand = 5e-4;
% else

pCont.controlType = opt.selectControlType;

pSys.seed = round(rand() * 1e5);

end