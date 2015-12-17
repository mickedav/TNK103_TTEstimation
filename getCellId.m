function [startCell, cellOffset] = getCellId(Spot, linkIdArray, numberOfCells,  cellSize)
%get cell id from given spot
currentNumberOfCells = 0;

% index is the segment number (1-10)
index = find(linkIdArray == Spot.link.id);

for i = (index-1):-1:1
    currentNumberOfCells = currentNumberOfCells + numberOfCells(i);
end

%calculate cell offset
startCellOnLink = ceil(Spot.offset/cellSize(index));
cellOffset = (Spot.offset/cellSize(index) - floor(Spot.offset/cellSize(index)))* cellSize(index);
startCell = currentNumberOfCells + startCellOnLink;

end