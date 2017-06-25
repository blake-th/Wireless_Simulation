clear;
clc;

import BaseStation;
import MobileStation;
import Cell;
import HexagonGrid;
import RadioPropagation;
import TwoRay;
import Lognormal;
import Shadowing;
import Timer;

import util.*;
ut = util();

DROPOUT_THRESHOLD = 1e-9;
HANDOFF_THRESHOLD = 1e-5;
HANDOFF_TIME = 2;
HANDOFF_WINDOW = 5;
MOBILITY = 25;
SIMULATION_TIME = 100;

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

mu = 0;
sigma = 6;

MS_SPEEDRANGE = [MOBILITY, MOBILITY] / r;
MS_MOVINGTIMERANGE = [1, 6] / r;


rpModel = RadioPropagation(TwoRay(), Lognormal(), Fading());
hGrid = HexagonGrid(2, @Cell);
BS = {};
MS = {};
CELL = values(hGrid.cell);
r = ISD / sqrt(3);

centralBS = [];
for n = 1:numCell
    BS{n} = BaseStation(n, CELL{n}, height_BS, txPow_BS, txGain_BS, rxGain_BS);
    if CELL{n} == hGrid.cell('0,0,0')
        centralBS = BS{n};
    end
end 

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




