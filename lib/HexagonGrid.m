classdef HexagonGrid < handle
properties
    cells;
end


methods
    %% HexagonGrid: constructor
    function [obj] = HexagonGrid(gridSize, cellConstructor)
        obj.cells = containers.Map('KeyType', 'char', 'ValueType', 'any');
        obj.build(gridSize, cellConstructor);
    end

    %% build: build grid
    function [obj] = build(obj, gridSize, Cell)
        obj.cells('0,0,0') = Cell([0, 0, 0], [0, 0]);

        ydir = sqrt(3) * [cos(5*pi/6), sin(5*pi/6)];
        zdir = sqrt(3) * [cos(-5*pi/6), sin(-5*pi/6)];

        % x = 0
        x = 0;
        for y = 1:gridSize
            z = -y;
            obj.cells(sprintf('%d,%d,%d', x, y, z)) = Cell([x, y, z], y*ydir+z*zdir);
            disp([x,y,z]);        
        end

        % y = 0
        y = 0;
        for z = 1:gridSize
            x = -z;
            obj.cells(sprintf('%d,%d,%d', x, y, z)) = Cell([x, y, z], y*ydir+z*zdir);
            disp([x,y,z]);
        end

        % z = 0
        z = 0;
        for x = 1:gridSize
            y = -x;
            obj.cells(sprintf('%d,%d,%d', x, y, z)) = Cell([x, y, z], y*ydir+z*zdir);
            disp([x,y,z]);
        end

        % yx
        for y = 1:gridSize
            for x = -gridSize:-1
                z = -(y + x);
                obj.cells(sprintf('%d,%d,%d', x, y, z)) = Cell([x, y, z], y*ydir+z*zdir);
                disp([x,y,z]);
            end
        end

        % zy
        for z = 1:gridSize
            for y = -gridSize:-1
                x = -(z + y);
                obj.cells(sprintf('%d,%d,%d', x, y, z)) = Cell([x, y, z], y*ydir+z*zdir);
                disp([x,y,z]);
            end
        end

        % xz
        for x = 1:gridSize
            for z = -gridSize:-1
                y = -(x + z);
                obj.cells(sprintf('%d,%d,%d', x, y, z)) = Cell([x, y, z], y*ydir+z*zdir);
                disp([x,y,z]);
            end
        end

        disp('cell count:');
        disp(obj.cells.Count);

    end


end


end