% clear all
clc
close all
%
% % Adding a path to the top folder.
%       addpath(genpath('../'),'-end');
      
import core.*               %Core classes

% Setting the enviroment (i.e loading all jar files)
% We do not wanna set the enviroment if it is allready set.
try
    Time(); % This is just to see if the import was successful.
catch
    setEnviroment
end

% Importing all java classes that will be used.
import java.lang.*          %String classes
import java.util.*          %Wrapper classes
import core.*               %Core classes
import matrix.*             %Matrix classes
import netconfig.*          %Network clases
import bAE.*                %Output data classes not needed in this example
import highwaycommon.*      %Parameter classes

% Setting the network id and configuration id.
NETWORKID = 50;
CONFIGURATIONID = 15001;

core.Monitor.set_db_env('tal_local')
core.Monitor.set_prog_name('mms_matlab')
core.Monitor.set_nid(NETWORKID);
core.Monitor.set_cid(CONFIGURATIONID);

% Creating a network object.
network = Network();

%% Declare which sensors and links that are to be used
sensorIdArray = [244 243 239 238 236 235 231 230 229 227 226 225 224 223 222 221];
linkIdArray = [11269 14136 6189 8568 15256 9150 38698 9160 71687 9198];

% stepLength is what interval the vehicles are to be simulated through the
% stretch, in minutes
steplength = 5;

% firstCell is the cell where the first sensor is located (9 in network 50)
firstCell = 9;
%%

% numberOfLinks is the total number of links of the stretch
numberOfLinks = size(linkIdArray,2);

% firstDay is the date of the first day that want to be studied. The same for month and year  
firstDay = 21;
month = 03;
year = 2013;
% numberOfDays is the preferred number of days and numberOfWeeks is
% the preferred number of weeks
numberOfDays = 1;
numberOfWeeks = 1;

for day = 1:numberOfDays
    
    for week = 1:numberOfWeeks
        
        date = firstDay-1+day+(week-1)*7;

        %% Declare the selected start and end time
        startTime = Time.newTimeFromBerkeleyDateTime(year,month,date,6,30,59,59);
        endTime = Time.newTimeFromBerkeleyDateTime(year,month,date,9,30,0,0);
        %% 
        
        %% getSensorData - get all the sensors' speed and flow for each minute between startTime and endTime
        [sensorSpeedArray,sensorFlowArray, numberOfTimeSteps,numberOfSensors,sensorData]=getSensorData(network,sensorIdArray,startTime,endTime);
        %%
        
        %% getCellMap - get the cell attributes
        [numberOfCells, cellSize, lengthStretch, totalNumberOfCells, cellSizeAll] = getCellMap(network, linkIdArray);
        %%
        
        %% setCellDataSensor - creates sensorCellSpeedArray with the speed from the radar sensors and sensorCellTravelTimesArray with the travel time in each cell where there are a sensor
        [sensorCellSpeedArray, sensorCellTravelTimesArray,indexArray]=setCellDataSensor(numberOfCells,network,sensorIdArray,totalNumberOfCells,numberOfTimeSteps,numberOfSensors,linkIdArray,cellSize,sensorSpeedArray);
        %%
        
        % save the sensorCellSpeedArray for each week if you want to use a
        % specific weekday from several weeks
%         sensorCellSpeedArrayWeek(:,:,week) = sensorCellSpeedArray;
        
        %% plot heat maps of the raw sensor data: the speeds of the stretch, for each date
                h=figure(date);
                plotHeatMap(sensorCellSpeedArray.*3.6,startTime, endTime, numberOfTimeSteps,'date');
% To save the figure in a specific folder:
%                 filename1 = sprintf('H:\\TNK103\\plots\\%d', date)
%                 print(h,'-dpng',filename1)
        %%
    end
    
end

%% Algorithm 1: radar sensors - only space fill
estimatedSpeedAlg1 = algorithm1(network,sensorCellSpeedArray,numberOfTimeSteps);
h=figure(1);
plotHeatMap(estimatedSpeedAlg1,startTime, endTime, numberOfTimeSteps, 'Algorithm 1: Radar sensors - only space fill');
% print(h,'-dpng','H:\TNK103\plots\algorithm1For21mars.png')
%%

%% Algorithm 2: radar sensors - Isotropic Smoothing Method
estimatedSpeedAlg2 = algorithm2(sensorCellSpeedArray,cellSize,numberOfTimeSteps,numberOfSensors,totalNumberOfCells,numberOfLinks,numberOfCells);
h=figure(2);
plotHeatMap(estimatedSpeedAlg2,startTime, endTime, numberOfTimeSteps, 'Algorithm 2: Radar sensors - Isotropic Smoothing Method');
% print(h,'-dpng','H:\TNK103\plots\algorithm2For21mars.png')
%%

%% Algorithm 3: radar sensors- Adaptive Smoothing Method
estimatedSpeedAlg3 = algorithm3(sensorCellSpeedArray,cellSize,numberOfTimeSteps,numberOfSensors,totalNumberOfCells,numberOfLinks,numberOfCells);
h=figure(3);
plotHeatMap(estimatedSpeedAlg3,startTime, endTime, numberOfTimeSteps, 'Algorithm 3:  Radar sensors - Adaptive Smoothing Method');
% print(h,'-dpng','H:\TNK103\plots\algorithm3For21mars.png')
%%

%% Algorithm 4: GPS data - to use in data fusion
load('cellSpeedAggregatedTime')
estimatedSpeedAlg4 = algorithm4(cellSpeedAggregatedTime,cellSize,totalNumberOfCells,numberOfLinks,numberOfTimeSteps,numberOfCells,firstCell);
h=figure(4);
plotHeatMap(estimatedSpeedAlg4,startTime, endTime, numberOfTimeSteps, 'Algorithm 4: GPS data - Isotropic Smoothing Method');
% print(h,'-dpng','H:\TNK103\plots\algorithm4For21mars.png')
%%

%% Algorithm 5: GPS data - Isotropic Smoothing Method - to use standalone
% -------------------------------ÄNDRA HÄRRRRRRRRRRRRRRRRRRRRRRRR-% load the cellSpeedAggregatedTime to get 
load('cellSpeedAggregatedTime')
estimatedSpeedAlg5 = algorithm5(cellSpeedAggregatedTime,cellSize,totalNumberOfCells,numberOfLinks,numberOfTimeSteps,numberOfCells,firstCell);
h=figure(5);
plotHeatMap(estimatedSpeedAlg5,startTime, endTime, numberOfTimeSteps, 'Algorithm 5: GPS data - Isotropic Smoothing Method - to use standalone');
% print(h,'-dpng','H:\TNK103\plots\algorithm5For21mars.png')
%%

%% Algorithm 6: GPS data - Adaptive Smoothing Method
load('cellSpeedAggregatedTime')
estimatedSpeedAlg6 = algorithm6(cellSpeedAggregatedTime,cellSize,totalNumberOfCells,numberOfLinks,numberOfTimeSteps,numberOfCells,firstCell);
h=figure(6);
plotHeatMap(estimatedSpeedAlg6,startTime, endTime, numberOfTimeSteps, 'Algorithm 6: GPS data - Adaptive Smoothing Method');
% print(h,'-dpng','H:\TNK103\plots\algorithm6For21mars.png')
%%

%% Algorithm 7: GPS data - Adaptive Smoothing Method - to use standalone
load('cellSpeedAggregatedTime')
estimatedSpeedAlg7 = algorithm7(cellSpeedAggregatedTime,cellSize,totalNumberOfCells,numberOfLinks,numberOfTimeSteps,numberOfCells,firstCell);
h=figure(7);
plotHeatMap(estimatedSpeedAlg7,startTime, endTime, numberOfTimeSteps, 'Algorithm 7:  GPS data - Adaptive Smoothing Method - to use standalone');
% print(h,'-dpng','H:\TNK103\plots\algorithm5For21mars.png')
%%

%% Data fusion: Data fusion for algorithm 3 (radar sensor data) and algorithm 6 (GPS data)
estimatedSpeedFusion = dataFusion(numberOfTimeSteps,firstCell,totalNumberOfCells,estimatedSpeedAlg3,estimatedSpeedAlg6);
h=figure(8);
plotHeatMap(estimatedSpeedFusion,startTime, endTime, numberOfTimeSteps, 'Data fusion for algorithm 2 (radar sensor data) and algorithm 6 (GPS data)');
% print(h,'-dpng','H:\TNK103\plots\algorithm7For21mars.png')
%%


% -----------------------------------------------HA KVAR?
%% Get Bluetooth Data
%links = [200]
%BTdata = getTTFromBluetooth(links, network, starTime, endTime, linkIdArray)
%%