function [rheobase,rheobaseIdx] = rheobasecurrent(inputData,outputData,Pars,startLoc,stopLoc)
% [rheobase,rheobaseIdx] = rheobasecurrent(inputData,outputData,Pars,startLoc,stopLoc)
%
% calculates the rheobase current
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
% rheobase          rheobase current in pA
% rheobaseIdx       index of rheobase current
%
% Written           Niraj S. Desai (NSD), 12/27/21

warning off

minSpikeHeight = -10;
dt = 1000/Pars.sampleRate;

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
        'MinPeakDistance',round(5/dt),'MaxPeakWidth',round(10/dt),...
        'MinPeakProminence',30);
    if isempty(pks)
        continue
    else
        nPeaks(ii) = numel(pks);
    end
end

foo = find(nPeaks);
if isempty(foo)
    rheobase = NaN;
    rheobaseIdx = NaN;
    return
end
rheobase = steps(foo(1));
rheobaseIdx = foo(1);
for jj = 1:numel(foo)-1
    if foo(jj) && foo(jj+1)
        rheobase = steps(foo(jj));
        rheobaseIdx = foo(jj);
        break
    end
end

warning on