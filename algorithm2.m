function [estimatedSpeed]=algorithm2(sensorCellSpeedArray,cellSize,numberOfTimeSteps,numberOfSensors,totalNumberOfCells,numberOfLinks,numberOfCells)
% indexSensorArray consists of each sensor's cell number
sensorCellSpeedArray(isnan(sensorCellSpeedArray)) = 0;
indexSensorArray = find(sensorCellSpeedArray(:,1));

% fill lengthFromStartHalf with the length from start to half of the cell
% for each cell
% fill lengthFromStartReal with the length from start to the end of the
% cell for each cell
lengthFromStartHalf(1) = cellSize(1)/2;
lengthFromStartReal(1) = cellSize(1);
for i=2:totalNumberOfCells
    currentNumberOfCells = 0;
    index = 0;
    for j=1:numberOfLinks
        currentNumberOfCells =  currentNumberOfCells + numberOfCells(j);
        index = index + 1;
        % break if cell t is on link number index
        if (i/currentNumberOfCells) <=1
            lengthFromStartHalf(i) = lengthFromStartReal(end) + cellSize(index)./2;
            lengthFromStartReal(i) = lengthFromStartReal(end) + cellSize(index);
            break;
        end
    end
end

% fill lengthBetweenSensors with the distance (meters) between two sensors
for i=2:(numberOfSensors-1)
    distanceBetweenSensors(i-1) = lengthFromStartHalf(indexSensorArray(i))-lengthFromStartHalf(indexSensorArray(i-1));
end

% average distance between two sensors
averageDistanceSensor = mean(distanceBetweenSensors);

%% Fill in the preferred parameter values for the isotropic smoothing method
% sigma is calculated as half of the average distance between two sensors
sigma = averageDistanceSensor/2;
% tau is set to half of the aggregated interval (1 min)
tau = 0.5;
%%

% fill estimatedSpeed with estimated speed for all cells
% depending on the two nearest sensors based on the isotropic smoothing
% method from Treiber(2013)
estimatedSpeed = sensorCellSpeedArray;
for t=2:(numberOfTimeSteps-1)
    
    % loop through all the sensors
    for i=2:(numberOfSensors-1)
        sensor1 = indexSensorArray(i-1);
        sensor2 = indexSensorArray(i);
        
        % if the two sensors are not in neighboring cells, no estimation will be
        % done
        if sensor1+1 ~= sensor2
            
            % for the first cell after the first sensor to the last cell before the
            % next sensor, t.ex. cell 10-11
            for cell=(sensor1+1):(sensor2-1)
                
                % loop for two sensors at the time
                % x is the position in the middle on the cell we want to estimate the speed
                % in
                x = lengthFromStartHalf(cell);
                x1 = lengthFromStartHalf(sensor1);
                x2 = lengthFromStartHalf(sensor2);
                t2 = t-1;
                t1 = t+1;
                
                N = exp(-((abs(x-x1)/sigma)+(abs(t-t1)/tau))) + exp(-((abs(x-x2)/sigma)+(abs(t-t2)/tau)));
                sumNv = exp(-((abs(x-x1)/sigma)+(abs(t-t1)/tau)))*sensorCellSpeedArray(sensor1,t1) + exp(-((abs(x-x2)/sigma)+(abs(t-t2)/tau)))*sensorCellSpeedArray(sensor2,t2);
                estimatedSpeed(cell,t)=sumNv/N;
            end
        end 
    end
end

% fill the first time step with the values from the second time step
for i=1:totalNumberOfCells
    if estimatedSpeed(i,1) == 0
        estimatedSpeed(i,1) =estimatedSpeed(i,2);
    end
end

% fill the last time step with the values from the previous time step
for i=1:totalNumberOfCells
    if estimatedSpeed(i,numberOfTimeSteps) == 0
        estimatedSpeed(i,numberOfTimeSteps) =estimatedSpeed(i,numberOfTimeSteps-1);
    end
end
% convert to km/h
estimatedSpeed = estimatedSpeed.*3.6;
end