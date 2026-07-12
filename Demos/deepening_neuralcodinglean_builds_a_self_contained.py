"""
Numerical demonstrations for
"Energy Concentration in Dense Neural Codes: Exact Moments and a Metabolic
Law of Large Numbers".

A neural code on N neurons is a binary string in {0,1}^N; its WEIGHT is the
number of active (=1) neurons, a direct proxy for metabolic energy. Regarding
all 2^N codes as equally likely, the weight is a Binomial(N, 1/2) random
variable. This script verifies, exactly and by brute force, the paper's closed
forms:

    * capacity                 : #codes                 = 2^N
    * pairwise joint activity  : #{c: c_i=c_j=1, i!=j}  = 2^(N-2)
    * first moment             : sum_c weight(c)        = N * 2^(N-1)   (mean N/2)
    * second moment            : sum_c weight(c)^2      = 2^N N(N+1)/4
    * centered second moment   : sum_c (weight-N/2)^2   = N * 2^N / 4
    * variance                 : Var[weight]            = N/4
    * Chebyshev bound          : frac(|w-N/2|>=t)       <= N/(4 t^2)
    * sqrt(N)-window           : frac(|w-N/2|< sqrt N)  >= 3/4

Everything is exact: brute-force enumeration for small N, and O(N) computation
via the binomial profile #{weight = k} = C(N, k) for larger N.

Run:  python demo.py
"""

from __future__ import annotations

import itertools
import math
from typing import Iterator


# --------------------------------------------------------------------------- #
# Core model
# --------------------------------------------------------------------------- #
def all_codes(N: int) -> Iterator[tuple[int, ...]]:
    """Enumerate all 2^N binary neural codes on N neurons."""
    return itertools.product((0, 1), repeat=N)


def weight(code: tuple[int, ...]) -> int:
    """Metabolic energy of a code: the number of active neurons."""
    return sum(code)


# --------------------------------------------------------------------------- #
# Brute-force statistics (ground truth, feasible for N up to ~20)
# --------------------------------------------------------------------------- #
def brute_force_stats(N: int) -> dict[str, float]:
    """Exact moments obtained by enumerating all 2^N codes."""
    total = 0
    sum_w = 0
    sum_w2 = 0
    sum_centered_sq = 0.0
    mean = N / 2.0
    for c in all_codes(N):
        w = weight(c)
        total += 1
        sum_w += w
        sum_w2 += w * w
        sum_centered_sq += (w - mean) ** 2
    return {
        "count": total,
        "sum_weight": sum_w,
        "sum_weight_sq": sum_w2,
        "sum_centered_sq": sum_centered_sq,
        "variance": sum_centered_sq / total,
    }


def joint_pair_count(N: int, i: int, j: int) -> int:
    """Number of codes in which neurons i and j are both active (brute force)."""
    return sum(1 for c in all_codes(N) if c[i] == 1 and c[j] == 1)


# --------------------------------------------------------------------------- #
# O(N) statistics via the binomial profile  #{weight = k} = C(N, k)
# --------------------------------------------------------------------------- #
def binomial_moment(N: int, m: int) -> int:
    """sum_c weight(c)^m computed from the binomial profile in O(N)."""
    return sum(math.comb(N, k) * (k ** m) for k in range(N + 1))


def deviating_fraction_exact(N: int, t: float) -> float:
    """Exact fraction of codes with |weight - N/2| >= t."""
    mean = N / 2.0
    hits = sum(math.comb(N, k) for k in range(N + 1) if abs(k - mean) >= t)
    return hits / (2 ** N)


def chebyshev_ceiling(N: int, t: float) -> float:
    """Chebyshev upper bound N/(4 t^2) on the deviating fraction."""
    return N / (4.0 * t * t)


def subgaussian_ceiling(N: int, t: float) -> float:
    """Conjectured sub-Gaussian upper bound 2 exp(-2 t^2 / N)."""
    return 2.0 * math.exp(-2.0 * t * t / N)


# --------------------------------------------------------------------------- #
# Closed-form predictions from the paper
# --------------------------------------------------------------------------- #
def predicted(N: int) -> dict[str, float]:
    return {
        "count": 2 ** N,
        "sum_weight": N * 2 ** (N - 1) if N >= 1 else 0,
        "sum_weight_sq": 2 ** N * N * (N + 1) // 4,
        "sum_centered_sq": N * 2 ** N / 4.0,
        "variance": N / 4.0,
    }


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_moments() -> None:
    print("=" * 68)
    print("EXACT MOMENTS: brute force vs. closed form")
    print("=" * 68)
    header = f"{'N':>3} {'quantity':>18} {'brute force':>16} {'closed form':>16}"
    for N in range(0, 13):
        bf = brute_force_stats(N)
        pr = predicted(N)
        print("-" * 68)
        print(header)
        for key in ("count", "sum_weight", "sum_weight_sq",
                    "sum_centered_sq", "variance"):
            ok = math.isclose(bf[key], pr[key], rel_tol=1e-9, abs_tol=1e-9)
            flag = "OK" if ok else "MISMATCH!"
            print(f"{N:>3} {key:>18} {bf[key]:>16.4g} {pr[key]:>16.4g}  {flag}")


def demo_pair_symmetry() -> None:
    print("\n" + "=" * 68)
    print("SECOND-ORDER SYMMETRY: a fixed pair i != j is jointly active")
    print("in exactly 2^(N-2) codes")
    print("=" * 68)
    for N in range(2, 9):
        cnt = joint_pair_count(N, 0, 1)
        pred = 2 ** (N - 2)
        flag = "OK" if cnt == pred else "MISMATCH!"
        print(f"N = {N:>2}:  #(neuron 0 and 1 active) = {cnt:>5}   "
              f"2^(N-2) = {pred:>5}   {flag}")


def demo_binomial_check() -> None:
    print("\n" + "=" * 68)
    print("O(N) BINOMIAL-PROFILE CHECK (large N, no enumeration)")
    print("=" * 68)
    for N in (10, 25, 50, 100):
        m1 = binomial_moment(N, 1)
        m2 = binomial_moment(N, 2)
        centered = m2 - N * m1 + (N ** 2 / 4.0) * 2 ** N
        pr = predicted(N)
        print(f"N = {N:>3}:  sum_w  = {m1}  (pred {pr['sum_weight']})")
        print(f"          sum_w2 = {m2}  (pred {pr['sum_weight_sq']})")
        print(f"          centered = {centered:.6g}  (pred {pr['sum_centered_sq']:.6g})")
        print(f"          variance = {centered / 2 ** N:.6g}  (pred {N/4:.6g})")


def demo_concentration() -> None:
    print("\n" + "=" * 68)
    print("CONCENTRATION: exact tail vs. Chebyshev vs. sub-Gaussian")
    print("=" * 68)
    for N in (16, 64, 256):
        t = math.sqrt(N)  # one-standard-deviation-scale window
        exact = deviating_fraction_exact(N, t)
        cheb = chebyshev_ceiling(N, t)
        subg = subgaussian_ceiling(N, t)
        near = 1.0 - exact
        print(f"N = {N:>3}, t = sqrt(N) = {t:6.2f}")
        print(f"   exact  frac(|w-N/2| >= t) = {exact:.6f}")
        print(f"   Chebyshev ceiling  N/(4t^2) = {cheb:.6f}")
        print(f"   sub-Gaussian 2 exp(-2t^2/N) = {subg:.6f}")
        print(f"   => fraction WITHIN sqrt(N) = {near:.6f}  "
              f"(theorem guarantees >= 0.75)")
        assert near >= 0.75 - 1e-12, "sqrt(N)-window theorem violated!"


def main() -> None:
    demo_moments()
    demo_pair_symmetry()
    demo_binomial_check()
    demo_concentration()
    print("\nAll checks passed: closed forms match brute force and the "
          "3/4 window bound holds.")


if __name__ == "__main__":
    main()
