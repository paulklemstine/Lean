#!/usr/bin/env python3
"""
Depth Gap Framework: Algorithms

Implements the core algorithms from the depth gap theory with
full complexity analysis and executable examples.
"""

from dataclasses import dataclass
from typing import Optional
import heapq
from collections import defaultdict


@dataclass(frozen=True)
class TheoremProfile:
    """Theorem profile with 5 structural features.

    Time complexity for creation: O(1)
    Space complexity: O(1)
    """
    defs_introduced: int
    type_changes: int
    perspective_shifts: int
    proof_size: int
    compression_score: int


# ── Algorithm 1: Depth Gap Computation ──────────────────────────────

def compute_depth_gap(corpus: list[TheoremProfile], target: TheoremProfile) -> int:
    """Compute the depth gap from corpus to target.

    Algorithm: Linear scan over corpus computing L1 distance on
    conceptual coordinates, return minimum.

    Time complexity: O(|K|) where |K| is corpus size
    Space complexity: O(1) additional space

    Args:
        corpus: Nonempty list of known theorem profiles
        target: Target theorem profile

    Returns:
        The minimum leap cost from any corpus element to target

    Example:
        >>> corpus = [TheoremProfile(0,0,0,10,5), TheoremProfile(1,0,0,20,15)]
        >>> compute_depth_gap(corpus, TheoremProfile(3,2,1,50,40))
        5
    """
    if not corpus:
        raise ValueError("Corpus must be nonempty")

    min_cost = float('inf')
    for s in corpus:
        cost = (abs(s.defs_introduced - target.defs_introduced) +
                abs(s.type_changes - target.type_changes) +
                abs(s.perspective_shifts - target.perspective_shifts))
        min_cost = min(min_cost, cost)
    return min_cost


# ── Algorithm 2: Nearest Neighbor with Certificate ──────────────────

def nearest_neighbor_certificate(
    corpus: list[TheoremProfile],
    target: TheoremProfile
) -> tuple[TheoremProfile, int, dict]:
    """Find nearest corpus element with a full certificate.

    Returns the nearest neighbor, the depth gap, and a certificate
    containing per-dimension distances for interpretability.

    Time complexity: O(|K|)
    Space complexity: O(1)

    Args:
        corpus: Nonempty list of known theorem profiles
        target: Target theorem profile

    Returns:
        Tuple of (nearest_profile, depth_gap, certificate_dict)

    Example:
        >>> corpus = [TheoremProfile(0,0,0,10,5)]
        >>> nn, gap, cert = nearest_neighbor_certificate(corpus, TheoremProfile(3,2,1,50,40))
        >>> gap
        6
    """
    if not corpus:
        raise ValueError("Corpus must be nonempty")

    best = None
    best_cost = float('inf')
    best_cert = {}

    for s in corpus:
        dd = abs(s.defs_introduced - target.defs_introduced)
        dt = abs(s.type_changes - target.type_changes)
        dp = abs(s.perspective_shifts - target.perspective_shifts)
        cost = dd + dt + dp
        if cost < best_cost:
            best = s
            best_cost = cost
            best_cert = {
                'defs_distance': dd,
                'types_distance': dt,
                'perspective_distance': dp,
                'total': cost,
                'dominant_dimension': max(
                    [('defs', dd), ('types', dt), ('perspective', dp)],
                    key=lambda x: x[1]
                )[0]
            }

    return best, best_cost, best_cert


# ── Algorithm 3: Derivative Classification ──────────────────────────

def classify_derivative(
    corpus: list[TheoremProfile],
    target: TheoremProfile,
    threshold: int
) -> dict:
    """Classify whether a target is derivative with full analysis.

    Time complexity: O(|K|)
    Space complexity: O(1)

    Args:
        corpus: Nonempty list of known theorem profiles
        target: Target theorem profile
        threshold: Derivativeness threshold τ

    Returns:
        Classification result with certificate
    """
    nn, gap, cert = nearest_neighbor_certificate(corpus, target)
    is_deriv = gap <= threshold

    return {
        'is_derivative': is_deriv,
        'depth_gap': gap,
        'threshold': threshold,
        'margin': threshold - gap if is_deriv else gap - threshold,
        'nearest_neighbor': nn,
        'certificate': cert,
        'classification': 'DERIVATIVE' if is_deriv else 'NOVEL'
    }


# ── Algorithm 4: Batch Novelty Scoring ──────────────────────────────

def batch_novelty_score(
    corpus: list[TheoremProfile],
    candidates: list[TheoremProfile],
    threshold: int
) -> list[dict]:
    """Score a batch of candidates for novelty relative to corpus.

    Time complexity: O(|K| × |candidates|)
    Space complexity: O(|candidates|)

    Args:
        corpus: Known theorem corpus
        candidates: List of candidate theorem profiles to score
        threshold: Derivativeness threshold

    Returns:
        List of scoring results, sorted by depth gap (most novel first)
    """
    results = []
    for i, cand in enumerate(candidates):
        result = classify_derivative(corpus, cand, threshold)
        result['index'] = i
        results.append(result)

    results.sort(key=lambda r: -r['depth_gap'])
    return results


# ── Algorithm 5: Typed Leap Path Finder ─────────────────────────────

def find_typed_leap_path(
    source: TheoremProfile,
    target: TheoremProfile
) -> list[tuple[str, TheoremProfile, TheoremProfile]]:
    """Find an optimal typed leap path from source to target.

    Constructs a sequence of single-coordinate unit leaps that realizes
    the leap cost exactly. Each leap changes exactly one of the three
    conceptual coordinates by exactly 1.

    Time complexity: O(leap_cost(source, target))
    Space complexity: O(leap_cost(source, target))

    Args:
        source: Starting profile
        target: Ending profile

    Returns:
        List of (leap_kind, from_profile, to_profile) tuples
    """
    path = []
    current = source

    # Process each dimension in sequence
    dimensions = [
        ('introDef', 'defs_introduced'),
        ('typeChange', 'type_changes'),
        ('perspectiveShift', 'perspective_shifts'),
    ]

    for kind, attr in dimensions:
        while getattr(current, attr) != getattr(target, attr):
            delta = 1 if getattr(current, attr) < getattr(target, attr) else -1
            new_vals = {
                'defs_introduced': current.defs_introduced,
                'type_changes': current.type_changes,
                'perspective_shifts': current.perspective_shifts,
                'proof_size': current.proof_size,
                'compression_score': current.compression_score,
            }
            new_vals[attr] += delta
            next_profile = TheoremProfile(**new_vals)
            path.append((kind, current, next_profile))
            current = next_profile

    return path


# ── Algorithm 6: Corpus Coverage Analysis ───────────────────────────

def corpus_coverage_analysis(
    corpus: list[TheoremProfile],
    max_coord: int = 10,
    thresholds: list[int] = None
) -> dict:
    """Analyze how well a corpus covers the profile space.

    Computes coverage statistics: what fraction of the grid [0..max_coord]³
    is derivative at various thresholds.

    Time complexity: O(|K| × max_coord³)
    Space complexity: O(max_coord³)

    Args:
        corpus: Known theorem corpus
        max_coord: Maximum coordinate value for grid
        thresholds: List of threshold values to evaluate

    Returns:
        Coverage statistics dictionary
    """
    if thresholds is None:
        thresholds = [1, 2, 3, 5, 10]

    total = (max_coord + 1) ** 3
    gap_distribution = defaultdict(int)

    # Compute all depth gaps
    import itertools
    for d, t, p in itertools.product(range(max_coord + 1), repeat=3):
        target = TheoremProfile(d, t, p, 0, 0)
        gap = compute_depth_gap(corpus, target)
        gap_distribution[gap] += 1

    # Coverage at each threshold
    coverage = {}
    for tau in thresholds:
        derivative_count = sum(
            count for gap, count in gap_distribution.items() if gap <= tau
        )
        coverage[tau] = derivative_count / total

    max_gap = max(gap_distribution.keys())
    mean_gap = sum(g * c for g, c in gap_distribution.items()) / total

    return {
        'total_profiles': total,
        'corpus_size': len(corpus),
        'max_gap': max_gap,
        'mean_gap': round(mean_gap, 2),
        'coverage_by_threshold': coverage,
        'gap_distribution': dict(sorted(gap_distribution.items())),
    }


# ── Example Usage ───────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    corpus = [
        TheoremProfile(0, 0, 0, 10, 5),
        TheoremProfile(2, 1, 0, 25, 20),
        TheoremProfile(0, 0, 2, 15, 10),
    ]

    target = TheoremProfile(4, 3, 1, 60, 45)

    # Algorithm 1
    print("\n--- Algorithm 1: Depth Gap ---")
    gap = compute_depth_gap(corpus, target)
    print(f"  Depth gap: {gap}")

    # Algorithm 2
    print("\n--- Algorithm 2: Nearest Neighbor Certificate ---")
    nn, gap, cert = nearest_neighbor_certificate(corpus, target)
    print(f"  Nearest: ({nn.defs_introduced},{nn.type_changes},{nn.perspective_shifts})")
    print(f"  Gap: {gap}")
    print(f"  Certificate: {cert}")

    # Algorithm 3
    print("\n--- Algorithm 3: Classification ---")
    for tau in [3, 5, 8]:
        result = classify_derivative(corpus, target, tau)
        print(f"  τ={tau}: {result['classification']} (margin={result['margin']})")

    # Algorithm 4
    print("\n--- Algorithm 4: Batch Scoring ---")
    candidates = [
        TheoremProfile(0, 0, 0, 12, 6),
        TheoremProfile(1, 1, 1, 20, 15),
        TheoremProfile(5, 5, 5, 100, 80),
        TheoremProfile(3, 2, 1, 40, 30),
    ]
    scores = batch_novelty_score(corpus, candidates, threshold=5)
    for s in scores:
        t = candidates[s['index']]
        print(f"  ({t.defs_introduced},{t.type_changes},{t.perspective_shifts}): "
              f"gap={s['depth_gap']} → {s['classification']}")

    # Algorithm 5
    print("\n--- Algorithm 5: Typed Leap Path ---")
    source = TheoremProfile(0, 0, 0, 10, 5)
    dest = TheoremProfile(2, 1, 1, 30, 22)
    path = find_typed_leap_path(source, dest)
    for kind, src, tgt in path:
        print(f"  {kind:<20} ({src.defs_introduced},{src.type_changes},{src.perspective_shifts}) → "
              f"({tgt.defs_introduced},{tgt.type_changes},{tgt.perspective_shifts})")

    # Algorithm 6
    print("\n--- Algorithm 6: Coverage Analysis ---")
    analysis = corpus_coverage_analysis(corpus, max_coord=8, thresholds=[1, 3, 5, 8])
    print(f"  Mean gap: {analysis['mean_gap']}")
    print(f"  Max gap: {analysis['max_gap']}")
    for tau, cov in analysis['coverage_by_threshold'].items():
        print(f"  Coverage at τ={tau}: {cov:.1%}")
