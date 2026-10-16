# Decisive test: are the jump sequences produced by the curve degenerate?
import random
from random import Random as PyRandom

P_P = 2**256 - 2**32 - 977
FF = GF(P_P)
EE = EllipticCurve(FF, [0, 7])
GG = EE(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
        0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)

BV = 20
SEED = 1150041
w = 2**BV
Mmax = 2048
K = 3072
L = 10240
rng = PyRandom(int(SEED + 7919 * BV))
d = rng.randrange(w)
Q = GG * d
bB = w - 1
bG = GG * bB

J = [None] * (Mmax + 1)
cur = EE(0)
for j in range(1, Mmax + 1):
    cur = cur + GG
    J[j] = cur

# ---- tame
cur = bG; dist = 0; tj = []; tscal = []
for _ in range(K):
    xd = int(cur[0]); j = 1 + (xd % Mmax)
    tj.append(j); cur = cur + J[j]; dist += j; tscal.append(bB + dist)
# ---- wild
cur = Q; dist = 0; wj = []; wscal = []
for _ in range(L):
    xd = int(cur[0]); j = 1 + (xd % Mmax)
    wj.append(j); cur = cur + J[j]; dist += j; wscal.append(d + dist)

A = set(tscal); B = set(wscal)
print("plant d=%d  g = b - d = %d  (= %.1f jumps)" % (d, bB - d, (bB - d) / 1024.0))
print("tame jumps : n=%d  mean=%.1f  min=%d max=%d  distinct=%d"
      % (len(tj), float(sum(tj)) / len(tj), min(tj), max(tj), len(set(tj))))
print("wild jumps : n=%d  mean=%.1f  min=%d max=%d  distinct=%d"
      % (len(wj), float(sum(wj)) / len(wj), min(wj), max(wj), len(set(wj))))
print("intersection |A&B| = %d" % len(A & B))

# chi-square-ish: histogram of tame jumps and wild jumps in 256 bins
def hist(js, nb=256):
    h = [0] * nb
    for j in js:
        h[(j - 1) * nb // Mmax] += 1
    return h
ht = hist(tj); hw = hist(wj)
print("tame jump hist (256 bins): min %d max %d mean %.1f"
      % (min(ht), max(ht), float(sum(ht)) / len(ht)))
print("wild jump hist (256 bins): min %d max %d mean %.1f"
      % (min(hw), max(hw), float(sum(hw)) / len(hw)))

# ---- CONTROL 1: replace the WILD jump sequence with i.i.d. uniform draws,
#      keep the tame's actual recorded jumps.  Does the intersection appear?
srng = PyRandom(int(SEED + 991))
hits = 0; tot = 0
for t in range(200):
    sw = []
    p = 0
    for _ in range(L):
        v = 1 + srng.randrange(Mmax)
        sw.append(v); p += v
    Bs = set(d + sum(sw[:i + 1]) for i in range(L))
    inter = A & Bs
    hits += (1 if inter else 0); tot += len(inter)
print("CONTROL tame-actual + wild-synthetic : P(hit)=%.3f mean|A&B|=%.2f"
      % (hits / 200.0, tot / 200.0))

# ---- CONTROL 2: replace the TAME jump sequence with i.i.d. uniform draws,
#      keep the wild's actual recorded jumps.
hits = 0; tot = 0
for t in range(200):
    st = []
    p = 0
    for _ in range(K):
        v = 1 + srng.randrange(Mmax)
        st.append(v); p += v
    As = set(bB + sum(st[:i + 1]) for i in range(K))
    inter = As & B
    hits += (1 if inter else 0); tot += len(inter)
print("CONTROL tame-synthetic + wild-actual : P(hit)=%.3f mean|A&B|=%.2f"
      % (hits / 200.0, tot / 200.0))

# ---- CONTROL 3: both synthetic
hits = 0; tot = 0
for t in range(200):
    st = []; p = 0
    for _ in range(K):
        v = 1 + srng.randrange(Mmax); st.append(v); p += v
    sw = []; p = 0
    for _ in range(L):
        v = 1 + srng.randrange(Mmax); sw.append(v); p += v
    As = set(bB + sum(st[:i + 1]) for i in range(K))
    Bs = set(d + sum(sw[:i + 1]) for i in range(L))
    inter = As & Bs
    hits += (1 if inter else 0); tot += len(inter)
print("CONTROL both-synthetic              : P(hit)=%.3f mean|A&B|=%.2f"
      % (hits / 200.0, tot / 200.0))
