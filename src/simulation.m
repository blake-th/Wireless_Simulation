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
DROPOUT_THRESHOLD = 0.01; % watt given
HANDOFF_THRESHOLD = 0.1; % watt given
HANDOFF_TIME = 2; % given
HANDOFF_WINDOW = 5;% (avoid noise)
MOBILITY = 8; % m/s
SIMULATION_TIME = 100;

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
MS_SPEEDRANGE = [MOBILITY, MOBILITY] / r;
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
    %% total power and each ms signal power
    for m = 1:numMS
        ms = MS{m};
        d = ms.dist(bs, r);
        rxPow = rpModel.rxPow({d, height_BS, height_MS}, {}, {}, ms.txPow, ms.txGain, bs.rxGain);
        totalPow = totalPow + rxPow;
        bs.rxPow(ms.id) = rxPow;
    end
    %% calc sinr
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
    ms.lastBs = BS{bsId{idx}};
    ms.registerBsId = bsId{idx};
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

    % calc SINR
    for n = 1:numBS
        bs = BS{n};
        totalPow = 0;
        %% total power and each ms signal power
        for m = 1:numMS
            ms = MS{m};
            d = ms.dist(bs, r);
            rxPow = rpModel.rxPow({d, height_BS, height_MS}, {}, {}, ms.txPow, ms.txGain, bs.rxGain);
            totalPow = totalPow + rxPow;
            bs.rxPow(ms.id) = rxPow;
        end
        %% sinr
        for m = 1:numMS
            ms = MS{m};
            rxPow = bs.rxPow(ms.id);
            SINR = ut.SINR(rxPow, totalPow-rxPow, thermalNoise);
            bs.SINR(ms.id) = SINR;
            ms.SINR(bs.id) = SINR;
        end
    end

    %% trigger handoff
    for n = 1:numMS
        ms = MS{n};
        lastBsId = ms.bsHistory(end);
        if lastBsId == 0 
            if ms.handoffTime < 0
                %% find new BS
                bsId = keys(ms.SINR);
                SINR = values(ms.SINR, bsId);
                [m, idx] = max(cell2mat(SINR));
                ms.startHandoff(ms.lastBs, BS{bsId{idx}}, HANDOFF_TIME);
            end
            continue;
        end
        lastBs = BS{lastBsId};
        newBs = lastBs;
        if ms.SINR(lastBs.id) < HANDOFF_THRESHOLD
            if ms.handoffTime >= 0
                continue;
            end
            bsId = keys(ms.SINR);
            SINR = values(ms.SINR, bsId);
            [m, idx] = max(cell2mat(SINR));
            newBs = BS{bsId{idx}};
            if newBs ~= lastBs
                ms.startHandoff(lastBs, newBs, HANDOFF_TIME);
            end
        end
    end

    %% bs drop
    for n = 1:numBS
        bs = BS{n};
        msId = keys(bs.register);
        for m = 1:numel(msId)
            ms = MS{msId{m}};
            if bs.SINR(msId{m}) < DROPOUT_THRESHOLD
                remove(bs.register, msId{m});
                ms.registerBsId = 0;
            end
        end
    end

end
%%}



%%{
%% show all
for n = 1:numBS
    BS{n}.showLoc(1);
    BS{n}.cell.showBoundary(1);
    BS{n}.showId(1);
end
for n = 1:numMS
    MS{n}.showLoc(1);
    MS{n}.showId(1);
end
hGrid.showBoundary(1);
%%}