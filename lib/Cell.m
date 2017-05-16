classdef Cell < handle
properties
    id;
    loc;
end

methods
    %% Cell: constructor
    function [obj] = Cell(id, loc)
        obj.id = id;
        obj.loc = loc;
    end

    %% vertices: return hexagon vertices
    function [x, y] = vertices(obj)
        phase = linspace(0, 2*pi, 7);
        x = cos(phase) + obj.loc(1);
        y = sin(phase) + obj.loc(2);
    end

    
end

end