import time
from math import log as pylog
P_P = 2**256 - 2**32 - 977
FF = GF(P_P)
EE = EllipticCurve(FF, [0, 7])
GG = EE(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
        0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)

M64 = 0xFFFFFFFFFFFFFFFF

def jmix(pt):
    """well-mixed 64-bit value from the affine x-coordinate"""
    x = int(pt[0])
    h = (x ^ (x >> 127)) & M64
    h = (h * 0x9E3779B97F4A7C15) & M64
    h = (h ^ (h >> 29)) & M64
    return h

def jmix_simple(pt):
    x = int(pt[0])
    return ((x ^ (x >> 127)) * 0x9E3779B97F4A7C15) & M64

def trial(bv, phi, nseed=12, kfac=3.0):
    from math import sqrt as sq
    w = 2 ** int(bv)
    bB = w - 1
    Mmax = max(4, int(round(2.0 * sq(w))))
    meanjump = (Mmax + 1) // 2
    K = max(2, int(round(kfac * meanjump)))
    cap = int(ceil(w / meanjump)) + K + int(6 * meanjump)
    J = [None] * (Mmax + 1)
    cur = EE(0)
    for j in range(1, Mmax + 1):
        cur = cur + GG; J[j] = cur
    ok = 0; steps = []; ops = []
    for t in range(nseed):
        d = int((t * 86753 + 11) % w)
        Q = GG * d
        cur = GG * bB; dist = 0; traps = {}
        for _ in range(K):
            j = 1 + (phi(cur) % Mmax); cur = cur + J[j]; dist += j
            traps[int(cur[0])] = dist
        cur = Q; dist = 0; hit = None; ns = 0
        while ns < cap:
            j = 1 + (phi(cur) % Mmax); cur = cur + J[j]; dist += j; ns += 1
            dt = traps.get(int(cur[0]))
            if dt is not None:
                cand = bB + dt - dist
                if 0 <= cand <= bB:
                    hit = cand
                break
        steps.append(ns); ops.append(K + ns)
        if hit is not None and GG * hit == Q:
            ok += 1
    return ok, nseed, sum(steps) / float(nseed), sum(ops) / float(nseed), Mmax, K, cap

print("jump function: full 64-bit mix (xor-fold, golden multiply, xor-shift)")
for bv in (8, 12, 16, 20, 24, 28, 32):
    ok, n, ms, mo, MM, K, cap = trial(bv, jmix)
    print("  b=%2d  Mmax=%6d K=%7d  recovery %2d/%d  mean wild steps %8.0f  mean ops %9.0f  2^%.2f"
          % (bv, MM, K, ok, n, ms, mo, pylog(mo, 2.0) if mo > 0 else 0), flush=True)
