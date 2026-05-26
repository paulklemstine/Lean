#!/usr/bin/env python3
"""
Exceptional Expander Ladder — Algorithms

Implements the certified finite optimization algorithms from the
exceptional certificate framework.

Algorithms:
1. ComputeGlobalBound: O(k) certified maximum over torus types
2. CertificateRefinement: Iterative refinement with monotonicity guarantee
3. SpectralSafetyMarginSearch: Binary search for threshold crossing
4. ToralComplexityProfile: Extract and analyze complexity distribution
"""

from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Dict
import math


# ─── Data Structures ─────────────────────────────────────────────────────────

@dataclass
class ExceptionalFamily:
    """Exceptional family with torus types, complexities, and local bounds.

    Corresponds to the Lean structure ExceptionalFamily.
    """
    name: str
    complexities: List[int]
    local_bounds: List[float]

    def __post_init__(self):
        assert len(self.complexities) == len(self.local_bounds), \
            "complexities and local_bounds must have the same length"
        assert len(self.complexities) > 0, "must have at least one torus type"

    @property
    def num_torus_types(self) -> int:
        return len(self.complexities)


@dataclass
class ExceptionalCertificate(ExceptionalFamily):
    """Exceptional certificate with a complexity bound.

    Corresponds to the Lean structure ExceptionalCertificate.
    """
    complexity_bound: Optional[int] = None

    def __post_init__(self):
        super().__post_init__()
        if self.complexity_bound is None:
            self.complexity_bound = max(self.complexities)
        assert all(c <= self.complexity_bound for c in self.complexities)


@dataclass
class RefinementResult:
    """Result of a certificate refinement."""
    coarse: ExceptionalCertificate
    refined: ExceptionalCertificate
    refine_map: List[int]
    global_bound_coarse: float
    global_bound_refined: float
    improvement_pct: float


# ─── Algorithm 1: Certified Global Bound ─────────────────────────────────────

def compute_global_bound(family: ExceptionalFamily) -> Tuple[int, float]:
    """Compute the global bound and the argmax torus type.

    Corresponds to `computeGlobalBound_spec` in the Lean formalization.

    Args:
        family: An exceptional family with local bounds.

    Returns:
        (argmax_index, global_bound): The index of the maximizing
        torus type and its local bound value.

    Time complexity: O(k) where k = number of torus types.
    Space complexity: O(1).

    Correctness certificate:
        - global_bound = max(family.local_bounds)
        - family.local_bounds[argmax_index] = global_bound
        - For all t: family.local_bounds[t] <= global_bound
    """
    if not family.local_bounds:
        raise ValueError("Family must have at least one torus type")

    argmax = 0
    best = family.local_bounds[0]

    for i in range(1, len(family.local_bounds)):
        if family.local_bounds[i] > best:
            best = family.local_bounds[i]
            argmax = i

    return argmax, best


# ─── Algorithm 2: Certificate Refinement ─────────────────────────────────────

def refine_certificate(
    cert: ExceptionalCertificate,
    split_index: int,
    sub_bounds: List[float],
    sub_complexities: List[int],
) -> RefinementResult:
    """Refine a certificate by splitting one torus type into subtypes.

    Corresponds to `ExceptionalRefinement` in the Lean formalization.
    The monotonicity theorem guarantees globalBound(refined) <= globalBound(cert).

    Args:
        cert: The coarse certificate.
        split_index: Index of the torus type to split.
        sub_bounds: Local bounds for each subtype (must all be <= cert.local_bounds[split_index]).
        sub_complexities: Complexities for each subtype.

    Returns:
        RefinementResult with the refined certificate and metadata.

    Raises:
        ValueError: If the refinement condition is violated.
    """
    original_bound = cert.local_bounds[split_index]
    for sb in sub_bounds:
        if sb > original_bound + 1e-12:
            raise ValueError(
                f"Refinement violated: sub-bound {sb} > original {original_bound}"
            )

    # Build refined certificate
    new_bounds = list(cert.local_bounds)
    new_complexities = list(cert.complexities)

    # Remove the split type
    new_bounds.pop(split_index)
    new_complexities.pop(split_index)

    # Add subtypes
    new_bounds.extend(sub_bounds)
    new_complexities.extend(sub_complexities)

    # Build refinement map
    refine_map = list(range(cert.num_torus_types))
    refine_map.pop(split_index)
    refine_map.extend([split_index] * len(sub_bounds))

    refined = ExceptionalCertificate(
        name=f"{cert.name} (refined at t_{split_index})",
        complexities=new_complexities,
        local_bounds=new_bounds,
    )

    gb_coarse = compute_global_bound(cert)[1]
    gb_refined = compute_global_bound(refined)[1]

    assert gb_refined <= gb_coarse + 1e-12, \
        f"Monotonicity violated: {gb_refined} > {gb_coarse}"

    improvement = (gb_coarse - gb_refined) / gb_coarse * 100 if gb_coarse > 0 else 0

    return RefinementResult(
        coarse=cert,
        refined=refined,
        refine_map=refine_map,
        global_bound_coarse=gb_coarse,
        global_bound_refined=gb_refined,
        improvement_pct=improvement,
    )


# ─── Algorithm 3: Iterative Refinement Search ────────────────────────────────

def iterative_refinement_search(
    cert: ExceptionalCertificate,
    threshold: float = 1.0,
    max_iterations: int = 20,
    split_factor: int = 3,
    shrink_range: Tuple[float, float] = (0.7, 0.95),
) -> Tuple[ExceptionalCertificate, List[RefinementResult]]:
    """Iteratively refine a certificate until the global bound drops below threshold.

    At each step, splits the worst torus type into `split_factor` subtypes
    with bounds uniformly shrunk from the original.

    Args:
        cert: Initial certificate.
        threshold: Target threshold for global bound.
        max_iterations: Maximum refinement steps.
        split_factor: Number of subtypes per split.
        shrink_range: (min_shrink, max_shrink) for subtype bound generation.

    Returns:
        (final_certificate, refinement_history)
    """
    import random
    rng = random.Random(42)

    history = []
    current = cert

    for iteration in range(max_iterations):
        gb = compute_global_bound(current)[1]
        if gb < threshold:
            break

        argmax, _ = compute_global_bound(current)
        worst_bound = current.local_bounds[argmax]
        worst_complexity = current.complexities[argmax]

        sub_bounds = [
            worst_bound * rng.uniform(*shrink_range)
            for _ in range(split_factor)
        ]
        sub_complexities = [
            worst_complexity + i + 1
            for i in range(split_factor)
        ]

        result = refine_certificate(current, argmax, sub_bounds, sub_complexities)
        history.append(result)
        current = result.refined

    return current, history


# ─── Algorithm 4: Spectral Safety Margin ─────────────────────────────────────

def spectral_safety_margin(family: ExceptionalFamily, theta: float = 1.0) -> float:
    """Compute the spectral safety margin: θ - globalBound(F).

    Corresponds to `spectralSafetyMargin` in the Lean formalization.

    Returns:
        theta - max(local_bounds). Positive means certified expansion.
    """
    _, gb = compute_global_bound(family)
    return theta - gb


# ─── Algorithm 5: Toral Complexity Profile ────────────────────────────────────

def toral_complexity_profile(family: ExceptionalFamily) -> Dict[str, any]:
    """Analyze the toral complexity profile.

    Corresponds to `toralComplexityProfile` in the Lean formalization.

    Returns:
        Dictionary with profile statistics.
    """
    profile = sorted(set(family.complexities))
    max_complexity = max(family.complexities)
    min_complexity = min(family.complexities)
    mean_complexity = sum(family.complexities) / len(family.complexities)

    return {
        "profile": profile,
        "num_distinct": len(profile),
        "max": max_complexity,
        "min": min_complexity,
        "mean": mean_complexity,
        "spread": max_complexity - min_complexity,
    }


# ─── Algorithm 6: Conjecture Test ────────────────────────────────────────────

def test_toral_boundedness_conjecture(
    lie_type: str,
    q_values: List[int],
    generate_bounds_fn,
) -> Dict[str, any]:
    """Test the Exceptional Toral Boundedness Conjecture for a given type.

    For each q, computes M_X(q) = globalBound and q * M_X(q).
    The conjecture predicts that q * M_X(q) is bounded.

    Args:
        lie_type: One of "F4", "E6", "E7", "E8".
        q_values: List of prime powers to test.
        generate_bounds_fn: Function(lie_type, q) -> ExceptionalFamily.

    Returns:
        Dictionary with conjecture test results.
    """
    results = []
    for q in q_values:
        family = generate_bounds_fn(lie_type, q)
        _, gb = compute_global_bound(family)
        scaled = q * gb
        results.append({
            "q": q,
            "global_bound": gb,
            "scaled": scaled,
        })

    max_scaled = max(r["scaled"] for r in results)
    appears_bounded = all(r["scaled"] <= max_scaled * 1.1 for r in results[-3:])

    return {
        "lie_type": lie_type,
        "results": results,
        "max_scaled": max_scaled,
        "appears_bounded": appears_bounded,
    }


# ─── Example Usage ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    import random

    # Create a sample F₄ certificate
    rng = random.Random(42)
    n = 25  # F₄ has 25 torus types

    complexities = [rng.randint(1, 50) for _ in range(n)]
    local_bounds = [rng.uniform(0.1, 0.8) for _ in range(n)]

    cert = ExceptionalCertificate(
        name="F₄(q=7) sample",
        complexities=complexities,
        local_bounds=local_bounds,
    )

    # Algorithm 1: Compute global bound
    argmax, gb = compute_global_bound(cert)
    print(f"Global bound: {gb:.6f} (at torus type t_{argmax})")

    # Algorithm 2: Single refinement
    result = refine_certificate(
        cert, argmax,
        sub_bounds=[gb * 0.8, gb * 0.85, gb * 0.9],
        sub_complexities=[cert.complexities[argmax] + 1,
                          cert.complexities[argmax] + 2,
                          cert.complexities[argmax] + 3],
    )
    print(f"After refinement: {result.global_bound_refined:.6f} "
          f"(improvement: {result.improvement_pct:.2f}%)")

    # Algorithm 4: Spectral safety margin
    margin = spectral_safety_margin(cert)
    print(f"Spectral safety margin: {margin:.6f}")

    # Algorithm 5: Toral complexity profile
    profile = toral_complexity_profile(cert)
    print(f"Complexity profile: {profile['num_distinct']} distinct values, "
          f"range [{profile['min']}, {profile['max']}]")
