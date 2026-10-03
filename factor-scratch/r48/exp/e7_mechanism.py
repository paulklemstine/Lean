"""
E7 -- MECHANISM OF THE SCALE DEPENDENCE (the truncation confound removed).

E6 produced a contradiction: mean v_2 was IDENTICAL across box sizes
(1.2498 / 1.2436 / 1.2429) while the smoothness ratio swung 1.417 -> 1.136.
If the local prime structure is the same, the smoothness cannot differ.  So
either the local structure is not the mechanism, or the boxes are not
comparable.

They are NOT comparable.  TRUNCATION: the smallest box (a<=700) has max value
7.29e5, so for a window [2^12, 2^22) it can only populate [2^12, 7.29e5] --
the SMOOTHER, LOWER part of the window.  It therefore looks artificially
smoother.  E6.1's "box-size dependent" verdict is an artifact.

TWO questions, now cleanly separated:
  7.1  Using ONLY windows every box can fully populate, is delta independent
       of box size?  (=> the bias is local in the value)
  7.2  If 7.1 says yes, then the E5/E5b/E6 "fall with N" was ENTIRELY
       truncation, and delta is a function of u alone -> it extrapolates.
       If 7.1 says no, find what else differs.

CANDIDATE MECHANISM for a genuine N-dependence (tested in 7.3): the pile-up of
values near a^2 = b^3.  For a box with max b = Bmax, there are O(T^{1/2})
pairs with |a^2-b^3| <= T; relative to the O(Bmax * Amax) population these
near-degenerate values are a LARGE fraction in a small box and a negligible
one in a large box.  Near-degenerate values are exactly the ones with the
inflated v_p.  This gives a clean, testable, N-dependent prediction.

Run: timeout 3000 python3 e7_mechanism.py
"""
import numpy as np
from math import log
from e2data import lpf_array

rng = np.random.default_rng(1122)


def hdr(s):
    print("\n" + "=" * 78 + f"\n{s}\n" + "=" * 78)


def build(Amax, Bmax):
    a = np.arange(1, Amax + 1, dtype=np.int64)
    b = np.arange(1, Bmax + 1, dtype=np.int64)
    return (a[:, None] ** 2 - b[None, :] ** 3).astype(np.int64)


BOXES = [(700, 90), (3200, 220), (12000, 530)]
NLAB = [4.9e5, 1.0e7, 1.44e8]
MAXVAL = 729_000          # max value of the SMALLEST box; windows must fit

hdr("E7.1  windows every box can FULLY populate (all below 7.29e5)")
L = lpf_array(MAXVAL + 10)
WINDOWS = [(1 << 12, 1 << 15), (1 << 14, 1 << 17), (1 << 16, 1 << 19)]
BS = [100, 1_000, 10_000, 100_000]
print(f"  {'window':>18} {'B':>8} " +
      "".join(f"{'N~%.0e' % N:>13}" for N in NLAB) + "   verdict")
for (w0, w1) in WINDOWS:
    for B in BS:
        if B >= w1:
            continue
        pu = float((L[w0:w1 + 1] <= B).mean())
        if pu <= 0:
            continue
        per = []
        for (Am, Bm) in BOXES:
            V = np.abs(build(Am, Bm).reshape(-1))
            m = (V >= w0) & (V <= w1)
            n = int(m.sum())
            per.append(float((L[V[m]] <= B).mean()) / pu if n >= 500 else np.nan)
        d = [x for x in per if not np.isnan(x)]
        if len(d) < 3:
            continue
        spread = (max(d) - min(d)) / np.mean(d)
        v = ("SAME -> bias is LOCAL in the value" if spread < 0.04
             else f"DIFFERS {spread*100:.1f}%")
        print(f"  [2^{w0.bit_length()-1},2^{w1.bit_length()-1})".rjust(18) +
              f" {B:>8} " + "".join(f"{x:>13.4f}" for x in per) + f"   {v}")

hdr("E7.2  TRUNCATION CHECK: where does each box's mass actually sit?")
print("  If the small box truncates, its mass piles at the top of what it")
print("  can reach, and its effective u is LOWER than the window's nominal u.")
for (Am, Bm), Nlab in zip(BOXES, NLAB):
    V = np.abs(build(Am, Bm).reshape(-1))
    V = V[V > 0]
    print(f"\n  box N~{Nlab:.0e}: max value {V.max():.3e}, pairs {V.size}")
    for (w0, w1) in [(1 << 12, 1 << 15), (1 << 16, 1 << 19), (1 << 20, 1 << 24)]:
        m = (V >= w0) & (V < w1)
        n = int(m.sum())
        if n == 0:
            print(f"    window [2^{w0.bit_length()-1},2^{w1.bit_length()-1}): "
                  f"EMPTY  <-- TRUNCATED")
            continue
        med = float(np.median(np.log2(V[m])))
        print(f"    window [2^{w0.bit_length()-1},2^{w1.bit_length()-1}): "
              f"n={n:>8} ({100*n/V.size:>5.2f}% of box)  median log2 = {med:>6.2f}"
              f"  (nominal centre {0.5*(w0.bit_length()-1 + w1.bit_length()-1):.2f})")

hdr("E7.3  CANDIDATE MECHANISM: fraction of NEAR-DEGENERATE values")
print("  near-degenerate := |a^2-b^3| <= 2^{-12} (a^2+b^3)  (tiny relative gap)")
print("  prediction: this fraction is LARGE in a small box, negligible in a big")
print("  one -- which would make the smoothness bias genuinely N-dependent.")
for (Am, Bm), Nlab in zip(BOXES, NLAB):
    V = build(Am, Bm)
    a = np.arange(1, Am + 1, dtype=np.int64)[:, None]
    b = np.arange(1, Bm + 1, dtype=np.int64)[None, :]
    S = a * a + b * b * b
    for frac in (2 ** -12, 2 ** -8):
        nd = (np.abs(V) <= frac * S)
        f = nd.sum() / V.size
        print(f"  box N~{Nlab:.0e}: frac with |a^2-b^3| <= 2^{int(np.log2(frac))}"
              f"(a^2+b^3) = {f*100:>8.4f}%")

hdr("E7.4  DECISIVE: delta at MATCHED effective-u, identical full window")
print("  Use window [2^16,2^19) (fully populated by every box) and choose B so")
print("  that u_eff = ln(median value)/ln B is the SAME for every box.")
Lbig = lpf_array(729_000 + 10)
w0, w1 = 1 << 16, 1 << 19
for (Am, Bm), Nlab in zip(BOXES, NLAB):
    V = np.abs(build(Am, Bm).reshape(-1))
    m = (V >= w0) & (V < w1)
    med = float(np.median(V[m]))
    B = int(np.exp(log(med) / 2.0))
    pu = float((Lbig[w0:w1] <= B).mean())
    pn = float((Lbig[V[m]] <= B).mean())
    print(f"  box N~{Nlab:.0e}: median value {med:.3e}  B={B:>6}  "
          f"nfs {pn:.5f}  unif {pu:.5f}  ratio {pn/pu:.4f}")

hdr("E7 VERDICT")
print("  7.1 SAME  => the bias is a LOCAL property of a^2-b^3; all earlier")
print("              'N-dependence' was truncation, and delta is a function")
print("              of u ALONE, so it DOES extrapolate to 1024 bits.")
print("  7.1 DIFFERS + 7.3 large => genuine N-dependence from near-degenerate")
print("              values; the bias dies as N grows and is a small-scale")
print("              artifact.")