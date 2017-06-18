classdef BaseStation < Station 
properties
    cell;
    register;
end

methods
    %% BaseStation: constructor
    function [obj] = BaseStation(id, cell, height, txPow, txGain, rxGain)
        obj@Station(id, cell.location, height, txPow, txGain, rxGain);
        obj.cell = cell;
        obj.register = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    end

    %% showLoc: show location
    function [obj] = showLoc(obj, r)
        hold on;
        scatter(r*obj.location(1), r*obj.location(2), [], 'g', 'filled', 'diamond');
        hold off;
    end

    %% drop: drop ms whose sinr too low
    function [obj] = drop(obj)
        ms = values(obj.register);
        for n = 1:numel(ms)

        end
    end

    %% sinr: calc sinr
    function [ratio] = sinr(obj, o)
        ratio = 1;
    end
    

end

end