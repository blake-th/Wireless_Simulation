classdef Station < handle
properties
    location;
    height;
    txPow;
    txGain;
    rxGain;
    trafficBuffer;
    analysis;
end

methods
    %% Station: constructor
    function [obj] = Station(location, height, txPow, txGain, rxGain, trafficBuffer, analysis)
        obj.location = location;
        obj.height = height;
        obj.txPow = txPow;
        obj.txGain = txGain;
        obj.rxGain = rxGain;
        obj.trafficBuffer = trafficBuffer;
        obj.analysis = analysis;
    end

    %% dist: distance between self and s
    function [d] = dist(obj, s, r)
        d = r * pdist([obj.location; s.location]);
    end
    
    %% receiveData: receive data
    function [obj] = receiveData(obj, dataSize)
        obj.trafficBuffer.dataIn(dataSize);
    end

    %% transmitData: transmit data
    function [obj] = transmitData(obj, shannonCapacity)
        obj.trafficBuffer.dataOut(shannonCapacity);
    end
    
end

end