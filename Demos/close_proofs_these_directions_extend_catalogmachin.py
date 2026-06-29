"""
demo.py — Numerical demonstrations of empirical Rademacher complexity
for finite hypothesis classes (behavior-on-the-sample representation).

Each hypothesis is identified with its output vector v = (v_1, ..., v_n) in R^n.
A hypothesis class F is a finite list of such vectors. The empirical Rademacher
complexity is

    empRad(F) = (1 / (2^n * n)) * sum_sigma  max_{v in F}  sum_i sigma_i * v_i

where sigma ranges over all 2^n sign patterns in {+1, -1}^n.

This file reproduces, numerically, the five core results:
  1. signSum_coord_eq_zero   — signs at any coordinate cancel over all patterns.
  2. empRad_singleton        — a single hypothesis has complexity exactly 0.
  3. empRad_nonneg           — containing the zero vector implies complexity >= 0.
  4. empRad_mono             — complexity is monotone under class inclusion.
  5. empRad_le_of_bounded    — B-bounded classes have complexity <= B.

It also illustrates the conjectured Massart finite-class refinement.

Pure standard library; no external dependencies.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Iterable, List, Sequence, Tuple

Vector = Sequence[float]
SignPattern = Tuple[int, ...]  # entries in {+1, -1}


# --------------------------------------------------------------------------- #
# Core definitions                                                            #
# --------------------------------------------------------------------------- #
def all_sign_patterns(n: int) -> Iterable[SignPattern]:
    """Yield all 2^n sign patterns in {+1, -1}^n."""
    for bits in itertools.product((1, -1), repeat=n):
        yield bits


def corr(sigma: SignPattern, v: Vector) -> float:
    """Correlation <sigma, v> = sum_i sigma_i * v_i."""
    return sum(s * x for s, x in zip(sigma, v))


def emp_rad(F: Sequence[Vector]) -> float:
    """Exact empirical Rademacher complexity of a nonempty finite class F.

    F is a list of behavior vectors, all of common length n.
    Cost: O(2^n * |F| * n).
    """
    if not F:
        raise ValueError("F must be nonempty")
    n = len(F[0])
    if n == 0:
        # Degenerate empty-sample case: denominator 2^n * n = 0. By convention 0.
        return 0.0
    total = 0.0
    for sigma in all_sign_patterns(n):
        total += max(corr(sigma, v) for v in F)
    return total / (2 ** n * n)


def emp_rad_monte_carlo(F: Sequence[Vector], num_samples: int,
                        seed: int = 0) -> float:
    """Unbiased Monte-Carlo estimate of empRad(F) over sampled sign patterns.

    Useful when 2^n is too large to enumerate. Cost: O(num_samples * |F| * n).
    """
    if not F:
        raise ValueError("F must be nonempty")
    n = len(F[0])
    if n == 0:
        return 0.0
    rng = random.Random(seed)
    acc = 0.0
    for _ in range(num_samples):
        sigma = tuple(rng.choice((1, -1)) for _ in range(n))
        acc += max(corr(sigma, v) for v in F)
    return acc / (num_samples * n)


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_sign_cancellation(n: int = 4) -> None:
    """Result 1: sum over all patterns of sigma_i is zero for every coord i."""
    print("=" * 64)
    print(f"1. signSum_coord_eq_zero  (n = {n})")
    print("   For each coordinate i, sum over all 2^n patterns of sigma_i:")
    patterns = list(all_sign_patterns(n))
    for i in range(n):
        s = sum(sigma[i] for sigma in patterns)
        print(f"     coordinate {i}: sum = {s}")
    print("   -> all zero, as proved.")


def demo_singleton() -> None:
    """Result 2: a single hypothesis has empirical Rademacher complexity 0."""
    print("=" * 64)
    print("2. empRad_singleton")
    for v in ([3.0, -1.5, 2.0], [10.0, 10.0, 10.0, 10.0], [-7.0]):
        val = emp_rad([v])
        print(f"     empRad({{ {v} }}) = {val:.12f}")
    print("   -> exactly 0 regardless of how 'complex' the single vector is.")


def demo_nonneg() -> None:
    """Result 3: containing the zero vector implies complexity >= 0."""
    print("=" * 64)
    print("3. empRad_nonneg  (class contains the zero hypothesis)")
    n = 3
    zero = [0.0] * n
    F = [zero, [1.0, -2.0, 0.5], [-3.0, 1.0, 2.0], [0.2, 0.2, 0.2]]
    val = emp_rad(F)
    print(f"     F has {len(F)} vectors including 0; empRad(F) = {val:.6f} >= 0")


def demo_monotonicity() -> None:
    """Result 4: complexity is monotone under class inclusion F subset G."""
    print("=" * 64)
    print("4. empRad_mono  (F subset G  =>  empRad(F) <= empRad(G))")
    F = [[1.0, -1.0, 1.0], [-1.0, 1.0, 1.0]]
    extra = [[1.0, 1.0, -1.0], [-1.0, -1.0, -1.0]]
    G = F + extra
    rF, rG = emp_rad(F), emp_rad(G)
    print(f"     empRad(F) = {rF:.6f}")
    print(f"     empRad(G) = {rG:.6f}   (G = F + 2 more vectors)")
    print(f"     monotone? {rF <= rG + 1e-12}")


def demo_uniform_bound(B: float = 5.0) -> None:
    """Result 5: every coordinate bounded by B implies empRad(F) <= B."""
    print("=" * 64)
    print(f"5. empRad_le_of_bounded  (|v_i| <= B = {B})")
    F = [[B, -B, B, -B], [-B, B, -B, B], [B, B, B, B], [0.0, 0.0, 0.0, 0.0]]
    val = emp_rad(F)
    print(f"     empRad(F) = {val:.6f}   <=   B = {B} ?  {val <= B + 1e-12}")


def demo_massart(num_classes: int = 6, n: int = 8, B: float = 1.0) -> None:
    """Illustrate the conjectured Massart bound B*sqrt(2 log|F| / n)."""
    print("=" * 64)
    print("6. Massart refinement (conjecture):  empRad(F) <= B*sqrt(2 log|F|/n)")
    rng = random.Random(42)
    print(f"     n = {n}, B = {B}")
    print(f"     {'|F|':>6} {'empRad':>12} {'Massart bound':>16} {'holds':>7}")
    for k in (1, 2, 4, 8, 16, 32):
        F = [[rng.choice((B, -B)) for _ in range(n)] for _ in range(k)]
        val = emp_rad(F)
        bound = B * math.sqrt(2.0 * math.log(k) / n) if k > 1 else 0.0
        holds = val <= bound + 1e-9
        print(f"     {k:>6} {val:>12.6f} {bound:>16.6f} {str(holds):>7}")
    print("   -> empirical complexity stays under the sqrt(log|F|/n) bound.")


def main() -> None:
    print("Empirical Rademacher Complexity — numerical demonstrations\n")
    demo_sign_cancellation()
    demo_singleton()
    demo_nonneg()
    demo_monotonicity()
    demo_uniform_bound()
    demo_massart()
    print("=" * 64)
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
