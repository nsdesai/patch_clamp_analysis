function [ahpamplitude,ahplatency,ahpwidth] = ...
    afterhyperpolarization(inputData,~,Pars,startLoc,stopLoc,rheobaseIdx)
% function [ahpamplitude,ahplatency,ahpwidth] = ...
%         afterhyperpolarization(inputData,outputData,Pars,startLoc,stopLoc)
%
% calculates AHP properties
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
% ahpamplitude      AHP amplitude relative to spike threshold
% ahplatency        AHP latency relative to time of spike threshold
% ahpwidth          AHP width at half maximum (calculated from first
%                   current step to produce two spikes
%
% Written           Niraj S. Desai (NSD), 12/28/21


dt = 1000/Pars.sampleRate; % time step in msec

for ii = rheobaseIdx:size(inputData,2)
    data = inputData(startLoc:stopLoc,ii);
    [data1,dt1,locs1,spikethreshold1] = findspikes(data,dt);
    if isempty(locs1)
        continue
    else
        locs = locs1;
        data = data1; 
        spikethreshold = spikethreshold1;
    end
    if numel(locs)>1
        break
    else
        locs(2) = stopLoc-startLoc;
    end
end
data = data(locs(1):locs(2));
[minAHP,locAHP] = min(data);
ahpamplitude = spikethreshold - minAHP;
ahplatency = locAHP*dt1;

halfVm = spikethreshold - ahpamplitude/2;
data1 = zeros(numel(data),1);
data1(data<halfVm) = -200;
foo = find(diff(data1));
if numel(foo)>1
    ahpwidth = (foo(2)-foo(1))*dt1;
elseif numel(foo)==1
    ahpwidth = (stopLoc - foo(1))*dt1;
else % no spikes for this analysisDuration
    ahpwidth = NaN;
end

end



% ************************************************************************
function [data,dt,locs,spikethreshold] = findspikes(data,dt)

minSpikeHeight = 0; % mV
spikeVelocity = 10; % 10 mV/msec
t = (1:length(data))*dt - dt;
% dt = dt/10;
% t1 = 0:dt:t(end);
% data = interp1(t,data,t1);
if max(data)<minSpikeHeight
    locs = []; %#ok<*NASGU>
    spikethreshold = [];
    return
end
[~,locs] = ...
    findpeaks(data,'MinPeakHeight',minSpikeHeight,...
    'MinPeakDistance',round(5/dt),'MaxPeakWidth',round(5/dt),...
    'MinPeakProminence',30);
dvdt = gradient(data,dt);
dvdt(1:locs(1)-round(3/dt)) = 0;
thresholdIdx = find(dvdt>spikeVelocity,1);
spikethreshold = data(thresholdIdx);
locs = locs - round(0.75/dt);

end

