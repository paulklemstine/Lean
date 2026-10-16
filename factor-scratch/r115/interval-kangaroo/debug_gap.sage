import bisect
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

def run(d):
    Q = GG * d
    cur = GG * bB; dist = 0; tscal = []
    for _ in range(K):
        xd = int(cur[0]); j = 1 + (xd % Mmax)
        cur = cur + J[j]; dist += j; tscal.append(int(bB + dist))
    cur = Q; dist = 0; wscal = []
    for _ in range(L):
        xd = int(cur[0]); j = 1 + (xd % Mmax)
        cur = cur + J[j]; dist += j; wscal.append(int(d + dist))
    return tscal, wscal

# verify the scalar bookkeeping directly against the group
tscal, wscal = run(193513)
ts = sorted(tscal)
# recompute the tame's actual points and confirm the scalars
cur = GG * bB; dist = 0; chk = []
for _ in range(50):
    xd = int(cur[0]); j = 1 + (xd % Mmax)
    cur = cur + J[j]; dist += j
    chk.append(bool(GG * int(bB + dist) == cur))
print("scalar bookkeeping check (GG*(bB+dist) == tame position): %s"
      % (all(chk), ))
print("last 5 of 50 checks:", chk[-5:])
print()
print("gap structure: for the wild's steps inside the tame's region,")
print("gap_j = wscal[j] - (largest tame scalar <= wscal[j])")
inside = [j for j in range(L) if ts[0] <= wscal[j] <= ts[-1]]
gaps = []
for j in inside:
    p = bisect.bisect_right(ts, wscal[j]) - 1
    gaps.append(wscal[j] - ts[p])
print("n inside = %d" % len(inside))
print("first 40 gaps: %s" % gaps[:40])
print("gap histogram in 16 bins of width 128: %s"
      % ([sum(1 for g in gaps if 128 * k <= g < 128 * (k + 1)) for k in range(16)],))
print("gap 0 (exact collision): %d of %d" % (sum(1 for g in gaps if g == 0), len(gaps)))
print("mean gap %.1f  min %d max %d" % (float(sum(gaps)) / len(gaps), min(gaps), max(gaps)))
print()
# how many tame scalars are BELOW the wild's entry point?
entry = [j for j in range(L) if wscal[j] >= ts[0]][0]
print("wild first enters the trap region at step %d, scalar %d (tame first trap %d)"
      % (entry, wscal[entry], ts[0]))
print("wild is %d past the tame's first trap" % (wscal[entry] - ts[0]))
# matched-index offset once inside
print()
print("matched-index offsets (wild_in[k] - tame[k]) for k=0..30:")
wsc_in = [wscal[j] for j in inside]
print("  %s" % [wsc_in[k] - tscal[k] for k in range(31)])
