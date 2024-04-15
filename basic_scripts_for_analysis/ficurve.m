function [fislope,maxfiringrate,nPeaks] = ficurve(inputData,outputData,Pars,...
        startLoc,stopLoc)
%
% calculates properties of f-I curve
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
%
% OUTPUTS
% fislope           slope of the f-I curve (Hz/pA)
% maxfiringrate     maximum firing rate
% nPeaks            number of spikes for each current step
%
% Written           Niraj S. Desai (NSD), 12/29/21

minSpikeHeight = 0;

dt = 1000/Pars.sampleRate; % time step in msec

steps = outputData(stopLoc,:);
nSteps = size(inputData,2);
nPeaks = zeros(nSteps,1);
for ii = 1:nSteps
    if steps(ii)<=0
        continue
    end
    r = inputData(startLoc:stopLoc,ii);
    if max(r)<minSpikeHeight
        continue
    end
    pks = ...
        findpeaks(r,'MinPeakHeight',minSpikeHeight,...
        'MinPeakDistance',round(5/dt),'MaxPeakWidth',round(5/dt),...
        'MinPeakProminence',30);
    if isempty(pks)
        continue
    else
        nPeaks(ii) = numel(pks);
    end
end

duration = (stopLoc - startLoc + 1)*dt/1000; % seconds (not milliseconds)
maxfiringrate = max(nPeaks)/duration;
startIdx = find(nPeaks,1) - 1;
[~,stopIdx] = max(nPeaks);
x = steps(startIdx:stopIdx);
y = nPeaks(startIdx:stopIdx)/duration;
p = polyfit(x,y,1);
fislope = p(1);
