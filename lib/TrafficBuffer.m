classdef TrafficBuffer < handle
properties
    maxSize;
    currentSize;
end


methods
    %% TrafficBuffer: constructor
    function [obj] = TrafficBuffer(maxSize)
        obj.maxSize = maxSize;
        obj.currentSize = 0;
    end

end

end