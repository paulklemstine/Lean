"""
Algorithms for Core-Collapse Entropy Analysis

Implements the key computational primitives from the formally verified theory:
feature statistics, majority core construction, collision entropy, and
semantic graph collapse prediction.

All algorithms operate on families of feature sets represented as
lists of frozensets (or sets).
"""

from __future__ import annotations
from typing import Sequence, FrozenSet, Set, Any
from collections import Counter
import math


def feature_support(family: Sequence[Set[Any]]) -> Set[Any]:
    """Compute the feature universe: union of all feature sets.

    Time: O(total features across all sets)
    Space: O(|universe|)

    >>> feature_support([{1,2}, {2,3}, {3,4}])
    {1, 2, 3, 4}
    """
    result: set = set()
    for s in family:
        result |= s
    return result


def feature_count(family: Sequence[Set[Any]], f: Any) -> int:
    """Count how many members of the family contain feature f.

    Time: O(|family|)

    >>> feature_count([{1,2}, {2,3}, {3,4}], 2)
    2
    """
    return sum(1 for s in family if f in s)


def feature_frequencies(family: Sequence[Set[Any]]) -> dict[Any, float]:
    """Compute empirical feature frequencies p_f = n_f / N.

    Time: O(total features)
    Space: O(|universe|)

    >>> freq = feature_frequencies([{1,2}, {2,3}])
    >>> freq[2]
    1.0
    """
    N = len(family)
    if N == 0:
        return {}
    counts: Counter = Counter()
    for s in family:
        for f in s:
            counts[f] += 1
    return {f: c / N for f, c in counts.items()}


def collision_entropy_numerator(family: Sequence[Set[Any]]) -> int:
    """Compute ∑_f n_f * (N - n_f), the unnormalized collision entropy.

    This equals half the total pairwise symmetric-difference count
    (by the Disagreement Identity theorem).

    Time: O(total features)
    Space: O(|universe|)

    >>> collision_entropy_numerator([{1,2}, {2,3}, {3,4}])
    8
    """
    N = len(family)
    counts: Counter = Counter()
    for s in family:
        for f in s:
            counts[f] += 1
    return sum(c * (N - c) for c in counts.values())


def collision_entropy(family: Sequence[Set[Any]]) -> float:
    """Normalized collision entropy: ∑_f p_f(1-p_f).

    >>> round(collision_entropy([{1,2}, {2,3}, {3,4}]), 4)
    0.8889
    """
    N = len(family)
    if N == 0:
        return 0.0
    counts: Counter = Counter()
    for s in family:
        for f in s:
            counts[f] += 1
    return sum((c / N) * (1 - c / N) for c in counts.values())


def majority_core(family: Sequence[Set[Any]]) -> Set[Any]:
    """Compute the majority core: features present in strictly more than
    half the family members.

    Time: O(total features)
    Space: O(|universe|)

    >>> sorted(majority_core([{1,2,3}, {1,2,4}, {1,3,4}]))
    [1]
    """
    N = len(family)
    counts: Counter = Counter()
    for s in family:
        for f in s:
            counts[f] += 1
    return {f for f, c in counts.items() if 2 * c > N}


def symm_diff_card(s: Set[Any], t: Set[Any]) -> int:
    """Symmetric difference cardinality = Hamming distance on feature sets.

    >>> symm_diff_card({1,2,3}, {2,3,4})
    2
    """
    return len(s ^ t)  # Python set symmetric difference


def core_radius(family: Sequence[Set[Any]], core: Set[Any]) -> int:
    """Maximum distance from any family member to the given core.

    >>> core_radius([{1,2}, {2,3}, {1,2,3}], {1,2})
    1
    """
    if not family:
        return 0
    return max(symm_diff_card(s, core) for s in family)


def minority_count(family: Sequence[Set[Any]], f: Any) -> int:
    """min(n_f, N - n_f) for feature f."""
    N = len(family)
    nf = feature_count(family, f)
    return min(nf, N - nf)


def minority_mass(family: Sequence[Set[Any]]) -> int:
    """Sum of minority counts: ∑_f min(n_f, N - n_f).

    This equals the total distance to the majority core
    (by the Majority Core Distance Identity theorem).
    """
    N = len(family)
    counts: Counter = Counter()
    for s in family:
        for f in s:
            counts[f] += 1
    return sum(min(c, N - c) for c in counts.values())


def total_pairwise_distance(family: Sequence[Set[Any]]) -> int:
    """Compute ∑_s ∑_t |s △ t| by direct enumeration.

    Time: O(|family|^2 * avg_set_size)
    """
    total = 0
    fam = list(family)
    for s in fam:
        for t in fam:
            total += symm_diff_card(s, t)
    return total


def predicted_complete_threshold(family: Sequence[Set[Any]]) -> int:
    """Predict the complete-graph threshold as 2 * coreRadius(majorityCore).

    By Theorem 3, the semantic graph is complete at this threshold.
    """
    core = majority_core(family)
    return 2 * core_radius(family, core)


def verify_disagreement_identity(family: Sequence[Set[Any]]) -> bool:
    """Verify the Disagreement Identity theorem computationally.

    Returns True if ∑∑|s△t| == 2 * collisionEntropyNumerator.
    """
    lhs = total_pairwise_distance(family)
    rhs = 2 * collision_entropy_numerator(family)
    return lhs == rhs


def verify_majority_core_identity(family: Sequence[Set[Any]]) -> bool:
    """Verify the Majority Core Distance Identity theorem computationally.

    Returns True if ∑|s△core| == minorityMass.
    """
    core = majority_core(family)
    lhs = sum(symm_diff_card(s, core) for s in family)
    rhs = minority_mass(family)
    return lhs == rhs


def semantic_graph_edges(family: Sequence[Set[Any]], threshold: int) -> list[tuple[int, int]]:
    """Compute edges of the semantic graph at given threshold.

    Two distinct elements i, j are adjacent iff |S_i △ S_j| ≤ threshold.
    """
    edges = []
    fam = list(family)
    n = len(fam)
    for i in range(n):
        for j in range(i + 1, n):
            if symm_diff_card(fam[i], fam[j]) <= threshold:
                edges.append((i, j))
    return edges


def is_complete_at_threshold(family: Sequence[Set[Any]], threshold: int) -> bool:
    """Check if the semantic graph is complete at the given threshold."""
    n = len(family)
    expected_edges = n * (n - 1) // 2
    return len(semantic_graph_edges(family, threshold)) == expected_edges


def complete_threshold_exact(family: Sequence[Set[Any]]) -> int:
    """Find the exact minimum threshold at which the graph becomes complete."""
    fam = list(family)
    n = len(fam)
    if n <= 1:
        return 0
    max_dist = 0
    for i in range(n):
        for j in range(i + 1, n):
            d = symm_diff_card(fam[i], fam[j])
            if d > max_dist:
                max_dist = d
    return max_dist


if __name__ == "__main__":
    # Example usage
    family = [{1, 2, 3}, {1, 2, 4}, {1, 3, 4}, {2, 3, 4}]

    print("Family:", [sorted(s) for s in family])
    print("Feature support:", sorted(feature_support(family)))
    print("Feature frequencies:", feature_frequencies(family))
    print("Majority core:", sorted(majority_core(family)))
    print("Collision entropy numerator:", collision_entropy_numerator(family))
    print("Collision entropy (normalized):", round(collision_entropy(family), 4))
    print("Minority mass:", minority_mass(family))
    print("Core radius:", core_radius(family, majority_core(family)))
    print()
    print("Disagreement identity holds:", verify_disagreement_identity(family))
    print("Majority core identity holds:", verify_majority_core_identity(family))
    print()
    print("Exact complete threshold:", complete_threshold_exact(family))
    print("Predicted complete threshold:", predicted_complete_threshold(family))
    print("Graph complete at predicted threshold:",
          is_complete_at_threshold(family, predicted_complete_threshold(family)))
