function [cellSpeed] = setCellSpeedTaxi(startCell, endCell, v, totalNumberOfCells)
%set cell speed for individual taxis
cellSpeed = NaN(1,totalNumberOfCells);
for i = startCell:endCell
    cellSpeed(i) = v;
end

end