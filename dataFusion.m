function[estimatedSpeedFusion] = dataFusion(numberOfTimeSteps,firstCell,totalNumberOfCells,estimatedSpeedAlg3,estimatedSpeedAlg6)

% fill estimatedSpeedFusion with estimated speed for all cells
% depending on the two data sources weighted together
for t=1:numberOfTimeSteps
    for cell=firstCell:totalNumberOfCells
        
        % if there are no estimate for GPS-data, all weight put on estimate for the
        % sensor data
        if isnan(estimatedSpeedAlg6(cell,t))
            
            estimatedSpeedFusion(cell,t) = estimatedSpeedAlg3(cell,t);
            
            % cells with lower number than 19, weight more on weightSensor
            % because there are public transport lanes which the taxis use
        elseif cell <= 19
            weightSensor = 0.9;
            weightGPS = 1-weightSensor;
            estimatedSpeedFusion(cell,t) = (weightSensor.*estimatedSpeedAlg3(cell,t)) + (weightGPS.*estimatedSpeedAlg6(cell,t));
            
            % other cells weight equally much
        else
            weightSensor = 0.5;
            weightGPS = 1-weightSensor;
            estimatedSpeedFusion(cell,t) = (weightSensor.*estimatedSpeedAlg3(cell,t)) + (weightGPS.*estimatedSpeedAlg6(cell,t));
        end
    end
end
end