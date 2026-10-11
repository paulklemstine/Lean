#!/usr/bin/env python3
"""
Per-N predictors at the sampling ceiling -- numerical companion.

Self-contained (standard library only).  Sections:

  1. Euler's criterion as a feature extractor; the QR count of a modulus N.
  2. Exact moments of the per-prime feature and CRT orthogonality of the QR count.
  3. Factor blindness of the residue dial.
  4. The binomial bias-variance law (exact rational arithmetic).
  5. The residual decomposition, the ceiling theorem and R^2 = ceiling * rho^2
     on a synthetic balanced panel.
  6. The ceiling growth law V / (V + E/n).
  7. The fraction-of-ceiling arithmetic of the reported experiment, and the
     consistency check of the reported triples.
  8. A miniature smoothness experiment: sieve values j^2 - N for random
     semiprimes, smoothness rate predicted from the QR count alone.
"""
from __future__ import annotations

import math
import random
from fractions import Fraction
from itertools import product
from typing import Callable, Sequence

SEED: int = 20260827


# ----------------------------------------------------------------------------
# helpers
# ----------------------------------------------------------------------------
def primes_upto(m: int) -> list[int]:
    """Sieve of Eratosthenes."""
    if m < 2:
        return []
    is_p = bytearray([1]) * (m + 1)
    is_p[0] = is_p[1] = 0
    for i in range(2, int(m ** 0.5) + 1):
        if is_p[i]:
            is_p[i * i:: i] = bytearray(len(is_p[i * i:: i]))
    return [i for i in range(m + 1) if is_p[i]]


ODD_PRIMES_TO_100: list[int] = [p for p in primes_upto(100) if p != 2]


def euler_pass(p: int, N: int) -> bool:
    """Euler-criterion test: N^((p-1)/2) == 1 (mod p)."""
    return pow(N % p, (p - 1) // 2, p) == 1


def legendre(N: int, p: int) -> int:
    """Legendre symbol by brute force (definition, not Euler)."""
    a = N % p
    if a == 0:
        return 0
    return 1 if any((x * x) % p == a for x in range(1, p)) else -1


def qr_count(N: int, primes: Sequence[int] = ODD_PRIMES_TO_100) -> int:
    """Number of primes p in the list at which N passes Euler's test."""
    return sum(1 for p in primes if euler_pass(p, N))


def mean(v: Sequence[float]) -> float:
    return sum(v) / len(v)


def scov(u: Sequence[float], v: Sequence[float]) -> float:
    """Centred cross-product sum (unnormalised covariance)."""
    mu, mv = mean(u), mean(v)
    return sum((a - mu) * (b - mv) for a, b in zip(u, v))


def is_smooth(v: int, primes: Sequence[int]) -> bool:
    """Trial division: is |v| a product of the given primes?"""
    v = abs(v)
    if v == 0:
        return False
    for p in primes:
        if p * p > v:
            break
        while v % p == 0:
            v //= p
    return v == 1 or v <= primes[-1]


def banner(title: str) -> None:
    print("\n" + "=" * 78 + f"\n{title}\n" + "=" * 78)


# ----------------------------------------------------------------------------
# 1. Euler's criterion and the QR count
# ----------------------------------------------------------------------------
def section_euler() -> None:
    banner("1. Euler's criterion computes the Legendre symbol")
    print(f"odd primes <= 100: {len(ODD_PRIMES_TO_100)} of them -> 24 Euler tests per N")
    bad = 0
    for p in ODD_PRIMES_TO_100[:10]:
        for N in range(-200, 200):
            if euler_pass(p, N) != (legendre(N, p) == 1):
                bad += 1
    print(f"Euler test == [Legendre symbol = 1] checked on 4000 (p, N) pairs; mismatches: {bad}")
    for N in [1000003 * 999983, 2**31 - 1, 123456789]:
        print(f"  QR count of N = {N}: {qr_count(N)} / 24")
    P, Q = 1000003, 999983
    ok = all(legendre(P * Q, p) == legendre(P, p) * legendre(Q, p) for p in ODD_PRIMES_TO_100)
    print(f"multiplicativity (PQ/p) = (P/p)(Q/p) for all 24 primes: {ok}")


# ----------------------------------------------------------------------------
# 2. Moments of the feature; CRT orthogonality
# ----------------------------------------------------------------------------
def section_moments() -> None:
    banner("2. Exact moments of the per-prime feature and of the QR count")
    for p in [3, 5, 7, 11, 13]:
        ind = [1 if euler_pass(p, a) else 0 for a in range(p)]
        mu = Fraction(sum(ind), p)
        m2 = sum((Fraction(x) - mu) ** 2 for x in ind)
        print(f"  p={p:2d}: #pass={sum(ind)} (=(p-1)/2={(p-1)//2}), mean={mu} "
              f"(=(p-1)/(2p)), centred 2nd moment={m2} (=(p^2-1)/(4p)={Fraction(p*p-1, 4*p)})")
    qs = [3, 5, 7, 11]
    M = math.prod(qs)
    counts = [sum(1 for p in qs if euler_pass(p, r)) for r in range(M)]
    mean_q = Fraction(sum(counts), M)
    var_q = sum((Fraction(c) - mean_q) ** 2 for c in counts) / M
    pred_mean = sum(Fraction(p - 1, 2 * p) for p in qs)
    pred_var = sum(Fraction(p * p - 1, 4 * p * p) for p in qs)
    print(f"\n  over a full CRT period mod {M} (primes {qs}):")
    print(f"    mean of QR count     = {mean_q}  predicted sum (p-1)/(2p)    = {pred_mean}")
    print(f"    variance of QR count = {var_q}  predicted sum (p^2-1)/(4p^2) = {pred_var}")
    full_mean = sum((p - 1) / (2 * p) for p in ODD_PRIMES_TO_100)
    full_sd = math.sqrt(sum((p * p - 1) / (4 * p * p) for p in ODD_PRIMES_TO_100))
    print(f"  for the 24 odd primes <= 100: mean {full_mean:.4f}, sd {full_sd:.4f} "
          f"(fair-coin sd would be {math.sqrt(6):.4f})")


# ----------------------------------------------------------------------------
# 3. Factor blindness
# ----------------------------------------------------------------------------
def section_factor_blind() -> None:
    banner("3. Factor blindness: the residue dial cannot see the hidden factor")
    for p in [7, 11, 13, 97]:
        for n in [1, 2, p - 1]:
            sq = sum(1 for x in range(1, p) for y in range(p)
                     if (x * y) % p == n and euler_pass(p, x))
            nsq = sum(1 for x in range(p) for y in range(p)
                      if (x * y) % p == n and not euler_pass(p, x))
            print(f"  p={p:3d}, N = {n:3d} mod p: factor x residue: {sq:3d}, non-residue: {nsq:3d}"
                  f"   ((p-1)/2 = {(p-1)//2})")


# ----------------------------------------------------------------------------
# 4. Binomial bias-variance law
# ----------------------------------------------------------------------------
def section_binomial() -> None:
    banner("4. Binomial bias-variance law  E[(k/n - c)^2] = (theta-c)^2 + theta(1-theta)/n")
    for n, theta, c in [(60, Fraction(1, 5), Fraction(1, 4)), (10, Fraction(1, 3), Fraction(0)),
                        (60, Fraction(7, 20), Fraction(7, 20))]:
        lhs = sum((Fraction(k, n) - c) ** 2 * math.comb(n, k) * theta ** k * (1 - theta) ** (n - k)
                  for k in range(n + 1))
        rhs = (theta - c) ** 2 + theta * (1 - theta) / n
        print(f"  n={n}, theta={theta}, c={c}:  exact equality {lhs == rhs}  (value {float(lhs):.6f})")
    print(f"  sampling floor per N at n=60, theta=0.2: {0.2*0.8/60:.5f}  (sd {math.sqrt(0.2*0.8/60):.4f})")


# ----------------------------------------------------------------------------
# 5. Panel algebra on a synthetic panel
# ----------------------------------------------------------------------------
def panel_stats(y: list[list[int]], f: Callable[[int], float]) -> dict[str, float]:
    n = len(y[0])
    m = [sum(row) / n for row in y]
    grand = mean(m)
    ssw = sum((v - m[N]) ** 2 for N, row in enumerate(y) for v in row)
    rss = sum((v - f(N)) ** 2 for N, row in enumerate(y) for v in row)
    sst = sum((v - grand) ** 2 for row in y for v in row)
    gap = n * sum((m[N] - f(N)) ** 2 for N in range(len(y)))
    return {"SSW": ssw, "RSS": rss, "SST": sst, "gap": gap,
            "binary_floor": n * sum(x * (1 - x) for x in m)}


def section_panel() -> None:
    banner("5. Residual decomposition, ceiling theorem, R^2 = ceiling * rho^2")
    rng = random.Random(SEED)
    n, panel = 60, 400
    x: list[float] = []
    theta: list[float] = []
    for _ in range(panel):
        q = sum(1 for p in ODD_PRIMES_TO_100 if rng.random() < (p - 1) / (2 * p))
        z = -1.4 + 0.12 * (q - 11.5) + rng.gauss(0, 0.25)  # feature + hidden structure
        x.append(float(q))
        theta.append(1 / (1 + math.exp(-z)))
    y = [[1 if rng.random() < t else 0 for _ in range(n)] for t in theta]
    m = [sum(r) / n for r in y]
    b = scov(x, m) / scov(x, x)
    a = mean(m) - b * mean(x)
    st = panel_stats(y, lambda N: a + b * x[N])
    print(f"  RSS = {st['RSS']:.6f};  SSW + n*sum(m-f)^2 = {st['SSW'] + st['gap']:.6f}")
    print(f"  SSW = {st['SSW']:.6f};  binary floor n*sum m(1-m) = {st['binary_floor']:.6f}")
    ceiling = 1 - st["SSW"] / st["SST"]
    r2 = 1 - st["RSS"] / st["SST"]
    rho2 = scov(x, m) ** 2 / (scov(x, x) * scov(m, m))
    print(f"  ceiling 1 - SSW/SST = {ceiling:.4f}")
    print(f"  one-feature R^2     = {r2:.4f}")
    print(f"  ceiling * rho^2     = {ceiling * rho2:.4f}   (rho^2 = {rho2:.4f})")
    st_oracle = panel_stats(y, lambda N: m[N])
    print(f"  oracle predictor f = per-N means: R^2 = {1 - st_oracle['RSS']/st['SST']:.4f} (= ceiling)")
    print(f"  residual / within-N floor ratio kappa = {st['RSS']/st['SSW']:.4f}")
    rng2 = random.Random(SEED + 1)
    worst = max(1 - panel_stats(y, lambda N, c=[rng2.gauss(0.2, 0.1) for _ in range(panel)]: c[N])["RSS"]
                / st["SST"] for _ in range(50))
    print(f"  best R^2 among 50 random per-N predictors: {worst:.4f}  (never above ceiling)")
    # rate level: per-N observed rates versus the binomial floor
    tot = scov(m, m)
    floor = sum(v * (1 - v) / (n - 1) for v in m)  # unbiased estimate of sum theta(1-theta)/n
    ceil_rate = 1 - floor / tot
    rho2_true = scov(x, theta) ** 2 / (scov(x, x) * scov(theta, theta))
    print("  --- the same panel at the level of per-N rates ---")
    print(f"  rate-level R^2 of the line = rho^2(x, m) = {rho2:.4f}")
    print(f"  rate-level ceiling 1 - floor/total       = {ceil_rate:.4f}")
    print(f"  fraction of ceiling {rho2 / ceil_rate:.3f}  vs  rho^2(x, true rate) = {rho2_true:.3f}")


# ----------------------------------------------------------------------------
# 6. Ceiling growth law
# ----------------------------------------------------------------------------
def ceiling(V: float, E: float, n: int) -> float:
    return V / (V + E / n)


def section_ceiling() -> None:
    banner("6. The ceiling V/(V + E/n) grows with values per N")
    for c60 in [0.45, 0.31]:
        r = c60 / (1 - c60) / 60  # V/E implied by ceiling(60)
        V, E = r, 1.0
        row = ", ".join(f"n={n}: {ceiling(V, E, n):.3f}" for n in [15, 30, 60, 120, 240, 960])
        print(f"  ceiling(60) = {c60}:  {row}")


# ----------------------------------------------------------------------------
# 7. Arithmetic of the reported numbers
# ----------------------------------------------------------------------------
def section_reported() -> None:
    banner("7. Fraction of ceiling and the consistency of the reported triples")
    for u, r2, c in [(2.5, 0.2998, 0.45), (3.5, 0.2246, 0.31)]:
        kappa = (1 - r2) / (1 - c)
        print(f"  u={u}: R^2/ceiling = {r2/c:.4f};  implied kappa = (1-R^2)/(1-ceiling) = {kappa:.4f}")
    print(f"  u=2.5 with kappa <= 1.24 forces ceiling <= {1 - 0.7002/1.24:.4f} < 0.436  -> mild tension")
    print("  u=3.5: implied kappa in (1.12, 1.13) lies inside the reported band 1.12-1.24 -> consistent")
    for T, F, k in [(1.0, 0.55, 1.12), (1.0, 0.69, 1.12), (1.0, 0.55, 1.24)]:
        frac = 1 - (k - 1) * F / (T - F)
        print(f"  fraction-of-ceiling law: T={T}, F={F}, kappa={k} -> {frac:.4f}")


# ----------------------------------------------------------------------------
# 8. Miniature smoothness experiment
# ----------------------------------------------------------------------------
def random_prime(bits: int, rng: random.Random) -> int:
    while True:
        c = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        if all(pow(a, c - 1, c) == 1 for a in (2, 3, 5, 7, 11, 13)):
            return c


def section_experiment() -> None:
    banner("8. Mini-experiment: smoothness of j^2 - N predicted by the QR count")
    rng = random.Random(SEED)
    n, panel, M = 60, 300, 1 << 10
    Ns = [random_prime(16, rng) * random_prime(16, rng) for _ in range(panel)]
    typical = 2 * math.isqrt(Ns[0]) * (M // 2)
    B = int(round(typical ** (1 / 2.5)))
    fb = primes_upto(B)
    print(f"  {panel} semiprimes of ~32 bits, {n} sieve values each, B = {B} (u ~ 2.5)")
    y: list[list[int]] = []
    for N in Ns:
        r = math.isqrt(N) + 1
        y.append([1 if is_smooth((r + rng.randrange(M)) ** 2 - N, fb) else 0 for _ in range(n)])
    x = [float(qr_count(N)) for N in Ns]
    m = [sum(r) / n for r in y]
    half = panel // 2
    b = scov(x[:half], m[:half]) / scov(x[:half], x[:half])
    a = mean(m[:half]) - b * mean(x[:half])
    pred = [a + b * v for v in x]
    test = range(half, panel)
    mt = [m[i] for i in test]
    pt = [pred[i] for i in test]
    sst = sum((v - mean(mt)) ** 2 for v in mt)
    r2 = 1 - sum((mt[i] - pt[i]) ** 2 for i in range(len(mt))) / sst
    slope = scov(pt, mt) / scov(pt, pt)
    floor = sum(v * (1 - v) / n for v in mt)
    ceil = 1 - floor / sst
    kappa = sum((mt[i] - pt[i]) ** 2 for i in range(len(mt))) / floor
    print(f"  mean smooth rate {mean(m):.3f}; fitted slope per extra QR prime {b:.4f}")
    print(f"  held-out per-N R^2 = {r2:.3f}, calibration slope = {slope:.3f}")
    print(f"  held-out ceiling (1 - binomial floor / total) ~ {ceil:.3f}; fraction {r2/ceil:.2f}")
    print(f"  residual / binomial floor kappa ~ {kappa:.2f}")
    print("  (illustrative only: a small panel, not the reported experiment)")


def main() -> None:
    section_euler()
    section_moments()
    section_factor_blind()
    section_binomial()
    section_panel()
    section_ceiling()
    section_reported()
    section_experiment()


if __name__ == "__main__":
    main()
