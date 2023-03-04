function [] = makephaseplot(filename,sweepnum)

if nargin < 2
    sweepnum = 0;
end
data = load(['data',filesep,filename],'inputData','outputData','Pars');
dt = 1000/data.Pars.sampleRate;
v = data.inputData;
outputData = data.outputData;


% find the location (start and stop) of the current steps
maxCurrentAmplitude = max(outputData(:));
x = max(outputData);
[~,maxNo] = max(x);
foo = find(outputData(:,maxNo)==maxCurrentAmplitude);
startLoc = foo(1);
stopLoc = foo(end);

v = v(startLoc:stopLoc,:);
dvdt = diff(v)/dt;
dvdt(end+1,:) = dvdt(end,:);

figure
if sweepnum
    plot(v(:,sweepnum),dvdt(:,sweepnum))
else
    plot(v,dvdt)
end
xlim([-80 50])
ylabel('dv/dt (mV/msec)')
xlabel('v (mV)')
ax = gca;
ax.FontWeight = 'bold';
ax.FontSize = 12;
