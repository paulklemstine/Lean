"""
Algorithms for Causal Integration Theory

Type-hinted implementations of the core algorithms for computing
integrated information (Φ) and the Integration Complex.
"""

from typing import List, Set, Tuple, Optional
import itertools


def cut_weight(weight: List[List[float]], S: Set[int]) -> float:
    """Compute the bidirectional cut weight of subset S.

    Args:
        weight: n×n weight matrix (weight[i][j] = causal influence from i to j)
        S: subset of node indices

    Returns:
        Total weight of edges crossing the partition (S, Sᶜ)
    """
    n = len(weight)
    Sc = set(range(n)) - S
    forward = sum(weight[i][j] for i in S for j in Sc)
    backward = sum(weight[i][j] for i in Sc for j in S)
    return forward + backward


def compute_phi(weight: List[List[float]]) -> Tuple[float, Optional[Set[int]]]:
    """Compute integrated information Φ and the minimum information partition.

    Args:
        weight: n×n nonnegative weight matrix

    Returns:
        (phi_value, minimizing_subset) or (0, None) if n < 2
    """
    n = len(weight)
    if n < 2:
        return 0.0, None

    min_cut = float('inf')
    min_partition: Optional[Set[int]] = None

    # Enumerate all nontrivial subsets (nonempty, not full)
    for r in range(1, n):
        for subset in itertools.combinations(range(n), r):
            S = set(subset)
            cw = cut_weight(weight, S)
            if cw < min_cut:
                min_cut = cw
                min_partition = S

    return min_cut, min_partition


def integration_complex(weight: List[List[float]], threshold: float) -> List[Set[int]]:
    """Compute the Integration Complex at a given threshold.

    Returns all nontrivial subsets with cut weight strictly above the threshold.

    Args:
        weight: n×n nonnegative weight matrix
        threshold: integration threshold t

    Returns:
        List of subsets in the Integration Complex ℐ_t
    """
    n = len(weight)
    complex_sets: List[Set[int]] = []

    for r in range(1, n):
        for subset in itertools.combinations(range(n), r):
            S = set(subset)
            cw = cut_weight(weight, S)
            if cw > threshold:
                complex_sets.append(S)

    return complex_sets


def integration_spectrum(weight: List[List[float]]) -> List[Tuple[Set[int], float]]:
    """Compute the full integration spectrum: all (subset, cutWeight) pairs.

    Args:
        weight: n×n nonnegative weight matrix

    Returns:
        Sorted list of (subset, cut_weight) pairs, ascending by cut weight
    """
    n = len(weight)
    spectrum: List[Tuple[Set[int], float]] = []

    for r in range(1, n):
        for subset in itertools.combinations(range(n), r):
            S = set(subset)
            cw = cut_weight(weight, S)
            spectrum.append((S, cw))

    spectrum.sort(key=lambda x: x[1])
    return spectrum


def is_reducible(weight: List[List[float]]) -> Tuple[bool, Optional[Set[int]]]:
    """Check if a network is reducible (has a nontrivial zero-cut partition).

    Args:
        weight: n×n nonnegative weight matrix

    Returns:
        (is_reducible, separating_subset)
    """
    n = len(weight)
    for r in range(1, n):
        for subset in itertools.combinations(range(n), r):
            S = set(subset)
            if cut_weight(weight, S) == 0.0:
                return True, S
    return False, None


def stoer_wagner_approx_phi(weight: List[List[float]]) -> float:
    """Approximate Φ using minimum s-t cut enumeration.

    For symmetric networks, this gives the exact minimum cut.
    For asymmetric networks, provides an upper bound.

    Args:
        weight: n×n nonnegative weight matrix

    Returns:
        Approximate Φ value
    """
    n = len(weight)
    if n < 2:
        return 0.0

    # Symmetrize for min-cut
    sym = [[weight[i][j] + weight[j][i] for j in range(n)] for i in range(n)]

    # Simple implementation: merge vertices iteratively
    # (Stoer-Wagner algorithm)
    vertices = list(range(n))
    merged: dict = {i: {i} for i in range(n)}
    min_cut = float('inf')

    adj = {i: {j: sym[i][j] for j in range(n) if j != i} for i in range(n)}

    while len(vertices) > 1:
        # MinimumCutPhase
        A = {vertices[0]}
        candidates = set(vertices[1:])
        last_added = vertices[0]
        second_last = vertices[0]

        while candidates:
            # Find most tightly connected vertex
            best_v = None
            best_w = -1.0
            for v in candidates:
                w_sum = sum(adj.get(v, {}).get(u, 0.0) for u in A)
                if w_sum > best_w:
                    best_w = w_sum
                    best_v = v
            second_last = last_added
            last_added = best_v
            A.add(best_v)
            candidates.remove(best_v)

        # Cut of the phase = weight of last added
        cut_of_phase = sum(adj.get(last_added, {}).get(u, 0.0) for u in vertices if u != last_added)
        min_cut = min(min_cut, cut_of_phase)

        # Merge last_added into second_last
        for v in vertices:
            if v != last_added and v != second_last:
                w1 = adj.get(second_last, {}).get(v, 0.0)
                w2 = adj.get(last_added, {}).get(v, 0.0)
                if second_last in adj and v in adj[second_last]:
                    adj[second_last][v] = w1 + w2
                elif second_last in adj:
                    adj[second_last][v] = w2
                if v in adj and second_last in adj[v]:
                    adj[v][second_last] = w1 + w2
                elif v in adj:
                    adj[v][second_last] = w2

        # Remove last_added
        if last_added in adj:
            del adj[last_added]
        for v in adj:
            if last_added in adj[v]:
                del adj[v][last_added]
        merged[second_last] = merged[second_last] | merged[last_added]
        vertices.remove(last_added)

    return min_cut
