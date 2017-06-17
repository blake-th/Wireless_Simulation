classdef Station < handle
properties
    id;
    location;
    height;
    txPow;
    txGain;
    rxGain;
end

methods
    %% Station: constructor
    function [obj] = Station(id, location, height, txPow, txGain, rxGain)
        obj.id = id;
        obj.location = location;
        obj.height = height;
        obj.txPow = txPow;
        obj.txGain = txGain;
        obj.rxGain = rxGain;
    end

    %% dist: distance between self and s
    function [d] = dist(obj, s, r)
        d = r * pdist([obj.location; s.location]);
    end
    
end

end