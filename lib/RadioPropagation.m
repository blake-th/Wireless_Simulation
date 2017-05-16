classdef RadioPropagation
properties
    pathLoss;
    shadowing;
    fading;
end

methods
    %% RadioPropagation: constructor
    function [obj] = RadioPropagation(pathLoss, shadowing, fading)
        obj.pathLoss = pathLoss;
        obj.shadowing = shadowing;
        obj.fading = fading;
    end

    %% rxPow: compute receive power
    function [p] = rxPow(obj, plArgs, sdArgs, fdArgs, txPow, txGain, rxGain)
        p = pathLoss.T(plArgs{:}) * shadowing.T(sdArgs{:}) * fading.T(fdArgs{:}) * txPow * txGain * rxGain;
    end

end


end