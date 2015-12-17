function [sensorSpeedArray,sensorFlowArray,numberOfTimeSteps,numberOfSensors,sensorData] = getSensorData(network,sensorIdArray,startTime,endTime)
import java.lang.*
import core.*

% calculate the startminute and endminute in minutes after midnight
startTimeString=matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(startTime);
[Y, M, D, H, MN, S] = datevec(startTimeString);
startMinute = H*60+MN+1;
endTimeString=matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(endTime);
[Y, M, D, H, MN, S] = datevec(endTimeString);
endMinute = H*60+MN+1;

% calculate the number of time steps for the investigated entire time period
numberOfTimeSteps = endMinute - startMinute;
% calculate the number of sensors in the network
numberOfSensors = size(sensorIdArray,2);

sensorSpeedArray = NaN(numberOfTimeSteps,numberOfSensors);
sensorFlowArray = NaN(numberOfTimeSteps,numberOfSensors);

% fill sensorSpeedArray with extracted point speed for each sensor for each
% time period 
for i = 1:numberOfSensors
    sensorId = Integer(sensorIdArray(i));
    sensorData = output.SensorOutput.getSensorOutput(network,sensorId,startTime,endTime);
    sensorDataSpeed = sensorData.speed;
    
    numberOfRealTimeSteps = size(sensorDataSpeed,1);
    
    for t = 1:numberOfRealTimeSteps
        sensorTimeStamp=sensorData.timestamps;
        timeStamp=matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(sensorTimeStamp(t));
        [Y, M, D, H, MN, S] = datevec(timeStamp);
        minute = H*60+MN - startMinute+1;
        
        sensorSpeedArray(minute,i) = sensorDataSpeed(t);
    end
end

end