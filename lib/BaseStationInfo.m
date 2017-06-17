classdef BaseStationInfo < handle
properties
    register;
end

methods
    %% BaseStationInfo: constructor
    function [obj] = BaseStationInfo()
        obj.register = containers.Map('KeyType', int32, 'ValueType', 'any');
    end
    
end




end