classdef Station < handle
properties
    id;
    location;
    height;
    txPow;
    txGain;
    rxGain;
    rxPow;
    SINR;
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
        obj.rxPow = containers.Map('KeyType', 'int32', 'ValueType', 'double');
        obj.SINR = containers.Map('KeyType', 'int32', 'ValueType', 'double');
    end

    %% dist: distance between self and s
    function [d] = dist(obj, s, r)
        d = r * pdist([obj.location; s.location]);
    end


    
end

end