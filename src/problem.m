import BaseStation;
import MobileStation;
import Cell;
import HexagonGrid;
import RadioPropagation;
import TwoRay;
import Fading;
import Shadowing;
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
    BS{n} = BaseStation(CELL{n}, height_BS, txPow_BS, xGain, xGain, trafficBufferSize);
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
    MS{n} = MobileStation([rndInX(n), rndInY(n)], height_MS, txPow_MS, xGain, xGain, trafficBufferSize);
end

%% 1. [Downlink, Constant Bit Rate]
%1-1
figure('Name', 'problem 1-1');
centralBS.showLoc(r);
centralBS.cell.showBoundary(r);
for n = 1:numMS
    MS{n}.showLoc(r);
end

%1-2
sumCapacity = 0;
figure('Name', 'problem 1-2');
for n = 1:numMS
    ms = MS{n};
    intfPower = 0;
    rxPow = 0;
    for m = 1:numCell
        bs = BS{m};
        d = r * ms.dist(bs);
        if bs == centralBS
            rxPow = rpModel.rxPow({d, height_BS, height_MS}, {}, {}, bs.txPow, bs.txGain, ms.rxGain);
            continue;
        end
        intfPower = intfPower + rpModel.rxPow({d, height_BS, height_MS}, {}, {}, bs.txPow, bs.txGain, ms.rxGain);
    end
    capacity = ut.shannonCapacity(allocatedBW, rxPow, intfPower, thermalNoise);
    sumCapacity = sumCapacity + capacity;
    hold on;
    scatter(r*ms.dist(centralBS), capacity);
    title('1-2 Shannon Capacity');
    xlabel('Distance (m)');
    ylabel('Shannon Capacity (bits/s)');
    hold off;
end

%1-3
avgCapacity = sumCapacity / numMS;
CBR_L = 0.1 * avgCapacity;
CBR_H = 1.0 * avgCapacity;
CBR_M = (CBR_H + CBR_L) / 2;

%%{ DEBUG PART
figure('Name', 'Debug');
for n = 1:numel(CELL)
    BS{n}.showLoc(r);
    CELL{n}.showBoundary(r);
    CELL{n}.showId(n, r);
end
%%}


