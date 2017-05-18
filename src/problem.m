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

%% init
hGrid = HexagonGrid(2, @Cell);
BS = {};
MS = {};
CELL = values(hGrid.cell);
r = ISD / sqrt(3);

for n = 1:numel(CELL)
    BS{n} = BaseStation(CELL{n}, height_BS, txPow_BS, xGain, xGain);
    BS{n}.showLoc(r);
    CELL{n}.showBoundary(r);
    CELL{n}.showId(n, r);
end


