function [adaptationIdx,CV,ahpMax] = spikefrequencyadaptation(inputData,~,Pars,...
        startLoc,stopLoc,nPeaks)

%
% calculates adaptation index
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
% nPeaks            the number of spikes for each current step
%
% OUTPUTS
% adaptationIdx     adaptation index
% CV                coefficient of variation on interspike intervals
% ahpMax            AHP after the current step of the maximum firing rate
%                   step
%
% Written           Niraj S. Desai (NSD), 12/29/21
%
% Modified          NSD, 01/16/22

dt = 1000/Pars.sampleRate;

[~,idx] = max(nPeaks);

minSpikeHeight = -10;

data = inputData(startLoc:stopLoc,idx);
[~,loc] = ...
    findpeaks(data,'MinPeakHeight',minSpikeHeight,...
    'MinPeakDistance',round(5/dt),'MaxPeakWidth',round(10/dt),...
    'MinPeakProminence',30);

len = length(data);

first = numel(find(loc<=len/2));
second = numel(loc) - first;
if first>0
    adaptationIdx = second/first;
else
    adaptationIdx = NaN;
end

if numel(loc)<3
    CV = 0;
else
    isi = zeros(numel(loc)-1);
    for ii = 1:numel(loc)-1
        isi(ii) = (loc(ii+1)-loc(ii))*dt;
    end
    CV = std(isi)/mean(isi);
end

data = inputData(:,idx);
baseline = mean(data(startLoc-round(10/dt):startLoc-round(1/dt)));
if length(data)>(stopLoc+round(300/dt))
    ahp = min(medfilt1(data(stopLoc:stopLoc+round(300/dt)),10));
else
    ahp = min(medfilt1(data(stopLoc:end)));
end
ahpMax = baseline - ahp;


