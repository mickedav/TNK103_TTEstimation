function [speedData, speedDataAggregated,  cellSizeAll] = GPSdataExtractor(nbrDays, network, analyst, dbr, linkIdArray, start_TimeStamp, end_TimeStamp, endSec)

%% Function returns speedData, a 3D-matric with (day, cell, minute)

%Imports
import java.lang.*          %String classes
import java.util.*          %Wrapper classes
import core.*               %Do we really need core again?

startDay = start_TimeStamp.getDayOfMonth;
startHour = start_TimeStamp.getHour;
startMinute = start_TimeStamp.getMinute;

endDay = end_TimeStamp.getDayOfMonth;
endHour = end_TimeStamp.getHour;
endMinute = end_TimeStamp.getMinute;

%Create dataBase reader and nw-analyst that is needed to extract and
%analyse data

%Create Time intervall
for day = 1:nbrDays
    % tick = Time();
    startTimeStampString = char(start_TimeStamp.toString);
    startTimeStampString = ['''' startTimeStampString ''''];
    endTimeStampString = char(end_TimeStamp.toString);
    endTimeStampString = ['''' endTimeStampString ''''];
    numberOfTimeStepsTemp = TimeInterval(start_TimeStamp, end_TimeStamp);
    numberOfTimeSteps = numberOfTimeStepsTemp.get_time_interval_duration;
    
    %% Query to get Taxi Gps-data!
    query = ['SELECT * FROM info24_feed.taxi_tt '...
        'WHERE(startlid = 11269 OR startlid = 14136 '...
        'OR startlid = 6189 OR startlid = 8568 '...
        'OR startlid = 15256 OR startlid = 9150 OR startlid = 38698 '...
        'OR startlid = 9160 OR startlid = 71687 OR startlid = 9198) '...
        'AND(endlid = 11269 OR endlid = 14136 OR endlid = 6189 OR endlid = 8568 '...
        'OR endlid = 15256 OR endlid = 9150 OR endlid = 38698 '...
        'OR endlid = 9160 OR endlid = 71687 OR endlid = 9198) AND isvalid '...
        ['AND (start_time BETWEEN ' startTimeStampString ' AND ' endTimeStampString ') ']...
        'ORDER BY start_time']
    
    %% Query to get number of rows!
    query2 = ['SELECT count(*) AS rows FROM info24_feed.taxi_tt '...
        'WHERE(startlid = 11269 OR startlid = 14136 '...
        'OR startlid = 6189 OR startlid = 8568 '...
        'OR startlid = 15256 OR startlid = 9150 OR startlid = 38698 '...
        'OR startlid = 9160 OR startlid = 71687 OR startlid = 9198) '...
        'AND(endlid = 11269 OR endlid = 14136 OR endlid = 6189 OR endlid = 8568 '...
        'OR endlid = 15256 OR endlid = 9150 OR endlid = 38698 '...
        'OR endlid = 9160 OR endlid = 71687 OR endlid = 9198) AND isvalid '...
        ['AND (start_time BETWEEN ' startTimeStampString ' AND ' endTimeStampString ') ']];
    %%
    
    %   query = 'SELECT * FROM info24_feed.taxi_tt WHERE(startlid = 11269 OR startlid = 14136 OR startlid = 6189 OR startlid = 8568 OR startlid = 15256 OR startlid = 9150 OR startlid = 38698 OR startlid = 9160 OR startlid = 71687 OR startlid = 9198) AND(endlid = 11269 OR endlid = 14136 OR endlid = 6189 OR endlid = 8568 OR endlid = 15256 OR endlid = 9150 OR endlid = 38698 OR endlid = 9160 OR endlid = 71687 OR endlid = 9198)AND DATE(start_time) = "2013-03-21" AND isvalid ORDER BY start_time';
    query = String(query);
    query2 = String(query2);
    dbr.psCreate(String('test'),query);
    dbr.psCreate(String('test2'),query2);
    
    %% Try fetching data from DB
    try
        dbr.psQuery(String('test'));
    catch
        'Can not retrive the GPS data'
    end
    
    try
        dbr.psQuery(String('test2'));
    catch
        'Cant retrieve number of rows'
    end
    
    %% Get column names in order to fetch data
    wantedDataInt = [String('startlid'), String('endlid'), String('traveltime')];
    wantedDataDouble = [String('start_offset'), String('end_offset')];
    wantedDataTimeStamp = [String('start_time'), String('end_time')];
    
    %% Decide number of rows in DB
    dbr.psRSNext('test2');
    nbrRows = dbr.psRSGetBigInt('test2','rows').intValue;
    
    %% Initiate arrays to store
    intData = zeros(nbrRows,3);
    doubleData = zeros(nbrRows,2);
    timeStampData = zeros(nbrRows,2);
    
    row = 1;
    
    %% Loop through the DB answer and store data in MATLAB arrays
    while dbr.psRSNext('test');
        
        for i = 1:size(wantedDataInt)
            intData(row,i) = dbr.psRSGetInteger('test',wantedDataInt(i));
        end
        
        for i = 1:size(wantedDataDouble)
            k = dbr.psRSGetDouble('test',wantedDataDouble(i));
            if (k.doubleValue < 0)
                doubleData(row,i) = 0;
            else
                doubleData(row,i) = k;
            end
        end
        %create time stamps
        for i = 1:size(wantedDataTimeStamp)
            time_stamp_temp = TimeInterval(start_TimeStamp, dbr.psRSGetTimestamp('test', wantedDataTimeStamp(i)));
            timeStampData(row,i) = round(time_stamp_temp.get_time_interval_duration);
        end
        row = row + 1;
        
    end
    row = row - 1;
    
    [speedDataAggregatedTime, speedData(day,:,:), totalNumberOfCells, cellSizeAll] = setCellSpeedDay(intData, doubleData, timeStampData, linkIdArray, network, analyst ,row, endSec);
    dbr.psDestroy('test');
    dbr.psDestroy('test2');
    start_TimeStamp = Time.newTimeFromBerkeleyDateTime(2013,03,startDay +(day)*7,startHour, startMinute,59,59);
    end_TimeStamp = Time.newTimeFromBerkeleyDateTime(2013,03,endDay +(day)*7, endHour, endMinute,0,0);
end
%Aggregate over days
speedDataAggregated = aggregate(speedData, endSec, totalNumberOfCells);

end