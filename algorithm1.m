function [sensorAllCellsSpeedArray] = algorithm1(network,sensorCellSpeedArray,numberOfTimeSteps)
% get the data from each sensor from the database
sensor = network.getRadarSensors;

sensorCellSpeedArray(isnan(sensorCellSpeedArray)) = 0;
sensorAllCellsSpeedArray=sensorCellSpeedArray;

% indexSensorArray consists of each sensor's cell number
indexSensorArray = find(sensorCellSpeedArray(:,1));

% fill sensorAllCellsSpeedArray with estimated speed for all cells
% depending on the two nearest sensors. The speed difference and the 
% difference in number of cells between the two sensors are used to 
% calculate a step length for how much them speed will change for each 
% empty cell between the two sensors’ cells.

for j=1:numberOfTimeSteps
    for k = 2:size(indexSensorArray,1)
        indexDifference = (indexSensorArray(k)-indexSensorArray(k-1));
        speedDifference=(sensorCellSpeedArray(indexSensorArray(k),j)-sensorCellSpeedArray(indexSensorArray(k-1),j))/indexDifference;
        
        for i = 1:(indexDifference-1)
            sensorAllCellsSpeedArray(indexSensorArray(k-1)+i,j) = sensorCellSpeedArray(indexSensorArray(k-1),j) + i*speedDifference;
        end
    end
end
% convert to km/h
sensorAllCellsSpeedArray = sensorAllCellsSpeedArray.*3.6;
end