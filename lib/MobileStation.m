classdef MobileStation < Station 
properties
end

methods
    %% MobileStation: constructor
    function [obj] = MobileStation(location, height, txPow, txGain, rxGain)
        obj@Station(location, height, txPow, txGain, rxGain);
    end

end

end