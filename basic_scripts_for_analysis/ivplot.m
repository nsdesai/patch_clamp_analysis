function [steps,Vss] = ivplot(filename)

data = load(['data',filesep,filename],'inputData','outputData','Pars');
Pars = data.Pars;
inputData = data.inputData;
outputData = data.outputData;

% find the location (start and stop) of the current steps
maxCurrentAmplitude = max(outputData(:));
x = max(outputData);
[~,maxNo] = max(x);
foo = find(outputData(:,maxNo)==maxCurrentAmplitude);
startLoc = foo(1);
stopLoc = foo(end);

[~,~,steps,Vss] = inputresistance(inputData,outputData,Pars,startLoc,stopLoc,[-200 100]);

figure
plot(steps,Vss,'o-')
xlabel('current I (pA)')
ylabel('voltage deflection \DeltaV (mV)')
ax = gca;
ax.FontWeight = 'bold';
ax.FontSize = 12;
