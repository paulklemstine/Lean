import random
from random import Random as PyRandom
P_P = 2**256 - 2**32 - 977
FF = GF(P_P)
EE = EllipticCurve(FF, [0, 7])
GG = EE(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
        0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)

BV = 20; SEED = 1150041
w = 2**BV; Mmax = 2048; K = 3072; L = 10240
J = [None] * (Mmax + 1)
cur = EE(0)
for j in range(1, Mmax + 1):
    cur = cur + GG; J[j] = cur
bB = w - 1

def walks(d):
    """return tame jump list, wild jump list, tame scalar list, wild scalar list"""
    rng = PyRandom(int(SEED + 7919 * BV + 31 * int(d)))
    Q = GG * d
    bG = GG * bB
    cur = bG; dist = 0; tj = []; tscal = []
    for _ in range(K):
        xd = int(cur[0]); j = 1 + (xd % Mmax)
        tj.append(int(j)); cur = cur + J[j]; dist += j; tscal.append(int(bB + dist))
    cur = Q; dist = 0; wj = []; wscal = []
    for _ in range(L):
        xd = int(cur[0]); j = 1 + (xd % Mmax)
        wj.append(int(j)); cur = cur + J[j]; dist += j; wscal.append(int(d + dist))
    return tj, wj, tscal, wscal

def pre(lst, base):
    out = []; s = 0
    for v in lst:
        s += v; out.append(base + s)
    return out

print("=== does the real (tame,wild) pair collide?  b=%d, 20 plants ===" % BV)
ok = 0
for t in range(20):
    d = (t * 977) % w
    tj, wj, tscal, wscal = walks(d)
    A = set(tscal); B = set(wscal)
    n = len(A & B)
    # synthetic-wild control with the SAME tame
    srng = random.Random(int(SEED * 7 + t))
    sw = [1 + srng.randrange(Mmax) for _ in range(L)]
    Bs = set(pre(sw, d))
    ns = len(A & Bs)
    if n: ok += 1
    print("  d=%8d g/meanjump=%6.1f   real|A&B|=%4d   synthetic|A&B|=%4d"
          % (d, (bB - d) / 1024.0, n, ns))
print("  real collisions: %d/20" % ok)

print()
print("=== is the wild jump sequence shifted-equal to the tame's? ===")
d = 193513
tj, wj, tscal, wscal = walks(d)
best = 0
for s in range(0, L - K):
    c = sum(1 for i in range(K) if tj[i] == wj[i + s])
    best = max(best, c)
print("  max # of equal tame[i]==wild[i+s] over all shifts s: %d  (of %d)" % (best, K))
print("  (chance level ~ %d)" % int(K * 3072 / float(Mmax)))
