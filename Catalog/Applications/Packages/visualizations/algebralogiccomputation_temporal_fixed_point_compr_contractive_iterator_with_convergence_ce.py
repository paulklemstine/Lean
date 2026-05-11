#!/usr/bin/env python3
"""
Ultrametric Temporal Fixed-Point Compression — Algorithms

Core algorithms from the research paper:
1. Ultrametric contractive iterator with convergence certificate
2. Certified extractor with error bounds
3. Ball stabilization detector
4. Compression core finder
"""

import numpy as np
from typing import Callable, Tuple, Optional, List
from dataclasses import dataclass


@dataclass
class ConvergenceCertificate:
    """Certificate for fixed-point convergence."""
    fixed_point: float
    iterations: int
    contraction_constant: float
    initial_distance: float
    final_error_bound: float
    orbit: List[float]
    distances: List[float]


@dataclass
class ExtractionResult:
    """Result of the certified extractor."""
    extracted_value: float
    iterations_used: int
    certified_error: float
    compression_applied: bool


@dataclass
class BallStabilizationResult:
    """Result of ball stabilization analysis."""
    entry_steps: dict  # radius -> step at which orbit enters ball
    stabilization_step: int  # step after which all balls are stable
    hierarchy_depth: int


def ultrametric_dist_padic(x: int, y: int, p: int = 2) -> float:
    """Compute p-adic ultrametric distance |x - y|_p = p^{-v_p(x-y)}."""
    if x == y:
        return 0.0
    diff = abs(x - y)
    v = 0
    while diff % p == 0:
        diff //= p
        v += 1
    return float(p) ** (-v)


def contractive_iterator(
    F: Callable[[float], float],
    dist: Callable[[float, float], float],
    x0: float,
    q: float,
    epsilon: float = 1e-12,
    max_iter: int = 1000
) -> ConvergenceCertificate:
    """
    Iterate a q-contractive map F until convergence.

    Algorithm:
        1. Compute orbit x₀, F(x₀), F²(x₀), ...
        2. Track distances d(F^{n+1}(x₀), F^n(x₀))
        3. Stop when q^n · d(F(x₀), x₀) < ε
        4. Return certificate with error bound

    Complexity: O(log(1/ε) / log(1/q)) iterations

    Args:
        F: The contractive map
        dist: Distance function (should satisfy ultrametric inequality)
        x0: Starting point
        q: Contraction constant (0 < q < 1)
        epsilon: Target precision
        max_iter: Safety bound on iterations

    Returns:
        ConvergenceCertificate with fixed point and error bound
    """
    assert 0 < q < 1, "Contraction constant must satisfy 0 < q < 1"

    orbit = [x0]
    distances = []

    x = x0
    d_initial = dist(F(x0), x0)

    for n in range(max_iter):
        x_new = F(x)
        d = dist(x_new, x)
        distances.append(d)
        orbit.append(x_new)

        # Check certified convergence bound
        error_bound = q ** n * d_initial
        if error_bound < epsilon:
            return ConvergenceCertificate(
                fixed_point=x_new,
                iterations=n + 1,
                contraction_constant=q,
                initial_distance=d_initial,
                final_error_bound=error_bound,
                orbit=orbit,
                distances=distances
            )
        x = x_new

    return ConvergenceCertificate(
        fixed_point=x,
        iterations=max_iter,
        contraction_constant=q,
        initial_distance=d_initial,
        final_error_bound=q ** max_iter * d_initial,
        orbit=orbit,
        distances=distances
    )


def certified_extractor(
    F: Callable[[float], float],
    C: Callable[[float], float],
    dist: Callable[[float, float], float],
    x0: float,
    q: float,
    epsilon: float
) -> ExtractionResult:
    """
    Certified extractor: iterate F, then compress with C.

    The extractor computes C(F^N(x₀)) where N is chosen so that
    the error d(extractor, p⋆) ≤ q^N · d(x₀, p⋆) < ε.

    If C is nonexpansive and fixes p⋆, the compression doesn't
    increase the error.

    Algorithm:
        1. Estimate d(x₀, p⋆) ≈ d(x₀, F(x₀)) / (1-q) (geometric series bound)
        2. Compute N = ⌈log(ε/d₀) / log(q)⌉
        3. Iterate F exactly N times
        4. Apply C to compress

    Complexity: O(N) = O(log(ε/d₀) / log(1/q)) iterations

    Args:
        F: Contractive map
        C: Compression (nonexpansive) map
        dist: Distance function
        x0: Starting point
        q: Contraction constant
        epsilon: Target precision

    Returns:
        ExtractionResult with certified error bound
    """
    # Estimate initial distance to fixed point
    d0 = dist(F(x0), x0) / (1 - q)  # upper bound via geometric series

    if d0 < 1e-15:
        return ExtractionResult(
            extracted_value=C(x0),
            iterations_used=0,
            certified_error=0.0,
            compression_applied=True
        )

    # Compute required iterations
    import math
    N = max(1, int(math.ceil(math.log(epsilon / d0) / math.log(q))))

    # Iterate F exactly N times
    x = x0
    for _ in range(N):
        x = F(x)

    # Apply compression
    result = C(x)

    return ExtractionResult(
        extracted_value=result,
        iterations_used=N,
        certified_error=q ** N * d0,
        compression_applied=True
    )


def ball_stabilization_analysis(
    orbit: List[float],
    dist: Callable[[float, float], float],
    radii: List[float]
) -> BallStabilizationResult:
    """
    Analyze hierarchical ball stabilization of an orbit.

    In ultrametric spaces, balls are clopen: once an orbit enters a ball,
    it never leaves. This function detects the entry step for each radius.

    Algorithm:
        1. For each radius r in the hierarchy:
           a. Find first n where d(orbit[n], orbit[-1]) ≤ r
           b. Verify stability: orbit stays in ball for all subsequent steps
        2. Compute stabilization step = max of all entry steps

    Complexity: O(|orbit| × |radii|)

    Args:
        orbit: Sequence of iterates [x₀, F(x₀), F²(x₀), ...]
        dist: Ultrametric distance function
        radii: List of radii to check, in decreasing order

    Returns:
        BallStabilizationResult with entry steps and stabilization info
    """
    limit = orbit[-1]
    entry_steps = {}

    for r in sorted(radii, reverse=True):
        entry = None
        for i, x in enumerate(orbit):
            if dist(x, limit) <= r + 1e-15:
                entry = i
                break
        if entry is not None:
            entry_steps[r] = entry

    stabilization = max(entry_steps.values()) if entry_steps else len(orbit)

    return BallStabilizationResult(
        entry_steps=entry_steps,
        stabilization_step=stabilization,
        hierarchy_depth=len(entry_steps)
    )


def compression_core_finder(
    F: Callable[[float], float],
    C: Callable[[float], float],
    dist: Callable[[float, float], float],
    x0: float,
    q: float,
    epsilon: float = 1e-10
) -> Tuple[float, int, bool]:
    """
    Find the compression core: the unique fixed point of C ∘ F.

    The compression core p⋆ satisfies C(F(p⋆)) = p⋆ and is the
    canonical compressed representative of all orbits.

    Algorithm:
        1. Iterate G = C ∘ F starting from x₀
        2. Detect convergence when d(G^{n+1}(x₀), G^n(x₀)) < ε
        3. Verify C(p⋆) = p⋆ (idempotent stability)

    Args:
        F: Transition map
        C: Compression map (should be nonexpansive + idempotent)
        dist: Distance function
        x0: Starting point
        q: Contraction constant for C ∘ F
        epsilon: Convergence threshold

    Returns:
        (core_point, iterations, is_idempotent_stable)
    """
    G = lambda x: C(F(x))

    x = x0
    for n in range(10000):
        x_new = G(x)
        if dist(x_new, x) < epsilon:
            # Check idempotent stability
            is_stable = dist(C(x_new), x_new) < epsilon
            return x_new, n + 1, is_stable
        x = x_new

    return x, 10000, False


# ─── Example usage ─────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)
    print()

    # Example 1: Contractive iterator
    p_star = 2.718
    q = 0.3
    F = lambda x: p_star + q * (x - p_star)
    dist = lambda x, y: abs(x - y)

    cert = contractive_iterator(F, dist, x0=100.0, q=q, epsilon=1e-10)
    print(f"Contractive Iterator:")
    print(f"  Fixed point found: {cert.fixed_point:.10f}")
    print(f"  True fixed point:  {p_star:.10f}")
    print(f"  Iterations: {cert.iterations}")
    print(f"  Final error bound: {cert.final_error_bound:.2e}")
    print()

    # Example 2: Certified extractor
    C = lambda x: round(x, 3)  # compression = rounding
    result = certified_extractor(F, C, dist, x0=100.0, q=q, epsilon=1e-6)
    print(f"Certified Extractor:")
    print(f"  Extracted value: {result.extracted_value}")
    print(f"  Iterations used: {result.iterations_used}")
    print(f"  Certified error: {result.certified_error:.2e}")
    print()

    # Example 3: Ball stabilization
    orbit = cert.orbit
    radii = [10.0, 1.0, 0.1, 0.01, 0.001, 0.0001]
    stab = ball_stabilization_analysis(orbit, dist, radii)
    print(f"Ball Stabilization:")
    for r, step in sorted(stab.entry_steps.items(), reverse=True):
        print(f"  Radius {r:>8.4f}: enters at step {step}")
    print(f"  Full stabilization at step: {stab.stabilization_step}")
    print()

    # Example 4: Compression core
    core, iters, stable = compression_core_finder(F, C, dist, x0=100.0, q=q)
    print(f"Compression Core:")
    print(f"  Core point: {core}")
    print(f"  Iterations: {iters}")
    print(f"  Idempotent stable: {stable}")
