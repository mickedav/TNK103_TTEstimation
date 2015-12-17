function [travelTimesArray, cellPositionAll] = travelTimesInterval(temp, steplength, cellSizeAll, numberOfTimeSteps, startCell, endCell, startOffset, endOffset)
%check number of inputs in the function
%startCell, endCell, startOffset, endOffset is not needed
if nargin <= 4
    startCell = 9;
    endCell = 50;
    startOffset = 0;
    endOffset = 0;
end

start_time = 1;
%time steps based on minutes
numberOfSeconds = numberOfTimeSteps*60;
%steplength in minutes
NumOfIntervals = numberOfTimeSteps/steplength;

intervals = 1;
maxTT = 0;
startTimeSec = 0;


cellPositions = endCell*ones(NumOfIntervals, numberOfSeconds);

while intervals < NumOfIntervals
    %only done to not reset start time every iteration
    if startTimeSec == 0
        startTimeSec = 1;
    else
        startTimeSec = startTimeSec + steplength*60;
    end
    
    %calculate travel time with trajectory
    travelTime = trajectory(temp, cellSizeAll, start_time, startCell, endCell, startOffset, endOffset);
    actualTravelTime = size(travelTime,2);
    
    %find the maximum travel time to minimize size of array
    if actualTravelTime + startTimeSec > maxTT
        maxTT = actualTravelTime + startTimeSec;
        
        %save travel times
        if travelTime(end) == endCell
            travelTimesArray(intervals) = actualTravelTime;
        end
    end
    
    % extract cell position for each second
    for i = startTimeSec:(actualTravelTime) + startTimeSec - 1
        cellPositions(intervals,i) = travelTime(i-startTimeSec+1);
    end
    
    intervals = intervals + 1;
    % update starttime for next time step
    start_time = start_time + steplength;
end

% store cell position for all trajectories
cellPositionAll = cellPositions(:,1:maxTT);
for i = 1:NumOfIntervals
    for j = 1:maxTT       
        if cellPositionAll(i,j) == endCell;
            %Set all positions to startCell if the trajectory is done. Just
            %for neater plots
            cellPositionAll(i,j) = startCell;
        else
            break;
        end
    end
end
cellPositionAll = cellPositionAll';
end