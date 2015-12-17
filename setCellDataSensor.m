function [sensorCellSpeedArray, sensorCellTravelTimesArray,indexArray]=setCellDataSensor(numberOfCells,network,sensorIdArray,totalNumberOfCells,numberOfTimeSteps,numberOfSensors,linkIdArray,cellSize,sensorSpeedArray)

% get the data from each sensor from the database
sensor = network.getRadarSensors;
sensorArray = 0;

% sensorArray consists of all the sensor's ID in network 50
for k=1:size(sensor,1)
    sensorArray(end+1) = sensor(k).ID;
end
sensorArray = sensorArray(2:end);

% sensorIdArray is the predefined sensors' ID from the network 50.
% indexArray consists of the index of the sensors in sensorArray
% The offset to the sensor's location of the link
sensorOffset = 0;
indexArray=0;
for m = sensorIdArray
    index = find(sensorArray == m);
    sensorOffset(end+1) = sensor(index).offset;
    indexArray(end+1)=index;
end
sensorOffset = sensorOffset(2:end);
indexArray = indexArray(2:end);

% fill sensorCellSpeedArray with speeds for every time step for each sensor
sensorCellSpeedArray = NaN(totalNumberOfCells, numberOfTimeSteps);
sensorCellTravelTimesArray = NaN(totalNumberOfCells,numberOfTimeSteps);
for n=1:numberOfSensors
    
    % get the link ID where the sensor is located
    link=sensor(indexArray(n)).link.id;
    
    % index is the segment number (1-10)
    index = find(linkIdArray == link);
    
    % currentNumberOfCells is a counter to keep track of the current number
    % of cells from the start of the network
    currentNumberOfCells = 0;
    for i=(index-1):-1:1
        currentNumberOfCells = currentNumberOfCells + numberOfCells(i);
    end
    % detemine which cell at the link the sensor is located in 
    cellWithSensor=ceil(sensorOffset(n)/cellSize(index));
    
    % If there is a sensor located in the cell, the element is set to speed.
    if ~isnan(sensorCellSpeedArray(currentNumberOfCells+cellWithSensor,1))
        
        sensorCellSpeedArray(currentNumberOfCells+cellWithSensor,:)= (sensorSpeedArray(:,n)+sensorSpeedArray(:,n-1))./2;
    else
        sensorCellSpeedArray(currentNumberOfCells+cellWithSensor,:)=sensorSpeedArray(:,n);
    end
end
end