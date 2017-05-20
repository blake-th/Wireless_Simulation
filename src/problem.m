clear;
clc;

import BaseStation;
import MobileStation;
import Cell;
import HexagonGrid;
import RadioPropagation;
import TwoRay;
import Fading;
import Shadowing;
import TrafficBuffer;
import Analysis;
import TrafficData;
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
    BS{n} = BaseStation(CELL{n}, height_BS, txPow_BS, xGain, xGain, TrafficBuffer(trafficBufferSize), Analysis());
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
    MS{n} = MobileStation([rndInX(n), rndInY(n)], height_MS, txPow_MS, xGain, xGain, TrafficBuffer(trafficBufferSize), Analysis());
end

intfPower = zeros(1, numMS);
rxPow = zeros(1, numMS);
shannonCapacity = zeros(1, numMS);


%% 1. [Downlink, Constant Bit Rate]
%1-1
figure('Name', 'problem 1-1');
centralBS.showLoc(r);
centralBS.cell.showBoundary(r);
for n = 1:numMS
    MS{n}.showLoc(r);
end
axis equal;
title('1-1 Location');
xlabel('Distance (m)');
ylabel('Distance (m)');

%1-2
figure('Name', 'problem 1-2');
for n = 1:numMS
    ms = MS{n};
    for m = 1:numCell
        bs = BS{m};
        d = ms.dist(bs, r);
        if bs == centralBS
            rxPow(n) = rpModel.rxPow({d, height_BS, height_MS}, {}, {}, bs.txPow, bs.txGain, ms.rxGain);
            continue;
        end
        intfPower(n) = intfPower(n) + rpModel.rxPow({d, height_BS, height_MS}, {}, {}, bs.txPow, bs.txGain, ms.rxGain);
    end
    shannonCapacity(n) = ut.shannonCapacity(allocatedBW, rxPow(n), intfPower(n), thermalNoise);
    hold on;
    scatter(ms.dist(centralBS, r), shannonCapacity(n));
    title('1-2 Shannon Capacity');
    xlabel('Distance (m)');
    ylabel('Shannon Capacity (bits/s)');
    hold off;
end

%1-3
totalShannonCapacity = sum(shannonCapacity);
avgShannonCapacity = totalShannonCapacity / numMS;
ratio = trafficBufferSize / avgShannonCapacity;
disp('ratio');
disp(ratio);

CBR_L = 0.13 * trafficBufferSize;
CBR_M = 0.15 * trafficBufferSize;
CBR_H = 0.17 * trafficBufferSize;
CBR = [CBR_L, CBR_M, CBR_H];

loss = zeros(1, 3);
lossRate = zeros(1, 3);

for n = 1:numel(CBR)
    trafficDataPerSec = CBR(n) * numMS;

    for t = 1:simulationDuration
        centralBS.receiveData(trafficDataPerSec);
        centralBS.transmitData(totalShannonCapacity);

        if centralBS.trafficBuffer.isOverflow()
            loss(n) = loss(n) + centralBS.trafficBuffer.drop();
        end
    end

    centralBS.trafficBuffer.clear();
    lossRate(n) = loss(n) / (trafficDataPerSec * simulationDuration);
end

figure('Name', ' problem 1-3');
bar(lossRate, 'c');
title('CBR');
set(gca, 'XTick', 1:numel(CBR), 'XTickLabel', {'Low', 'Medium', 'High'});
axis([0.5, numel(CBR)+0.5, 0, 1.0]);
xlabel('Traffic Load');
ylabel('Bits Loss Probability');
for n = 1:numel(CBR)
    text(n, lossRate(n)+0.1, sprintf('%.4f', lossRate(n)));
end