"""
E5 -- SCALE INVARIANCE, done right.

E4.2 returned nan for the two smaller boxes (too few samples per 1/32-octave
sub-band).  This is THE decisive test for extrapolation: if the smoothness bias
depends only on u = ln N / ln B, then it is a permanent algebraic feature and
survives to 1024 bits.  If it depends on N, it is a small-scale artifact and
the whole H1 result is local noise.

Method: hold u FIXED, vary N over ~3 orders of magnitude, size-match, compare.
Sample-size control: choose the sub-band count per octave so every cell keeps
>= 2000 samples -- more sub-bands at small N is meaningless if cells are empty.

The tightest case is the one where the boxes are smallest, so the u grid is
run where it is measurable at EVERY scale, and the agreement is checked on the
overlap only.

Run: timeout 3000 python3 e5_scaleinv.py
"""
import numpy as np
from math import log
from e2data import lpf_array

rng = np.random.default_rng(9001)


def hdr(s):
    print("\n" + "=" * 78 + f"\n{s}\n" + "=" * 78)


def build_box(Amax, Bmax):
    a = np.arange(1, Amax + 1, dtype=np.int64)
    b = np.arange(1, Bmax + 1, dtype=np.int64)
    return np.abs((a[:, None] ** 2 - b[None, :] ** 3).reshape(-1))


def matched(L, V, B, nsub, minn=2000):
    V = V[V > 0]
    if V.size == 0 or B >= L.size:
        return np.nan, 0
    lg = np.floor(np.log2(V)).astype(np.int64)
    tp = tn = 0.0
    for j in np.unique(lg):
        if (1 << (int(j) + 1)) > L.size:
            continue
        for s in range(nsub):
            t0 = log(1 << int(j)) + log(2.0) * s / nsub
            t1 = log(1 << int(j)) + log(2.0) * (s + 1) / nsub
            b0, b1 = int(np.exp(t0)), min(int(np.exp(t1)) - 1, L.size - 1)
            if b1 <= b0:
                continue
            m = (lg == j) & (V >= b0) & (V <= b1)
            n = int(m.sum())
            if n < minn:
                continue
            pu = float((L[b0:b1 + 1] <= B).mean())
            if pu <= 0:
                continue
            tp += float((L[V[m]] <= B).mean()) * n
            tn += pu * n
    return (tp / tn if tn else np.nan), int(tn)


hdr("E5  SCALE INVARIANCE: hold u fixed, vary N over 3 orders of magnitude")
BOXES = [(700, 90), (3200, 220), (12000, 530)]      # N_eff ~ 4.9e5, 1.0e7, 1.4e8
UGRID = [1.6, 2.0, 2.4, 2.8, 3.2]

# choose sub-band count so cells stay populated at the smallest scale
NSUB = {4.9e5: 4, 1.0e7: 8, 1.44e8: 32}

res = {}
print(f"  {'u':>5} " + "".join(f"{'N~%.1e' % N:>13}" for N, _ in
                                zip([4.9e5, 1.0e7, 1.44e8], BOXES)))
for (Am, Bm), Nlab in zip(BOXES, [4.9e5, 1.0e7, 1.44e8]):
    V = build_box(Am, Bm)
    L = lpf_array(int(V.max()) + 10)
    for u in UGRID:
        B = int(np.exp(log(int(V.max())) / u))
        r, n = matched(L, V, B, NSUB[Nlab])
        res[(u, Nlab)] = r
    del L
for u in UGRID:
    print(f"  {u:>5.1f} " + "".join(f"{res[(u,N)]:>13.4f}" for N in (4.9e5, 1.0e7, 1.44e8)))

print("\n  Agreement down each column => delta is a function of u ALONE.")
print("  Disagreement down a column => delta depends on N and does NOT")
print("  extrapolate; the 1024-bit claim would be unfounded.")

hdr("E5.2  MEASURED VALUES vs the E1 Dickman floor")
print("  For honesty: the Dickman floor from E1/A3 is rel gap up to 0.324 at")
print("  these scales, so a delta of 0.03-0.06 IS resolvable, but only because")
print("  we compare against the EXACT matched rate, not against rho.")
print(f"\n  {'u':>5} {'delta (matched)':>16} {'E1 Dickman floor':>18}")
for u in UGRID:
    vals = [res[(u, N)] for N in (4.9e5, 1.0e7, 1.44e8) if not np.isnan(res[(u, N)])]
    if not vals:
        continue
    d = float(np.mean(vals))
    B = int(np.exp(log(1.44e8) / u))
    floor = 0.324 if B <= 300 else (0.111 if B <= 3000 else 0.046)
    print(f"  {u:>5.1f} {d:>16.4f} {floor:>18.3f}")

hdr("E5 VERDICT")