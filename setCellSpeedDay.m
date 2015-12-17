function [cellSpeedAggregatedTime, cellSpeed, totalNumberOfCells, cellSizeAll] = setCellSpeedDay(intData, doubleData, timeStampData, linkIdArray, network, analyst, row, endSec)

% Imports
import core.*
import netconfig.*

% Create cellmap using provided network.
[numberOfCells, cellSize, lengthStretch, totalNumberOfCells, cellSizeAll] = getCellMap(network, linkIdArray);

% Create matrix in which CellSpeeds are stored, fill with NaN to make it
% possible to create NaNmean.
cellSpeedTemp = cell(totalNumberOfCells,endSec);
positions = [];
for i = 1:row
    % Create spots used to find Taxi route, also get TravelTime for this route
    a = Spot(network.getLinkWithID(intData(i,1)), doubleData(i,1), -1);
    b = Spot(network.getLinkWithID(intData(i,2)), doubleData(i,2), -1);
    travelTime = intData(i,3);
    
    % Try extracting Taxi Route. If fail, no data is added to cellSpeeds
    try
    route = analyst.extractRoute(a,b);
    route.getRouteLength;
    v = (route.getRouteLength/travelTime)*3.6;
    startCell = getCellId(a, linkIdArray, numberOfCells, cellSize);
    endCell = getCellId(b, linkIdArray, numberOfCells, cellSize);
    tempPositions = ones(((endCell-startCell+1)*(timeStampData(i,2)-timeStampData(i,1)+1)),2);
    row = 1;
    %store cell speeds and positions if found
    for j = startCell:endCell
        for k = timeStampData(i,1):timeStampData(i,2)
            cellSpeedTemp{j,k} = [cellSpeedTemp{j,k} v];
            tempPositions(row,:) = [j k];
            row = row+ 1;
        end
    end
    %store all positions
    positions = [positions;tempPositions];
    catch
    'Taxi not working';
    end
end

cellSpeed = nan(totalNumberOfCells,endSec);
%set actual cell speed for found positions and get mean speed
for i = 1:size(positions,1)
    index = positions(i,:);
    cellSpeed(index(1,1),index(1,2)) = nanmean(cellSpeedTemp{index(1,1),index(1,2)});
end
%aggregate to get in minutes
cellSpeedAggregatedTime = aggregateTime(cellSpeed, endSec, totalNumberOfCells);
end