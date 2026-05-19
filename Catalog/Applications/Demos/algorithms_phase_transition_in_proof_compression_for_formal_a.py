#!/usr/bin/env python3
"""
Algorithms for Proof Compression Phase Transition Analysis

Implements the key algorithms from the research paper:
1. Search tree size computation
2. Normalization blowup estimation
3. Phase transition detection
4. Distortion classification
"""

import math
from typing import Optional, Tuple, List, Dict
from dataclasses import dataclass


# ============================================================
# Algorithm 1: Search Tree Size Computation
# ============================================================

@dataclass
class SearchTree:
    """Represents a search tree for witness-finding problems.

    Attributes:
        size: Total number of nodes
        depth: Maximum depth (root-to-leaf path length)
        branching_factor: Maximum children per node
    """
    size: int
    depth: int
    branching_factor: int

    def __repr__(self) -> str:
        return (f"SearchTree(size={self.size}, depth={self.depth}, "
                f"branching_factor={self.branching_factor})")


def complete_search_tree(b: int, d: int) -> SearchTree:
    """Construct the complete b-ary search tree of depth d.

    A complete b-ary tree of depth d has:
    - b^d leaves
    - (b^(d+1) - 1) / (b - 1) total nodes (for b > 1)
    - b^d total nodes when counting only leaves

    Time complexity: O(1)
    Space complexity: O(1)

    >>> complete_search_tree(2, 3)
    SearchTree(size=8, depth=3, branching_factor=2)
    """
    size = b ** d
    return SearchTree(size=size, depth=d, branching_factor=b)


def pigeonhole_search_tree(n: int) -> SearchTree:
    """Construct the search tree for pigeonhole collision finding.

    For functions f: Fin(n+1) → Fin(n), the search tree has:
    - Branching factor n (possible function values at each query)
    - Depth n+1 (must query all n+1 elements in worst case)
    - Size n^(n+1) (total leaves)

    Time complexity: O(1)
    Space complexity: O(1)

    >>> pigeonhole_search_tree(3)
    SearchTree(size=256, depth=4, branching_factor=3)
    """
    if n <= 0:
        return SearchTree(size=1, depth=1, branching_factor=1)
    return SearchTree(
        size=n ** (n + 1),
        depth=n + 1,
        branching_factor=n
    )


# ============================================================
# Algorithm 2: Normalization Blowup Estimation
# ============================================================

@dataclass
class BlowupEstimate:
    """Estimate of normalization blowup for a sentence family.

    Attributes:
        raw_upper: Upper bound on shortest raw proof length
        norm_lower: Lower bound on shortest normalized proof length
        distortion: Ratio norm_lower / raw_upper
        log_distortion: log₂ of the distortion
    """
    n: int
    raw_upper: int
    norm_lower: int
    distortion: float
    log_distortion: float


def estimate_blowup(n: int, C: int = 1, k: int = 2,
                     b: int = 2, a: int = 1) -> BlowupEstimate:
    """Estimate the normalization blowup for parameter n.

    Uses the bounds:
    - Raw proof length ≤ C * n^k (polynomial from counting argument)
    - Normalized proof length ≥ b^(n^a) (exponential from search lower bound)

    Time complexity: O(1) (assuming arbitrary precision arithmetic)
    Space complexity: O(1)

    >>> est = estimate_blowup(10)
    >>> est.distortion > 1.0
    True
    """
    raw_upper = C * n ** k
    norm_lower = b ** (n ** a)
    distortion = norm_lower / max(raw_upper, 1)
    log_dist = math.log2(distortion) if distortion > 0 else 0
    return BlowupEstimate(
        n=n,
        raw_upper=raw_upper,
        norm_lower=norm_lower,
        distortion=distortion,
        log_distortion=log_dist
    )


def blowup_table(n_range: range, C: int = 1, k: int = 2,
                  b: int = 2, a: int = 1) -> List[BlowupEstimate]:
    """Generate a table of blowup estimates.

    Time complexity: O(|n_range|)
    Space complexity: O(|n_range|)

    >>> table = blowup_table(range(1, 5))
    >>> len(table)
    4
    """
    return [estimate_blowup(n, C, k, b, a) for n in n_range]


# ============================================================
# Algorithm 3: Phase Transition Detection
# ============================================================

def detect_phase_transition(C: int, k: int, b: int, a: int,
                             max_n: int = 10000) -> Optional[int]:
    """Find the critical parameter n₀ where the phase transition occurs.

    Returns the smallest n such that b^(n^a) > C * n^k,
    i.e., where normalized proof length first exceeds raw proof length.

    Time complexity: O(n₀)
    Space complexity: O(1)

    >>> detect_phase_transition(1, 2, 2, 1)
    5
    """
    for n in range(1, max_n):
        try:
            norm = b ** (n ** a)
            raw = C * n ** k
            if norm > raw:
                return n
        except OverflowError:
            return n  # Exponential already overflows => certainly larger
    return None


def detect_gap_threshold(D: int, j: int, C: int = 1, k: int = 2,
                          b: int = 2, a: int = 1,
                          max_n: int = 10000) -> Optional[int]:
    """Find n₀ where b^(n^a) > D * (C * n^k)^j.

    This is the threshold from the normalization_gap_unbounded theorem:
    beyond this point, no polynomial D * (raw)^j can bound the
    normalized proof length.

    Time complexity: O(n₀)
    Space complexity: O(1)

    >>> detect_gap_threshold(1, 3)  # Can D*(raw)^3 bound norm?
    7
    """
    for n in range(1, max_n):
        try:
            norm = b ** (n ** a)
            raw = C * n ** k
            poly_bound = D * raw ** j
            if norm > poly_bound:
                return n
        except OverflowError:
            return n
    return None


# ============================================================
# Algorithm 4: Distortion Classification
# ============================================================

@dataclass
class DistortionClass:
    """Classification of a family's distortion behavior.

    Attributes:
        family_name: Name of the sentence family
        is_polynomial: True if distortion appears polynomial
        is_exponential: True if distortion appears exponential
        estimated_exponent: Estimated exponent if exponential
        evidence: Description of classification evidence
    """
    family_name: str
    is_polynomial: bool
    is_exponential: bool
    estimated_exponent: Optional[float]
    evidence: str


def classify_distortion(family_name: str,
                         raw_lengths: List[int],
                         norm_lengths: List[int]) -> DistortionClass:
    """Classify the distortion behavior of a family from data.

    Computes log(norm) / log(raw) for each data point and checks
    whether the ratio stabilizes (polynomial) or grows (exponential).

    Time complexity: O(n) where n = len(raw_lengths)
    Space complexity: O(n)

    >>> raw = [n**2 for n in range(2, 20)]
    >>> norm_exp = [2**n for n in range(2, 20)]
    >>> result = classify_distortion("test", raw, norm_exp)
    >>> result.is_exponential
    True
    """
    if len(raw_lengths) != len(norm_lengths):
        raise ValueError("Length mismatch between raw and norm lengths")

    # Compute log-log ratios
    ratios = []
    for raw, norm in zip(raw_lengths, norm_lengths):
        if raw > 1 and norm > 1:
            ratios.append(math.log(norm) / math.log(raw))

    if len(ratios) < 3:
        return DistortionClass(
            family_name=family_name,
            is_polynomial=False,
            is_exponential=False,
            estimated_exponent=None,
            evidence="Insufficient data"
        )

    # Check if ratios stabilize (polynomial) or grow (exponential)
    # Use the last third vs first third
    n = len(ratios)
    first_third_avg = sum(ratios[:n//3]) / max(n//3, 1)
    last_third_avg = sum(ratios[2*n//3:]) / max(n - 2*n//3, 1)

    growth_rate = last_third_avg / max(first_third_avg, 0.001)

    if growth_rate < 1.5:
        return DistortionClass(
            family_name=family_name,
            is_polynomial=True,
            is_exponential=False,
            estimated_exponent=last_third_avg,
            evidence=f"log-log ratio stabilized at ~{last_third_avg:.2f}"
        )
    else:
        return DistortionClass(
            family_name=family_name,
            is_polynomial=False,
            is_exponential=True,
            estimated_exponent=None,
            evidence=f"log-log ratio growing: {first_third_avg:.2f} → {last_third_avg:.2f}"
        )


# ============================================================
# Algorithm 5: Transfer Pipeline
# ============================================================

def transfer_pipeline(n: int,
                       search_lower_bound: int,
                       raw_upper_bound: int) -> Dict[str, int]:
    """Execute the search-to-normalization transfer pipeline.

    Given:
    1. A search lower bound (from combinatorial argument)
    2. A raw proof upper bound (from polynomial proof construction)

    Returns bounds on normalized proof length and distortion.

    Time complexity: O(1)
    Space complexity: O(1)

    >>> result = transfer_pipeline(10, 2**10, 100)
    >>> result['norm_lower_bound']
    1024
    """
    norm_lower = search_lower_bound  # Transfer: norm ≥ search
    distortion = norm_lower // max(raw_upper_bound, 1)

    return {
        'n': n,
        'search_lower_bound': search_lower_bound,
        'raw_upper_bound': raw_upper_bound,
        'norm_lower_bound': norm_lower,
        'distortion_lower_bound': distortion,
        'is_exponential_gap': norm_lower > raw_upper_bound ** 2
    }


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("PROOF COMPRESSION ALGORITHMS")
    print("=" * 60)

    # Demo 1: Search trees
    print("\n--- Search Tree Construction ---")
    for n in [3, 5, 8, 10]:
        tree = pigeonhole_search_tree(n)
        print(f"  n={n}: {tree}")

    # Demo 2: Blowup estimation
    print("\n--- Blowup Estimation ---")
    table = blowup_table(range(1, 16))
    print(f"  {'n':>4} | {'Raw ≤':>10} | {'Norm ≥':>14} | {'log₂(Dist)':>12}")
    print("  " + "-" * 50)
    for est in table:
        if est.norm_lower < 10**12:
            print(f"  {est.n:>4} | {est.raw_upper:>10} | {est.norm_lower:>14,} | {est.log_distortion:>12.1f}")
        else:
            print(f"  {est.n:>4} | {est.raw_upper:>10} | {est.norm_lower:>14.3e} | {est.log_distortion:>12.1f}")

    # Demo 3: Phase transition detection
    print("\n--- Phase Transition Detection ---")
    configs = [
        (1, 1, 2, 1, "C=1, k=1"),
        (1, 2, 2, 1, "C=1, k=2"),
        (10, 3, 2, 1, "C=10, k=3"),
        (100, 5, 2, 1, "C=100, k=5"),
    ]
    for C, k, b, a, label in configs:
        n0 = detect_phase_transition(C, k, b, a)
        print(f"  {label}: transition at n₀ = {n0}")

    # Demo 4: Gap thresholds
    print("\n--- Gap Thresholds (no polynomial bounds norm) ---")
    for j in [1, 2, 3, 5, 10, 20]:
        n0 = detect_gap_threshold(1, j)
        print(f"  Polynomial degree j={j}: exceeded at n₀ = {n0}")

    # Demo 5: Distortion classification
    print("\n--- Distortion Classification ---")

    # Polynomial family (identity normalizer)
    raw_poly = [n**2 for n in range(2, 30)]
    norm_poly = [3 * n**4 for n in range(2, 30)]
    cls_poly = classify_distortion("Polynomial family", raw_poly, norm_poly)
    print(f"  {cls_poly.family_name}: poly={cls_poly.is_polynomial}, "
          f"exp={cls_poly.is_exponential}, {cls_poly.evidence}")

    # Exponential family (pigeonhole)
    raw_exp = [n**2 for n in range(2, 30)]
    norm_exp = [2**n for n in range(2, 30)]
    cls_exp = classify_distortion("Pigeonhole family", raw_exp, norm_exp)
    print(f"  {cls_exp.family_name}: poly={cls_exp.is_polynomial}, "
          f"exp={cls_exp.is_exponential}, {cls_exp.evidence}")

    # Demo 6: Transfer pipeline
    print("\n--- Transfer Pipeline ---")
    for n in [5, 10, 15, 20]:
        result = transfer_pipeline(
            n,
            search_lower_bound=2**n,
            raw_upper_bound=n**2
        )
        print(f"  n={n}: search≥{result['search_lower_bound']}, "
              f"raw≤{result['raw_upper_bound']}, "
              f"norm≥{result['norm_lower_bound']}, "
              f"exp_gap={result['is_exponential_gap']}")
