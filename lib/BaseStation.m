classdef BaseStation < Station 
properties
end

methods
    %% BaseStation: constructor
    function [obj] = BaseStation(loc, height, txPow, txGain, rxGain)
        obj@Station(loc, height, txPow, txGain, rxGain);
    end

end

end