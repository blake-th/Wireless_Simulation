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
        linspace(0, 2*pi, 6);
        x = ;
        y = ;
    end
    
end

end