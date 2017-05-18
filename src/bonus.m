import BaseStation;
import MobileStation;
import Cell;
import HexagonGrid;
import RadioPropagation;
import TwoRay;
import Fading;
import Shadowing;
import TrafficBuffer;
import util.*;
ut = util();


%% problem settings
temperature = ut.C_to_K(27);
ISD = 500;
channelBW = 10 * 10^6;
FRF  = 1;
txPow_BS = ut.dBm_to_w(33);
txPow_MS = ut.dBm_to_w(0);
xGain = ut.dB_to_w(14);
height_BS = 1.5 + 50;
height_MS = 1.5;
simulationDuration = 1000;
trafficBufferSize = 6 * 10^6;
numMS = 50;
numCell = 19;

%% init
rpModel = RadioPropagation(TwoRay(), Shadowing(), Fading());
hGrid = HexagonGrid(2, @Cell);
BS = {};
MS = {};
CELL = values(hGrid.cell);
r = ISD / sqrt(3);
allocatedBW = channelBW / numMS;

thermalNoise = ut.thermalNoise(temperature, allocatedBW);

centralBS = [];
for n = 1:numCell
    BS{n} = BaseStation(CELL{n}, height_BS, txPow_BS, xGain, xGain, TrafficBuffer(trafficBufferSize));
    if CELL{n} == hGrid.cell('0,0,0')
        centralBS = BS{n};
    end
end 

[centralCellX, centralCellY] = centralBS.cell.vertices();

rndInX = [];
rndInY = [];
while numel(rndInX) < numMS
    rndX = 2 * rand(1, numMS) - 1;
    rndY = 2 * rand(1, numMS) - 1;
    isIn = inpolygon(rndX, rndY, centralCellX, centralCellY);
    rndInX = [rndInX, rndX(isIn)];
    rndInY = [rndInY, rndY(isIn)];
end
rndInX = rndInX(1:numMS);
rndInY = rndInY(1:numMS);

for n = 1:numMS
    MS{n} = MobileStation([rndInX(n), rndInY(n)], height_MS, txPow_MS, xGain, xGain, TrafficBuffer(trafficBufferSize));
end


%B-1
figure('Name', 'problem B-1');
centralBS.showLoc(r);
centralBS.cell.showBoundary(r);
for n = 1:numMS
    MS{n}.showLoc(r);
end
axis equal;
title('B-1 Location');
xlabel('Distance (m)');
ylabel('Distance (m)');

%B-2
sumCapacity = 0;
figure('Name', 'problem B-2');
for n = 1:numMS
    ms = MS{n};
    intfPower = 0;
    rxPow = 0;
    for m = 1:numCell
        bs = BS{m};
        d = ms.dist(bs, r);
        if bs == centralBS
            rxPow = rpModel.rxPow({d, height_BS, height_MS}, {}, {}, bs.txPow, bs.txGain, ms.rxGain);
            continue;
        end
        intfPower = intfPower + rpModel.rxPow({d, height_BS, height_MS}, {}, {}, bs.txPow, bs.txGain, ms.rxGain);
    end
    capacity = ut.shannonCapacity(allocatedBW, rxPow, intfPower, thermalNoise);
    sumCapacity = sumCapacity + capacity;
    hold on;
    scatter(ms.dist(centralBS, r), capacity);
    title('B-2 Shannon Capacity');
    xlabel('Distance (m)');
    ylabel('Shannon Capacity (bits/s)');
    hold off;
end

%B-3
avgCapacity = sumCapacity / numMS;
lambda_L = 0.1 * avgCapacity;
lambda_H = 1.0;
lambda_M = (lambda_L + lambda_H) / 2;


%{ DEBUG PART
figure('Name', 'Debug');
for n = 1:numel(CELL)
    BS{n}.showLoc(r);
    CELL{n}.showBoundary(r);
    CELL{n}.showId(n, r);
end
%}


