classdef Cell < handle
properties
    id;
    loc;
    neighbor;
end

methods
    %% Cell: constructor
    function [obj] = Cell(id, loc)
        obj.id = id;
        obj.loc = loc;
        obj.neighbor = cell(1, 6);
    end

    %% vertices: return hexagon vertices
    function [x, y] = vertices(obj)
        phase = linspace(0, 5*pi/3, 6);
        x = cos(phase) + obj.loc(1);
        y = sin(phase) + obj.loc(2);
    end

    %% genNeighbor: generate neighbor by tierNum
    function [obj] = genNeighbor(obj, tierNum)
        if tierNum < 0
            return;
        end

        phase = linspace(pi/6, 11*pi/6, 6);
        x = sqrt(3) * cos(phase) + obj.loc(1);
        y = sqrt(3) * sin(phase) + obj.loc(2);

        for n = 1:numel(obj.neighbor)
            if isa(obj.neighbor{n}, 'Cell')
                continue;
            end

            

        end
    end

end

end