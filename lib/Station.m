classdef Station < handle
properties
    loc;
    height;
    txPow;
    txGain;
    rxGain;
end

methods
    %% Station: constructor
    function [obj] = Station(loc, height, txPow, txGain, rxGain)
        obj.loc = loc;
        obj.height = height;
        obj.txPow = txPow;
        obj.txGain = txGain;
        obj.rxGain = rxGain;
    end

    
    
end

end