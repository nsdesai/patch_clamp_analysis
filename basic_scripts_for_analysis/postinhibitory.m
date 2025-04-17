function postinhibitory = postinhibitory(inputData,~,Pars,~,stopLoc)

dt = 1000/Pars.sampleRate;
r = inputData(:,1);
baseline = mean(r(1:round(200/dt)));
postpeak = max(r(stopLoc+round(10/dt):stopLoc+round(200/dt)));
postinhibitory = postpeak - baseline;

