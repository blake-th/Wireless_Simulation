classdef Cell < handle
properties
    coordinate;
    location;
end

methods
    %% Cell: constructor
    function [obj] = Cell(coordinate, location)
        obj.coordinate = coordinate;
        obj.location = location;
        obj.showBoundary(1);
    end

    %% vertices: return hexagon vertices
    function [x, y] = vertices(obj)
        phase = linspace(0, 5*pi/3, 6);
        x = cos(phase) + obj.location(1);
        y = sin(phase) + obj.location(2);
    end

    %% showBoundary: show boundary
    function [obj] = showBoundary(obj, r)
        [x, y] = obj.vertices();
        hold on;
        plot(r*[x, x(1)], r*[y, y(1)], 'r');
        hold off;
    end

end

end