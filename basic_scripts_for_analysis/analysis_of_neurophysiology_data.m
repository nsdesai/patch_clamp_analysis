function analyzedData = analysis_of_neurophysiology_data(folderName)
% run analysis on all recording files in the folder called folderName
% return table of analysis measurements
%
% INPUT
% folderName        complete name of folder containing recordings to be
%                   analyzed
% OUTPUT
% analyzedData      table containing analysis measurements
% 
% Last modified: 04/15/24 (NSD)

sagCurrent = -60; % use the -60 pA current step to measure sag potential
analysisDuration = 500; % analyze only the first 500 msec of the current step

analyzedData = table;

% find the data files and get the numbers identifying each recording; 
% in some cases, data from a single recording are spread over more than one
% file
files = dir([folderName,filesep,'experiment*.mat']);
for ii = 1:numel(files)
    filename = files(ii).name;
    foo = strfind(filename,'experiment');
    recordingNumbers(ii) = str2double(filename(foo+10:foo+12)); 
end
recordingNumbers = unique(recordingNumbers);


for ii = 1:numel(recordingNumbers)

    % get all data files associated with current recording number &
    % concatentate them if there is more than one
    recordingNo = recordingNumbers(ii);
    files = dir([folderName,filesep,'experiment',num2str(recordingNo,'%03.0f'),'*.mat']);
    inputData = []; outputData = [];
    for jj = 1:numel(files)
        foo = load(files(jj).name,'inputData','outputData','Pars');
        inputData = [inputData, foo.inputData]; %#ok<*AGROW>
        foo.outputData = foo.outputData(:,foo.Pars.orderOfSteps);
        outputData = [outputData, foo.outputData];
        Pars = foo.Pars;
    end
    cellID{ii} = files(1).name; %#ok<*AGROW> 

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
    [out.sag,out.sagRatio] = sagpotential(inputData,outputData,Pars,startLoc,stopLoc,sagCurrent);
    
    % input resistance and membrane time constant
    [out.Rn,out.tau] = inputresistance(inputData,outputData,Pars,startLoc,stopLoc);

    % rheobase
    [out.rheobase,rheobaseIdx] = rheobasecurrent(inputData,outputData,Pars,startLoc,stopLoc);
    
    if isnan(out.rheobase)
        results(ii) = out; %#ok<*SAGROW>
        continue
    end
    
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
    nRecordings = numel(recordingNumbers);
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
