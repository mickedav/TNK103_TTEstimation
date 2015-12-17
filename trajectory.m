function [trajectory] = trajectory(cellSpeed, cellSizeAll, start_time, startCell, endCell, startOffset, endOffset)
%if looking at shorter sections start and end cells are given
if(startCell == NaN)
    startCell = 9;
end

if(endCell == NaN)
    endCell = 50;
end

if(startCell > endCell)
    'Start Cell is bigger than end Cell, start set to 9 and end set to 50'
    startCell = 9;
    startCell = 50;
end

%initial values
currCell = startCell;
minute = start_time;
second = 1;
totSecond = 1;
trajectory = 0;
%start at the given start offset
deltaDist = startOffset;
cellSpeed(isnan(cellSpeed)) = 0;

%traverse through network until last cell is reached
while (currCell < endCell) && (minute < size(cellSpeed,2))
    
    currSpeed = cellSpeed(currCell,minute);
    
    %travelled dist during 1 second
    %rewrite km/h to m/s
    deltaDist = deltaDist + (currSpeed)/3.6;
    
    if deltaDist > cellSizeAll(currCell)
        %move on to the next cell
        deltaDist = 0;
        currCell = currCell + 1;
    end
    
    if second > 60
        %one minute has passed
        minute = minute + 1;
        second = 1;
    end
    %save position (cell) for every second
    trajectory(totSecond) = currCell;
    %check next second
    second = second + 1;
    totSecond = totSecond + 1;
end
%the remaining last cell is not needed to be traversed, just the offset
temp = floor(endOffset/(currSpeed/3.6));
trajectory(end:(end + temp)) = endCell;
end

