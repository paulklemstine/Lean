"""
Bayesian Werewolf <-> Vandermonde's Convolution: numerical demonstrations.

This self-contained script demonstrates the exact combinatorial bridge between
the hypergeometric "werewolves-in-a-committee" distribution and two classical
binomial-coefficient identities:

  * Normalization  <->  Vandermonde's convolution:
        sum_j C(k,j) C(n-k, t-j) = C(n, t)
  * Mean = t*k/n   <->  binomial absorption + Vandermonde:
        j*C(k,j) = k*C(k-1,j-1),  then Vandermonde
  * t = 1 corollary: a single random suspect is a werewolf with probability k/n.

All arithmetic is exact (integers and fractions.Fraction), so the printed
equalities are verified exactly, not approximately.
"""

from __future__ import annotations

from fractions import Fraction
from math import comb
from typing import List, Tuple


def hyp_weight(n: int, k: int, t: int, j: int) -> Fraction:
    """Exact hypergeometric weight: probability that a uniformly random
    t-subset of n players (k of them werewolves) contains exactly j werewolves.

        h(n,k,t,j) = C(k,j) * C(n-k, t-j) / C(n, t).
    """
    return Fraction(comb(k, j) * comb(n - k, t - j), comb(n, t))


def hyp_distribution(n: int, k: int, t: int) -> List[Fraction]:
    """The full weight vector (h(n,k,t,j))_{j=0}^{t} as exact fractions."""
    return [hyp_weight(n, k, t, j) for j in range(t + 1)]


def vandermonde_lhs(n: int, k: int, t: int) -> int:
    """Left-hand side of Vandermonde's convolution: sum_j C(k,j) C(n-k, t-j)."""
    return sum(comb(k, j) * comb(n - k, t - j) for j in range(t + 1))


def absorption_check(k: int, j: int) -> Tuple[int, int]:
    """Return the two sides of the absorption identity j*C(k,j) = k*C(k-1,j-1)."""
    return j * comb(k, j), k * comb(k - 1, j - 1)


def hyp_mean_direct(n: int, k: int, t: int) -> Fraction:
    """Mean computed by the naive definition sum_j j * h(n,k,t,j)."""
    return sum(Fraction(j) * hyp_weight(n, k, t, j) for j in range(t + 1))


def hyp_mean_formula(n: int, k: int, t: int) -> Fraction:
    """Mean via the closed form of Bridge 2: t*k/n."""
    return Fraction(t * k, n)


def demo_normalization() -> None:
    print("=" * 70)
    print("BRIDGE 1: normalization is Vandermonde's convolution")
    print("=" * 70)
    for (n, k, t) in [(5, 2, 1), (10, 3, 4), (20, 7, 6), (52, 13, 5)]:
        dist = hyp_distribution(n, k, t)
        total = sum(dist)
        lhs = vandermonde_lhs(n, k, t)
        rhs = comb(n, t)
        print(f"n={n:3d} k={k:3d} t={t:3d}:  sum of weights = {total}  "
              f"(Vandermonde: {lhs} = C(n,t) = {rhs}: {lhs == rhs})")
        assert total == 1, "weights must sum to exactly 1"
        assert lhs == rhs, "Vandermonde identity must hold"
    print("All normalizations equal 1 exactly.\n")


def demo_absorption() -> None:
    print("=" * 70)
    print("Binomial absorption identity  j*C(k,j) = k*C(k-1,j-1)")
    print("=" * 70)
    for (k, j) in [(5, 1), (5, 3), (10, 4), (13, 7)]:
        left, right = absorption_check(k, j)
        print(f"k={k:3d} j={j:3d}:  j*C(k,j) = {left:6d}   "
              f"k*C(k-1,j-1) = {right:6d}   equal: {left == right}")
        assert left == right
    print()


def demo_mean() -> None:
    print("=" * 70)
    print("BRIDGE 2: mean equals t*k/n  (absorption + Vandermonde)")
    print("=" * 70)
    for (n, k, t) in [(5, 2, 1), (10, 3, 4), (20, 7, 6), (52, 13, 5)]:
        direct = hyp_mean_direct(n, k, t)
        formula = hyp_mean_formula(n, k, t)
        print(f"n={n:3d} k={k:3d} t={t:3d}:  direct sum = {str(direct):>8}   "
              f"t*k/n = {str(formula):>8}   equal: {direct == formula}")
        assert direct == formula, "mean must equal t*k/n exactly"
    print("All means match the closed form exactly.\n")


def demo_detection_prior() -> None:
    print("=" * 70)
    print("Single-suspect prior (t = 1): P(suspect is werewolf) = k/n")
    print("=" * 70)
    for (n, k) in [(5, 1), (7, 2), (12, 3), (100, 20)]:
        mean = hyp_mean_direct(n, k, 1)
        prior = Fraction(k, n)
        print(f"n={n:4d} k={k:3d}:  E[werewolves in 1-committee] = {str(mean):>8}"
              f"   k/n = {str(prior):>8} ~= {float(prior):.4f}   equal: {mean == prior}")
        assert mean == prior
    print()


def demo_distribution_table() -> None:
    print("=" * 70)
    print("Full hypergeometric table (n=20, k=7 werewolves, committee t=6)")
    print("=" * 70)
    n, k, t = 20, 7, 6
    dist = hyp_distribution(n, k, t)
    for j, w in enumerate(dist):
        bar = "#" * int(round(float(w) * 100))
        print(f"  P(exactly {j} werewolves) = {str(w):>12} ~= {float(w):.5f}  {bar}")
    print(f"  sum = {sum(dist)}   mean = {hyp_mean_formula(n, k, t)} "
          f"~= {float(hyp_mean_formula(n, k, t)):.4f}\n")


if __name__ == "__main__":
    demo_normalization()
    demo_absorption()
    demo_mean()
    demo_detection_prior()
    demo_distribution_table()
    print("All exact identities verified. The Bayesian backbone of Werewolf")
    print("is Vandermonde's convolution and binomial absorption in disguise.")
