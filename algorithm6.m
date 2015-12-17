function [GPSCellSpeedArray]=algorithm6(cellSpeedAggregatedTime,cellSize,totalNumberOfCells,numberOfLinks,numberOfTimeSteps,numberOfCells,firstCell)

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
        %         break if cell t is on link number index
        if (i/currentNumberOfCells) <=1
            lengthFromStartHalf(i) = lengthFromStartReal(end) + cellSize(index)./2;
            lengthFromStartReal(i) = lengthFromStartReal(end) + cellSize(index);
            break;
        end
    end
end

%% Fill in the preferred parameter values for the adaptive smoothing method
% tau is set to half of the aggregated interval (1 min)
tau = 0.5;
% propagation velocity for free flow and congested situations, in m/s
cfree = 70/3.6;
ccong = -15/3.6;
% Vc is the threshold between free and congested traffic and deltaV is the
% transition width around Vc
Vc = 50/3.6;
deltaV = 10/3.6;
%%

% cellSpeedAggregatedTime contains NaN-values and GPSCellSpeedArray
% contains zeros instead of NaN
GPSCellSpeedArray = cellSpeedAggregatedTime;
GPSCellSpeedArray(isnan(GPSCellSpeedArray)) = 0;

% fill estimatedSpeed with estimated speed for all cells
% depending the nearest measured or estimated GPS data points based on the
% adapative smoothing method from Treiber(2013)
for t=2:(numberOfTimeSteps-1)
    
    % Loop through all cells from firstCell
    for cell=firstCell:(totalNumberOfCells-1)
        
        if isnan(cellSpeedAggregatedTime(cell,t))
            noMeasure1 = 1; noMeasure2 = 1; tooLong1 = 1; tooLong2 = 1;
            % x is the position in the middle on the cell we want to estimate the speed
            % in
            x = lengthFromStartHalf(cell);
            t1 = t+1;
            t2 = t-1;
            
            % loop for finding x1
            for i=(cell-1):-1:1
                
                % x1 is the distance to the closest prevois data point
                % cellGPS1 is the cell number where the closest prevois data point is
                % located
                if GPSCellSpeedArray(i,t1)== 0 && isnan(cellSpeedAggregatedTime(i,t1))
                    %  if there are no measurement in the cell -> do not use
                    %  any value
                    x1 = 0;
                    noMeasure1 = 0;
                    cellGPS1 = i;
                    
                else
                    %   if there is a measured or estimated speed that is greater than zero ->
                    %   use this value
                    x1 = lengthFromStartHalf(i);
                    cellGPS1 = i;
                    
                    if abs(x-x1) > 1000
                        % if the distance between the data points is
                        % larger than 1 km -> do not use any value
                        % GPSCellSpeedArray(i,t1)=0;
                        tooLong1 = 0;
                    end
                    
                    break;
                    
                end
                
            end
            
            % loop for finding x2
            for i=(cell+1):totalNumberOfCells
                
                % x2 is the distance to the closest prevois data point
                % cellGPS2 is the cell number where the closest prevois data point is
                % located
                if GPSCellSpeedArray(i,t2)== 0 && isnan(cellSpeedAggregatedTime(i,t2))
                    %  if there are no measurement in the cell -> do not use
                    %  any value
                    x2 = 0;
                    noMeasure2 = 0;
                    cellGPS2 = i;
                    
                else
                    %   if there is a measured or estimated speed that is greater than zero ->
                    %   use this value
                    x2 = lengthFromStartHalf(i);
                    cellGPS2 = i;
                    
                    if abs(x-x2) > 1000
                        % if the distance between the data points is
                        % larger than 1 km -> do not use any value
                        tooLong2 = 0;
                    end
                    
                    break;
                    
                end
                
            end
            
            % sigma is calculated as half of the distance between the two data points
            % are used to estimate the speed in the cell
            if noMeasure1 == 0 || tooLong1 == 0
                sigma = abs(x-x2)/2;
            elseif  noMeasure2 == 0 || tooLong2 == 0
                sigma = abs(x-x1)/2;
            else
                sigma = abs(x1-x2)/2;
            end
            
            y1 = noMeasure1*tooLong1;
            y2 = noMeasure2*tooLong2;
            
            Nfree = y1*exp(-((abs(x-x1)/sigma)+((abs(t-t1)-(abs(x-x1)/cfree))/tau))) + y2*exp(-((abs(x-x2)/sigma)+((abs(t-t2)-(abs(x-x2)/cfree))/tau)));
            Ncong = y1*exp(-((abs(x-x1)/sigma)+((abs(t-t1)-(abs(x-x1)/ccong))/tau))) + y2*exp(-((abs(x-x2)/sigma)+((abs(t-t2)-(abs(x-x2)/ccong))/tau)));
            sumNvfree = y1*exp(-((abs(x-x1)/sigma)+((abs(t-t1)-(abs(x-x1)/cfree))/tau)))*GPSCellSpeedArray(cellGPS1,t1)+  y2*exp(-((abs(x-x2)/sigma)+((abs(t-t2)-(abs(x-x2)/cfree))/tau)))*GPSCellSpeedArray(cellGPS2,t2);
            sumNvcong = y1*exp(-((abs(x-x1)/sigma)+((abs(t-t1)-(abs(x-x1)/ccong))/tau)))*GPSCellSpeedArray(cellGPS1,t1) +  y2*exp(-((abs(x-x2)/sigma)+((abs(t-t2)-(abs(x-x2)/ccong))/tau)))*GPSCellSpeedArray(cellGPS2,t2);
            Vfree = sumNvfree/Nfree;
            Vcong = sumNvcong/Ncong;
            
            Vstar = min(Vfree,Vcong);
            
            % weight is between the two speed fields
            weight = 0.5*(1+tanh((Vc-Vstar)/deltaV));
            
            GPSCellSpeedArray(cell,t)=weight*Vcong+(1-weight)*Vfree;
        end
    end
end

% fill the first time step with the values from the second time step
for i=1:totalNumberOfCells
    if GPSCellSpeedArray(i,1) == 0
        GPSCellSpeedArray(i,1) =GPSCellSpeedArray(i,2);
    end
end

% fill the last time step with the values from the previous time step
for i=1:totalNumberOfCells
    if GPSCellSpeedArray(i,numberOfTimeSteps) == 0
        GPSCellSpeedArray(i,numberOfTimeSteps) =GPSCellSpeedArray(i,numberOfTimeSteps-1);
    end
end

% fill the last cell with values from previous cell
if GPSCellSpeedArray(totalNumberOfCells,:)==0
    GPSCellSpeedArray(totalNumberOfCells,:)=GPSCellSpeedArray(totalNumberOfCells-1,:);
end

% removes values from cell 1-8
GPSCellSpeedArray(1:8,:)=0;

end
