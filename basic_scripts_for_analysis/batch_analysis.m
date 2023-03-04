function analyzedData = batch_analysis(folderName)

analyzedData = table;

% get subfolder names (e.g., FL, LJ, GW, and NSD)
d = dir(folderName);
df = d([d(:).isdir]);
df = df(~ismember({df(:).name},{'.','..'}));

oldDir0 = cd(folderName);
pat = "L" + digitsPattern + "C" + digitsPattern;


for ii = 1:numel(df)

    oldDir1 = cd(df(ii).name);

    LJ = strcmp(df(ii).name,'LJ');
    if LJ
        cd('pClamp Data')
        d1 = dir;
        df1 = d1([d1(:).isdir]);
        df1 = df1(~ismember({df1(:).name},{'.','..'}));
        for jj = 1:numel(df1) 
            ad1 = analysis_of_neurophysiology_data_LJ(df1(jj).name);
            analyzedData(end+1,:) = ad1;
        end
        cd(oldDir1)
        continue
    end

    d1 = dir;
    df1 = d1([d1(:).isdir]);
    df1 = df1(~ismember({df1(:).name},{'.','..'}));
    for jj = 1:numel(df1)
        if isempty(strfind(df1(jj).name,pat))
            continue
        end

        oldDir2 = cd(df1(jj).name);
        if ~exist('for_current_step_analysis','dir')
            cd(oldDir2)
            continue
        end

        ad2 = analysis_of_neurophysiology_data_090922('for_current_step_analysis');
        analyzedData(end+1,:) = ad2; %#ok<*AGROW> 
        cd(oldDir2)

    end

    cd(oldDir1)

end

cd(oldDir0)

