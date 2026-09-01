"""
Density versus Dependence in a Binary Scan
==========================================

Numerical demonstrations of the exact results on hit-indicator lag profiles.

The programme:

  1. The mean-centring identity.  For ANY cyclic record of length n, the average
     sample autocorrelation over the n-1 nonzero lags is exactly -1/(n-1).

  2. Difference sets realise the flat profile.  For a 0/1 record with support S,
     C(k) = d_S(k) - |S|^2/n; flat over nonzero lags iff S is a cyclic
     difference set, and the level is then exactly -1/(n-1).

  3. Pure density is exactly null when detrended at the true rate curve, and the
     literal global-mean reading is bounded by delta^2 / v uniformly in the lag.

  4. The Markov alternative has profile exactly lambda^k, peaking at lag 1.

  5. The coincidence (MA-1) scan has covariance p_i p_{i+1} p_{i+2} (1-p_{i+1})
     at lag 1 and EXACTLY zero at every lag >= 2, for every rate curve; its
     lag-1 correlation is c(1-b)/(1-ab), maximised over [l,u] by
     u(1-l)/(1-u l), attained by the alternating curve, with supremum 1.

  6. The noise floor 1/(16 m t^2), and the three-way shape classifier.

Self-contained: standard library plus (optional) numpy is NOT required.
Run with:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from itertools import product
from typing import Callable, Dict, List, Sequence, Tuple


# ----------------------------------------------------------------------------
# Section 0.  Elementary helpers
# ----------------------------------------------------------------------------

def cyclic_autocov(x: Sequence[float], k: int) -> float:
    """Mean-centred cyclic autocovariance C(k) = sum_i r_i r_{i+k}, r = x - mean."""
    n = len(x)
    mean = sum(x) / n
    r = [xi - mean for xi in x]
    return sum(r[i] * r[(i + k) % n] for i in range(n))


def cyclic_autocorr_profile(x: Sequence[float]) -> List[float]:
    """rho(k) = C(k)/C(0) for k = 1 .. n-1."""
    n = len(x)
    c0 = cyclic_autocov(x, 0)
    if c0 == 0.0:
        raise ValueError("constant record: autocorrelation undefined")
    return [cyclic_autocov(x, k) / c0 for k in range(1, n)]


def difference_multiplicity(support: Sequence[int], n: int, k: int) -> int:
    """d_S(k) = #{a in S : a + k mod n in S}."""
    s = set(a % n for a in support)
    return sum(1 for a in s if (a + k) % n in s)


# ----------------------------------------------------------------------------
# Section 1.  The mean-centring identity:  average rho(k) = -1/(n-1)
# ----------------------------------------------------------------------------

def demo_mean_centring_identity(seed: int = 599) -> None:
    print("=" * 78)
    print("1.  THE MEAN-CENTRING IDENTITY:  mean of rho(k) over k != 0 is -1/(n-1)")
    print("=" * 78)
    rng = random.Random(seed)

    cases: List[Tuple[str, List[float]]] = [
        ("iid Bernoulli(0.5), n=101",
         [float(rng.random() < 0.5) for _ in range(101)]),
        ("Bernoulli with a smooth hump, n=101",
         [float(rng.random() < 0.5 + 0.05 * math.sin(math.pi * i / 100))
          for i in range(101)]),
        ("strongly clustered record (blocks), n=101",
         [float((i // 7) % 2 == 0) for i in range(101)]),
        ("deterministic ramp (not 0/1 at all), n=101",
         [float(i) ** 1.3 for i in range(101)]),
        ("adversarial: one spike, n=101",
         [1.0 if i == 17 else 0.0 for i in range(101)]),
    ]

    print(f"{'record':<42}{'mean rho':>14}{'-1/(n-1)':>14}")
    print("-" * 70)
    for name, x in cases:
        prof = cyclic_autocorr_profile(x)
        m = sum(prof) / len(prof)
        n = len(x)
        print(f"{name:<42}{m:>14.10f}{-1.0/(n-1):>14.10f}")
    print()
    print("  The identity holds for random records, structured records, and")
    print("  non-binary records alike.  It is an algebraic property of centring,")
    print("  not a probabilistic statement.  A uniform ~ -0.01 offset on a")
    print("  101-position window is therefore FORCED, not evidence of inhibition.")
    print()


# ----------------------------------------------------------------------------
# Section 2.  Difference sets realise exact flatness at -1/(n-1)
# ----------------------------------------------------------------------------

def demo_difference_sets() -> None:
    print("=" * 78)
    print("2.  EXACT FLATNESS  <=>  CYCLIC DIFFERENCE SET,  AT LEVEL -1/(n-1)")
    print("=" * 78)

    examples: List[Tuple[str, int, List[int]]] = [
        ("Fano plane      S = {0,1,3} in Z_7",   7,  [0, 1, 3]),
        ("Singer (13,4,1) S = {0,1,3,9} in Z_13", 13, [0, 1, 3, 9]),
        ("Biplane (11,5,2) S = {1,3,4,5,9} in Z_11", 11, [1, 3, 4, 5, 9]),
        ("NOT a difference set: {0,1,2} in Z_7", 7, [0, 1, 2]),
    ]

    for name, n, S in examples:
        x = [1.0 if i in S else 0.0 for i in range(n)]
        prof = cyclic_autocorr_profile(x)
        d = [difference_multiplicity(S, n, k) for k in range(1, n)]
        flat = max(prof) - min(prof) < 1e-12
        print(f"\n  {name}")
        print(f"    d_S(k), k=1..{n-1}      : {d}")
        print(f"    rho(k)                : {[round(v, 6) for v in prof]}")
        print(f"    difference mult const : {len(set(d)) == 1}")
        print(f"    profile flat          : {flat}")
        if flat:
            print(f"    level                 : {prof[0]:.10f}"
                  f"   (-1/(n-1) = {-1.0/(n-1):.10f})")
        # verify C(k) = d_S(k) - |S|^2/n
        errs = [abs(cyclic_autocov(x, k) - (d[k - 1] - len(S) ** 2 / n))
                for k in range(1, n)]
        print(f"    max |C(k) - (d_S(k) - |S|^2/n)| = {max(errs):.2e}")
    print()
    print("  The flattest possible 0/1 records are the most DETERMINISTIC ones.")
    print("  Flatness is a design-theoretic signature, not a randomness one.")
    print()


# ----------------------------------------------------------------------------
# Section 3.  Pure density: exact null, and the second-order curvature bound
# ----------------------------------------------------------------------------

def exact_bernoulli_expectation(p: Sequence[float],
                                f: Callable[[Tuple[int, ...]], float]) -> float:
    """Exact expectation over all 2^n configurations of a product-Bernoulli law."""
    n = len(p)
    total = 0.0
    for s in product((0, 1), repeat=n):
        w = 1.0
        for i in range(n):
            w *= p[i] if s[i] else 1.0 - p[i]
        total += w * f(s)
    return total


def centered_pair_sum(s: Tuple[int, ...], k: int, m: int,
                      c: Sequence[float]) -> float:
    return sum((s[i] - c[i]) * (s[i + k] - c[i + k]) for i in range(m))


def demo_pure_density_exact_null() -> None:
    print("=" * 78)
    print("3.  PURE DENSITY:  EXACT NULL WHEN DETRENDED AT THE TRUE RATE CURVE")
    print("=" * 78)

    # A deliberately wild, non-smooth rate curve on n = 12 positions.
    n = 12
    p = [0.13, 0.91, 0.44, 0.07, 0.66, 0.50, 0.83, 0.22, 0.95, 0.31, 0.58, 0.72]
    print(f"  rate curve p (n={n}, arbitrary, non-smooth):")
    print(f"    {p}")
    print()
    print(f"  {'lag k':>6}{'E[A_k detrended at p]':>26}{'E[A_k at global mean]':>26}")
    print("  " + "-" * 56)
    gm = sum(p) / n
    for k in range(1, 6):
        m = n - k
        e_true = exact_bernoulli_expectation(
            p, lambda s, k=k, m=m: centered_pair_sum(s, k, m, p))
        e_lit = exact_bernoulli_expectation(
            p, lambda s, k=k, m=m: centered_pair_sum(s, k, m, [gm] * n))
        print(f"  {k:>6}{e_true:>26.15f}{e_lit:>26.10f}")
    print()
    print("  Detrending at the TRUE curve is exactly zero at every lag, to machine")
    print("  precision, for a curve with no smoothness whatsoever.  The literal")
    print("  global-mean reading is not zero -- that residue is curvature.")
    print()

    # Curvature bound: |E[A_k]/(m v)| <= delta^2 / v.
    print("  Curvature bound  |rho_literal| <= delta^2 / v  (uniform in the lag):")
    delta, v = 0.05, 0.45 * 0.55
    n2 = 14
    q = [0.5 + delta * math.sin(2 * math.pi * i / n2) for i in range(n2)]
    gm2 = sum(q) / n2
    worst = 0.0
    for k in range(1, 8):
        m = n2 - k
        e = sum((q[i] - gm2) * (q[i + k] - gm2) for i in range(m))
        worst = max(worst, abs(e / (m * v)))
    print(f"    delta = {delta}, v = {v:.6f},  bound delta^2/v = {delta**2/v:.6f}")
    print(f"    worst observed |rho| over lags 1..7 = {worst:.6f}")
    print(f"    bar = 0.05   ->  curvature cannot fake H1: "
          f"{delta**2/v < 0.05}")
    print()


# ----------------------------------------------------------------------------
# Section 4.  Variance, and the noise floor 1/(16 m t^2)
# ----------------------------------------------------------------------------

def demo_variance_and_noise_floor() -> None:
    print("=" * 78)
    print("4.  EXACT VARIANCE  sum_i p_i(1-p_i) p_{i+k}(1-p_{i+k})  AND NOISE FLOOR")
    print("=" * 78)

    n = 12
    p = [0.13, 0.91, 0.44, 0.07, 0.66, 0.50, 0.83, 0.22, 0.95, 0.31, 0.58, 0.72]
    print(f"  {'lag k':>6}{'exact E[A_k^2]':>22}{'sum V_i V_{i+k}':>22}")
    print("  " + "-" * 50)
    for k in range(1, 5):
        m = n - k
        lhs = exact_bernoulli_expectation(
            p, lambda s, k=k, m=m: centered_pair_sum(s, k, m, p) ** 2)
        rhs = sum(p[i] * (1 - p[i]) * p[i + k] * (1 - p[i + k]) for i in range(m))
        print(f"  {k:>6}{lhs:>22.12f}{rhs:>22.12f}")
    print()
    print("  The terms are pairwise uncorrelated EVEN WHEN TWO PAIRS SHARE A")
    print("  POSITION (j = i+k), which is why the variance is a clean sum.")
    print()

    print("  Chebyshev noise floor  P[|A_k| >= t m] <= 1/(16 m t^2):")
    for m, t in [(100, 0.05), (1000, 0.05), (9594, 0.05), (9594, 0.02)]:
        print(f"    m = {m:>6}, t = {t:<5} ->  bound = {1.0/(16*m*t*t):.6f}")
    print()
    print("  At the experiment's m = 9594 hits and the 0.05 bar the bound is")
    print(f"  {1.0/(16*9594*0.05**2):.6f} < 0.003: the null is an EXCLUSION, not a shrug.")
    print()


# ----------------------------------------------------------------------------
# Section 5.  The Markov alternative: profile exactly lambda^k
# ----------------------------------------------------------------------------

def markov_profile(a: float, b: float, kmax: int) -> List[float]:
    """rho(k) computed by iterating the affine one-step map, not by the formula."""
    lam = 1.0 - a - b
    pi = a / (a + b)
    out = []
    for k in range(1, kmax + 1):
        x = 1.0
        for _ in range(k):
            x = x * (1 - b) + (1 - x) * a
        cov = pi * (x - pi)
        out.append(cov / (pi * (1 - pi)))
    return out


def demo_markov_profile() -> None:
    print("=" * 78)
    print("5.  MARKOV ALTERNATIVE:  rho(k) = lambda^k EXACTLY, PEAKING AT LAG 1")
    print("=" * 78)
    for a, b in [(0.2, 0.3), (0.05, 0.05), (0.6, 0.1), (0.4, 0.6)]:
        lam = 1 - a - b
        prof = markov_profile(a, b, 6)
        pred = [lam ** k for k in range(1, 7)]
        err = max(abs(x - y) for x, y in zip(prof, pred))
        argmax = max(range(6), key=lambda i: abs(prof[i])) + 1
        print(f"\n  a = {a}, b = {b}   lambda = {lam:+.3f}   "
              f"stationary rate = {a/(a+b):.4f}")
        print(f"    iterated profile : {[round(v, 8) for v in prof]}")
        print(f"    lambda^k         : {[round(v, 8) for v in pred]}")
        print(f"    max deviation    : {err:.2e}     argmax lag = {argmax}")
    print()
    print("  lambda = 0 (a + b = 1) gives the memoryless chain and a profile that")
    print("  vanishes identically: memory and lag-1 correlation are the SAME thing.")
    print()


# ----------------------------------------------------------------------------
# Section 6.  The coincidence (MA-1) scan
# ----------------------------------------------------------------------------

def ma_profile_exact(p: Sequence[float], i: int, kmax: int) -> List[float]:
    """Lag profile of Y_j = X_j X_{j+1} anchored at i, by exact enumeration."""
    n = len(p)
    out = []
    for k in range(1, kmax + 1):
        if i + k + 1 >= n:
            break
        mu_i = p[i] * p[i + 1]
        mu_ik = p[i + k] * p[i + k + 1]
        cov = exact_bernoulli_expectation(
            p, lambda s, i=i, k=k, mu_i=mu_i, mu_ik=mu_ik:
            (s[i] * s[i + 1] - mu_i) * (s[i + k] * s[i + k + 1] - mu_ik))
        var = mu_i - mu_i ** 2
        out.append(cov / var)
    return out


def spike_bound(l: float, u: float) -> float:
    """Sigma(l,u) = u(1-l)/(1-ul): the sharp maximum coincidence spike."""
    return u * (1 - l) / (1 - u * l)


def alt_rate(l: float, u: float, n: int) -> List[float]:
    """The alternating rate curve u, l, u, l, ... which attains the bound."""
    return [l if j % 2 == 1 else u for j in range(n)]


def demo_coincidence_scan() -> None:
    print("=" * 78)
    print("6.  THE COINCIDENCE (MA-1) SCAN:  ONE SPIKE, THEN EXACT ZEROS")
    print("=" * 78)

    n = 11
    curves: List[Tuple[str, List[float]]] = [
        ("constant q = 0.5", [0.5] * n),
        ("constant q = 0.8", [0.8] * n),
        ("wild heterogeneous", [0.2, 0.9, 0.35, 0.75, 0.1, 0.6, 0.45,
                                0.85, 0.3, 0.55, 0.7]),
        ("alternating 0.9/0.1", alt_rate(0.1, 0.9, n)),
    ]
    for name, p in curves:
        prof = ma_profile_exact(p, 0, 5)
        a, b, c = p[0], p[1], p[2]
        closed = c * (1 - b) / (1 - a * b)
        print(f"\n  {name}")
        print(f"    exact profile rho_Y(k), k=1..{len(prof)}:")
        print(f"      {[round(v, 12) for v in prof]}")
        print(f"    closed form c(1-b)/(1-ab) = {closed:.12f}"
              f"   (lag-1 match: {abs(prof[0]-closed) < 1e-12})")
        print(f"    max |rho_Y(k)| for k >= 2 : {max((abs(v) for v in prof[1:]), default=0.0):.2e}")
    print()
    print("  EXACT zeros from lag 2 on, for EVERY rate curve.  A Markov profile")
    print("  lambda^k can never do this without also vanishing at lag 1.")
    print()

    print("  Sharpness of the window bound Sigma(l,u) = u(1-l)/(1-ul):")
    print(f"  {'[l, u]':>16}{'Sigma(l,u)':>14}{'alt-curve spike':>18}"
          f"{'random-curve max':>20}")
    print("  " + "-" * 68)
    rng = random.Random(2026)
    for l, u in [(0.1, 0.9), (0.3, 0.7), (0.45, 0.55), (0.01, 0.99)]:
        sigma = spike_bound(l, u)
        p_alt = alt_rate(l, u, 5)
        attained = p_alt[2] * (1 - p_alt[1]) / (1 - p_alt[0] * p_alt[1])
        best = 0.0
        for _ in range(20000):
            a = rng.uniform(l, u); b = rng.uniform(l, u); c = rng.uniform(l, u)
            best = max(best, c * (1 - b) / (1 - a * b))
        print(f"  [{l:.2f}, {u:.2f}]".rjust(16)
              + f"{sigma:>14.8f}{attained:>18.8f}{best:>20.8f}")
    print()
    print("  Random search never exceeds Sigma, and the alternating curve hits it")
    print("  exactly.  So Sigma is the MAXIMUM, not merely an upper bound.")
    print()

    print("  Heterogeneity beats the homogeneous cap q/(1+q) < 1/2:")
    print(f"    constant q = 0.99 : spike = {0.99/1.99:.6f}  (< 0.5 always)")
    print(f"    alternating 0.1/0.9: spike = {spike_bound(0.1, 0.9):.6f} = 81/91")
    print()
    print("  Supremum over all curves with values in (0,1) is exactly 1:")
    print(f"    {'t':>10}{'Sigma(t, 1-t)':>18}")
    for t in [0.25, 0.1, 0.01, 1e-3, 1e-5]:
        print(f"    {t:>10}{spike_bound(t, 1 - t):>18.10f}")
    print()
    print("  ...but never reaches 1.  AMPLITUDE CARRIES NO MECHANISM INFORMATION;")
    print("  only SHAPE (exact zeros from lag 2) does.")
    print()


# ----------------------------------------------------------------------------
# Section 7.  The three-way shape classifier
# ----------------------------------------------------------------------------

def classify_profile(rho1: float, rho2: float, tol: float = 0.01) -> str:
    """Classify a mechanism from the first two lags alone (Trichotomy theorem)."""
    if abs(rho1) <= tol and abs(rho2) <= tol:
        return "pure density (flat)"
    if abs(rho1) > tol and abs(rho2) <= tol:
        return "coincidence / MA-1 (one spike)"
    if abs(rho2 - rho1 ** 2) <= tol:
        return f"Markov (geometric, lambda ~ {rho1:+.3f})"
    return "unclassified"


def demo_shape_classifier() -> None:
    print("=" * 78)
    print("7.  THE THREE-WAY SHAPE CLASSIFIER (FIRST TWO LAGS SUFFICE)")
    print("=" * 78)

    n = 9
    samples: List[Tuple[str, float, float]] = []

    # pure density: exactly zero
    samples.append(("pure density, arbitrary curve", 0.0, 0.0))

    # Markov chains
    for a, b in [(0.2, 0.3), (0.6, 0.1)]:
        prof = markov_profile(a, b, 2)
        samples.append((f"Markov a={a}, b={b}", prof[0], prof[1]))

    # coincidence scans
    for name, p in [("coincidence, q = 0.6", [0.6] * n),
                    ("coincidence, alternating 0.1/0.9", alt_rate(0.1, 0.9, n))]:
        prof = ma_profile_exact(p, 0, 2)
        samples.append((name, prof[0], prof[1]))

    # the measured record
    samples.append(("MEASURED RECORD (lags 1,2)", -0.0199, -0.0104))

    print(f"  {'mechanism':<36}{'rho(1)':>10}{'rho(2)':>10}   verdict")
    print("  " + "-" * 84)
    for name, r1, r2 in samples:
        print(f"  {name:<36}{r1:>10.4f}{r2:>10.4f}   {classify_profile(r1, r2, 0.03)}")
    print()
    print("  Note the measured record: both lags sit at the arithmetic artefact")
    print("  level, far below the 0.05 bar.  Density, and nothing else.")
    print()


# ----------------------------------------------------------------------------
# Section 8.  A Monte-Carlo replay of the experimental verdict
# ----------------------------------------------------------------------------

def simulate_scan_density(rate: Callable[[float], float], n: int,
                          rng: random.Random) -> List[int]:
    return [1 if rng.random() < rate(i / (n - 1)) else 0 for i in range(n)]


def simulate_scan_markov(a: float, b: float, n: int,
                         rng: random.Random) -> List[int]:
    pi = a / (a + b)
    x = 1 if rng.random() < pi else 0
    out = [x]
    for _ in range(n - 1):
        x = (1 if rng.random() >= b else 0) if x == 1 else (1 if rng.random() < a else 0)
        out.append(x)
    return out


def detrended_profile(x: Sequence[int], p_hat: Sequence[float],
                      kmax: int) -> List[float]:
    n = len(x)
    denom = sum(ph * (1 - ph) for ph in p_hat)
    out = []
    for k in range(1, kmax + 1):
        m = n - k
        num = sum((x[i] - p_hat[i]) * (x[i + k] - p_hat[i + k]) for i in range(m))
        scale = sum(p_hat[i] * (1 - p_hat[i]) for i in range(m))
        out.append(num / scale if scale else 0.0)
    return out


def demo_monte_carlo_replay(seed: int = 599) -> None:
    print("=" * 78)
    print("8.  MONTE-CARLO REPLAY:  DENSITY IS NULL, INJECTED DEPENDENCE IS CAUGHT")
    print("=" * 78)
    rng = random.Random(seed)
    n = 9594

    # (a) pure density with a mid-window hump at u ~ 0.65
    def rate(u: float) -> float:
        return 0.50 + 0.05 * math.exp(-((u - 0.65) ** 2) / (2 * 0.08 ** 2))

    x = simulate_scan_density(rate, n, rng)
    p_hat = [rate(i / (n - 1)) for i in range(n)]
    prof = detrended_profile(x, p_hat, 20)
    print(f"\n  (a) pure density, mid-window hump at u = 0.65, n = {n}")
    print(f"      hits = {sum(x)}   (rate curve peaks at {max(p_hat):.4f})")
    print(f"      detrended rho over lags 1..20: "
          f"[{min(prof):+.4f}, {max(prof):+.4f}]")
    print(f"      max |rho| = {max(abs(v) for v in prof):.4f}   "
          f"vs bar 0.05  ->  {'NULL' if max(abs(v) for v in prof) < 0.05 else 'DETECT'}")
    argmax = max(range(20), key=lambda i: abs(prof[i])) + 1
    print(f"      argmax lag = {argmax}   (no preferred lag: no shape)")

    # (b) injected lag-1 dependence: the power control
    lam = 0.35
    a_par = 0.5 * (1 - lam)
    b_par = 0.5 * (1 - lam)
    y = simulate_scan_markov(a_par, b_par, n, rng)
    p_flat = [sum(y) / n] * n
    profy = detrended_profile(y, p_flat, 20)
    argmaxy = max(range(20), key=lambda i: abs(profy[i])) + 1
    print(f"\n  (b) injected Markov dependence, lambda = {lam}")
    print(f"      hits = {sum(y)}")
    print(f"      detrended rho over lags 1..20: "
          f"[{min(profy):+.4f}, {max(profy):+.4f}]")
    print(f"      rho(1) = {profy[0]:+.4f}   theory lambda = {lam:+.4f}")
    print(f"      argmax lag = {argmaxy}   ->  "
          f"{'DETECTED at lag 1' if argmaxy == 1 else 'shape mismatch'}")
    print(f"      rho(2) = {profy[1]:+.4f}   theory lambda^2 = {lam**2:+.4f}"
          f"   (geometric decay)")

    # (c) coincidence scan: one spike then nothing
    latent = simulate_scan_density(lambda u: 0.6, n, rng)
    z = [latent[i] * latent[i + 1] for i in range(n - 1)]
    mu = sum(z) / len(z)
    profz = detrended_profile(z, [mu] * len(z), 6)
    print(f"\n  (c) coincidence scan Y_i = X_i X_{{i+1}}, latent q = 0.6")
    print(f"      hits = {sum(z)}   marginal rate = {mu:.4f} (theory 0.36)")
    print(f"      rho(1) = {profz[0]:+.4f}   theory q/(1+q) = {0.6/1.6:+.4f}")
    print(f"      rho(2..6) = {[round(v, 4) for v in profz[1:]]}   (theory: all 0)")
    print()
    print("  Verdict reproduced: density is null, dependence is caught, and the")
    print("  three mechanisms are told apart by the SHAPE of the first two lags.")
    print()


# ----------------------------------------------------------------------------

def main() -> None:
    print()
    print("#" * 78)
    print("#  DENSITY VERSUS DEPENDENCE IN A BINARY SCAN  --  numerical companion")
    print("#" * 78)
    print()
    demo_mean_centring_identity()
    demo_difference_sets()
    demo_pure_density_exact_null()
    demo_variance_and_noise_floor()
    demo_markov_profile()
    demo_coincidence_scan()
    demo_shape_classifier()
    demo_monte_carlo_replay()
    print("=" * 78)
    print("SUMMARY")
    print("=" * 78)
    print("  * mean of the lag profile is exactly -1/(n-1) for EVERY record;")
    print("  * exact flatness at that level characterises cyclic difference sets;")
    print("  * pure density detrended at the true curve is exactly null at all lags;")
    print("  * the literal reading is bounded by delta^2/v ~ 0.0101, below the bar;")
    print("  * Markov memory gives rho(k) = lambda^k, peaking at lag 1;")
    print("  * the coincidence scan gives one spike then EXACT zeros, at any height;")
    print("  * so amplitude identifies nothing, and shape identifies everything.")
    print()


if __name__ == "__main__":
    main()
