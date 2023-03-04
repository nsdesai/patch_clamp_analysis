function analyzedData = gatherdata(fDir)

ff = dir(fDir);

analyzedData = table;
for ii = 3:numel(ff)
    
    fName = [fDir,filesep,ff(ii).name];
    ad = analysis_of_neurophysiology_engram(fName);
    analyzedData(end+1:end+size(ad,1),:) = ad;

end

for ii = 1:size(analyzedData,1)
    foo = datestr(analyzedData.time(ii),30);
    foo = foo(1:8);
    boo(ii,:) = [foo,'_',num2str(analyzedData.eNo(ii),'%03d')]; %#ok<AGROW> 
end
analyzedData.cellID = boo;
analyzedData = [analyzedData(:,end),analyzedData(:,1:end-1)];
[~,idx] = sort(analyzedData.time);
analyzedData = analyzedData(idx,:);
