# debug: at b=20, do the tame and wild walks actually intersect?
import time, os
from random import Random as PyRandom

P_P = 2**256 - 2**32 - 977
FF = GF(P_P)
EE = EllipticCurve(FF, [0, 7])
GG = EE(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
        0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)

def debug(bv, seedidx, SEED=1150041, MU_RATIO=1.0, KFAC=3.0, cap=None):
    w = 2**int(bv)
    Mmax = max(4, int(round(2.0 * MU_RATIO * (float(w) ** 0.5))))
    meanjump = (Mmax + 1) // 2
    K = max(2, int(round(KFAC * meanjump)))
    if cap is None:
        cap = int(ceil(w / meanjump)) + K + 6 * meanjump
    rng = PyRandom(int(SEED + 7919 * int(bv) + 104729 * int(seedidx)))
    d = rng.randrange(w)
    Q = GG * d
    bB = w - 1
    bG = GG * bB
    # jump table
    J = [None] * (Mmax + 1)
    cur = EE(0)
    for j in range(1, Mmax + 1):
        cur = cur + GG
        J[j] = cur
    # tame
    cur = bG; dist = 0
    tame_scal = []
    js_hist = []
    for _ in range(K):
        xd = int(cur[0]); j = 1 + (xd % Mmax)
        js_hist.append(j)
        cur = cur + J[j]; dist += j
        tame_scal.append(bB + dist)
    # wild
    cur = Q; dist = 0
    wild_scal = []
    hit = None
    for step in range(int(cap)):
        xd = int(cur[0]); j = 1 + (xd % Mmax)
        js_hist.append(j)
        cur = cur + J[j]; dist += j
        wild_scal.append(d + dist)
    ts = set(tame_scal); ws = set(wild_scal)
    inter = ts & ws
    # distribution of jumps actually used
    from collections import Counter
    c = Counter(js_hist)
    print("b=%d seed=%d  w=%d Mmax=%d meanjump=%d K=%d cap=%d plant d=%d"
          % (bv, seedidx, w, Mmax, meanjump, K, cap, d))
    print("   tame scalars in [%d, %d]  n=%d" % (min(tame_scal), max(tame_scal), len(ts)))
    print("   wild scalars in [%d, %d]  n=%d" % (min(wild_scal), max(wild_scal), len(ws)))
    print("   INTERSECTION SIZE = %d" % len(inter))
    print("   sorted(inter)[:5] = %s" % sorted(inter)[:5])
    # gaps in tame walk
    gaps = [tame_scal[i+1]-tame_scal[i] for i in range(len(tame_scal)-1)]
    print("   tame gap: min %d max %d mean %.1f" % (min(gaps), max(gaps), float(sum(gaps))/len(gaps)))
    wgaps = [wild_scal[i+1]-wild_scal[i] for i in range(len(wild_scal)-1)]
    print("   wild gap: min %d max %d mean %.1f" % (min(wgaps), max(wgaps), float(sum(wgaps))/len(wgaps)))
    # how many distinct jump values used, and their distribution
    print("   distinct jump values used: %d of %d" % (len(c), Mmax))
    top = sorted(c.items(), key=lambda kv: -kv[1])[:10]
    print("   most common jumps: %s" % top)
    print("   least common jumps: %s" % sorted(c.items(), key=lambda kv: kv[1])[:10])
    # x mod Mmax uniformity over the walk
    print("")

debug(20, 0)
debug(20, 1)
debug(20, 2)
debug(20, 3)
