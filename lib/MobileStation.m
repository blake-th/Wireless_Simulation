classdef MobileStation < Station 
properties
end

methods
    %% MobileStation: constructor
    function [obj] = MobileStation(loc, height, txPow, txGain, rxGain)
        obj@Station(loc, height, txPow, txGain, rxGain);
    end

end

end