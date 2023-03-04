function [md] = makecumulativehistogram(feature, analyzedData)

figure
if nargin<2
    load('analyzedData.mat','analyzedData')
end
a1 = axes;
a1.FontWeight = 'bold';
a1.FontSize = 12;
hold on

data = analyzedData.(feature);

xMin = min(data);
xMax = max(data);
nBins = floor(numel(data)/5);
dB = (xMax-xMin)/nBins;
BE = (xMin-dB):dB:(xMax+dB);
cB = (BE(2:end)+BE(1:(end-1)))/2;

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
    cts = histcounts(dataIdx,BE)/numel(dataIdx);
    cumDistFunc = cumsum(cts);
    plot(cB,cumDistFunc,'o-','color',markerColor,'markerfacecolor',markerColor)
    
end

legend('GFP','BLA','AUD','Location','southeast')
title(feature)
ylabel('fraction')
xlabel('value')