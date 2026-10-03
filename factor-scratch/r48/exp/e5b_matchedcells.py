"""
E5b -- SCALE INVARIANCE with IDENTICAL CELLS (the confound removed).

E5 found delta DECREASING with N (e.g. u=3.2: 1.632 / 1.478 / 1.413).  Before
reading that as "the bias dies at scale", the obvious artifact must be ruled
out:

  CONFOUND: the small box has only 6.3e4 pairs, so requiring >=2000 samples per
  cell populates few cells and skews toward the LOWEST octaves, while the big
  box (6.4e6 pairs) populates all octaves.  The two columns then aggregate
  DIFFERENT size ranges, and delta is u-dependent, so the comparison is
  meaningless.

  FIX: run the comparison on ONE fixed, explicitly enumerated cell set -- the
  same (octave, sub-band) pairs, with the same B, at every scale.  Drop any
  cell that is unpopulated at ANY scale, so all three columns aggregate
  literally the same relative size range with the same weights.

If delta still falls with N on identical cells, the fall is real.

Run: timeout 3000 python3 e5b_matchedcells.py
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


BOXES = [(700, 90), (3200, 220), (12000, 530)]
NLAB = [4.9e5, 1.0e7, 1.44e8]

hdr("E5b  SCALE INVARIANCE on IDENTICAL size cells")
NSUB = 8
# fixed relative size window: octaves 10..20, 8 sub-bands each, expressed as
# ratios to the box max so every scale sees the SAME relative range.
OCT_LO, OCT_HI = 10, 20
print(f"  cells: octaves {OCT_LO}..{OCT_HI-1} x {NSUB} sub-bands "
      f"(relative window [2^{{-10}},2^0] of each box's max value)")
print("  a cell is used only if populated at EVERY scale\n")

data = {}
for (Am, Bm), Nlab in zip(BOXES, NLAB):
    V = build_box(Am, Bm)
    Vmax = int(V.max())
    L = lpf_array(Vmax + 10)
    cells = []
    for j in range(OCT_LO, OCT_HI):
        for s in range(NSUB):
            t0 = log(Vmax) - log(2.0) * (OCT_HI - j) + log(2.0) * s / NSUB
            t1 = log(Vmax) - log(2.0) * (OCT_HI - j) + log(2.0) * (s + 1) / NSUB
            cells.append((int(np.exp(t0)), min(int(np.exp(t1)) - 1, L.size - 1)))
    data[Nlab] = (V, L, cells, Vmax)
    print(f"  N~{Nlab:.1e}: Vmax={Vmax:.3e}, pairs={V.size:.3e}, cells={len(cells)}")

hdr("E5b.1  delta at MATCHED u, identical cells, min 200 samples/cell everywhere")
for u in (1.6, 2.0, 2.4, 2.8, 3.2):
    per = {}
    for Nlab in NLAB:
        V, L, cells, Vmax = data[Nlab]
        B = int(np.exp(log(Vmax) / u))
        if B >= L.size:
            per[Nlab] = np.nan
            continue
        tp = tn = 0.0
        for (b0, b1) in cells:
            if b1 <= b0:
                continue
            m = (V >= b0) & (V <= b1)
            n = int(m.sum())
            if n < 200:
                continue
            pu = float((L[b0:b1 + 1] <= B).mean())
            if pu <= 0:
                continue
            tp += float((L[V[m]] <= B).mean()) * n
            tn += pu * n
        per[Nlab] = tp / tn if tn else np.nan
    d = [per[N] for N in NLAB]
    trend = "FALLING (N-dependent)" if (d[0] - d[-1]) / d[0] > 0.02 else "flat (u-only)"
    print(f"  u={u:>4.1f}  B@1.4e8={int(np.exp(log(1.44e8)/u)):>9}  " +
          "".join(f"{x:>11.4f}" for x in d) + f"   {trend}")

hdr("E5b.2  EXTRAPOLATION to 1024-bit N (a MODEL, not a measurement)")
print("  Fitting delta(N) = delta_inf + c/N^gamma on the log-log trend at fixed u.")
for u in (1.6, 2.0, 2.4, 2.8, 3.2):
    per = []
    for Nlab in NLAB:
        V, L, cells, Vmax = data[Nlab]
        B = int(np.exp(log(Vmax) / u))
        tp = tn = 0.0
        for (b0, b1) in cells:
            if b1 <= b0:
                continue
            m = (V >= b0) & (V <= b1)
            n = int(m.sum())
            if n < 200:
                continue
            pu = float((L[b0:b1 + 1] <= B).mean())
            if pu <= 0:
                continue
            tp += float((L[V[m]] <= B).mean()) * n
            tn += pu * n
        per.append(tp / tn if tn else np.nan)
    Ns = np.array(NLAB)
    ds = np.array(per)
    ok = ~np.isnan(ds)
    if ok.sum() < 3:
        continue
    # log-log linear fit of (delta - 1) vs N  -> if slope is negative, bias decays
    x = np.log(Ns[ok])
    y = np.log(ds[ok] - 1)
    slope, icept = np.polyfit(x, y, 1)
    N1024 = 2.0 ** 1024
    pred = 1.0 + np.exp(icept + slope * np.log(N1024))
    print(f"  u={u:>4.1f}: delta at N=2^1024 predicted {pred:.6f} "
          f"(log-log slope {slope:+.3f}, i.e. bias {'DECAYS' if slope<0 else 'grows'} with N)")

hdr("E5b VERDICT")
print("  Compare E5b.1 to E5.  If the columns now AGREE, the E5 fall was a")
print("  cell-population artifact.  If they still fall, the bias is N-dependent")
print("  and does NOT extrapolate to 1024-bit N.")