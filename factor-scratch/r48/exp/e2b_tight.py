"""
E2b -- THE TIGHT TEST.  Is the 1.06 ratio real, or a within-stratum SIZE artifact?

E2 found NFS a^2-b^3 values are 1.06x more B-smooth than uniform when compared
inside dyadic octaves.  But E2.4 found P(p | a^2-b^3) = 1/p to within 0.2% for
every prime tested.  Those two facts are in TENSION: if the local structure is
exactly uniform, the smoothness should be uniform.

Resolution to test: within an octave, the NFS values may not be spread evenly
over [2^j, 2^{j+1}); smaller values are smoother, so any clustering toward the
BOTTOM of the octave inflates the NFS rate even with perfect local uniformity.

DECISIVE TEST: subdivide each octave into SUB_BANDS.  If the ratio -> 1 as the
band narrows, the deviation is pure size-matching error.  If it stays ~1.06 at
every resolution, it is a genuine smoothness deviation.

The control runs FIRST (E2b.0): an artificial population built to have EXACTLY
1/p divisibility for all p but a NON-UNIFORM size distribution inside the
octave must reproduce the artifact.  If it does, the artifact is explained.

Run: timeout 3000 python3 e2b_tight.py
"""
import numpy as np
from math import log, sqrt
from e2data import lpf_array, nfs_box, AMAX, BMAX, M, NP

FAIL = []
rng = np.random.default_rng(4242)


def hdr(s):
    print("\n" + "=" * 78 + f"\n{s}\n" + "=" * 78)


hdr("E2b  IS THE a^2-b^3 DEVIATION REAL, OR A SIZE-MATCHING ARTIFACT?")

LPF = lpf_array(M)
VM = nfs_box(sign=-1)
av = np.abs(VM)

hdr("E2b.0  WITHIN-OCTAVE SIZE DISTRIBUTION of the NFS values")
print("  If NFS values crowd the bottom of an octave, they are smoother for free.")
for j in (20, 22, 24, 26):
    lo, hi = 1 << j, (1 << (j + 1)) - 1
    sel = av[(av >= lo) & (av < hi + 1)]
    if sel.size < 1000:
        continue
    # position within the octave, 0..1, for NFS  vs  uniform expectation 0.5
    pos = (np.log2(sel.astype(np.float64)) - j)
    print(f"  octave [2^{j},2^{j+1}): n={sel.size:>8}  mean log2 position "
          f"{pos.mean():.4f}  (uniform predicts 0.5000)  "
          f"median {np.median(pos):.4f}  skew {float(((pos-pos.mean())**3).mean()/pos.std()**3):+.3f}")

hdr("E2b.1  THE ARTIFACT CONTROL")
print("  Artificial population: SAME octaves, but values sampled with a size")
print("  distribution SHAPED like the NFS one, then rounded.  If it reproduces")
print("  the ~1.06 ratio, the ratio is explained by size alone.")


def nfs_like_pop(n_per_octave=200_000, octaves=(18, 20, 22, 24, 26), shape=0.0):
    """Draw uniform integers whose within-octave log-position has the NFS skew."""
    out = []
    for j in octaves:
        lo, hi = 1 << j, (1 << (j + 1))
        if hi > M:
            continue
        u = rng.random(n_per_octave)
        if shape:                       # skew toward the bottom of the octave
            u = u ** (1.0 + shape)
        v = (lo * (2.0 ** u)).astype(np.int64)
        out.append(np.clip(v, lo, min(hi - 1, M)))
    return np.concatenate(out)


for shape, label in ((0.0, "UNIFORM within octave (should read 1.00)"),
                     (0.35, "bottom-skewed, mild"),
                     (0.9, "bottom-skewed, strong")):
    pop = nfs_like_pop(shape=shape)
    lv = np.floor(np.log2(pop)).astype(np.int64)
    tot_p = tot_u = tot_n = 0
    for j in (18, 20, 22, 24, 26):
        m = lv == j
        n = int(m.sum())
        if n < 1000:
            continue
        for B in (10_000, 100_000, 1_000_000):
            if B >= (1 << (j + 1)):
                continue
            pu = float((LPF[(1 << j):(1 << (j + 1))] <= B).mean())
            pn = float((LPF[pop[m]] <= B).mean())
            tot_p += pn * n
            tot_u += pu * n
            tot_n += n
    print(f"  {label:38s}: ratio {tot_p/tot_u:.4f}  (n={tot_n/1e6:.2f}e6)")

hdr("E2b.2  THE DECISIVE TEST: ratio vs SUB-BAND width")
V = np.abs(VM)
lv = np.floor(np.log2(V)).astype(np.int64)
print("  ratio = P_NFS(B-smooth) / P_uniform(B-smooth), inside progressively")
print("  narrower multiplicative bands.  Real deviation => flat.  Artifact => ->1.")
for K in (1, 4, 16, 64, 256):
    print(f"\n  --- {K} sub-bands per octave "
          f"(band width factor 2^{1/K} = {2**(1/K):.4f}) ---")
    agg = {}
    for B in (10_000, 100_000, 1_000_000):
        tp = tu = tn = 0.0
        for j in range(17, 27):
            lo_oct = 1 << j
            hi_oct = (1 << (j + 1)) - 1
            if hi_oct > M:
                continue
            for s in range(K):
                t0 = log(lo_oct) + (log(2.0) * s / K)
                t1 = log(lo_oct) + (log(2.0) * (s + 1) / K)
                b0 = int(np.exp(t0))
                b1 = min(int(np.exp(t1)) - 1, M)
                if b1 <= b0:
                    continue
                m = (V >= b0) & (V <= b1)
                n = int(m.sum())
                if n < 5000:
                    continue
                pu = float((LPF[b0:b1 + 1] <= B).mean())
                if pu <= 0:
                    continue
                pn = float((LPF[V[m]] <= B).mean())
                tp += pn * n
                tu += pu * n
                tn += n
        if tn > 0:
            r = tp / tu
            sg = (tp - tu) / np.sqrt(max(tu * (1 - tu / tn), 1e-12))
            print(f"    B={B:>9}  ratio {r:.4f}   n={tn/1e6:>6.2f}e6   "
                  f"diff {r-1:+.4f}")

hdr("E2b.3  LOCAL UNIFORMITY: full v_p distributions")
print("  If v_p matches uniform for all p, smoothness MUST match uniform.")
print(f"  {'p':>5} {'P(v_p=0) NFS':>14} {'P(v_p=0) unif':>14} {'ratio':>8} "
      f"{'P(v_p>=2) NFS':>14} {'P(v_p>=2) unif':>14} {'ratio':>8}")
for p in (2, 3, 5, 7, 11, 13):
    vn = V.copy()
    vp = np.zeros(vn.size, dtype=np.int32)
    tmp = vn.copy()
    for _ in range(8):
        m = (tmp % p == 0)
        if not m.any():
            break
        tmp[m] //= p
        vp += m
    # uniform control: same size range, sampled uniformly
    ctrl = rng.integers(1 << 24, 1 << 27, size=4_000_000)
    vc = np.zeros(ctrl.size, dtype=np.int32)
    tc = ctrl.copy()
    for _ in range(8):
        m = (tc % p == 0)
        if not m.any():
            break
        tc[m] //= p
        vc += m
    n0n, n0u = (vp == 0).mean(), (vc == 0).mean()
    n2n, n2u = (vp >= 2).mean(), (vc >= 2).mean()
    print(f"  {p:>5} {n0n:>14.6f} {n0u:>14.6f} {n0n/n0u:>8.4f} "
          f"{n2n:>14.6f} {n2u:>14.6f} {n2n/n2u:>8.4f}")

hdr("E2b VERDICT")
print("  Read E2b.1 (does a size artifact reproduce it?) and E2b.2 (does the")
print("  ratio survive band refinement?).  Those two together decide H1.")