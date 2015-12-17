function [cellSpeedAggregated] = aggregateTime(cellSpeed, endSec, cellSizeAll)

totalNumberOfCells = size(cellSizeAll,2);
% convert from seconds to minutes by aggregating
for i = 60:60:endSec - 60
    for j = 1:totalNumberOfCells
        cellSpeedAggregated(i/60,j) = nanmean(cellSpeed(j,i:i+59));
    end
end

cellSpeedAggregated = cellSpeedAggregated';

end