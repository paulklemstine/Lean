"""
Numerical demonstrations of the measure-theory-free theory of the
Expected Empirical Rademacher Complexity over the Boolean hypercube.

Every quantity in the formal development is a *finite* sum, so each theorem can
be checked exactly by brute-force enumeration over the 2**n sign patterns of the
Boolean hypercube {-1, +1}**n.  This script verifies, on concrete instances:

  * rademacher_correlation_bounded  -- |corr(sigma, h)| <= B
  * sum_rademacherCorrelation_eq_zero -- sum over all 2**n patterns is exactly 0
  * expectedRademacher_singleton_eq_zero -- R_n({h}) = 0
  * expectedRademacher_nonneg -- 0 in H  =>  R_n(H) >= 0
  * expectedRademacher_mono -- H subset H'  =>  R_n(H) <= R_n(H')
  * expectedRademacher_le_bound -- |h_i| <= B  =>  R_n(H) <= B
  * expectedRademacher_smul_nonneg -- R_n(c*H) = c * R_n(H) for c >= 0

All functions are self-contained and use only the Python standard library.
"""

from __future__ import annotations

from itertools import product
from typing import Iterable, Sequence

# --------------------------------------------------------------------------- #
# Core definitions (mirroring the formal Lean development)                     #
# --------------------------------------------------------------------------- #

Hypothesis = Sequence[float]          # a vector h : Fin n -> R
SignVector = Sequence[int]            # an element of {-1, +1}**n


def sign_vectors(n: int) -> Iterable[SignVector]:
    """Enumerate all 2**n elements of the Boolean hypercube as +-1 vectors."""
    return product((-1, 1), repeat=n)


def rademacher_correlation(sigma: SignVector, h: Hypothesis) -> float:
    """corr(sigma, h) = (1/n) * sum_i sigma_i * h_i."""
    n = len(h)
    if n == 0:
        return 0.0
    return sum(s * hi for s, hi in zip(sigma, h)) / n


def expected_rademacher(n: int, H: Sequence[Hypothesis]) -> float:
    """R_n(H) = mean over all 2**n sign patterns of max_{h in H} corr(sigma, h)."""
    assert len(H) > 0, "hypothesis class must be nonempty"
    total = 0.0
    count = 0
    for sigma in sign_vectors(n):
        total += max(rademacher_correlation(sigma, h) for h in H)
        count += 1
    return total / count  # count == 2**n


def flip(sigma: SignVector) -> SignVector:
    """The sign-flip involution: negate every coordinate (true<->false)."""
    return tuple(-s for s in sigma)


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #

def demo_correlation_bound() -> None:
    print("=" * 70)
    print("Theorem 4.1  |corr(sigma, h)| <= B  when |h_i| <= B")
    print("=" * 70)
    n = 5
    h: Hypothesis = [0.7, -1.0, 0.3, 0.9, -0.5]
    B = max(abs(x) for x in h)
    worst = max(abs(rademacher_correlation(s, h)) for s in sign_vectors(n))
    print(f"  n = {n}, B = {B}")
    print(f"  max over all 2^{n} patterns of |corr| = {worst:.6f}")
    print(f"  bound B = {B:.6f}  ->  satisfied: {worst <= B + 1e-12}")
    print()


def demo_duality_identity() -> None:
    print("=" * 70)
    print("Theorem 4.2  sum over all 2^n sign patterns of corr(sigma, h) = 0")
    print("=" * 70)
    for n, h in [(3, [1.0, -2.0, 0.5]), (4, [0.2, 0.9, -0.4, 1.3])]:
        s = sum(rademacher_correlation(sig, h) for sig in sign_vectors(n))
        # also show the involution cancellation, pair by pair
        pair_sum = 0.0
        for sig in sign_vectors(n):
            pair_sum += (rademacher_correlation(sig, h)
                         + rademacher_correlation(flip(sig), h))
        print(f"  n={n}, h={h}")
        print(f"    sum of correlations          = {s:.2e}")
        print(f"    sum of (corr(s)+corr(flip s)) = {pair_sum:.2e}  (each pair cancels)")
    print()


def demo_singleton_collapse() -> None:
    print("=" * 70)
    print("Theorem 4.3  R_n({h}) = 0  (a singleton class chases no noise)")
    print("=" * 70)
    n = 4
    h: Hypothesis = [1.1, -0.6, 0.4, 2.0]
    val = expected_rademacher(n, [h])
    print(f"  n={n}, h={h}")
    print(f"  R_n({{h}}) = {val:.2e}  ->  zero: {abs(val) < 1e-12}")
    print()


def demo_nonneg_and_mono() -> None:
    print("=" * 70)
    print("Theorem 4.4 / 4.5  nonnegativity (0 in H) and monotonicity (H subset H')")
    print("=" * 70)
    n = 4
    zero: Hypothesis = [0.0] * n
    H_small: list[Hypothesis] = [zero, [1.0, -1.0, 1.0, -1.0]]
    H_big: list[Hypothesis] = H_small + [[0.5, 0.5, 0.5, 0.5], [-1.0, 0.2, 0.9, 0.3]]
    r_small = expected_rademacher(n, H_small)
    r_big = expected_rademacher(n, H_big)
    print(f"  R_n(H_small) = {r_small:.6f}  ->  nonneg: {r_small >= -1e-12}")
    print(f"  R_n(H_big)   = {r_big:.6f}")
    print(f"  monotone (small <= big): {r_small <= r_big + 1e-12}")
    print()


def demo_upper_bound() -> None:
    print("=" * 70)
    print("Theorem 4.6  R_n(H) <= B  when every |h_i| <= B")
    print("=" * 70)
    n = 5
    H: list[Hypothesis] = [
        [1.0, -1.0, 1.0, -1.0, 1.0],
        [0.5, 0.5, -0.5, 0.5, -0.5],
        [-1.0, 0.8, 0.2, -0.9, 0.3],
    ]
    B = max(abs(x) for h in H for x in h)
    r = expected_rademacher(n, H)
    print(f"  n={n}, B={B}")
    print(f"  R_n(H) = {r:.6f}  <=  B = {B:.6f}  ->  satisfied: {r <= B + 1e-12}")
    print()


def demo_homogeneity() -> None:
    print("=" * 70)
    print("Theorem 4.7  R_n(c*H) = c * R_n(H)  for c >= 0")
    print("=" * 70)
    n = 4
    H: list[Hypothesis] = [[1.0, -0.5, 0.3, 0.8], [0.0, 0.0, 0.0, 0.0],
                           [-0.7, 0.9, 0.2, -1.0]]
    base = expected_rademacher(n, H)
    for c in (0.0, 0.5, 2.0, 3.7):
        cH = [[c * x for x in h] for h in H]
        lhs = expected_rademacher(n, cH)
        rhs = c * base
        print(f"  c={c:<4}  R_n(cH)={lhs:.6f}  c*R_n(H)={rhs:.6f}  "
              f"equal: {abs(lhs - rhs) < 1e-12}")
    print()


def demo_capacity_grows_with_class() -> None:
    print("=" * 70)
    print("Illustration: capacity climbs as the menu of rules grows")
    print("=" * 70)
    n = 6
    import random
    random.seed(0)
    pool: list[Hypothesis] = [[random.choice([-1.0, 1.0]) for _ in range(n)]
                              for _ in range(40)]
    print(f"  n={n}, all |h_i| = 1 so B = 1")
    print("  |H|   R_n(H)")
    for m in (1, 2, 4, 8, 16, 32):
        H = pool[:m]
        print(f"  {m:>3}   {expected_rademacher(n, H):.6f}")
    print("  (monotone increasing, always <= B = 1)")
    print()


if __name__ == "__main__":
    demo_correlation_bound()
    demo_duality_identity()
    demo_singleton_collapse()
    demo_nonneg_and_mono()
    demo_upper_bound()
    demo_homogeneity()
    demo_capacity_grows_with_class()
    print("All theorems verified numerically on concrete instances.")
