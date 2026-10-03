"""
E2 -- H1: does a^2-b^3 have a non-uniform SMOOTHNESS distribution?

The null harness (E1) established:
  * rho trustworthy for u in [1,4]
  * smoothness oracle: 0 disagreements vs exact factorisation
  * stratum-matched uniform null reads ~0 sigma
  * Dickman's own finite-x floor is rel gap 0.023-0.324  (E1/A3)

This file does NOT compare a^2-b^3 against uniform-in-[1,M].  That comparison
is confounded: a^2-b^3 has an extremely non-uniform SIZE distribution (it piles
up near 0, where everything is trivially smooth).  The tight test is
STRATUM-MATCHED: inside each dyadic size stratum, compare the smoothness rate
of a^2-b^3 against the EXACT rate for uniform integers in that same stratum.

Power control: the same test is run on a^2 (a perfect square), which is KNOWN
to be non-uniform.  If the harness cannot see a^2's deviation, it has no
power to see a^2-b^3's.

MECHANISM being tested: a^2-b^3 is a value on the curve y^2=x^3-type geometry.
The number of (a,b) mod p with a^2-b^3 = 0 mod p is p + O(sqrt p) (a curve
count), not p^2 * (1/p) = p exactly.  So P(p | a^2-b^3) > 1/p by O(p^{-3/2}),
i.e. the values are systematically MORE divisible by small primes, hence
smoother.  Prediction stated in NOTES before the run: the excess is small
(relative O(p^{-1/2})), the cumulative smoothness gain is a LOW-ORDER effect
on the L[1/3] constant, and the sign is toward SMOOTH.

Run: timeout 3000 python3 e2_nfsbox.py
"""
import numpy as np
from math import log, sqrt
import common as C

FAIL = []
rng = np.random.default_rng(20261003)


def hdr(s):
    print("\n" + "=" * 78 + f"\n{s}\n" + "=" * 78)


# ------------------------------------------------------------------ oracle
def lpf_array(M):
    """lpf[n] = largest prime factor of n, for n <= M.  n is B-smooth iff lpf[n]<=B.
    ONE pass; any B is then a cheap comparison.  int32 => 4(M+1) bytes."""
    lpf = np.zeros(M + 1, dtype=np.int32)
    lpf[1] = 1
    s = bytearray([1]) * (M + 1)
    s[0:2] = b"\x00\x00"
    from math import isqrt
    for p in range(2, isqrt(M) + 1):
        if s[p]:
            s[p * p::p] = bytearray(len(s[p * p::p]))
    # ascending primes -> last write wins -> largest prime factor
    for p in range(2, M + 1):
        if s[p]:
            lpf[p::p] = p
    return lpf


hdr("E2  H1: smoothness of a^2-b^3 vs uniform, STRATUM-MATCHED")

AMAX, BMAX = 12_000, 530        # a^2 ~ 1.44e8, b^3 ~ 1.49e8, pairs = 6.36e6
NP = AMAX * BMAX
M = int(1.6e8)
print(f"box: 1<=a<={AMAX}, 1<=b<={BMAX}  -> {NP/1e6:.2f}e6 pairs "
      f"(NFS-equivalent N ~ 1.4e8)")
print(f"oracle: lpf array to M={M:.2e}  ({4*(M+1)/1e9:.2f} GB)")

import time
t0 = time.time()
LPF = lpf_array(M)
print(f"lpf built in {time.time()-t0:.1f}s")

a = np.arange(1, AMAX + 1, dtype=np.int64)
b = np.arange(1, BMAX + 1, dtype=np.int64)
A2 = (a * a)[:, None]
B3 = (b * b * b)[None, :]

SAMPLES = {
    "a^2 - b^3": (A2 - B3).reshape(-1),
    "a^2 + b^3": (A2 + B3).reshape(-1),
    "a^2  (CONTROL, known non-uniform)": A2.reshape(-1).repeat(BMAX),
}
for k, v in SAMPLES.items():
    print(f"  {k:36s} |value| range {np.abs(v).min():>12d} .. {np.abs(v).max():>12d}")

# ---------------------------------------------------------------- size strata
BS = [1000, 10_000, 100_000, 1_000_000, 10_000_000]
# stratum edges: dyadic, plus the sub-1 region handled separately
STRATA = [(j, j + 1) for j in range(10, 28)]


def stratify(V):
    av = np.abs(V)
    ok = av > 0
    lg = np.zeros(av.size, dtype=np.int32)
    lg[ok] = np.floor(np.log2(av[ok].astype(np.float64))).astype(np.int32)
    return lg


hdr("E2.1  POWER CONTROL: a^2 (a perfect square) MUST show a deviation")
V = SAMPLES["a^2  (CONTROL, known non-uniform)"]
lg = stratify(V)
print(f"{'stratum':>14} {'B':>9} {'n':>9} {'a^2 rate':>11} {'uniform rate':>13} {'sigma':>9}")
for (j0, j1) in STRATA[:8]:
    lo, hi = 1 << j0, (1 << j1) - 1
    m = (lg >= j0) & (lg < j1)
    n = int(m.sum())
    if n < 5000:
        continue
    for B in (100_000,):
        u = log(hi) / log(B)
        p_uni = float((LPF[lo:hi + 1] <= B).mean())
        p_a2 = float((LPF[np.abs(V[m])] <= B).mean())
        sg = (p_a2 - p_uni) / sqrt(max(p_uni * (1 - p_uni), 1e-18) / n)
        print(f"[2^{j0},2^{j1})".rjust(14) + f" {B:>9} {n:>9} {p_a2:>11.5f} "
              f"{p_uni:>13.5f} {sg:>9.1f}")
        if abs(sg) < 10:
            FAIL.append(f"power control a^2 at 2^{j0}")

hdr("E2.2  THE TEST: a^2-b^3 vs uniform, stratum-matched, many B")
summary = []
for name in ("a^2 - b^3", "a^2 + b^3"):
    V = SAMPLES[name]
    lg = stratify(V)
    print(f"\n--- {name} ---")
    print(f"{'stratum':>14} {'B':>10} {'n':>9} {'nfs rate':>11} {'uniform rate':>13} "
          f"{'ratio':>7} {'sigma':>9}")
    for (j0, j1) in STRATA:
        lo, hi = 1 << j0, (1 << j1) - 1
        m = (lg >= j0) & (lg < j1)
        n = int(m.sum())
        if n < 20_000 or hi > M:
            continue
        for B in BS:
            if B >= hi:
                continue
            p_uni = float((LPF[lo:hi + 1] <= B).mean())
            if p_uni <= 0:
                continue
            p_nfs = float((LPF[np.abs(V[m])] <= B).mean())
            sg = (p_nfs - p_uni) / sqrt(max(p_uni * (1 - p_uni), 1e-18) / n)
            ratio = p_nfs / p_uni
            summary.append((name, j0, B, n, p_nfs, p_uni, ratio, sg))
            print(f"[2^{j0},2^{j1})".rjust(14) + f" {B:>10} {n:>9} {p_nfs:>11.5f} "
                  f"{p_uni:>13.5f} {ratio:>7.4f} {sg:>9.1f}")

hdr("E2.3  AGGREGATE: weighted by stratum, the headline ratio")
import collections
for name in ("a^2 - b^3", "a^2 + b^3"):
    rows = [r for r in summary if r[0] == name]
    if not rows:
        continue
    tot = sum(r[3] for r in rows)
    pn = sum(r[4] * r[3] for r in rows) / tot
    pu = sum(r[5] * r[3] for r in rows) / tot
    sig = (pn - pu) / sqrt(max(pu * (1 - pu), 1e-18) / tot)
    print(f"  {name}: NFS {pn:.6f} vs uniform {pu:.6f}  ratio {pn/pu:.4f}  "
          f"sigma {sig:.1f}  (n={tot/1e6:.2f}e6)")

hdr("E2.4  MECHANISM: small-prime divisibility P(p | a^2-b^3) vs 1/p")
print("  the curve count predicts P(p|a^2-b^3) = 1/p + (excess ~ p^{1/2}/p^2)")
print(f"{'p':>6} {'#(a,b): p | a^2-b^3':>20} {'1/p':>12} {'ratio':>9} "
      f"{'#(a,b): p | a^2+b^3':>20} {'ratio':>9}")
for p in [2, 3, 5, 7, 11, 13, 17, 23, 31, 53, 101, 211, 509]:
    Am = a % p
    Bm = b % p
    cnt_m = int((((Am[:, None] ** 2 - Bm[None, :] ** 3) % p) == 0).sum())
    cnt_p = int((((Am[:, None] ** 2 + Bm[None, :] ** 3) % p) == 0).sum())
    rm = cnt_m / NP * p
    rp = cnt_p / NP * p
    print(f"{p:>6} {cnt_m:>20} {1/p:>12.6f} {rm:>9.4f} {cnt_p:>20} {rp:>9.4f}")

hdr("E2.5  SMALL-VALUE CONCENTRATION (the confound, quantified)")
V = SAMPLES["a^2 - b^3"]
av = np.abs(V)
print(f"  |a^2-b^3| < 1e4 : {int((av<1e4).sum()):>10} of {NP} pairs "
      f"= {(av<1e4).mean()*100:.4f}%   (uniform would give {1e4/1.4e8*100:.6f}%)")
print(f"  |a^2-b^3| = 0   : {int((av==0).sum()):>10}")
print("  => the size distribution alone accounts for a MASSIVE apparent excess;")
print("     this is exactly why E2.2 stratifies.")

hdr("E2 VERDICT")
if FAIL:
    print(f"  HARNESS PROBLEM: {FAIL}")
else:
    print("  harness has power (sees a^2) -- results above are meaningful.")
np.save("/home/raver1975/lean/factor-scratch/r48/exp/e2_summary.npy",
        np.array(summary, dtype=object), allow_pickle=True)