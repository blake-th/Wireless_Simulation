classdef MobileStation < Station 
properties
end

methods
    %% MobileStation: constructor
    function [obj] = MobileStation(id, location, height, txPow, txGain, rxGain)
        obj@Station(id, location, height, txPow, txGain, rxGain);
    end

    %% showLoc: show location
    function [obj] = showLoc(obj, r)
        hold on;
        scatter(r*obj.location(1), r*obj.location(2), [], 'b', 'filled', 'o');
        hold off;
    end

    %% move: random walk
    function [outputs] = move(arg)
        outputs = ;
    

end

end