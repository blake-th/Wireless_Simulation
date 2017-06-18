classdef MobileStation < Station 
properties
    speedRange;
    movingTimeRange;
    ang;
    timeCount;
    speed;
end

methods
    %% MobileStation: constructor
    function [obj] = MobileStation(id, location, height, txPow, txGain, rxGain, speedRange, movingTimeRange)
        obj@Station(id, location, height, txPow, txGain, rxGain);
        obj.speedRange = speedRange;
        obj.movingTimeRange = movingTimeRange;
    end

    %% showLoc: show location
    function [obj] = showLoc(obj, r)
        hold on;
        scatter(r*obj.location(1), r*obj.location(2), [], 'b', 'filled', 'o');
        hold off;
    end

    %% nextLoc: random walk
    function [newLoc] = nextLoc(obj)
        if obj.timeCount == 0
            obj.ang = 2 * pi * rand();
            obj.speed = (obj.speedRange(2)-obj.speedRange(1)) * rand() + obj.speedRange(1);
            obj.timeCount = randsample(obj.movingTimeRange(2), 1);
        end
        obj.timeCount = obj.timeCount - 1;
        newLoc = obj.speed * [cos(obj.ang), sin(obj.ang)];
    end
    

end

end