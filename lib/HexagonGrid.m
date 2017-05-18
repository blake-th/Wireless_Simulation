classdef HexagonGrid < handle
properties
    cell;
end


methods
    %% HexagonGrid: constructor
    function [obj] = HexagonGrid(gridSize, cellConstructor)
        obj.cell = containers.Map('KeyType', 'char', 'ValueType', 'any');
        obj.build(gridSize, cellConstructor);
    end

    %% build: build grid
    function [obj] = build(obj, gridSize, Cell)
        obj.cell('0,0,0') = Cell([0, 0, 0], [0, 0]);

        ydir = sqrt(3) * [cos(5*pi/6), sin(5*pi/6)];
        zdir = sqrt(3) * [cos(-5*pi/6), sin(-5*pi/6)];

        % x = 0
        x = 0;
        for y = 1:gridSize
            z = -y;
            obj.cell(sprintf('%d,%d,%d', x, y, z)) = Cell([x, y, z], y*ydir+z*zdir);    
        end

        % y = 0
        y = 0;
        for z = 1:gridSize
            x = -z;
            obj.cell(sprintf('%d,%d,%d', x, y, z)) = Cell([x, y, z], y*ydir+z*zdir);
        end

        % z = 0
        z = 0;
        for x = 1:gridSize
            y = -x;
            obj.cell(sprintf('%d,%d,%d', x, y, z)) = Cell([x, y, z], y*ydir+z*zdir);
        end

        % yx
        for y = 1:gridSize
            for x = -gridSize:-1
                z = -(y + x);
                obj.cell(sprintf('%d,%d,%d', x, y, z)) = Cell([x, y, z], y*ydir+z*zdir);
            end
        end

        % zy
        for z = 1:gridSize
            for y = -gridSize:-1
                x = -(z + y);
                obj.cell(sprintf('%d,%d,%d', x, y, z)) = Cell([x, y, z], y*ydir+z*zdir);
            end
        end

        % xz
        for x = 1:gridSize
            for z = -gridSize:-1
                y = -(x + z);
                obj.cell(sprintf('%d,%d,%d', x, y, z)) = Cell([x, y, z], y*ydir+z*zdir);
            end
        end

    end

end


end