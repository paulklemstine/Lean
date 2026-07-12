"""Numerical demonstrations for the capacity of robust neural codes.

This self-contained module illustrates the main results of the accompanying
paper:

  * Raw capacity 2^N and the per-neuron doubling law.
  * Average dense-activity cost N/2.
  * Exact sparse (weight-k) counts C(N, k) and bits-per-spike efficiency.
  * The 1/sqrt(N) population-precision law (Monte-Carlo verification).
  * The Singleton bound |C| <= 2^(N+1-d) and its tightness at d = 1, d = N.
  * The robust-capacity exchange law |C| <= 2^(N-2t).

Everything is written with explicit type hints and no external dependencies
beyond the Python standard library.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Iterable, List, Sequence, Tuple

Pattern = Tuple[int, ...]  # a neural code: tuple of 0/1 of length N


# --------------------------------------------------------------------------- #
# Part I: noiseless capacity                                                   #
# --------------------------------------------------------------------------- #

def all_patterns(n: int) -> List[Pattern]:
    """Enumerate all 2^n binary activity patterns on n neurons."""
    return [p for p in itertools.product((0, 1), repeat=n)]


def capacity(n: int) -> int:
    """Exact number of neural codes on n neurons: 2^n."""
    return 2 ** n


def average_dense_energy(n: int) -> float:
    """Average number of active neurons over all 2^n patterns; equals n/2."""
    patterns = all_patterns(n)
    return sum(sum(p) for p in patterns) / len(patterns)


def sparse_count(n: int, k: int) -> int:
    """Number of weight-k neural codes on n neurons: C(n, k)."""
    return math.comb(n, k)


def bits_per_spike(n: int, k: int) -> float:
    """Bits-per-spike efficiency log2(C(n,k)) / k of a weight-k code."""
    if k == 0:
        return 0.0
    return math.log2(math.comb(n, k)) / k


def population_precision_law(n: int, variance: float, trials: int = 20000,
                             seed: int = 0) -> Tuple[float, float]:
    """Monte-Carlo estimate of the variance of the mean of n i.i.d. neurons.

    Returns (empirical_variance_of_mean, theoretical variance/n).
    """
    rng = random.Random(seed)
    sigma = math.sqrt(variance)
    means: List[float] = []
    for _ in range(trials):
        sample = [rng.gauss(0.0, sigma) for _ in range(n)]
        means.append(sum(sample) / n)
    m = sum(means) / len(means)
    emp = sum((x - m) ** 2 for x in means) / (len(means) - 1)
    return emp, variance / n


# --------------------------------------------------------------------------- #
# Part II: robust capacity under noise                                         #
# --------------------------------------------------------------------------- #

def hamming(x: Pattern, y: Pattern) -> int:
    """Hamming distance: number of neurons on which x and y disagree."""
    return sum(1 for a, b in zip(x, y) if a != b)


def min_distance(codebook: Sequence[Pattern]) -> int:
    """Minimum pairwise Hamming distance of a codebook (inf-like for <2 words)."""
    best = math.inf
    for x, y in itertools.combinations(codebook, 2):
        best = min(best, hamming(x, y))
    return int(best) if best != math.inf else 0


def singleton_bound(n: int, d: int) -> int:
    """Singleton capacity ceiling 2^(N+1-d) for minimum distance d."""
    return 2 ** (n + 1 - d)


def robust_capacity_bound(n: int, t: int) -> int:
    """Robust-capacity ceiling 2^(N-2t) for a t-error-correcting code."""
    return 2 ** (n - 2 * t)


def greedy_codebook(n: int, d: int) -> List[Pattern]:
    """Greedily build a codebook of minimum distance >= d (a feasibility demo)."""
    chosen: List[Pattern] = []
    for p in all_patterns(n):
        if all(hamming(p, q) >= d for q in chosen):
            chosen.append(p)
    return chosen


def repetition_code(n: int) -> List[Pattern]:
    """The two-word repetition code {all-silent, all-active}."""
    return [tuple(0 for _ in range(n)), tuple(1 for _ in range(n))]


# --------------------------------------------------------------------------- #
# Driver                                                                       #
# --------------------------------------------------------------------------- #

def main() -> None:
    print("=" * 70)
    print("PART I  --  Noiseless capacity")
    print("=" * 70)

    print("\nCapacity and the doubling law:")
    for n in range(1, 9):
        ratio = capacity(n) / capacity(n - 1) if n > 0 else float("nan")
        print(f"  N={n:2d}:  capacity 2^N = {capacity(n):5d}   "
              f"ratio to N-1 = {ratio:.1f}")

    print("\nAverage dense energy (should equal N/2):")
    for n in range(1, 7):
        print(f"  N={n:2d}:  empirical mean weight = {average_dense_energy(n):.3f}"
              f"   theory N/2 = {n / 2:.3f}")

    print("\nSparse counts C(N,k) and bits-per-spike (N=16):")
    n = 16
    for k in range(1, 6):
        print(f"  k={k}:  C(N,k) = {sparse_count(n, k):5d}   "
              f"bits/spike = {bits_per_spike(n, k):.3f}")
    print(f"  one-hot advantage: eta(N,1) = log2(N) = {bits_per_spike(n, 1):.3f}")

    print("\nPopulation precision law (variance of mean = v/N, v=1.0):")
    for n in (1, 4, 16, 64):
        emp, theory = population_precision_law(n, variance=1.0)
        print(f"  N={n:3d}:  empirical var(mean) = {emp:.4f}   "
              f"theory v/N = {theory:.4f}   1/sqrt(N) = {1 / math.sqrt(n):.4f}")

    print()
    print("=" * 70)
    print("PART II  --  Robust capacity under noise")
    print("=" * 70)

    print("\nSingleton bound |C| <= 2^(N+1-d) vs. greedy achievable size (N=6):")
    n = 6
    for d in range(1, n + 1):
        book = greedy_codebook(n, d)
        assert min_distance(book) >= d or len(book) < 2
        assert len(book) <= singleton_bound(n, d)
        print(f"  d={d}:  Singleton bound = {singleton_bound(n, d):3d}   "
              f"greedy |C| = {len(book):3d}   (min dist {min_distance(book)})")

    print("\nTightness witnesses:")
    n = 6
    full = all_patterns(n)
    print(f"  d=1 (full code):        |C| = {len(full):3d}   "
          f"Singleton 2^(N+1-1) = {singleton_bound(n, 1):3d}")
    rep = repetition_code(n)
    print(f"  d=N (repetition code):  |C| = {len(rep):3d}   "
          f"Singleton 2^(N+1-N) = {singleton_bound(n, n):3d}   "
          f"(min dist {min_distance(rep)})")

    print("\nRobust-capacity exchange law |C| <= 2^(N-2t) (N=10):")
    n = 10
    for t in range(0, n // 2 + 1):
        print(f"  t={t}:  correct up to {t} flips  ->  capacity ceiling "
              f"2^(N-2t) = {robust_capacity_bound(n, t):5d}")


if __name__ == "__main__":
    main()
