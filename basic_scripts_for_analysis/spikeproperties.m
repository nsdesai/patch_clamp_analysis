function [spikethreshold,spikeamplitude,spikewidth,spikelatency,spikepeak,upstroke,downstroke] = ...
    spikeproperties(inputData,~,Pars,startLoc,stopLoc,rheobaseIdx)
%
% calculates spike properties
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
% rheobaseIdx       index of current step to analyze
%
% OUTPUTS
% spikethreshold         spike threshold (mV)
% spikeamplitude         spike amplitude (mV) relative to threshold
% spikewidth             spike width at half maximum (msec)
% spikelatency           latency to first spike (msec)
% spikepeak              peak amplitude of first spike (mV) 
% upstroke               maximum upstroke velocity (mV/msec)
% downstroke             minimum downstroke velocity (mV/msec)
%
% Written           Niraj S. Desai (NSD), 12/28/21

spikeVelocity = 10; % 10 mV/msec
minSpikeHeight = -10; % minimum absolute spike height

dt = 1000/Pars.sampleRate; % time step in msec
data = inputData(startLoc:stopLoc,rheobaseIdx);
t = (1:length(data))*dt - dt;
dt = dt/10;
t1 = 0:dt:t(end);
data = interp1(t,data,t1);

[pks,locs] = ...
    findpeaks(data,'MinPeakHeight',minSpikeHeight,...
    'MinPeakDistance',round(5/dt),'MaxPeakWidth',round(10/dt),...
    'MinPeakProminence',30);
spikepeak = pks(1);
spikelatency = locs(1)*dt;

dvdt = gradient(data,dt);
dvdt(1:locs(1)-round(3/dt)) = 0;
thresholdIdx = find(dvdt>spikeVelocity,1);
spikethreshold = data(thresholdIdx);

spikeamplitude = spikepeak - spikethreshold;

halfpeak = spikethreshold + (spikepeak - spikethreshold)/2;
data1 = ones(numel(data),1);
data1(data<halfpeak) = 0;
foo = find(diff(data1));
spikewidth = (foo(2)-foo(1))*dt;

% upstroke and downstroke
upIdx = locs(1)-round(5/dt);
downIdx = max(locs(1)-round(20/dt),length(dvdt));
dvdt1 = dvdt(upIdx:downIdx);
upstroke = max(dvdt1);
downstroke = min(dvdt1);
