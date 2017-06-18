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

import util.*;
ut = util();

%% handoff criteria
DROPOUT_THRESHOLD = -100; % dB given
HANDOFF_THRESHOLD = -90; % dB given
HANDOFF_TIME = 2; % given
HANDOFF_WINDOW = 5;% (avoid noise)
MOBILITY = 8; % m/s
SIMULATION_TIME = 1;

%% problem settings
temperature = ut.C_to_K(27);
ISD = 500;
channelBW = 10 * 10^6;
FRF  = 1;
txPow_BS = ut.dBm_to_w(33);
txPow_MS = ut.dBm_to_w(0);
txGain_BS = ut.dB_to_w(14);
txGain_MS = ut.dB_to_w(14);
rxGain_BS = ut.dB_to_w(14);
rxGain_MS = ut.dB_to_w(14);
height_BS = 1.5 + 50;
height_MS = 1.5;

numMS = 50;
numCell = 19;
numBS = 19;
thermalNoise = ut.thermalNoise(temperature, channelBW);

%% init
rpModel = RadioPropagation(TwoRay(), Shadowing(), Fading());
hGrid = HexagonGrid(2, @Cell);
BS = {};
MS = {};
CELL = values(hGrid.cell);
r = ISD / sqrt(3);

%% init BS
centralBS = [];
for n = 1:numCell
    BS{n} = BaseStation(n, CELL{n}, height_BS, txPow_BS, txGain_BS, rxGain_BS);
    if CELL{n} == hGrid.cell('0,0,0')
        centralBS = BS{n};
    end
end 

%% init random MS
MS_SPEEDRANGE = [1, 15] / r;
MS_MOVINGTIMERANGE = [1, 6] / r;
while numel(MS) < numMS
    bsId = randi(numBS);
    [cellVerticesX, cellVerticesY] = BS{bsId}.cell.vertices();
    isIn = false;
    rndX = Inf;
    rndY = Inf;
    while ~isIn
        rndX = 2 * rand() - 1 + BS{bsId}.location(1);
        rndY = 2 * rand() - 1 + BS{bsId}.location(2);
        isIn = inpolygon(rndX, rndY, cellVerticesX, cellVerticesY);
    end
    MS{end+1} = MobileStation(numel(MS)+1, [rndX, rndY], height_MS, txPow_MS, txGain_MS, rxGain_MS, MS_SPEEDRANGE, MS_MOVINGTIMERANGE);
end

%% asign MS to BS according to max SINR
for n = 1:numBS
    bs = BS{n};
    totalPow = 0;

    for m = 1:numMS
        ms = MS{m};
        d = ms.dist(bs, r);
        rxPow = rpModel.rxPow({d, height_BS, height_MS}, {}, {}, ms.txPow, ms.txGain, bs.rxGain);
        totalPow = totalPow + rxPow;
        bs.rxPow(ms.id) = rxPow;
    end

    for m = 1:numMS
        ms = MS{m};
        rxPow = bs.rxPow(ms.id);
        SINR = ut.SINR(rxPow, totalPow-rxPow, thermalNoise);
        bs.SINR(ms.id) = SINR;
        ms.SINR(bs.id) = SINR;
    end
end

for n = 1:numMS
    ms = MS{n};
    bsId = keys(ms.SINR);
    SINR = values(ms.SINR, bsId);
    [m, idx] = max(cell2mat(SINR));
    BS{bsId{idx}}.register(ms.id) = true;
    ms.bsHistory(end+1) = bsId{idx};
end


%% calc map boundary
hGrid.calcBoundary();

%% start simulation 
%%{
disp('start simulation...');
for t = 1:SIMULATION_TIME
    disp(sprintf('t: %d\n', t));
    % ms move
    for n = 1:numMS
        newLoc = MS{n}.nextMove() + MS{n}.location;
        if ~inpolygon(newLoc(1), newLoc(2), hGrid.bndX, hGrid.bndY)
            newLoc = - MS{n}.location;
        end

        MS{n}.location = newLoc;
    end

    % bs signal power
    for n = 1:numBS
        bs = BS{n};
        for m = 1:numMS
            ms = MS{m};
            d = ms.dist(bs, r);
            bs.rxPow(ms.id) = rpModel.rxPow({d, height_BS, height_MS}, {}, {}, ms.txPow, ms.txGain, bs.rxGain);
        end

    end
end
%%}



%%{
%% show all
for n = 1:numBS
    BS{n}.showLoc(1);
    BS{n}.cell.showBoundary(1);
end
for n = 1:numMS
    MS{n}.showLoc(1);
end
hGrid.showBoundary(1);
%%}