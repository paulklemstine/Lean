import random
from random import Random as PyRandom
P_P = 2**256 - 2**32 - 977
FF = GF(P_P)
EE = EllipticCurve(FF, [0, 7])
GG = EE(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
        0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)

BV = 20; SEED = 1150041
w = 2**BV; Mmax = 2048; K = 3072; L = 10240
rng = PyRandom(int(SEED + 7919 * BV))
d = rng.randrange(w)
Q = GG * d; bB = w - 1; bG = GG * bB
J = [None] * (Mmax + 1)
cur = EE(0)
for j in range(1, Mmax + 1):
    cur = cur + GG; J[j] = cur
cur = bG; dist = 0; tj = []; tscal = []
for _ in range(K):
    xd = int(cur[0]); j = 1 + (xd % Mmax)
    tj.append(j); cur = cur + J[j]; dist += j; tscal.append(bB + dist)
cur = Q; dist = 0; wj = []; wscal = []
for _ in range(L):
    xd = int(cur[0]); j = 1 + (xd % Mmax)
    wj.append(j); cur = cur + J[j]; dist += j; wscal.append(d + dist)

print("first 8 tame jumps %s  first 8 tame scalars %s" % (tj[:8], tscal[:8]))
print("first 8 wild jumps %s  first 8 wild scalars %s" % (wj[:8], wscal[:8]))
D = [tscal[i] - wscal[i] for i in range(K)]
print("D[i] = tame_scal[i] - wild_scal[i]  (i=0..%d)" % (K - 1))
print("  D[0..12] = %s" % D[:13])
print("  min %d  max %d  mean %.1f" % (min(D), max(D), float(sum(D)) / len(D)))
print("  D mod 2048 distinct values: %s" % sorted(set(x % 2048 for x in D))[:20])
print("  D mod 2048 count distinct: %d" % len(set(x % 2048 for x in D)))
print("  |D| < 2048 count: %d" % sum(1 for x in D if abs(x) < 2048))
# where does the wild cross the tame's range?
lo, hi = min(tscal), max(tscal)
inside = [i for i in range(L) if lo <= wscal[i] <= hi]
print("wild steps inside tame's scalar range [%d,%d]: %d of %d" % (lo, hi, len(inside), L))
if inside:
    print("   those wild scalars: %s ... %s" % (wscal[inside[0]], wscal[inside[-1]]))
    print("   tame scalars sorted[:8] %s" % sorted(tscal)[:8])
    # nearest tame to each inside wild scalar
    ts = sorted(tscal)
    import bisect
    best = 10**18
    for i in inside:
        p = bisect.bisect_left(ts, wscal[i])
        for q in (p - 1, p):
            if 0 <= q < len(ts):
                best = min(best, abs(ts[q] - wscal[i]))
    print("   min |wild scalar - tame scalar| over all pairs = %d" % best)
