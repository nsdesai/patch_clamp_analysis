function [Rn,tau,steps,Vss] = inputresistance(inputData,outputData,Pars,startLoc,stopLoc,currentRange)
% [Rn,tau] = inputresistance(inputData,outputData,Pars,startLoc,stopLoc)
%
% calculates the input resistance
%
% INPUTS
% inputData         recorded data (mV) in an n x m matrix, where n is the 
%                   number of sample points per current step 
%                   (=duration * time step) and m is the number of steps
% outputData        current steps (pA) in an n x m matrix, where n is the
%                   number of sample points per step (=duration * time 
%                   step) and m is the number of steps
% Pars              a structure variable that contains information about
%                   the recording
% startLoc          the index of the start of the current step
% stopLoc           the index of the stop of the current step
% currentRange      range of current steps [minCurrent maxCurrent] to use
%                   to fit slope of I-V curve
%
% OUTPUTS
% Rn                input resistance (MOhms) measured from steady-state
%                   deflection
% tau               membrane time constant
% steps             amplitude of current steps used in the fitting
% Vss               steady-state voltage deflections of the current steps
%
% Written           Niraj S. Desai (NSD), 12/27/21
%
% Modified          NSD, 02/01/22

if nargin < 6
    currentRange = [-50 0]; % range of current steps to use in Rn estimation
end

dt = 1000/Pars.sampleRate; % time step in msec

% find current steps between currentRange(1) and currentRange(2)
% eliminate steps that result in action potentials
% measure steady-state Vm deflection
steps = outputData(stopLoc,:);
steps(steps<currentRange(1)) = NaN;
steps(steps>currentRange(2)) = NaN;
foo = steps(~isnan(steps));
if foo>=0
    steps = outputData(stopLoc,:);
    steps(steps>0) = NaN;
end
idx = find(~isnan(steps));
steps = steps(idx);
Vss = zeros(numel(idx),1);
tau = NaN;
ft = fittype('a*exp(-b*t) + c','indep','t');
for ii = 1:numel(idx)
    r = inputData(startLoc-round(50/dt):stopLoc,idx(ii));
    if ~isempty(find(r>-20, 1))
        Vss(ii) = NaN;
    else
        V0 = mean(r(end-round(100/dt):end));
        Vss(ii) = V0 - mean(r(1:round(45/dt)));
        if abs(Vss(ii))>50 || V0<-150  % avoid saturated steps
            Vss(ii) = NaN;
        else
            if isnan(tau)
                try
                    r = r(round(52/dt):end);
                    t = (1:length(r))*dt - dt;
                    startPt = [r(1)-r(end), 0.1, r(end)];
                    f = fit(t(:),r(:),ft,'start',startPt);
                    tau = 1/f.b;
                catch
                    tau = NaN;
                end
            end
        end
    end
end
steps(isnan(Vss)) = [];
Vss(isnan(Vss)) = [];

% % fit a straight line to Vss vs current steps
% warning off
% if numel(steps)>1
%     p = polyfit(steps,Vss,1);
% else
%     p = Vss(1)/steps(1);
% end
% Rn = 1000*p(1); % MOhms
% warning on

% fit a straight line to Vss vs current steps
warning off
p = polyfit(steps,Vss,1);
Rn = abs(1000*p(1)); % MOhms
warning on

try
    idx = find(steps==-20,1);
    Vss = Vss(idx);
    Rn = abs(1000*Vss/20);
catch
    % nothing
end

