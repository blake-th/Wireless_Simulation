classdef MobileStation < Station 
properties
end

methods
    %% MobileStation: constructor
    function [obj] = MobileStation(location, height, txPow, txGain, rxGain, trafficBuffer, analysis)
        obj@Station(location, height, txPow, txGain, rxGain, trafficBuffer, analysis);
    end

    %% showLoc: show location
    function [obj] = showLoc(obj, r)
        hold on;
        scatter(r*obj.location(1), r*obj.location(2), [], 'b', 'filled', 'o');
        hold off;
    end

end

end