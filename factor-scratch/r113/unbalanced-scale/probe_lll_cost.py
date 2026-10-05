#!/usr/bin/env python3
"""CALIBRATION ONLY -- measure LLL wall-clock vs (n_bits, dim).
Not a result. Decides the affordable experiment grid."""
import time, random, sys
from fpylll import IntegerMatrix, LLL, BKZ

def probe(nbits, dim, seed=0):
    rnd = random.Random(seed)
    t0 = time.time()
    B = IntegerMatrix(dim, dim)
    for i in range(dim):
        for j in range(dim):
            B[i, j] = rnd.getrandbits(nbits)
    t1 = time.time()
    LLL.reduction(B, delta=0.99)
    t2 = time.time()
    return t1-t0, t2-t1

for nbits in (128, 256, 512, 1024):
    for dim in (20, 30, 40, 52):
        build, red = probe(nbits, dim)
        print("nbits=%4d dim=%3d  build=%.2fs  LLL=%.2fs" % (nbits, dim, build, red), flush=True)
        if red > 120:
            print("   ^ too slow, stopping this nbits row", flush=True)
            break
