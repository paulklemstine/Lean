#!/usr/bin/env python3
"""
Deflection Algebras: Core Algorithms

Type-hinted implementations of the key algorithms from the Deflection Algebra theory.
"""

import numpy as np
from typing import Callable, List, Tuple, Optional
from dataclasses import dataclass


# ============================================================================
# Core Types
# ============================================================================

Point = np.ndarray
ExpectationOp = Callable[[Point], Point]


@dataclass
class DeflectionSpace:
    """A metric space with an expectation operator."""
    dim: int
    expect: ExpectationOp
    lipschitz_constant: Optional[float] = None
    contraction_constant: Optional[float] = None
    fixed_point: Optional[Point] = None


@dataclass
class DeflectionMorphism:
    """A morphism between deflection spaces."""
    map_fn: Callable[[Point], Point]
    bound: float
    source: DeflectionSpace
    target: DeflectionSpace


@dataclass
class DeflectionAnalysis:
    """Results of analyzing a point's deflection properties."""
    point: Point
    expected: Point
    deflection: float
    fixpoint_dist: Optional[float] = None
    upper_bound: Optional[float] = None
    lower_bound: Optional[float] = None


# ============================================================================
# Algorithm 1: Deflection Computation
# ============================================================================

def compute_deflection(x: Point, E: ExpectationOp) -> float:
    """
    Compute the deflection δ(x) = ‖E(x) - x‖.

    Time complexity: O(d) where d = dim(x)
    Space complexity: O(d)
    """
    return float(np.linalg.norm(E(x) - x))


# ============================================================================
# Algorithm 2: Contraction-Deflection Analysis
# ============================================================================

def contraction_analysis(
    x: Point,
    E: ExpectationOp,
    k: float,
    fixed_point: Point
) -> DeflectionAnalysis:
    """
    Compute bilateral bounds between deflection and fixed-point distance.

    Given a k-contraction E with known fixed point p:
    - Upper bound: δ(x) ≤ (1+k) · d(x, p)
    - Lower bound: d(x, p) ≤ δ(x) / (1-k)

    Time complexity: O(d)
    """
    ex = E(x)
    defl = float(np.linalg.norm(ex - x))
    fp_dist = float(np.linalg.norm(x - fixed_point))

    return DeflectionAnalysis(
        point=x,
        expected=ex,
        deflection=defl,
        fixpoint_dist=fp_dist,
        upper_bound=(1 + k) * fp_dist,
        lower_bound=defl / (1 - k) if k < 1 else float('inf')
    )


# ============================================================================
# Algorithm 3: Geometric Decay Estimation
# ============================================================================

def estimate_contraction_constant(
    x: Point,
    E: ExpectationOp,
    n_iterations: int = 20
) -> Tuple[float, List[float]]:
    """
    Estimate the contraction constant by observing geometric decay.

    Iterates E starting from x, records deflections, and fits
    an exponential decay model δₙ ≈ k^n · δ₀.

    Returns: (estimated_k, deflection_sequence)
    Time complexity: O(n_iterations · d)
    """
    deflections: List[float] = []
    y = x.copy()

    for _ in range(n_iterations):
        d = compute_deflection(y, E)
        deflections.append(d)
        y = E(y)

    # Estimate k from consecutive ratios
    ratios = []
    for i in range(1, len(deflections)):
        if deflections[i - 1] > 1e-15:
            ratios.append(deflections[i] / deflections[i - 1])

    estimated_k = float(np.median(ratios)) if ratios else 0.0
    return estimated_k, deflections


# ============================================================================
# Algorithm 4: Deflection Energy Computation
# ============================================================================

def compute_deflection_energy(
    points: List[Point],
    E: ExpectationOp
) -> Tuple[float, float, float]:
    """
    Compute deflection energy, total deflection, and verify Cauchy-Schwarz.

    Returns: (total_deflection, deflection_energy, cauchy_schwarz_ratio)
    where cauchy_schwarz_ratio = T² / (n · E) ≤ 1
    """
    n = len(points)
    deflections = [compute_deflection(p, E) for p in points]

    total = sum(deflections)
    energy = sum(d ** 2 for d in deflections)
    ratio = total ** 2 / (n * energy) if n * energy > 0 else 0.0

    return total, energy, ratio


# ============================================================================
# Algorithm 5: Deflection Spectrum
# ============================================================================

def compute_deflection_spectrum(
    points: List[Point],
    E: ExpectationOp
) -> List[float]:
    """
    Compute the sorted deflection spectrum of a finite point set.

    Returns deflections in sorted order (ascending).
    """
    deflections = sorted(compute_deflection(p, E) for p in points)
    return deflections


# ============================================================================
# Algorithm 6: Morphism Composition and Bound Verification
# ============================================================================

def compose_morphisms(
    f: DeflectionMorphism,
    g: DeflectionMorphism
) -> DeflectionMorphism:
    """
    Compose two deflection morphisms g ∘ f with bound B_g · B_f.
    """
    return DeflectionMorphism(
        map_fn=lambda x: g.map_fn(f.map_fn(x)),
        bound=g.bound * f.bound,
        source=f.source,
        target=g.target
    )


def verify_morphism_bound(
    morphism: DeflectionMorphism,
    test_points: List[Point],
    tolerance: float = 1e-10
) -> Tuple[bool, float]:
    """
    Verify that a morphism satisfies its deflection bound on test points.

    Returns: (is_valid, max_observed_ratio)
    """
    max_ratio = 0.0
    E_source = morphism.source.expect
    E_target = morphism.target.expect

    for x in test_points:
        d_source = compute_deflection(x, E_source)
        d_target = compute_deflection(morphism.map_fn(x), E_target)

        if d_source > tolerance:
            ratio = d_target / d_source
            max_ratio = max(max_ratio, ratio)

    return max_ratio <= morphism.bound + tolerance, max_ratio


# ============================================================================
# Algorithm 7: Lipschitz Constant Estimation
# ============================================================================

def estimate_lipschitz_constant(
    E: ExpectationOp,
    test_points: List[Point],
    n_pairs: int = 1000
) -> float:
    """
    Estimate the Lipschitz constant of E by sampling pairs of points.

    Returns: estimated Lipschitz constant K
    """
    max_ratio = 0.0
    rng = np.random.RandomState(42)

    for _ in range(n_pairs):
        i, j = rng.choice(len(test_points), 2, replace=False)
        x, y = test_points[i], test_points[j]

        d_xy = np.linalg.norm(x - y)
        if d_xy < 1e-15:
            continue

        d_exy = np.linalg.norm(E(x) - E(y))
        max_ratio = max(max_ratio, d_exy / d_xy)

    return max_ratio


if __name__ == "__main__":
    # Quick self-test
    E = lambda x: 0.5 * x
    x = np.array([4.0, 3.0])

    print(f"Deflection of {x} = {compute_deflection(x, E):.4f}")

    analysis = contraction_analysis(x, E, k=0.5, fixed_point=np.zeros(2))
    print(f"Fixed-point distance: {analysis.fixpoint_dist:.4f}")
    print(f"Upper bound: {analysis.upper_bound:.4f}")
    print(f"Lower bound: {analysis.lower_bound:.4f}")

    k_est, seq = estimate_contraction_constant(x, E)
    print(f"Estimated contraction constant: {k_est:.4f}")
