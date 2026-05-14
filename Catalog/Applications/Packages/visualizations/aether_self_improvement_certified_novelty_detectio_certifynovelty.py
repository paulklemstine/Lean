#!/usr/bin/env python3
"""
Algorithms for Certified Novelty Detection

Implements the core algorithms from the research paper with full
type hints, docstrings, and complexity analysis.
"""

import math
from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Callable, Dict
import heapq


@dataclass(frozen=True)
class TheoremDescriptor:
    """
    Structured descriptor for a mathematical theorem.

    Corresponds to the Lean TheoremDescriptor structure.
    Each field is a measurable feature that can be extracted
    from a formal theorem statement.
    """
    arity: int
    symbol_count: int
    quantifier_depth: int
    dependency_count: int
    has_induction: bool
    has_contradiction: bool
    name: str = ""

    def to_vector(self, weights: Optional[Dict[str, float]] = None) -> Tuple[float, ...]:
        """
        Embed descriptor into weighted Euclidean space.

        Args:
            weights: Optional dict mapping field names to scaling weights.
                     Default: uniform weights of 1.0.

        Returns:
            Tuple of weighted feature values.

        Complexity: O(d) where d = 6 (number of features).
        """
        w = weights or {}
        return (
            w.get('arity', 1.0) * float(self.arity),
            w.get('symbol_count', 1.0) * float(self.symbol_count),
            w.get('quantifier_depth', 1.0) * float(self.quantifier_depth),
            w.get('dependency_count', 1.0) * float(self.dependency_count),
            w.get('has_induction', 1.0) * (1.0 if self.has_induction else 0.0),
            w.get('has_contradiction', 1.0) * (1.0 if self.has_contradiction else 0.0),
        )


def euclidean_distance(v1: Tuple[float, ...], v2: Tuple[float, ...]) -> float:
    """
    Compute Euclidean distance between two vectors.

    Complexity: O(d) where d = len(v1).
    """
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(v1, v2)))


def manhattan_distance(v1: Tuple[float, ...], v2: Tuple[float, ...]) -> float:
    """
    Compute Manhattan (L1) distance between two vectors.

    Complexity: O(d).
    """
    return sum(abs(a - b) for a, b in zip(v1, v2))


def chebyshev_distance(v1: Tuple[float, ...], v2: Tuple[float, ...]) -> float:
    """
    Compute Chebyshev (L∞) distance between two vectors.

    Complexity: O(d).
    """
    return max(abs(a - b) for a, b in zip(v1, v2))


# ============================================================
# Algorithm 1: Novelty Certification (from Research Paper §6.1)
# ============================================================

def certify_novelty(
    candidate: TheoremDescriptor,
    catalog: List[TheoremDescriptor],
    delta: float,
    distance_fn: Callable = euclidean_distance,
    weights: Optional[Dict[str, float]] = None,
) -> Tuple[bool, float, Optional[TheoremDescriptor]]:
    """
    Algorithm 1: CertifyNovelty

    Determines whether a candidate theorem is certifiably novel
    w.r.t. a finite catalog under equivalence radius delta.

    By Theorem 3.1 (novelty_of_far_from_catalog):
      If all catalog distances exceed delta, the candidate is
      provably not equivalent to any catalog theorem.

    Args:
        candidate: Theorem descriptor to test.
        catalog: List of known theorem descriptors.
        delta: Equivalence radius.
        distance_fn: Metric function (default: Euclidean).
        weights: Optional feature weights for embedding.

    Returns:
        (is_novel, novelty_score, nearest_theorem)

    Complexity: O(|K| · d) where d is feature dimension.
    """
    if not catalog:
        return True, float('inf'), None

    cand_vec = candidate.to_vector(weights)
    best_dist = float('inf')
    best_match = None

    for thm in catalog:
        d = distance_fn(cand_vec, thm.to_vector(weights))
        if d < best_dist:
            best_dist = d
            best_match = thm

    return best_dist > delta, best_dist, best_match


# ============================================================
# Algorithm 2: Multi-Feature Certification (§6.3)
# ============================================================

def multi_feature_certify(
    x: TheoremDescriptor,
    y: TheoremDescriptor,
    tolerances: Dict[str, float],
) -> Tuple[bool, List[str]]:
    """
    Algorithm 2: MultiFeatureCertify

    Checks whether any single feature shows a gap beyond its
    tolerance, certifying non-equivalence.

    By Theorem 3.5 (not_equivalent_of_any_feature_gap):
      A gap in ANY feature suffices for certification.

    Args:
        x, y: Theorem descriptors to compare.
        tolerances: Dict mapping feature names to tolerance values.

    Returns:
        (is_certified_nonequivalent, list_of_gap_witnesses)

    Complexity: O(d).
    """
    gaps = []
    features = [
        ('arity', x.arity, y.arity),
        ('symbol_count', x.symbol_count, y.symbol_count),
        ('quantifier_depth', x.quantifier_depth, y.quantifier_depth),
        ('dependency_count', x.dependency_count, y.dependency_count),
    ]
    for name, xval, yval in features:
        tol = tolerances.get(name, float('inf'))
        diff = abs(xval - yval)
        if diff > tol:
            gaps.append(f"{name}: |{xval} - {yval}| = {diff} > {tol}")

    return len(gaps) > 0, gaps


# ============================================================
# Algorithm 3: K-Nearest Neighbors Novelty Analysis
# ============================================================

def k_nearest_analysis(
    candidate: TheoremDescriptor,
    catalog: List[TheoremDescriptor],
    k: int = 3,
    distance_fn: Callable = euclidean_distance,
    weights: Optional[Dict[str, float]] = None,
) -> List[Tuple[float, TheoremDescriptor]]:
    """
    Find the k nearest catalog theorems to a candidate.

    Useful for understanding the local neighborhood structure
    around a candidate theorem.

    Args:
        candidate: Theorem to analyze.
        catalog: Known theorems.
        k: Number of neighbors.
        distance_fn: Metric.
        weights: Feature weights.

    Returns:
        List of (distance, theorem) pairs, sorted by distance.

    Complexity: O(|K| log k) using a heap.
    """
    cand_vec = candidate.to_vector(weights)
    # Use a max-heap of size k
    heap: List[Tuple[float, int, TheoremDescriptor]] = []

    for i, thm in enumerate(catalog):
        d = distance_fn(cand_vec, thm.to_vector(weights))
        if len(heap) < k:
            heapq.heappush(heap, (-d, i, thm))
        elif d < -heap[0][0]:
            heapq.heapreplace(heap, (-d, i, thm))

    result = [(-neg_d, thm) for neg_d, _, thm in heap]
    result.sort(key=lambda x: x[0])
    return result


# ============================================================
# Algorithm 4: Catalog Coverage Analysis
# ============================================================

def catalog_coverage(
    catalog: List[TheoremDescriptor],
    delta: float,
    grid_resolution: int = 20,
    distance_fn: Callable = euclidean_distance,
) -> float:
    """
    Estimate the fraction of feature space covered by the catalog's
    equivalence balls (δ-neighborhoods).

    This gives an empirical estimate related to the packing bounds
    discussed in Section 9.2 of the research paper.

    Args:
        catalog: Known theorems.
        delta: Equivalence radius.
        grid_resolution: Points per dimension for grid sampling.
        distance_fn: Metric.

    Returns:
        Fraction of grid points within δ of some catalog theorem.
    """
    if not catalog:
        return 0.0

    # Determine bounding box from catalog
    vectors = [t.to_vector() for t in catalog]
    dim = len(vectors[0])
    mins = [min(v[i] for v in vectors) - 2 * delta for i in range(dim)]
    maxs = [max(v[i] for v in vectors) + 2 * delta for i in range(dim)]

    # Sample only first 2 dimensions for tractability
    total = 0
    covered = 0
    steps_x = grid_resolution
    steps_y = grid_resolution

    for ix in range(steps_x):
        for iy in range(steps_y):
            x = mins[0] + (maxs[0] - mins[0]) * ix / max(steps_x - 1, 1)
            y = mins[1] + (maxs[1] - mins[1]) * iy / max(steps_y - 1, 1)
            # Use first 2 coords, fix rest at mean
            point = (x, y) + tuple(
                sum(v[i] for v in vectors) / len(vectors)
                for i in range(2, dim)
            )
            total += 1
            for vec in vectors:
                if distance_fn(point, vec) <= delta:
                    covered += 1
                    break

    return covered / total if total > 0 else 0.0


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Create a small catalog
    catalog = [
        TheoremDescriptor(3, 12, 1, 3, False, False, "Pythagorean"),
        TheoremDescriptor(1, 18, 2, 5, False, True, "Euclid Primes"),
        TheoremDescriptor(2, 15, 1, 6, True, False, "Fermat Little"),
    ]

    candidate = TheoremDescriptor(4, 35, 3, 20, False, False, "Cauchy Residue")
    delta = 5.0

    # Algorithm 1
    is_novel, score, nearest = certify_novelty(candidate, catalog, delta)
    print(f"Novelty certification: {'NOVEL' if is_novel else 'UNCERTAIN'}")
    print(f"Score: {score:.2f}, Nearest: {nearest.name if nearest else 'N/A'}")

    # Algorithm 2
    tolerances = {'arity': 1, 'symbol_count': 5, 'quantifier_depth': 1}
    certified, gaps = multi_feature_certify(candidate, catalog[0], tolerances)
    print(f"\nFeature-gap certification: {certified}")
    for g in gaps:
        print(f"  Gap: {g}")

    # Algorithm 3
    neighbors = k_nearest_analysis(candidate, catalog, k=2)
    print(f"\n2-nearest neighbors:")
    for d, thm in neighbors:
        print(f"  {thm.name}: distance = {d:.2f}")

    # Algorithm 4
    coverage = catalog_coverage(catalog, delta)
    print(f"\nEstimated coverage at δ={delta}: {coverage:.1%}")
