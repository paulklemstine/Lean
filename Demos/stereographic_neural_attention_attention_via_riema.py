"""Stereographic Neural Attention — numerical demonstrations.

This self-contained script demonstrates the formally verified results of the
Stereographic Attention package:

  K(q, k) = 1 / (1 + ||q - k||^2)                          (Cauchy attention kernel)
  P(x)    = (2 / (1 + ||x||^2)) * x                         (stereographic horizontal part)
  H(x)    = (||x||^2 - 1) / (||x||^2 + 1)                   (stereographic height)

Verified facts checked numerically below:
  1.  0 < K(q, k)                                  (positivity)
  2.  K(q, k) <= 1                                 (unit upper bound)
  3.  K(q, k) = 1  <=>  q = k                      (diagonal saturation)
  4.  ||P(x)||^2 + H(x)^2 = 1                       (lift lands on the unit sphere)
  5.  ||P(x)||^2 + (H(x) - 1)^2 = 4 * K(x, 0)       (chordal-distance identity)
  6.  K(q, k) >= tau  <=>  ||q - k|| <= sqrt(1/tau - 1)   (active region is a ball)
  7.  tau * #active <= sum(scores) <= N            (Markov sparsity bound)

No third-party dependencies are required (pure Python standard library).
"""

from __future__ import annotations

import math
import random
from typing import List, Sequence, Tuple

Vector = Sequence[float]


# --------------------------------------------------------------------------- #
# Core geometric primitives (all functions inlined, fully type-hinted).        #
# --------------------------------------------------------------------------- #
def norm_sq(x: Vector) -> float:
    """Squared Euclidean norm ||x||^2."""
    return sum(xi * xi for xi in x)


def norm(x: Vector) -> float:
    """Euclidean norm ||x||."""
    return math.sqrt(norm_sq(x))


def diff(q: Vector, k: Vector) -> List[float]:
    """Componentwise difference q - k."""
    return [qi - ki for qi, ki in zip(q, k)]


def cauchy_kernel(q: Vector, k: Vector) -> float:
    """Cauchy attention kernel K(q, k) = 1 / (1 + ||q - k||^2)."""
    return 1.0 / (1.0 + norm_sq(diff(q, k)))


def stereo_proj(x: Vector) -> List[float]:
    """Horizontal part P(x) = (2 / (1 + ||x||^2)) * x of the stereographic lift."""
    scale = 2.0 / (1.0 + norm_sq(x))
    return [scale * xi for xi in x]


def stereo_height(x: Vector) -> float:
    """Height H(x) = (||x||^2 - 1) / (||x||^2 + 1) of the stereographic lift."""
    t = norm_sq(x)
    return (t - 1.0) / (t + 1.0)


def active_radius(tau: float) -> float:
    """Radius sqrt(1/tau - 1) of the tau-active ball (Theorem 4.1). Needs 0 < tau <= 1."""
    return math.sqrt(1.0 / tau - 1.0)


def attention_weights(q: Vector, keys: Sequence[Vector]) -> List[float]:
    """Normalized stereographic attention weights over a set of keys."""
    scores = [cauchy_kernel(q, k) for k in keys]
    total = sum(scores)
    return [s / total for s in scores]


# --------------------------------------------------------------------------- #
# Demonstrations.                                                              #
# --------------------------------------------------------------------------- #
def demo_regularity() -> None:
    """Facts 1-3: positivity, unit upper bound, and diagonal saturation."""
    print("=" * 70)
    print("DEMO 1: kernel regularity (positivity, <= 1, saturation on diagonal)")
    print("=" * 70)
    q = [1.0, -2.0, 0.5]
    samples = [[1.0, -2.0, 0.5], [0.0, 0.0, 0.0], [3.0, 1.0, -1.0], [1.01, -2.0, 0.5]]
    for k in samples:
        val = cauchy_kernel(q, k)
        print(f"  K(q, {k}) = {val:.6f}   (0 < K <= 1: {0 < val <= 1 + 1e-12})")
    print(f"  K(q, q) == 1 exactly? {abs(cauchy_kernel(q, q) - 1.0) < 1e-12}")
    near = cauchy_kernel(q, [1.01, -2.0, 0.5])
    print(f"  Slightly perturbed key scores < 1: {near < 1.0}  (= {near:.6f})")
    print()


def demo_sphere_identity() -> None:
    """Fact 4: the stereographic lift lands on the unit sphere."""
    print("=" * 70)
    print("DEMO 2: stereographic lift lands on the unit sphere")
    print("        ||P(x)||^2 + H(x)^2 = 1")
    print("=" * 70)
    for x in [[0.0, 0.0], [1.0, 0.0], [3.0, -4.0], [0.1, 0.2], [10.0, 7.0, -2.0]]:
        lhs = norm_sq(stereo_proj(x)) + stereo_height(x) ** 2
        print(f"  x = {str(x):<22} ||P||^2 + H^2 = {lhs:.12f}  (err {abs(lhs - 1):.2e})")
    print()


def demo_chordal_identity() -> None:
    """Fact 5: the squared chordal distance to the north pole equals 4*K(x, 0)."""
    print("=" * 70)
    print("DEMO 3: the Cauchy score IS a chordal distance on the sphere")
    print("        ||P(x)||^2 + (H(x) - 1)^2 = 4 * K(x, 0)")
    print("=" * 70)
    origin = None
    for x in [[0.0, 0.0], [1.0, 0.0], [3.0, -4.0], [0.5, 0.5], [2.0, 1.0, -1.0]]:
        origin = [0.0] * len(x)
        chord = norm_sq(stereo_proj(x)) + (stereo_height(x) - 1.0) ** 2
        rhs = 4.0 * cauchy_kernel(x, origin)
        print(f"  x = {str(x):<20} chord^2 = {chord:.9f}   4*K(x,0) = {rhs:.9f}"
              f"   (err {abs(chord - rhs):.2e})")
    print()


def demo_active_ball(tau: float = 0.2) -> None:
    """Fact 6: active keys are exactly those inside a ball of radius sqrt(1/tau - 1)."""
    print("=" * 70)
    print(f"DEMO 4: active region is a ball (tau = {tau})")
    print(f"        K(q, k) >= tau  <=>  ||q - k|| <= sqrt(1/tau - 1) = {active_radius(tau):.4f}")
    print("=" * 70)
    rng = random.Random(0)
    q = [0.0, 0.0]
    rho = active_radius(tau)
    mismatches = 0
    for _ in range(10000):
        k = [rng.uniform(-5, 5), rng.uniform(-5, 5)]
        by_score = cauchy_kernel(q, k) >= tau
        by_ball = norm(diff(q, k)) <= rho + 1e-12
        mismatches += int(by_score != by_ball)
    print(f"  Checked 10000 random keys; characterization mismatches = {mismatches}")
    print()


def demo_markov_sparsity(n: int = 400, tau: float = 0.1) -> None:
    """Fact 7: tau * #active <= sum(scores) <= N, and #active <= N/tau."""
    print("=" * 70)
    print(f"DEMO 5: Markov sparsity bound (N = {n}, tau = {tau})")
    print("        tau * #active <= sum(scores) <= N")
    print("=" * 70)
    rng = random.Random(7)
    q = [0.0, 0.0, 0.0]
    # Spread keys: random points in a cube around the query.
    keys: List[List[float]] = [[rng.uniform(-6, 6) for _ in range(3)] for _ in range(n)]
    scores = [cauchy_kernel(q, k) for k in keys]
    total = sum(scores)
    n_active = sum(1 for s in scores if s >= tau)
    print(f"  sum(scores)        = {total:.4f}   (<= N = {n}: {total <= n})")
    print(f"  #active            = {n_active}")
    print(f"  tau * #active      = {tau * n_active:.4f}   (<= sum(scores): {tau * n_active <= total + 1e-9})")
    print(f"  bound  #active     <= N/tau = {n / tau:.1f}  -> satisfied: {n_active <= n / tau}")
    print(f"  observed sparsity  #active/N = {n_active / n:.4f}  vs  sqrt(N)/N = {math.sqrt(n) / n:.4f}")
    print()


def demo_attention_row() -> None:
    """A full stereographic attention row over a small key set."""
    print("=" * 70)
    print("DEMO 6: a stereographic attention row (normalized weights)")
    print("=" * 70)
    q = [1.0, 0.0]
    keys = [[1.0, 0.0], [1.2, 0.1], [3.0, 2.0], [-4.0, 5.0]]
    weights = attention_weights(q, keys)
    for k, w in zip(keys, weights):
        print(f"  key {str(k):<14} -> weight {w:.4f}")
    print(f"  weights sum to 1: {abs(sum(weights) - 1.0) < 1e-12}")
    print("  Note the far key receives a near-zero weight: built-in sparsity.")
    print()


def main() -> None:
    print("\nStereographic Neural Attention — numerical demonstrations\n")
    demo_regularity()
    demo_sphere_identity()
    demo_chordal_identity()
    demo_active_ball()
    demo_markov_sparsity()
    demo_attention_row()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
