% plotResults - Plots the optimization results and visualizes the simulation
%
% This function generates plots comparing the simulation results and the
% setpoint, along with control inputs and the cost buildup over time.
% The function can be customized to exclude simulation time or control 
% input vectors using the provided options.
%
% Syntax:  fig = plotResults(data, nChanceoverPoints, sim, costFunction, ts, opt)
%
% Inputs:
%    data              - Simulation data containing vectors T, B, and X  
%                        (double N x 1)
%    nChangeoverPoints - Number of crossover points for optimization  
%                        (integer scalar)
%    sim               - Simulation function handle, see `simSpringMassSystem`  
%                        (function_handle)
%    costFunction      - Cost function handle for performance evaluation  
%                        (function_handle)
%    ts                - Time step for the signal generator  
%                        (double scalar)
%    opt               - Structure containing optional fields:
%                        .noSimTime - Excludes simulation time if true  
%                                      (logical, default = false)
%                        .noU       - Excludes control input if true  
%                                      (logical, default = false)
%
% Outputs:
%    fig               - Figure handle for the generated plots  
%                        (figure)
% Example:
%    fig = plotResults(data, 100, @simSpringMassSystem, @costMae, 0.01, struct('noSimTime', false, 'noU', false));
%
%
% Dependencies:
%    Matlab release: R2021b or later
%    other m-files: signalGenerator, simSpringMassSystem (simulation function) 
%    MAT-files: none
%    Toolboxes: none
%
%
% This function is part of: Optimization-Based Signal Generator
%
%------------- BEGIN CODE ------------------------------------------------------
function [fig] = plotResults(data, nChanceoverPoints, sim, costFunction, ts, opt)
arguments
    data (:,1)   double
    nChanceoverPoints (1,1) double
    sim (1,1) function_handle
    costFunction (1,1) function_handle
    ts (1,1) double
    opt.noSimTime (1,1) logical=0
    opt.noU (1,1) logical=0
end
% This function plots the results of the optimization and performs a new
% simulation for visualization. If the simulation function does not provide
% a time output, use option `opt.noSimTime`. If the simulation function does
% not include control input `u`, use option `opt.noU`.

% Extract input vectors from the data
nT = nChanceoverPoints; %  Length of T vector
nB = ceil(nT/2); %  Length of VB vector
nX = nB + 1; %  Length of X vector
T = data(1:nT);           % Extract the T vector from the input array
B = data((nT + 1):(nB + nT));     % Extract the B vector
X = data((nB + nT + 1):(nX + nB + nT)); % Extract the X vector

% Use the signal generator to create the input for the simulation
pardata = signalGenerator(T, B, X, "isPlot", false, "isStat", true, "Ts", ts);

% Run the simulation with the generated signal
if opt.noSimTime && opt.noU % No time or control input vectors available
    [y_in, y_out] = sim(pardata);
    time_in = (0:1/length(y_in(1:end-1)):1).'; % Generate a time vector
    time_out = (0:1/length(y_out(1:end-1)):1).';
elseif ~opt.noSimTime && opt.noU % Only time vectors available, no control input
    [y_in, y_out, time_in, time_out] = sim(pardata);
elseif opt.noSimTime && ~opt.noU % Control input available, but no time vectors
    [y_in, y_out, ~, ~, u] = sim(pardata);
    time_in = (0:1/length(y_in(1:end-1)):1).';
    time_out = (0:1/length(y_out(1:end-1)):1).';
else % Both time and control input vectors available
    [y_in, y_out, time_in, time_out, u] = sim(pardata);
end

% Initialize cost calculation
f1 = @costMae;
f2 = @costRmse;
for i = 1:length(y_in)
    Costeverystep(i) = -costFunction(y_in(i), y_out(i)); % Compute cost for each step
end

% Compute cumulative cost buildup based on the selected cost function
if isequal(costFunction, f1)
    Costbuildup = cumsum(Costeverystep / length(y_in));
elseif isequal(costFunction, f2)
    for i = 1:length(y_in)
        Costbuildup(i) = (y_in(i) - y_out(i)).^2;
    end
    Costbuildup = sqrt(cumsum(Costbuildup) / length(y_in));
else % Warning for unknown cost function
    Costbuildup = cumsum(Costeverystep / length(y_in));
    warning('Cost buildup may be inaccurate!')
end

% Create and format plots
fig = figure;
Fontsize = 20;
if ~opt.noU % Four plots if control input `u` is available
    ax(1) = subplot(4,1,1); hold on; grid on;
    h1 = plot(time_out, y_out, 'DisplayName', 'simulation $y_{sys}$');
    h2 = plot(time_in, y_in, 'DisplayName', 'setpoint $y^d$');
    uistack(h1, 'top');
    ylim([-0.05, 1.05]);

    legend('Position', [0.4, 0.92, 0.2, 0.05], 'Interpreter', 'latex', 'FontSize', Fontsize, 'Orientation', 'horizontal', 'Box', 'off');
    ylabel('System I/O', 'Interpreter', 'latex');
    set(gca, 'FontSize', Fontsize);

    ax(2) = subplot(4,1,2); hold on; grid on;
    plot(time_out, u/4, 'DisplayName', 'u'); % Scaled control input plot
    ylabel('Input force', 'Interpreter', 'latex');
    set(gca, 'FontSize', Fontsize);

    ax(3) = subplot(4,1,3); hold on; grid on;
    plot(time_out, Costeverystep, 'DisplayName', '|x-y|');
    ylabel('Cost per step', 'Interpreter', 'latex');
    set(gca, 'FontSize', Fontsize);

    ax(4) = subplot(4,1,4); hold on; grid on;
    plot(time_out, Costbuildup, 'DisplayName', 'Cost buildup');
    plot([time_out(1), time_out(end)], -costFunction(y_in, y_out) * [1, 1], '--', 'Color', ax(3).ColorOrder(1, :), 'DisplayName', 'Total Cost');
    ylabel('Cost', 'Interpreter', 'latex');
    xlabel('Time', 'Interpreter', 'latex');
    set(gca, 'FontSize', Fontsize);
else % Three plots if no control input `u` is available
    ax(1) = subplot(3,1,1); hold on; grid on;
    h1 = plot(time_out, y_out, 'DisplayName', 'simulation $y_{sys}$');
    h2 = plot(time_in, y_in, 'DisplayName', 'setpoint $y^d$');
    uistack(h1, 'top');

    legend('Position', [0.4, 0.92, 0.2, 0.05], 'Interpreter', 'latex', 'FontSize', Fontsize, 'Orientation', 'horizontal', 'Box', 'off');
    ylabel('System I/O', 'Interpreter', 'latex');
    set(gca, 'FontSize', Fontsize);

    ax(2) = subplot(3,1,2); hold on; grid on;
    plot(time_out, abs(y_in - y_out), 'DisplayName', '|x-y|');
    ylabel('Error per step', 'Interpreter', 'latex');
    set(gca, 'FontSize', Fontsize);

    ax(3) = subplot(3,1,3); hold on; grid on;
    plot(time_out, Costbuildup, 'DisplayName', 'Cost buildup');
    plot([time_out(1), time_out(end)], -costFunction(y_in, y_out) * [1, 1], '--', 'Color', ax(3).ColorOrder(1, :), 'DisplayName', 'Total Cost');
    ylabel('Cost', 'Interpreter', 'latex');
    xlabel('Time', 'Interpreter', 'latex');
    set(gca, 'FontSize', Fontsize);
end

linkaxes(ax, 'x');
set(gcf, 'DefaultAxesTickLabelInterpreter', 'latex');
set(gcf, 'DefaultLegendInterpreter', 'latex');
set(gcf, 'DefaultTextInterpreter', 'latex');
if ~strcmp(get(fig, 'WindowStyle'), 'docked')
    set(fig, 'WindowState', 'maximized');
end

end


% function [fig] = plotResults(data, nChanceoverPoints, sim, costFunction, ts, opt)
% arguments
%     data (:,1)   double
%     nChanceoverPoints (1,1) double
%     sim (1,1) function_handle
%     costFunction (1,1) function_handle
%     ts (1,1) double
%     opt.noSimTime (1,1) logical=0
%     opt.noU (1,1) logical=0
% end
% % This Function plots the Results of the optimatzion, and does a new
% % simulation for this. If the simfunction does not have a time output use
% % option opt.nosimtime if the simfunction has no u us option opt.noU.
% 
% 
% %read out the inputvectors from the data
% NT = nChanceoverPoints;
% NB = ceil(NT/2);
% NX = NB + 1;
% T=data(1:NT);
% B=data(NT+1:NT+NB);
% X=data(NT+1+NB:NT+NB+NX);
% 
% %use the Singalgenerator to Generate the Input for the Simulation
% pardata=signalGenerator(T,B,X,"isPlot",false,"isStat",true,"Ts",ts);
% %Run the Simulation with the Signal
% if opt.noSimTime && opt.noU % if not U or Timevectors are given
%     [y_in,y_out]=sim(pardata);
%     time_in=(0:1/length(y_in(1:end-1)):1).'; %Produces a timevector
%     time_out=(0:1/length(y_out(1:end-1)):1).';
% elseif ~opt.noSimTime && opt.noU % if no U is given
%     [y_in,y_out,time_in,time_out]=sim(pardata);
% elseif opt.noSimTime && ~opt.noU % if U is given but no timevector
%     [y_in,y_out,~,~,u]=sim(pardata);
%     time_in=(0:1/length(y_in(1:end-1)):1).';%Produces a timevector
%     time_out=(0:1/length(y_out(1:end-1)):1).';
% else
%     [y_in,y_out,time_in,time_out,u]=sim(pardata);
% end
% % for choosing the right Costbuildup
% f1 = @costMae;
% f2 = @costRmse;
% for i=1:length(y_in)
% Costeverystep(i)=-costFunction(y_in(i),y_out(i)); %Making the Costeverystep Plot possible
% end
% 
% if isequal(costFunction,f1) % Creating the Corst Build up Vectors for the plot
%     Costbuildup=cumsum(Costeverystep/length(y_in));
% elseif isequal(costFunction,f2)
%     for i=1:length(y_in)
%         Costbuildup(i)=(y_in(i)-y_out(i)).^2;
%     end
%     Costbuildup=sqrt((cumsum(Costbuildup)/length(y_in)));
% else%Waring because Costfunktion might not be accuract for Cost Build Up
%     Costbuildup=cumsum(Costeverystep/length(y_in));
%     warning('Cost buildup will be wrong!')
% end
% 
% fig=figure;
% Fontsize=20;
% if ~opt.noU %If there is a U 4 Plots
%     ax(1) = subplot(4,1,1); hold on; grid on; % 4 subplots
%     h1=plot(time_out,y_out,'DisplayName','simulation $y_{sys}$'); % ploting out
%     h2=plot(time_in,y_in,'DisplayName','setpoint $y^d$'); % ploting in
%     uistack(h1, 'top');
%     ylim([-0.05,1.05]);
% 
%     legend('Position', [0.4,0.92,0.2,0.05],'Interpreter','latex','FontSize',Fontsize,Orientation='horizontal',Box='off'); %making the top legend
%     ylabel('Position','Interpreter','latex')
%     %xlabel('time','Interpreter','latex')
%     set(gca, 'Fontsize',Fontsize); % make the Font Big
% 
%     ax(2) = subplot(4,1,2); hold on; grid on;
%     plot(time_out,u/4,DisplayName='u'); % plot the input force /4 because of scaling (looks better)
%     %xlabel('time','Interpreter','latex')
%     ylabel('input force','Interpreter','latex')
%     set(gca, 'Fontsize',Fontsize); % make the Font Big
% 
%     ax(3) = subplot(4,1,3); hold on; grid on;
%     plot(time_out,Costeverystep,'DisplayName','|x-y|') % Plot error in every step 
%     ylabel('Cost in every step','Interpreter','latex')
%     %xlabel('time','Interpreter','latex')
% 
%     set(gca, 'Fontsize',Fontsize);
%     ax(4) = subplot(4,1,4); hold on; grid on;
%     plot(time_out,Costbuildup,'DisplayName','Cost buildup') %Plot the costbuildup
%     plot([time_out(1),time_out(end)],-costFunction(y_in,y_out)*[1,1],'--','Color',ax(3).ColorOrder(1,:),'DisplayName','Cost') %plot the Cost
%     ylabel('Cost','Interpreter','latex')
%     set(gca, 'DefaultAxesTickLabelInterpreter', 'latex');
%     legend('Position', [0.224721948172136,0.249333333673931,0.554127532227155,0.0552380945569],'Interpreter','latex','FontSize',Fontsize,Orientation='horizontal',Box='off'); % making the legend again go into between the spaces
%     xlabel('time','Interpreter','latex');
%     set(gca, 'Fontsize',Fontsize);
% 
% else %If there is no U 3 Plots
%     ax(1) = subplot(3,1,1); hold on; grid on;
%     h1=plot(time_out,y_out,'DisplayName','simulation $y_{sys}$');
%     h2=plot(time_in,y_in,'DisplayName','setpoint $y^d$');
%     uistack(h1, 'top');
% 
%     legend('Position', [0.4,0.92,0.2,0.05],'Interpreter','latex','FontSize',Fontsize,Orientation='horizontal',Box='off');
%     ylabel('Position','Interpreter','latex')
%     %xlabel('time','Interpreter','latex')
%     set(gca, 'Fontsize',Fontsize);
% 
%     ax(2) = subplot(3,1,2); hold on; grid on;
%     plot(time_out,abs(y_in-y_out),'DisplayName','|x-y|') % Plot error in every step 
%     ylabel('error in every step','Interpreter','latex')
%     %xlabel('time','Interpreter','latex')
% 
% 
%     set(gca, 'Fontsize',Fontsize);
%     ax(3) = subplot(3,1,3); hold on; grid on;
%     plot(time_out,(Costbuildup),'DisplayName','Cost buildup')%Plot the costbuildup
%     plot([time_out(1),time_out(end)],-costFunction(y_in,y_out)*[1,1],'--','Color',ax(3).ColorOrder(1,:),'DisplayName','Cost')%plot the Cost
%     ylabel('Cost','Interpreter','latex')
%     set(gca, 'DefaultAxesTickLabelInterpreter', 'latex');
%     legend('Position', [0.224721948172136,0.249333333673931,0.554127532227155,0.0552380945569],'Interpreter','latex','FontSize',Fontsize,Orientation='horizontal',Box='off');% making the legend again go into between the spaces
%     xlabel('time','Interpreter','latex');
%     set(gca, 'Fontsize',Fontsize);
% end
% linkaxes(ax,'x')
% set(gcf, 'DefaultAxesTickLabelInterpreter', 'latex'); %Everything Latex 
% set(gcf, 'DefaultLegendInterpreter', 'latex');
% set(gcf, 'DefaultTextInterpreter', 'latex')
% set(fig, 'WindowState', 'maximized');
% 
% end