function [sag,sagRatio] = sagpotential(inputData,outputData,Pars,startLoc,stopLoc,sagCurrent)
% [sag,sagRatio] = sagpotential(inputData,outputData,Pars,sagCurrent,startLoc,stopLoc,sagCurrent)
%
% calculates the absolute sag potential from hyperpolarizing current steps
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
% sagCurrent        current amplitude used to estimate sag (e.g., -80 pA)
%
% OUTPUTS
% sag               sag potential (mV) is the difference between the max
%                   voltage deflection in response to a current step of 
%                   amplitude sagCurrent and the steady-state deflection to
%                   that step. In case of an error, sag = NaN is returned
% sagRatio          ratio of max deflection to steady-state deflection
%
% Written           Niraj S. Desai (NSD), 12/22/21

dt = 1000/Pars.sampleRate; % time step in msec

% find the index of the sag current (or the closest smaller current)
x = outputData(stopLoc,:) - sagCurrent;
y = find(x<=0);
if isempty(y)
    sag = NaN;
    sagRatio = NaN;
    return
end
idx = y(end);

% check that the voltage response is not saturated when the step = idx
% if it is, go to the next step
saturation = false;
for ii = idx:size(outputData,2)
    foo = inputData(startLoc:stopLoc,ii);
    foo = diff(foo);
    foo = find(foo==0);
    

    [~,boo] = mode(foo);
    if boo<1000 % no more than 1000 points will be the same if no saturation
        % no saturation
        saturation = false;
        break
    else
        saturation = true;
    end
end

if saturation
    sag = NaN;
    sagRatio = NaN;
    return
else
    idx = ii;
end

% choose the response corresponding to the sag current step
data = inputData(:,idx);
data = medfilt1(data,round(20/dt)); % smooth noise > 20 Hz
base = mean(data(startLoc-round(20/dt):startLoc-round(1/dt)));
minX = min(data(startLoc:startLoc+round((stopLoc-startLoc)/2)));
ssX = max(data(startLoc+round((stopLoc-startLoc)/2):stopLoc-1));
sag = ssX - minX;
sagRatio = (minX-base)/(ssX-base);
if sag<0
    sag=0;
end