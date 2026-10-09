#!/usr/bin/env python3
"""
Per-N sieve-yield dial: numerical companion.

Demonstrates, with exact integer arithmetic wherever possible:

  1. Root-count law: for an odd prime p, the congruence x^2 = N (mod p) has
     exactly 1 + (N/p) solutions in one period, and the Euler test
     "p does not divide N and N^((p-1)/2) = 1 (mod p)" is exactly (N/p) = 1.
  2. Shape theorem: total root mass over a set S of odd primes equals
     2*QR_S(N) + #{p in S : p | N}.
  3. Periodicity / weighted yield: hits of x^2 - N in [0, L*p) equal L*roots.
  4. Level theorem: in a complete residue system mod p exactly (p-1)/2 values
     of N pass; the population-mean feature is sum_p ((p-1)/2)/p, in [8, 12)
     for the 24 odd primes up to 100, and the mean dial is in [0.08898, 0.13522).
  5. The adopted dial rate(q) = -7/2000 + (289/25000) q: positive iff q >= 1,
     at most 13697/50000, and negative on the semiprime 163520117 = 2027*80671.
  6. Transfer law on synthetic data:
        R2_transfer(b) = corr^2 - (b - beta_hat)^2 * Sxx / Syy,
     and the impossibility of an in-sample pair (0.2719, 0.2717).
  7. Pure-error floor: every feature-only predictor has SSE >= pure error.

Only the Python standard library is used.  The synthetic data in sections 6-7
are illustrative and are NOT the experimental populations.
"""
from __future__ import annotations

import math
import random
from fractions import Fraction
from typing import Callable, Dict, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Number theory
# ---------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


ODD_PRIMES_LE_100: List[int] = [p for p in range(3, 101) if is_prime(p)]


def legendre(n: int, p: int) -> int:
    """Legendre symbol (n/p) for an odd prime p, via Euler's criterion."""
    r = pow(n % p, (p - 1) // 2, p)
    if r == 0:
        return 0
    return 1 if r == 1 else -1


def euler_pass(p: int, n: int) -> bool:
    """The Euler test: p does not divide n and n^((p-1)/2) = 1 (mod p)."""
    return n % p != 0 and pow(n, p // 2, p) == 1


def qs_roots(p: int, n: int) -> int:
    """Number of r in [0, p) with p | r^2 - n (brute force)."""
    return sum(1 for r in range(p) if (r * r - n) % p == 0)


def qr_feature(primes: Sequence[int], n: int) -> int:
    return sum(1 for p in primes if euler_pass(p, n))


def dial(q: int) -> Fraction:
    return Fraction(-7, 2000) + Fraction(289, 25000) * q


# ---------------------------------------------------------------------------
# Regression algebra
# ---------------------------------------------------------------------------

def mean(v: Sequence[float]) -> float:
    return sum(v) / len(v)


def centered_ss(u: Sequence[float], v: Sequence[float]) -> float:
    mu, mv = mean(u), mean(v)
    return sum((a - mu) * (b - mv) for a, b in zip(u, v))


def sse(x: Sequence[float], y: Sequence[float], a: float, b: float) -> float:
    return sum((yi - (a + b * xi)) ** 2 for xi, yi in zip(x, y))


def r2_affine(x: Sequence[float], y: Sequence[float], a: float, b: float) -> float:
    return 1.0 - sse(x, y, a, b) / centered_ss(y, y)


def transfer_r2(x: Sequence[float], y: Sequence[float], b: float) -> float:
    """Slope b transferred, level refit to the target means."""
    a = mean(y) - b * mean(x)
    return r2_affine(x, y, a, b)


def corr_sq(x: Sequence[float], y: Sequence[float]) -> float:
    return centered_ss(x, y) ** 2 / (centered_ss(x, x) * centered_ss(y, y))


def ols_slope(x: Sequence[float], y: Sequence[float]) -> float:
    return centered_ss(x, y) / centered_ss(x, x)


def pure_error(x: Sequence[float], y: Sequence[float]) -> float:
    groups: Dict[float, List[float]] = {}
    for xi, yi in zip(x, y):
        groups.setdefault(xi, []).append(yi)
    gm = {k: mean(v) for k, v in groups.items()}
    return sum((yi - gm[xi]) ** 2 for xi, yi in zip(x, y))


def feature_sse(x: Sequence[float], y: Sequence[float], g: Callable[[float], float]) -> float:
    return sum((yi - g(xi)) ** 2 for xi, yi in zip(x, y))


# ---------------------------------------------------------------------------
# Sections
# ---------------------------------------------------------------------------

def section_root_law() -> None:
    print("=" * 72)
    print("1-2. Root-count law, Euler test, and the shape theorem")
    print("=" * 72)
    rng = random.Random(20260827)
    checked = 0
    for _ in range(300):
        n = rng.randrange(1, 10 ** 9)
        for p in ODD_PRIMES_LE_100:
            assert qs_roots(p, n) == 1 + legendre(n, p)
            assert euler_pass(p, n) == (legendre(n, p) == 1)
            assert qs_roots(p, n) == 2 * euler_pass(p, n) + (n % p == 0)
            checked += 1
        mass = sum(qs_roots(p, n) for p in ODD_PRIMES_LE_100)
        divs = sum(1 for p in ODD_PRIMES_LE_100 if n % p == 0)
        assert mass == 2 * qr_feature(ODD_PRIMES_LE_100, n) + divs
    print(f"  root law / Euler test / split checked on {checked} (N, p) pairs: OK")
    n = 1_000_003 * 999_983
    print(f"  example N = {n}")
    row = []
    for p in ODD_PRIMES_LE_100[:10]:
        row.append(f"p={p}:({legendre(n, p):+d})->{qs_roots(p, n)}")
    print("   ", "  ".join(row), "...")
    q = qr_feature(ODD_PRIMES_LE_100, n)
    mass = sum(qs_roots(p, n) for p in ODD_PRIMES_LE_100)
    divs = sum(1 for p in ODD_PRIMES_LE_100 if n % p == 0)
    print(f"  QR(<=100) = {q}, root mass = {mass} = 2*{q} + {divs}")


def section_periodicity() -> None:
    print("=" * 72)
    print("3. Periodicity and the weighted sieve yield")
    print("=" * 72)
    n = 123_456_789
    for p in [3, 7, 31, 97]:
        for L in [1, 5, 40]:
            hits = sum(1 for x in range(L * p) if (x * x - n) % p == 0)
            assert hits == L * qs_roots(p, n)
    S = [3, 5, 7, 11, 13]
    M = 3 * 5 * 7 * 11 * 13
    lhs = sum(sum(1 for x in range(M) if (x * x - n) % p == 0) for p in S)
    rhs = sum((M // p) * (2 * euler_pass(p, n) + (n % p == 0)) for p in S)
    print(f"  hits on [0, L*p) = L * roots: OK;  weighted yield over M={M}: {lhs} = {rhs}")
    assert lhs == rhs


def section_level() -> None:
    print("=" * 72)
    print("4. Level theorem: the population mean is fixed by the population")
    print("=" * 72)
    for p in ODD_PRIMES_LE_100:
        assert sum(1 for n in range(p) if euler_pass(p, n)) == (p - 1) // 2
    print("  exactly (p-1)/2 residues pass the Euler test mod every odd p <= 100: OK")
    S = [3, 5, 7, 11]
    M = 3 * 5 * 7 * 11
    total = sum(qr_feature(S, n) for n in range(M))
    exact = sum(Fraction((p - 1) // 2, p) for p in S)
    assert Fraction(total, M) == exact
    print(f"  S={S}, M={M}: mean QR = {Fraction(total, M)} = sum((p-1)/2p) = {exact}")
    mu = sum(Fraction((p - 1) // 2, p) for p in ODD_PRIMES_LE_100)
    print(f"  24 odd primes <= 100: population mean feature = {float(mu):.6f}"
          f"  (theorem: in [8, 12))")
    md = dial(0) + Fraction(289, 25000) * mu
    print(f"  population mean dial = {float(md):.6f}  (theorem: in [0.08898, 0.13522))")
    assert 8 <= mu < 12 and Fraction(4449, 50000) <= md < Fraction(6761, 50000)


def section_dial() -> None:
    print("=" * 72)
    print("5. The adopted dial: range and a negative witness")
    print("=" * 72)
    assert all((dial(q) > 0) == (q >= 1) for q in range(0, 25))
    assert dial(24) == Fraction(13697, 50000)
    print(f"  dial(q) > 0 iff q >= 1; max dial(24) = {dial(24)} = {float(dial(24))}")
    n = 163_520_117
    assert n == 2027 * 80671 and is_prime(2027) and is_prime(80671)
    q = qr_feature(ODD_PRIMES_LE_100, n)
    mass = sum(qs_roots(p, n) for p in ODD_PRIMES_LE_100)
    print(f"  N = {n} = 2027 * 80671: QR(<=100) = {q}, root mass = {mass},"
          f" dial = {dial(q)} = {float(dial(q))} < 0")
    assert q == 0 and mass == 0 and dial(q) < 0


def synthetic_population(rng: random.Random, size: int, level: float,
                         slope: float, noise: float) -> Tuple[List[float], List[float]]:
    xs: List[float] = []
    ys: List[float] = []
    for _ in range(size):
        q = float(sum(1 for _ in range(24) if rng.random() < 0.47))
        xs.append(q)
        ys.append(level + slope * q + rng.gauss(0.0, noise))
    return xs, ys


def section_transfer() -> None:
    print("=" * 72)
    print("6. Shape transfer vs level refit (synthetic populations)")
    print("=" * 72)
    rng = random.Random(20260827)
    xs_src, ys_src = synthetic_population(rng, 400, 0.010, 0.0116, 0.03)
    xs_tgt, ys_tgt = synthetic_population(rng, 400, -0.004, 0.0116, 0.03)
    b_src = ols_slope(xs_src, ys_src)
    beta = ols_slope(xs_tgt, ys_tgt)
    c2 = corr_sq(xs_tgt, ys_tgt)
    sxx, syy = centered_ss(xs_tgt, xs_tgt), centered_ss(ys_tgt, ys_tgt)
    print(f"  source slope b = {b_src:.5f}, target OLS slope = {beta:.5f}")
    print(f"  target corr^2 = {c2:.5f}")
    for b in [b_src, beta, 0.5 * beta, 1.5 * beta]:
        lhs = transfer_r2(xs_tgt, ys_tgt, b)
        rhs = c2 - (b - beta) ** 2 * sxx / syy
        assert abs(lhs - rhs) < 1e-9 and lhs <= c2 + 1e-12
        print(f"   b = {b:.5f}: transfer R^2 = {lhs:.5f}   law gives {rhs:.5f}")
    a_src = mean(ys_src) - b_src * mean(xs_src)
    print(f"  without level refit (source intercept): R^2 = "
          f"{r2_affine(xs_tgt, ys_tgt, a_src, b_src):.5f}  -> level must track population")
    # critic theorem: no in-sample affine R^2 can exceed corr^2
    worst = max(r2_affine(xs_tgt, ys_tgt, rng.uniform(-0.05, 0.05), rng.uniform(0, 0.03))
                for _ in range(20000))
    print(f"  max affine R^2 over 20000 random (a, b): {worst:.5f} <= corr^2 = {c2:.5f}")
    print("  => an in-sample pair (R^2 ~ 0.2719, corr^2 ~ 0.2717) is impossible:"
          " 0.27185 > 0.27175.")


def section_floor() -> None:
    print("=" * 72)
    print("7. Pure-error floor for feature-only predictors (synthetic)")
    print("=" * 72)
    rng = random.Random(7)
    xs, ys = synthetic_population(rng, 600, -0.0035, 0.01156, 0.02)
    # add a nonlinearity the affine dial cannot see
    ys = [y + 0.0004 * (x - 11) ** 2 for x, y in zip(xs, ys)]
    pe = pure_error(xs, ys)
    b = ols_slope(xs, ys)
    a = mean(ys) - b * mean(xs)
    fit = sse(xs, ys, a, b)
    adopted = sse(xs, ys, -0.0035, 0.01156)
    groups: Dict[float, List[float]] = {}
    for x, y in zip(xs, ys):
        groups.setdefault(x, []).append(y)
    gm = {k: mean(v) for k, v in groups.items()}
    best = feature_sse(xs, ys, lambda v: gm[v])
    print(f"  pure error floor     = {pe:.6f}")
    print(f"  group-mean predictor = {best:.6f}   (attains the floor)")
    print(f"  OLS affine refit     = {fit:.6f}   ratio {fit / pe:.3f}x")
    print(f"  adopted affine dial  = {adopted:.6f}   ratio {adopted / pe:.3f}x")
    print(f"  constant predictor   = {centered_ss(ys, ys):.6f}   (total spread)")
    assert abs(best - pe) < 1e-12 and pe <= fit <= adopted and pe <= centered_ss(ys, ys)


def main() -> None:
    section_root_law()
    section_periodicity()
    section_level()
    section_dial()
    section_transfer()
    section_floor()
    print("All checks passed.")


if __name__ == "__main__":
    main()
