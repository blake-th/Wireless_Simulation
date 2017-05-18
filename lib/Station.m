classdef Station < handle
properties
    location;
    height;
    txPow;
    txGain;
    rxGain;
end

methods
    %% Station: constructor
    function [obj] = Station(location, height, txPow, txGain, rxGain)
        obj.location = location;
        obj.height = height;
        obj.txPow = txPow;
        obj.txGain = txGain;
        obj.rxGain = rxGain;
    end
    
end

end