function [md] = makegraph(feature, analyzedData)

figure
if nargin<2
    load('analyzedData.mat','analyzedData')
end
a1 = axes;
a1.FontWeight = 'bold';
a1.FontSize = 12;
hold on

data = analyzedData.(feature);

for ii = 1:3
    
    if ii==1
        markerColor = 'g';
    elseif ii==2
        markerColor = 'r';
    else
        markerColor = 'b';
    end
    idx = analyzedData.cellType==ii;
    dataIdx = data(idx);
    plot(ii+0.025*randn(numel(dataIdx),1),dataIdx,'o','markerfacecolor',markerColor)

    md{ii} = dataIdx; %#ok<AGROW>
    
end

xlim([0.5 3.5])
a1.XTick = [1 2 3];
a1.XTickLabel = {'GFP only','BLA','AUD'};
title(feature)

