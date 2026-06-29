"""
Shannon Entropy on Finite Probability Distributions — Numerical Demonstrations
==============================================================================

This self-contained script demonstrates the four cornerstone theorems of the
formalization, all expressed through the *surprise function* s(x) = -x*log(x)
with the convention s(0) = 0:

    1. entropy_nonneg     :  H(p) >= 0                       (Theorem 3.1)
    2. entropy_prod       :  H(p (x) q) = H(p) + H(q)        (Theorem 3.2)
    3. entropy_uniform    :  H(uniform_n) = log n            (Theorem 3.3)
    4. entropy_le_log_card:  H(p) <= log n                   (Theorem 3.4)

Run with:  python demo.py
No external dependencies (uses only the standard library `math`).
"""

from __future__ import annotations

import math
from itertools import product
from typing import Sequence


# --------------------------------------------------------------------------- #
# Core: the surprise function and entropy                                      #
# --------------------------------------------------------------------------- #
def surprise(x: float) -> float:
    """The surprise function s(x) = -x*log(x), with s(0) = 0.

    The `x == 0` branch *is* the dissolved 0*log(0) convention: it is the
    value of the function at zero, not a patch applied afterwards.
    """
    if x <= 0.0:
        return 0.0
    return -x * math.log(x)


def entropy(p: Sequence[float]) -> float:
    """Shannon entropy H(p) = sum_x s(p_x) (natural log; nats)."""
    return sum(surprise(px) for px in p)


def product_distribution(
    p: Sequence[float], q: Sequence[float]
) -> list[float]:
    """The product (independent) distribution (p (x) q)(i,j) = p_i * q_j."""
    return [pi * qj for pi, qj in product(p, q)]


def uniform(n: int) -> list[float]:
    """The uniform distribution on n outcomes: each weight is 1/n."""
    return [1.0 / n] * n


def kl_to_uniform(p: Sequence[float]) -> float:
    """KL(p || uniform) = log n - H(p): the maximum-entropy gap (>= 0)."""
    n = len(p)
    return math.log(n) - entropy(p)


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def demo_nonnegativity() -> None:
    print("=" * 70)
    print("THEOREM 3.1  Non-negativity:  H(p) >= 0")
    print("=" * 70)
    examples = {
        "fair coin            ": [0.5, 0.5],
        "biased coin (0.9/0.1)": [0.9, 0.1],
        "point mass           ": [1.0, 0.0, 0.0],
        "fair die             ": uniform(6),
        "skewed quaternary    ": [0.7, 0.2, 0.07, 0.03],
    }
    for name, p in examples.items():
        h = entropy(p)
        print(f"  {name}  H = {h:8.5f} nats   ->  H >= 0 ? {h >= -1e-12}")
    print()


def demo_additivity() -> None:
    print("=" * 70)
    print("THEOREM 3.2  Additivity:  H(p (x) q) = H(p) + H(q)")
    print("=" * 70)
    pairs = [
        ([0.5, 0.5], [0.5, 0.5]),
        ([0.9, 0.1], [0.25, 0.25, 0.5]),
        (uniform(3), uniform(4)),
        ([0.6, 0.3, 0.1], [0.8, 0.2]),
    ]
    for p, q in pairs:
        joint = product_distribution(p, q)
        lhs = entropy(joint)
        rhs = entropy(p) + entropy(q)
        print(
            f"  |p|={len(p)} |q|={len(q)} : "
            f"H(p(x)q)={lhs:8.5f}  H(p)+H(q)={rhs:8.5f}  "
            f"diff={abs(lhs - rhs):.2e}"
        )
    print()


def demo_uniform() -> None:
    print("=" * 70)
    print("THEOREM 3.3  Uniform entropy:  H(uniform_n) = log n")
    print("=" * 70)
    for n in (2, 3, 6, 10, 52):
        h = entropy(uniform(n))
        print(
            f"  n={n:3d} :  H(uniform)={h:9.5f}   log n={math.log(n):9.5f}   "
            f"diff={abs(h - math.log(n)):.2e}"
        )
    print()


def demo_maximum_entropy() -> None:
    print("=" * 70)
    print("THEOREM 3.4  Maximum entropy:  H(p) <= log n   (= for uniform)")
    print("=" * 70)
    n = 4
    cap = math.log(n)
    dists = {
        "uniform        ": uniform(n),
        "mild skew      ": [0.30, 0.30, 0.25, 0.15],
        "strong skew    ": [0.70, 0.15, 0.10, 0.05],
        "near point mass": [0.97, 0.01, 0.01, 0.01],
    }
    print(f"  cap = log {n} = {cap:.5f} nats")
    for name, p in dists.items():
        h = entropy(p)
        gap = kl_to_uniform(p)
        ok = h <= cap + 1e-12
        print(
            f"  {name}  H={h:8.5f}  gap=log n - H={gap:8.5f}  "
            f"H <= log n ? {ok}"
        )
    print("  (the gap equals KL(p || uniform) >= 0, zero iff p is uniform)")
    print()


def demo_bits_vs_nats() -> None:
    print("=" * 70)
    print("BONUS  Reading entropy in bits (base-2): H_bits = H_nats / log 2")
    print("=" * 70)
    for name, p in [
        ("fair coin", [0.5, 0.5]),
        ("fair die ", uniform(6)),
        ("byte     ", uniform(256)),
    ]:
        bits = entropy(p) / math.log(2)
        print(f"  {name}:  {bits:8.5f} bits")
    print()


def main() -> None:
    print()
    print("SHANNON ENTROPY VIA THE SURPRISE FUNCTION  s(x) = -x log x")
    print()
    demo_nonnegativity()
    demo_additivity()
    demo_uniform()
    demo_maximum_entropy()
    demo_bits_vs_nats()
    print("All four cornerstone theorems demonstrated numerically.")


if __name__ == "__main__":
    main()
