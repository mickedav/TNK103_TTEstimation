function [tt, cells, cellOffset] = getTTFromBluetooth(link, network, startTime, endTime, linkIdArray)
import bAE.*

[numberOfCells, cellSize, lengthStretch, totalNumberOfCells, cellSizeAll] = getCellMap(network, linkIdArray);

cells = NaN(size(link,1),2);
counter = 1;

for i = link
        
    ttBluetooth = output.TravelTimeOutput.getBluetoothTravelTimeOutput(network, i, startTime, endTime, 5);
    
    startCell = ttBluetooth.route.getFirstSpot;
    endCell = ttBluetooth.route.getLastSpot;
    [cells(counter,1) cellOffset(counter,1)] = getCellId(startCell, linkIdArray, numberOfCells,  cellSize);
    [cells(counter,2) cellOffset(counter,2)] = getCellId(endCell, linkIdArray, numberOfCells,  cellSize);

    travelTimes = ttBluetooth.travelTime;
    timeStamps = ttBluetooth.timestamp;

    for j = 2:size(timeStamps)
        ttTemp(j-1,1) = travelTimes(j);
    end
    tt(counter,:) = ttTemp;
    counter = counter + 1;
end

end
