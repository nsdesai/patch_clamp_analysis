function analyzedData = analysis_of_neurophysiology_data_BNST(folderName,sagCurrent)

oldDir = cd(folderName);

if nargin < 2
    sagCurrent = -250; % pA
end

analyzedData = table;


files = dir('*.mat');

for ii = 1:numel(files)

    foo = load(files(ii).name,'inputData','outputData','Pars');
    inputData = foo.inputData; %#ok<*AGROW>
    outputData = foo.outputData(:,foo.Pars.orderOfSteps);
    Pars = foo.Pars;
    cellID{ii} = files(ii).name; %#ok<*AGROW> 
    analysisDuration = length(inputData);

    out.time = Pars.time;
    out.eNo = Pars.experimentNo;
    out.tNo = Pars.trialNo;
    
    % time step
    dt = 1000/Pars.sampleRate; % msec

    % find the location (start and stop) of the current steps
    maxCurrentAmplitude = max(outputData(:));
    x = max(outputData);
    [~,maxNo] = max(x);
    foo = find(outputData(:,maxNo)==maxCurrentAmplitude);
    startLoc = foo(1);
    stopLoc = foo(end);
    analysisDuration1 = ceil(analysisDuration/dt);
    if analysisDuration1 < (stopLoc-startLoc)
        stopLoc = startLoc + analysisDuration1-1;
    end
    
    % make sure the current steps are arranged in ascending order (most
    % negative amplitude to most positive amplitude)
    steps = outputData(stopLoc,:);
    [~,idx] = sort(steps);
    outputData = outputData(:,idx);
    inputData = inputData(:,idx(1:size(inputData,2)));
    
    % baseline Vm
    meanVm = mean(inputData,2);
    out.baselineVm = mean(meanVm(startLoc-round(10/dt):startLoc-round(1/dt)));

    % sag potential
    [out.sag,out.sagRatio,out.tauSag] = sagpotential(inputData,outputData,Pars,startLoc,stopLoc,sagCurrent);
    
    % input resistance and membrane time constant
    [out.Rn,out.tau] = inputresistance(inputData,outputData,Pars,startLoc,stopLoc);

    % rheobase
    [out.rheobase,rheobaseIdx] = rheobasecurrent(inputData,outputData,Pars,startLoc,stopLoc);
    
    if isnan(out.rheobase)
        results(ii) = out; %#ok<*SAGROW>
        continue
    end
    
    % slow depolarizing ramp just before rheobase
    [out.slowramp] = slowramp(inputData,outputData,Pars,startLoc,stopLoc,rheobaseIdx);
    [out.postinhibitoryrebound] = postinhibitory(inputData,outputData,Pars,startLoc,stopLoc);

    % spike properties: threshold, spike height, spike width, latency
    [out.spikethreshold,out.spikeamplitude,out.spikewidth,out.spikelatency,...
        out.spikepeak,out.upstroke,out.downstroke] = ...
        spikeproperties(inputData,outputData,Pars,startLoc,stopLoc,...
        rheobaseIdx);

    % afterhyperpolarization
    [out.ahpamplitude,out.ahplatency,out.ahpwidth] = ...
        afterhyperpolarization(inputData,outputData,Pars,startLoc,stopLoc,rheobaseIdx);
    %%% curvature?
    
    % f-I curve
    [out.fislope,out.maxfiringrate,nPeaks] = ficurve(inputData,outputData,Pars,...
        startLoc,stopLoc);

    % spike frequency adaptation
    [out.adaptationindex,out.CV,out.ahpMax] = spikefrequencyadaptation(inputData,outputData,Pars,...
        startLoc,stopLoc,nPeaks);

    results(ii) = out;
    
end

analyzedData.cellID = cellID(:);
features = fieldnames(results);
for jj = 1:numel(features)
    fStr = features{jj};
    nRecordings = numel(files);
    values = zeros(nRecordings,1);
    for kk = 1:nRecordings
        try
            values(kk) = results(kk).(fStr);
        catch
            values(kk) = NaN;
        end
    end
    analyzedData.(fStr) = values;
end


fStr = ['analyzedData_',datestr(now,30),'.xlsx'];
writetable(analyzedData,fStr)

cd(oldDir)
