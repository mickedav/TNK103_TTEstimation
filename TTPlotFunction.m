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
        % To save the figure in a specific folder:
        %                 filename1 = sprintf('H:\\TNK103\\plots\\%d', date)
        %                 print(h,'-dpng',filename1)
        %%
    end
end

%% Algorithm 1: radar sensors - only space fill
estimatedSpeedAlg1 = algorithm1(network,sensorCellSpeedArray,numberOfTimeSteps);
% print(h,'-dpng','H:\TNK103\plots\algorithm1For21mars.png')
%%

%% Algorithm 2: radar sensors - Isotropic Smoothing Method
estimatedSpeedAlg2 = algorithm2(sensorCellSpeedArray,cellSize,numberOfTimeSteps,numberOfSensors,totalNumberOfCells,numberOfLinks,numberOfCells);
% print(h,'-dpng','H:\TNK103\plots\algorithm2For21mars.png')
%%

%% Algorithm 3: radar sensors- Adaptive Smoothing Method
estimatedSpeedAlg3 = algorithm3(sensorCellSpeedArray,cellSize,numberOfTimeSteps,numberOfSensors,totalNumberOfCells,numberOfLinks,numberOfCells);
% print(h,'-dpng','H:\TNK103\plots\algorithm3For21mars.png')
%%

%% Algorithm 4: GPS data - to use in data fusion
load('cellSpeedAggregatedTime')
estimatedSpeedAlg4 = algorithm4(cellSpeedAggregatedTime,cellSize,totalNumberOfCells,numberOfLinks,numberOfTimeSteps,numberOfCells,firstCell);
% print(h,'-dpng','H:\TNK103\plots\algorithm4For21mars.png')
%%

%% Algorithm 5: GPS data - Isotropic Smoothing Method - to use standalone
% -------------------------------ÄNDRA HÄRRRRRRRRRRRRRRRRRRRRRRRR-% load the cellSpeedAggregatedTime to get
load('cellSpeedAggregatedTime')
estimatedSpeedAlg5 = algorithm5(cellSpeedAggregatedTime,cellSize,totalNumberOfCells,numberOfLinks,numberOfTimeSteps,numberOfCells,firstCell);
% print(h,'-dpng','H:\TNK103\plots\algorithm5For21mars.png')
%%

%% Algorithm 6: GPS data - Adaptive Smoothing Method
load('cellSpeedAggregatedTime')
estimatedSpeedAlg6 = algorithm6(cellSpeedAggregatedTime,cellSize,totalNumberOfCells,numberOfLinks,numberOfTimeSteps,numberOfCells,firstCell);
% print(h,'-dpng','H:\TNK103\plots\algorithm6For21mars.png')
%%

%% Algorithm 7: GPS data - Adaptive Smoothing Method - to use standalone
load('cellSpeedAggregatedTime')
estimatedSpeedAlg7 = algorithm7(cellSpeedAggregatedTime,cellSize,totalNumberOfCells,numberOfLinks,numberOfTimeSteps,numberOfCells,firstCell);
% print(h,'-dpng','H:\TNK103\plots\algorithm5For21mars.png')
%%

%% Data fusion: Data fusion for algorithm 3 (radar sensor data) and algorithm 6 (GPS data)
estimatedSpeedFusion = dataFusion(numberOfTimeSteps,firstCell,totalNumberOfCells,estimatedSpeedAlg3,estimatedSpeedAlg6);
% print(h,'-dpng','H:\TNK103\plots\algorithm7For21mars.png')
%%


%% PART ABOVE THIS IS THE SAME AS IN TNK103project
%% Get Bluetooth Data
links = [200, 198];
[temp, cells, cellOffset] = getTTFromBluetooth(links, network, startTime, endTime, linkIdArray);
BTdata(1,2:size(temp(1,:),2)) = temp(1,1:end-1);
BTdata(1,1) = BTdata(1,2);
BTdata(2,2:size(temp(2,:),2)) = temp(2,1:end-1);
BTdata(2,1) = BTdata(2,2);


%%
segment1Name = 'South (Cell 30-36)';
segment2Name = 'North (Cell 19-24)';

%% Plots
%Plot heatmaps for sensor data algorithms
figure(1)
subplot(2,2,1)
plotHeatMap(estimatedSpeedAlg1,startTime, endTime, numberOfTimeSteps, 'Algorithm 1: Radar sensors - only space fill');
subplot(2,2,2)
plotHeatMap(estimatedSpeedAlg2,startTime, endTime, numberOfTimeSteps, 'Algorithm 2: Radar sensors - Isotropic Smoothing Method');
subplot(2,2,3.5)
plotHeatMap(estimatedSpeedAlg3,startTime, endTime, numberOfTimeSteps, 'Algorithm 3: Radar sensors - Adaptive Smoothing Method');

%Plot tt for alg 1,2,3 and bt-data
ttAlg11 = travelTimesInterval(estimatedSpeedAlg1, steplength, cellSizeAll, numberOfTimeSteps, cells(1,1), cells(1,2), cellOffset(1,1), cellOffset(1,2));
ttAlg21 = travelTimesInterval(estimatedSpeedAlg2, steplength, cellSizeAll, numberOfTimeSteps, cells(1,1), cells(1,2), cellOffset(1,1), cellOffset(1,2));
ttAlg31 = travelTimesInterval(estimatedSpeedAlg3, steplength, cellSizeAll, numberOfTimeSteps, cells(1,1), cells(1,2), cellOffset(1,1), cellOffset(1,2));

ttAlg12 = travelTimesInterval(estimatedSpeedAlg1, steplength, cellSizeAll, numberOfTimeSteps, cells(2,1), cells(2,2), cellOffset(2,1), cellOffset(2,2));
ttAlg22 = travelTimesInterval(estimatedSpeedAlg2, steplength, cellSizeAll, numberOfTimeSteps, cells(2,1), cells(2,2), cellOffset(2,1), cellOffset(2,2));
ttAlg32 = travelTimesInterval(estimatedSpeedAlg3, steplength, cellSizeAll, numberOfTimeSteps, cells(2,1), cells(2,2), cellOffset(2,1), cellOffset(2,2));

figure(2)
subplot(2,1,1)
hold on;
plotTravelTimesDifferentStartTimes(BTdata(1,:), startTime, endTime, steplength,'--ob', segment1Name)
plotTravelTimesDifferentStartTimes(ttAlg11, startTime, endTime, steplength,'--xr', segment1Name)
plotTravelTimesDifferentStartTimes(ttAlg21, startTime, endTime, steplength,'--sg', segment1Name)
plotTravelTimesDifferentStartTimes(ttAlg31, startTime, endTime, steplength,'-->k', segment1Name)
legend('BT','Alg1','Alg2','Alg3','Location','northwest')
subplot(2,1,2)
hold on;
plotTravelTimesDifferentStartTimes(BTdata(2,:), startTime, endTime, steplength,'--ob', segment2Name)
plotTravelTimesDifferentStartTimes(ttAlg12, startTime, endTime, steplength,'--xr', segment2Name)
plotTravelTimesDifferentStartTimes(ttAlg22, startTime, endTime, steplength,'--sg', segment2Name)
plotTravelTimesDifferentStartTimes(ttAlg32, startTime, endTime, steplength,'-->k', segment2Name)
legend('BT','Alg1','Alg2','Alg3','Location','northwest')
hold off;

%Plot GPS Heatmaps
figure(3)
subplot(1,2,1)
plotHeatMap(estimatedSpeedAlg5,startTime, endTime, numberOfTimeSteps, 'Algorithm 5: GPS data - Isotropic Smoothing Method');
subplot(1,2,2)
plotHeatMap(estimatedSpeedAlg7,startTime, endTime, numberOfTimeSteps, 'Algorithm 7:  GPS data - Adaptive Smoothing Method');
%Plot tt for GPS algorithms
ttAlg51 = travelTimesInterval(estimatedSpeedAlg5, steplength, cellSizeAll, numberOfTimeSteps, cells(1,1), cells(1,2), cellOffset(1,1), cellOffset(1,2));
ttAlg71 = travelTimesInterval(estimatedSpeedAlg7, steplength, cellSizeAll, numberOfTimeSteps, cells(1,1), cells(1,2), cellOffset(1,1), cellOffset(1,2));
ttAlg52 = travelTimesInterval(estimatedSpeedAlg5, steplength, cellSizeAll, numberOfTimeSteps, cells(2,1), cells(2,2), cellOffset(2,1), cellOffset(2,2));
ttAlg72 = travelTimesInterval(estimatedSpeedAlg7, steplength, cellSizeAll, numberOfTimeSteps, cells(2,1), cells(2,2), cellOffset(2,1), cellOffset(2,2));
figure(4)
subplot(2,1,1)
hold on;
plotTravelTimesDifferentStartTimes(BTdata(1,:), startTime, endTime, steplength,'--ob', segment1Name)
plotTravelTimesDifferentStartTimes(ttAlg51, startTime, endTime, steplength,'--xr', segment1Name)
plotTravelTimesDifferentStartTimes(ttAlg71, startTime, endTime, steplength,'--sg', segment1Name)
legend('BT','Alg5','Alg7','Location','northwest')
subplot(2,1,2)
hold on;
plotTravelTimesDifferentStartTimes(BTdata(2,:), startTime, endTime, steplength,'--ob', segment2Name)
plotTravelTimesDifferentStartTimes(ttAlg52, startTime, endTime, steplength,'--xr', segment2Name)
plotTravelTimesDifferentStartTimes(ttAlg72, startTime, endTime, steplength,'--sg', segment2Name)
legend('BT','Alg5','Alg7','Location','northwest')
hold off;

%Plot heatMaps of the different "interesting" algorithms (Done!)
figure(5)
subplot(2,2,1)
plotHeatMap(estimatedSpeedAlg3,startTime, endTime, numberOfTimeSteps, 'Algorithm 3:  Radar sensors - Adaptive Smoothing Method');
subplot(2,2,2)
plotHeatMap(estimatedSpeedAlg6,startTime, endTime, numberOfTimeSteps, 'Algorithm 6: GPS data - Adaptive Smoothing Method');
subplot(2,2,3.5)
plotHeatMap(estimatedSpeedFusion,startTime, endTime, numberOfTimeSteps, 'Data fusion for Algorithm 3 (radar sensor data) and Algorithm 6 (GPS data)');

ttAlg61 = travelTimesInterval(estimatedSpeedAlg6, steplength, cellSizeAll, numberOfTimeSteps, cells(1,1), cells(1,2), cellOffset(1,1), cellOffset(1,2));
ttAlgfus1 = travelTimesInterval(estimatedSpeedFusion, steplength, cellSizeAll, numberOfTimeSteps, cells(1,1), cells(1,2), cellOffset(1,1), cellOffset(1,2));
ttAlg62 = travelTimesInterval(estimatedSpeedAlg6, steplength, cellSizeAll, numberOfTimeSteps, cells(2,1), cells(2,2), cellOffset(2,1), cellOffset(2,2));
ttAlgfus2 = travelTimesInterval(estimatedSpeedFusion, steplength, cellSizeAll, numberOfTimeSteps, cells(2,1), cells(2,2), cellOffset(2,1), cellOffset(2,2));
figure(6)
subplot(2,1,1)
hold on;
plotTravelTimesDifferentStartTimes(BTdata(1,:), startTime, endTime, steplength,'--ob', segment1Name)
plotTravelTimesDifferentStartTimes(ttAlg31, startTime, endTime, steplength,'--xr', segment1Name)
plotTravelTimesDifferentStartTimes(ttAlg61, startTime, endTime, steplength,'--sg', segment1Name)
plotTravelTimesDifferentStartTimes(ttAlgfus1, startTime, endTime, steplength,'-->k', segment1Name)
legend('BT','Alg3','Alg6','Fus','Location','northwest')
subplot(2,1,2)
hold on;
plotTravelTimesDifferentStartTimes(BTdata(2,:), startTime, endTime, steplength,'--ob', segment2Name)
plotTravelTimesDifferentStartTimes(ttAlg32, startTime, endTime, steplength,'--xr', segment2Name)
plotTravelTimesDifferentStartTimes(ttAlg62, startTime, endTime, steplength,'--sg', segment2Name)
plotTravelTimesDifferentStartTimes(ttAlgfus2, startTime, endTime, steplength,'-->k', segment2Name)
legend('BT','Alg3','Alg6','Fus','Location','northwest')
hold off;

%% abs mean calc
Deviation(1,:) = getAbsMean(BTdata(1,:), [ttAlg11; ttAlg21; ttAlg31; ttAlg51; ttAlg61; ttAlg71; ttAlgfus1]);
Deviation(2,:) = getAbsMean(BTdata(2,:), [ttAlg12; ttAlg22; ttAlg32; ttAlg52; ttAlg62; ttAlg72; ttAlgfus2]);
