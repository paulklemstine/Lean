"""
E8 -- RIGOROUS PREDICTION of delta from the EXACT local densities, compared to
the MEASUREMENT at the tightest feasible case.

The mechanism is now pinned down EXACTLY (E3.1, E6.3):
    P(v_p = 0)          = 1/p                                    [scale-free]
    E[v_p]              = 1/p + (1+1/p)/(p(p-1))   for p != 3
    P(v_p >= k)         = (1+1/p) p^{-k}          for k >= 2
p=3 is the sole exception (cubes mod 9 lie only in {0,+-1}).
Check p=2: E[v_2] = 1/2 + (3/2)/(2*1) = 0.5+0.75 = 1.25.  E6.3 measured
mean v_2 = 1.2429-1.2498.  MATCH.

This lets us PREDICT the smoothness density without any smoothness
assumption, by the standard local-density characterisation:

    P(B-smooth) = SUM over { k_p >= 0 : prod_{p<=B} p^{k_p} <= x }  prod_p nu_p(k_p)

where nu_p(k) = P(v_p = k) under the a^2-b^3 distribution.  The sum is
evaluated EXACTLY by dynamic programming over the primes -- no Dickman
approximation anywhere.  Uniform integers use the same code path with the
uniform nu_p(k) = (1-1/p) p^{-k}, which reproduces rho(u) as a bonus check.

Then compare PREDICTED delta to MEASURED delta at the tightest case where both
are computable: small B, small x, where the DP is exact and the measurement
has millions of samples.

Run: timeout 3000 python3 e8_rigorous.py
"""
import numpy as np
from math import log
from e2data import lpf_array
import common as C

rng = np.random.default_rng(5150)


def hdr(s):
    print("\n" + "=" * 78 + f"\n{s}\n" + "=" * 78)


def primes_upto(n):
    return C.sieve_primes(n)


def local_nu(p, mode):
    """nu_p(k) for k = 0..K as an array.

    uniform : nu_p(k) = (1-1/p) p^{-k}
    nfs     : nu_p(0) = 1-1/p
              nu_p(1) = 1/p
              nu_p(k) = nu_p(k-1) - (1+1/p) p^{-k}   for k >= 2
    The nfs branch encodes P(p^k | v) = (1+1/p) p^{-k} for k >= 2, exactly as
    measured in E3.1 by exhaustive count mod p^k.
    """
    K = 40
    k = np.arange(K + 1)
    if mode == "uniform":
        return (1 - 1.0 / p) * p ** (-k.astype(float))
    nu = np.zeros(K + 1)
    nu[0] = 1 - 1.0 / p
    nu[1] = 1.0 / p
    cum = nu[1]
    for kk in range(2, K + 1):
        pk = (1 + 1.0 / p) * p ** (-kk)
        nu[kk] = cum - pk
        cum -= pk
    return nu


def smooth_density(x, B, mode):
    """EXACT density of B-smooth integers <= x under local densities `mode`.

    DP over primes: f[j] = total weight of products using primes seen so far,
    indexed by the product value.  Arrays are keyed by integer value <= x.
    """
    ps = primes_upto(B)
    f = np.zeros(x + 1)
    f[1] = 1.0
    for p in ps:
        nu = local_nu(p, mode)
        # g = f * sum_k nu(k) * X^{p^k}  in the multiplicative semigroup:
        #   for each k, add w * f shifted by p^k.
        g = np.zeros(x + 1)
        g[:] = nu[0] * f
        step = p
        k = 1
        while step <= x:
            w = nu[k] if k < len(nu) else 0.0
            if w > 0:
                m = x // step            # g[j*step] += w*f[j] for j = 1..m
                g[step::step] += w * f[1:m + 1]
            step *= p
            k += 1
        f = g
    return float(f[1:x + 1].sum()) / x


hdr("E8.1  DP sanity check: uniform mode must reproduce rho(u)")
for (x, B) in [(100_000, 300), (100_000, 1000), (1_000_000, 1000)]:
    u = log(x) / log(B)
    dp = smooth_density(x, B, "uniform")
    print(f"  x={x:>9} B={B:>6} u={u:>6.3f}  DP {dp:.6e}   rho(u) "
          f"{C.rho(u):.6e}   rel {abs(dp-C.rho(u))/C.rho(u):.4f}")

hdr("E8.2  PREDICTED delta = (nfs local densities) / (uniform local densities)")
print("  This is a PREDICTION from the exact v_p laws -- no smoothness")
print("  sampling, no Dickman, no extrapolation.")
print(f"  {'x':>9} {'B':>6} {'u':>6} {'uniform':>11} {'NFS-pred':>11} {'delta_pred':>11}")
preds = []
for (x, B) in [(100_000, 300), (100_000, 1000), (1_000_000, 1000),
               (1_000_000, 3000), (2_000_000, 1000), (200_000, 1000)]:
    du = smooth_density(x, B, "uniform")
    dn = smooth_density(x, B, "nfs")
    u = log(x) / log(B)
    preds.append((x, B, u, du, dn, dn / du if du else np.nan))
    print(f"  {x:>9} {B:>6} {u:>6.3f} {du:>11.6e} {dn:>11.6e} {dn/du:>11.4f}")

hdr("E8.3  MEASUREMENT at the same (x, B) -- tightest feasible case")
print("  a^2-b^3 values restricted to <= x, compared to uniform in [1,x].")
L = lpf_array(2_000_000 + 10)
a = np.arange(1, 1450, dtype=np.int64)
b = np.arange(1, 130, dtype=np.int64)
V = np.abs((a[:, None] ** 2 - b[None, :] ** 3).reshape(-1))
print(f"  box: {V.size} pairs, values up to {V.max():.3e}")
print(f"  {'x':>9} {'B':>6} {'n':>9} {'meas ratio':>11} {'pred ratio':>11} "
      f"{'diff':>8} {'sigma':>7}")
for (x, B, u, du, dn, dp) in preds:
    if x > L.size - 1 or B >= x:
        continue
    m = (V > 0) & (V <= x)
    n = int(m.sum())
    if n < 2000:
        continue
    pu = float((L[1:x + 1] <= B).mean())
    pn = float((L[V[m]] <= B).mean())
    meas = pn / pu
    sg = (pn - pu) / np.sqrt(max(pu * (1 - pu), 1e-18) / n)
    print(f"  {x:>9} {B:>6} {n:>9} {meas:>11.4f} {dp:>11.4f} "
          f"{meas-dp:>8.4f} {sg:>7.1f}")

hdr("E8.4  WHAT IS THE PREDICTED DELTA AT NFS-RELEVANT u?")
print("  NFS uses B ~ N^{1/3} with values up to ~N, so u = ln N/ln B ~ 3.")
for u in (2.0, 2.5, 3.0, 3.5, 4.0, 5.0, 6.0):
    x, B = 2_000_000, int(np.exp(log(2_000_000) / u))
    if B < 2 or B >= x:
        continue
    du = smooth_density(x, B, "uniform")
    dn = smooth_density(x, B, "nfs")
    print(f"  u={u:>4.1f}  (x={x}, B={B:>6})  delta_pred = {dn/du:.4f}")

hdr("E8 VERDICT")
print("  If MEASUREMENT ~ PREDICTION, the bias is fully explained by the exact")
print("  v_p laws, and its size at NFS-relevant u is whatever E8.4 prints.")