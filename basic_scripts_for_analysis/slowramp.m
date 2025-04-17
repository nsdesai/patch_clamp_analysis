function slowrampslope = slowramp(inputData,~,Pars,startLoc,stopLoc,rheobaseIdx)

dt = 1000/Pars.sampleRate;

idx = rheobaseIdx - 1;
r = inputData(startLoc+round(200/dt):stopLoc,idx); % from 100 msec after step start to end
t = (1:length(r))*dt - dt;
p = polyfit(t,r,1);
slowrampslope = p(1);




