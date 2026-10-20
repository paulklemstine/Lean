#!/usr/bin/env python3
"""
Closing the Number Field Sieve channels: numerical companion.

Pure standard-library Python (no numpy needed).  Each section illustrates one
theorem of the paper "Constant Factors, Truncated Counters and Honest Slopes".

  1. The L-exponent of L[alpha, c] is c, and constant / bounded factors do not move it.
  2. A genuine improvement c' < c gives a superpolynomial cost ratio.
  3. Rank-nullity over GF(2): nullity >= excess, and a counter capped at 60 saturates.
  4. The two-point slopes 1.242 vs 1.819: no inversion.
  5. Base-m polynomial selection and the homogeneous norm bound.
  6. The degree balance d*u + x/d >= 2*sqrt(u*x).
"""
from __future__ import annotations

import math
import random
from typing import List, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. L-functions and the L-exponent
# ---------------------------------------------------------------------------

def log_L(alpha: float, c: float, x: float) -> float:
    """log L[alpha, c](x) = c * x^alpha * (log x)^(1 - alpha), with x = log N."""
    return c * x ** alpha * math.log(x) ** (1.0 - alpha)


def L_scale(alpha: float, x: float) -> float:
    """The L-scale x^alpha (log x)^(1-alpha)."""
    return x ** alpha * math.log(x) ** (1.0 - alpha)


def empirical_L_constant(log_cost: float, alpha: float, x: float) -> float:
    """The quotient log(cost) / L-scale whose limit defines the L-constant."""
    return log_cost / L_scale(alpha, x)


def section_L_exponent() -> None:
    print("=" * 76)
    print("1. Constant and bounded factors are invisible to the L-exponent")
    print("=" * 76)
    alpha = 1.0 / 3.0
    c = (64.0 / 9.0) ** (1.0 / 3.0)
    print(f"GNFS constant c = (64/9)^(1/3) = {c:.6f}")
    rng = random.Random(44)
    print(f"{'bits':>8} {'x=ln N':>10} {'f=L':>10} {'f=1000*L':>10} "
          f"{'f=0.001*L':>10} {'f=g*L, g in [0.98,1.006]':>26}")
    for bits in [512, 1024, 4096, 2 ** 16, 2 ** 20, 2 ** 30, 2 ** 40]:
        x = bits * math.log(2.0)
        base = log_L(alpha, c, x)
        g = rng.uniform(0.9932 - 0.0122, 0.9932 + 0.0122)  # a measured "ratio" with error bar
        row = [empirical_L_constant(base + math.log(K), alpha, x) for K in (1.0, 1000.0, 0.001)]
        row.append(empirical_L_constant(base + math.log(g), alpha, x))
        print(f"{bits:>8} {x:>10.1f} " + " ".join(f"{v:>10.5f}" for v in row[:3])
              + f" {row[3]:>26.5f}")
    print("All columns converge to the same constant: the factor is L-invisible.\n")


# ---------------------------------------------------------------------------
# 2. Genuine L-gains are superpolynomial
# ---------------------------------------------------------------------------

def section_superpoly() -> None:
    print("=" * 76)
    print("2. A genuine constant improvement c' < c beats every polynomial")
    print("=" * 76)
    alpha = 1.0 / 3.0
    c = (64.0 / 9.0) ** (1.0 / 3.0)
    c2 = 1.902  # an illustrative smaller constant
    print(f"c = {c:.4f}, c' = {c2:.4f}; ratio L[c]/L[c'] = L[c - c'] = exp((c-c') * scale)")
    print(f"{'bits':>12} {'log10 ratio':>14} {'log10 (ratio / x^3)':>22}")
    for bits in [10 ** 3, 10 ** 5, 10 ** 7, 10 ** 9, 10 ** 11, 10 ** 13]:
        x = bits * math.log(2.0)
        lr = (c - c2) * L_scale(alpha, x)
        print(f"{bits:>12} {lr / math.log(10):>14.3f} {(lr - 3 * math.log(x)) / math.log(10):>22.3f}")
    print("Eventually the ratio exceeds x^3 (and any x^d): no constant K can emulate it.\n")


# ---------------------------------------------------------------------------
# 3. GF(2) rank-nullity and the truncated counter
# ---------------------------------------------------------------------------

def gf2_rank(rows: List[int], ncols: int) -> int:
    """Rank over GF(2) of a matrix whose rows are encoded as integer bitmasks."""
    pivots: dict[int, int] = {}
    rank = 0
    for r in rows:
        v = r
        for bit in range(ncols - 1, -1, -1):
            if not (v >> bit) & 1:
                continue
            if bit in pivots:
                v ^= pivots[bit]
            else:
                pivots[bit] = v
                rank += 1
                break
    return rank


def random_sparse_relation_matrix(r: int, c: int, w: int, rng: random.Random) -> List[int]:
    """r rows, c columns, each row with w random ones (exponent vectors mod 2)."""
    rows: List[int] = []
    for _ in range(r):
        mask = 0
        for col in rng.sample(range(c), w):
            mask |= 1 << col
        rows.append(mask)
    return rows


def truncate(k: int, n: int) -> int:
    """A counter that stops after k items."""
    return min(k, n)


def section_truncation() -> None:
    print("=" * 76)
    print("3. Rank-nullity over GF(2) and the counter that stops at 60")
    print("=" * 76)
    rng = random.Random(2026)
    c = 200
    print(f"{'rows r':>7} {'cols c':>7} {'excess':>7} {'nullity':>8} "
          f"{'trunc60(nullity)':>17} {'trunc60(2^null - 1)':>20}")
    for excess in [0, 3, 6, 20, 59, 60, 61, 80, 150]:
        r = c + excess
        M = random_sparse_relation_matrix(r, c, 12, rng)
        nullity = r - gf2_rank(M, c)
        assert nullity >= excess, "rank-nullity violated?!"
        vec_count = 2 ** nullity - 1
        print(f"{r:>7} {c:>7} {excess:>7} {nullity:>8} {truncate(60, nullity):>17} "
              f"{truncate(60, vec_count):>20}")
    print("nullity >= excess always.  Once excess >= 60 the capped reading is the constant 60;")
    print("if nonzero dependency VECTORS are counted, the cap bites already at excess 6 (2^6-1=63).\n")


# ---------------------------------------------------------------------------
# 4. Slopes: no inversion
# ---------------------------------------------------------------------------

def loglog_slope(W1: float, W2: float, S1: float, S2: float) -> float:
    """Two-point log-log slope estimator."""
    return math.log(S2 / S1) / math.log(W2 / W1)


def section_slopes() -> None:
    print("=" * 76)
    print("4. Surplus slope 1.242 versus width-cost slope 1.819: no inversion")
    print("=" * 76)
    s = math.log(7.94) / math.log(5.30)
    t = 1.819
    print(f"surplus slope s = log 7.94 / log 5.30 = {s:.6f}")
    print(f"integer certificates: 7.94^4 = {7.94 ** 4:.2f} < 5.3^5 = {5.3 ** 5:.2f}  (s < 5/4)")
    print(f"                      5.3^6 = {5.3 ** 6:.2f} < 7.94^5 = {7.94 ** 5:.2f} (s > 6/5)")
    print(f"exact power law check: slope of 3*W^1.5 between W=2,9 -> "
          f"{loglog_slope(2, 9, 3 * 2 ** 1.5, 3 * 9 ** 1.5):.6f}")
    a, b = 5.0, 1.0
    print(f"{'W':>8} {'surplus a W^s':>15} {'cost b W^t':>14} {'ratio':>10}")
    for W in [1, 2, 5, 10, 30, 100, 1000, 10 ** 5]:
        S, C = a * W ** s, b * W ** t
        print(f"{W:>8} {S:>15.2f} {C:>14.2f} {S / C:>10.5f}")
    crossing = (a / b) ** (1.0 / (t - s))
    print(f"cost overtakes surplus at W = (a/b)^(1/(t-s)) = {crossing:.2f} and never falls back.\n")


# ---------------------------------------------------------------------------
# 5. Base-m selection and the norm bound
# ---------------------------------------------------------------------------

def integer_root(N: int, d: int) -> int:
    """floor(N^(1/d)) computed exactly."""
    m = int(round(N ** (1.0 / d)))
    while m ** d > N:
        m -= 1
    while (m + 1) ** d <= N:
        m += 1
    return m


def base_m_digits(N: int, m: int) -> List[int]:
    """Base-m digits of N, least significant first."""
    out: List[int] = []
    while N:
        N, rem = divmod(N, m)
        out.append(rem)
    return out


def homogeneous_norm(coeffs: Sequence[int], a: int, b: int) -> int:
    """F(a, b) = sum c_i a^i b^(d-i)."""
    d = len(coeffs) - 1
    return sum(ci * a ** i * b ** (d - i) for i, ci in enumerate(coeffs))


def section_base_m() -> None:
    print("=" * 76)
    print("5. Base-m polynomial selection and the norm bound |F(a,b)| <= (d+1) M U^d")
    print("=" * 76)
    N = 1000000016000000063  # = 1000000007 * 1000000009
    for d in [3, 4, 5]:
        m = integer_root(N, d)
        assert m ** d <= N < m ** (d + 1)
        f = base_m_digits(N, m)
        assert sum(ci * m ** i for i, ci in enumerate(f)) == N
        assert len(f) - 1 == d and all(ci < m for ci in f)
        print(f"d={d}: m={m}, coefficients (const first) = {f}")
        M = max(f)
        U = 1000
        rng = random.Random(d)
        worst = 0
        for _ in range(2000):
            a, b = rng.randint(-U, U), rng.randint(-U, U)
            worst = max(worst, abs(homogeneous_norm(f, a, b)))
        bound = (d + 1) * M * U ** d
        print(f"      largest sampled |F(a,b)| = {worst:.3e} <= bound {bound:.3e}")
    print()


# ---------------------------------------------------------------------------
# 6. Degree balance
# ---------------------------------------------------------------------------

def section_degree_balance() -> None:
    print("=" * 76)
    print("6. Degree balance: d*u + x/d >= 2 sqrt(u x), equality iff d = sqrt(x/u)")
    print("=" * 76)
    u, x = 20.0, 700.0
    dstar = math.sqrt(x / u)
    print(f"u = {u}, x = {x}; optimum d* = {dstar:.4f}, minimum 2 sqrt(ux) = {2 * math.sqrt(u * x):.4f}")
    for d in [2, 3, 4, 5, 5.9161, 6, 7, 8]:
        val = d * u + x / d
        print(f"  d = {d:>6}: d*u + x/d = {val:9.4f}   gap = {val - 2 * math.sqrt(u * x):8.4f}")
    best_int = min(range(1, 50), key=lambda k: k * u + x / k)
    print(f"best integer degree = {best_int}; (bounding this integer-rounding gap in general is an open problem).\n")


def main() -> None:
    section_L_exponent()
    section_superpoly()
    section_truncation()
    section_slopes()
    section_base_m()
    section_degree_balance()


if __name__ == "__main__":
    main()
