classdef Station < handle
properties
    location;
    height;
    txPow;
    txGain;
    rxGain;
    trafficBuffer;
end

methods
    %% Station: constructor
    function [obj] = Station(location, height, txPow, txGain, rxGain, trafficBuffer)
        obj.location = location;
        obj.height = height;
        obj.txPow = txPow;
        obj.txGain = txGain;
        obj.rxGain = rxGain;
        obj.trafficBuffer = trafficBuffer;
    end

    %% dist: distance between self and s
    function [d] = dist(obj, s)
        d = pdist([obj.location; s.location]);
    end
    
    
end

end