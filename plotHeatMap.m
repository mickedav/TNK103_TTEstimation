function [temp] = plotHeatMap(temp,startTime,endTime, numberOfTimeSteps,titleString)
% to use this function, the array temp needs to be an array of size[rows=numberOfcells, columns=numberOfTimesteps]

% replace all NaN:s with zeros in order to get a nice plot with the same
% colors on the colorbar
temp(isnan(temp)) = 0;

% switch rows in order to plot with vehicles enter from south
switchArray = temp;
for i =1:50
    j=51-i;
    temp(i,:)=switchArray(j,:);
end

% the preferred time step (in minutes) between the ticks on the x-axis
timeStep = 30;

% make the startTime and endTime to strings
startTimeString = matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(startTime);
endTimeString =  matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(endTime);

% format the ticklabels 
formatOut = 'HH:MM';
startTimeNum = datenum(datestr(startTimeString,formatOut));
endTimeNum = datenum(datestr(endTimeString,formatOut));

% determine how many ticks that the x-axis is going to have
ticks = numberOfTimeSteps/timeStep + 1;

% defines the ticks between startTime and endTime
xDataNum = linspace(startTimeNum,endTimeNum,ticks);

% convert xDataNum to a string cell array xDataStr with element on the
% format 'HH:MM'
xDataStr = cell(ticks,1);
for i=1:(ticks)
    xDataStr{i} =[datestr(xDataNum(i),formatOut)];
end

% load the saved color map from mycolor.mat and plot temp
load('mycolor','color')
imagesc(temp);
colormap(color);
c=colorbar;

% set the tick labels on the x-axis
set(gca,'XLim',[0 numberOfTimeSteps])
set(gca,'XTick',[0:timeStep:numberOfTimeSteps])
set(gca,'XTickLabel',xDataStr)

% set the y-axis
yDataNum = [50 45 40 35 30 25 20 15 10 5];

% set the tick labels on the y-axis
set(gca,'YLim',[1 50])
set(gca,'YTick',[1:5:50])
set(gca,'YTickLabel',yDataNum)

% format the title if plot raw data for different days
formatOut = 'yyyy-mm-dd';
if strcmp(titleString,'date')
    startTimestr = datestr(startTimeString,formatOut);
else
    startTimestr = titleString;
end

title(startTimestr)
xlabel('time')
ylabel('cell ID')
ylabel(c,'km/h')
set(handle(c), 'ylim', [0 110])

end