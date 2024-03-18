function [R, Dist] = isPointOnLine(P1, P2, Q)
% Is point Q=[x3,y3] on line through P1=[x1,y1] and P2=[x2,y2]
% Normal along the line:
P12 = P2 - P1;
L12 = sqrt(P12 * P12');
N   = P12 / L12;
% Line from P1 to Q:
PQ = Q - P1;
% Norm of distance vector: LPQ = N x PQ
Dist = abs(N(1) * PQ(2) - N(2) * PQ(1));
% Find within search distance
Limit = 0.025; %2.5cm either side
R     = (Dist < Limit);