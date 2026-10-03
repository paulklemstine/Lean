"""
E6 -- DECISIVE: nested boxes, IDENTICAL absolute value window, IDENTICAL B.

E5b found delta falling with N at fixed u (u=3.2: 1.516 / 1.453 / 1.407), and
that survived making the relative size cells identical.  Before believing it,
the last confound: the cells were placed RELATIVE to each box's own max value,
so the three columns still aggregated different ABSOLUTE size ranges, and B was
tied to the box max.

DECISIVE DESIGN.  Use NESTED boxes -- the (a,b) ranges are nested, so the big
box CONTAINS the small box -- and restrict every box to the SAME absolute value
window and the SAME B.  Then the value distribution, the value scale and the
factor-base bound are all identical across boxes; the ONLY thing that differs
is how much of the surrounding (a,b) rectangle generated them.

If delta is identical across boxes  => delta is a LOCAL function of (value, B)
                                   => the E5b fall was an artifact.
If delta still falls             => delta genuinely depends on the box size,
                                   i.e. on how many (a,b) pairs produce values
                                   of that size, and does NOT extrapolate.

We then separately map delta vs u at FIXED B, to see whether delta is a
function of u alone (extrapolates) or of B/box (does not).

Run: timeout 3000 python3 e6_nested.py
"""
import numpy as np
from math import log
from e2data import lpf_array

rng = np.random.default_rng(4711)


def hdr(s):
    print("\n" + "=" * 78 + f"\n{s}\n" + "=" * 78)


def build_box(Amax, Bmax):
    a = np.arange(1, Amax + 1, dtype=np.int64)
    b = np.arange(1, Bmax + 1, dtype=np.int64)
    return np.abs((a[:, None] ** 2 - b[None, :] ** 3).reshape(-1))


# nested: a <= 700,b <= 90 is contained in a <= 3200,b <= 220 etc.
BOXES = [(700, 90), (3200, 220), (12000, 530)]
NLAB = [4.9e5, 1.0e7, 1.44e8]

VMAX = int(build_box(12000, 530).max())
L = lpf_array(VMAX + 10)
print(f"oracle to {VMAX:.3e}")

hdr("E6.1  IDENTICAL absolute value window and B across nested boxes")
WINDOWS = [(1 << 10, 1 << 20), (1 << 12, 1 << 22), (1 << 14, 1 << 24),
           (1 << 16, 1 << 25)]
BS = [1_000, 10_000, 100_000]

print(f"\n  {'window':>20} {'B':>9} " +
      "".join(f"{'box N~%.0e' % N:>15}" for N in NLAB) + "   verdict")
for (w0, w1) in WINDOWS:
    if w1 > VMAX:
        continue
    for B in BS:
        if B >= w1:
            continue
        pu = float((L[w0:w1 + 1] <= B).mean())
        per = []
        for (Am, Bm) in BOXES:
            V = build_box(Am, Bm)
            m = (V >= w0) & (V <= w1)
            n = int(m.sum())
            if n < 1000:
                per.append(np.nan)
                continue
            per.append(float((L[V[m]] <= B).mean()) / pu)
        d = [x for x in per if not np.isnan(x)]
        if len(d) < 3:
            continue
        spread = (max(d) - min(d)) / np.mean(d)
        verdict = ("SAME (delta is local in (value,B))" if spread < 0.03
                   else f"DIFFERS by {spread*100:.1f}% (box-size dependent)")
        print(f"  [2^{w0.bit_length()-1},2^{w1.bit_length()-1})".rjust(20) +
              f" {B:>9} " + "".join(f"{x:>15.4f}" for x in per) + f"   {verdict}")

hdr("E6.2  delta vs u at FIXED B (does delta depend on u ALONE?)")
print("  For each B, sweep the value window; u = ln X / ln B changes with X.")
print("  If the curves for different B collapse onto one delta(u), delta is")
print("  u-only and EXTRAPOLATES to 1024 bits.")
print(f"\n  {'u':>6} " + "".join(f"{'B=%d' % B:>12}" for B in BS))
for k in range(1, 26):
    X = 1 << k
    u = log(X) / log(300_000)
    row = []
    for B in BS:
        if B >= X:
            row.append(np.nan)
            continue
        w0, w1 = X // 8, X
        if w1 > VMAX:
            row.append(np.nan)
            continue
        V = build_box(12000, 530)
        m = (V >= w0) & (V <= w1)
        n = int(m.sum())
        if n < 1000:
            row.append(np.nan)
            continue
        pu = float((L[w0:w1 + 1] <= B).mean())
        if pu <= 0:
            row.append(np.nan)
            continue
        row.append(float((L[V[m]] <= B).mean()) / pu)
    if any(np.isnan(x) for x in row):
        continue
    print(f"  {u:>6.2f} " + "".join(f"{x:>12.4f}" for x in row))

hdr("E6.3  THE MECHANISM CHECK: is the fall explained by v_p>=2 thinning out?")
print("  P(p|a^2-b^3) = 1/p EXACTLY at every scale (E3.1, scale-free).")
print("  If the first-order structure is scale-free and the bias nevertheless")
print("  falls with N, then the bias is NOT a local property of the value but")
print("  an interaction with how many candidate pairs share that value.")
Vbig = build_box(12000, 530)
Vsmall = build_box(700, 90)
for (w0, w1) in [(1 << 12, 1 << 22), (1 << 14, 1 << 24)]:
    if w1 > VMAX:
        continue
    B = 10_000
    pu = float((L[w0:w1 + 1] <= B).mean())
    print(f"\n  window [2^{w0.bit_length()-1},2^{w1.bit_length()-1}), B={B}, "
          f"uniform rate {pu:.5f}")
    for (Am, Bm), Nlab in zip(BOXES, NLAB):
        V = build_box(Am, Bm)
        m = (V >= w0) & (V <= w1)
        n = int(m.sum())
        if n < 1000:
            continue
        vals = V[m]
        # mean number of distinct prime factors of the SMALL primes <= B
        def mean_v2(p):
            t = vals.copy()
            c = 0
            for _ in range(6):
                mm = (t % p == 0)
                if not mm.any():
                    break
                t[mm] //= p
                c += mm
            return c.mean()
        print(f"    box N~{Nlab:.0e}: n={n:>8}  mean v_2={mean_v2(2):.4f} "
              f"(uniform {1.0:.4f})  mean v_3={mean_v2(3):.4f} "
              f"(uniform {0.5:.4f})  rate ratio "
              f"{float((L[vals] <= B).mean())/pu:.4f}")

hdr("E6 VERDICT")
print("  E6.1 answers whether delta is local in (value, B) or box-size")
print("  dependent.  E6.2 answers whether it is a function of u alone, which")
print("  is the question that decides whether ANY of this reaches 1024 bits.")