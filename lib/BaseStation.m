classdef BaseStation < Station 
properties
    cell;
end

methods
    %% BaseStation: constructor
    function [obj] = BaseStation(cell, height, txPow, txGain, rxGain, trafficBuffer, analysis)
        obj@Station(cell.location, height, txPow, txGain, rxGain, trafficBuffer, analysis);
        obj.cell = cell;
    end

    %% showLoc: show location
    function [obj] = showLoc(obj, r)
        hold on;
        scatter(r*obj.location(1), r*obj.location(2), [], 'g', 'filled', 'diamond');
        hold off;
    end

end

end