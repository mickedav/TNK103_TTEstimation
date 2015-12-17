function [numberOfCells, cellSize, lengthStretch, totalNumberOfCells, cellSizeAll] = getCellMap(network, linkIdArray)
%initiate
numberOfCells = 0;
cellSize = 0;
lengthStretch = 0;
cellSizeAll = 0;
%loop trough all link id:s
for j = linkIdArray
    link = network.getLinkWithID(j);
    %store number of cells and cell size from actual link
    numberOfCells(end+1) = link.getNbCells;
    cellSize(end+1) = link.getLength / numberOfCells(end);
    %summarize total total length of stretch
    lengthStretch = lengthStretch + link.getLength;
end
numberOfCells = numberOfCells(2:end);
cellSize = cellSize(2:end);
totalNumberOfCells = sum(numberOfCells);

curr = 1;
%create cell map whith all cells and cell sizes
for i = numberOfCells
    for j = 1:i
        cellSizeAll(end+1) = cellSize(curr);
    end
    curr = curr + 1;
end
cellSizeAll = cellSizeAll(2:end);
end