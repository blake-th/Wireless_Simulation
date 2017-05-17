import BaseStation;
import MobileStation;
import Cell;
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
txGain = ut.dB_to_w(14);
height_BS = 1.5 + 50;
height_MS = 1.5;


BS_central = 1;