"""
Algorithms for Phantom Topology Computation
=============================================

Core algorithms for computing phantom systems, consensus topologies,
phantom numbers, and disagreement metrics on finite sets.
"""

from itertools import combinations, chain
from typing import List, Set, Tuple, Optional, FrozenSet, Dict


# ============================================================
# Type aliases
# ============================================================
Element = int
Subset = FrozenSet[Element]
Topology = Set[Subset]


def powerset(s: List[Element]) -> List[Tuple[Element, ...]]:
    """Generate all subsets of a list as tuples."""
    return list(chain.from_iterable(combinations(s, r) for r in range(len(s) + 1)))


def to_frozensets(opens: List[Tuple]) -> Topology:
    """Convert a list of tuples to a set of frozensets."""
    return {frozenset(o) for o in opens}


# ============================================================
# Algorithm 1: Topology Validation
# ============================================================
def is_topology(X: List[Element], opens: List[Tuple]) -> bool:
    """
    Check if a collection of subsets forms a topology on X.

    A topology must:
    1. Contain the empty set and X itself
    2. Be closed under finite intersections
    3. Be closed under arbitrary unions

    Time complexity: O(2^|opens| * |opens|)
    Space complexity: O(|opens|)

    Args:
        X: The ground set
        opens: List of subsets (as tuples) proposed as open sets

    Returns:
        True if opens forms a valid topology on X
    """
    opens_set = {frozenset(o) for o in opens}
    X_frozen = frozenset(X)

    # Axiom 1: Empty set and X
    if frozenset() not in opens_set or X_frozen not in opens_set:
        return False

    # Axiom 2: Finite intersections (pairwise suffices by induction)
    for a in opens_set:
        for b in opens_set:
            if (a & b) not in opens_set:
                return False

    # Axiom 3: Arbitrary unions
    opens_list = list(opens_set)
    for subset_indices in powerset(list(range(len(opens_list)))):
        union = frozenset()
        for i in subset_indices:
            union = union | opens_list[i]
        if union not in opens_set:
            return False

    return True


# ============================================================
# Algorithm 2: Enumerate All Topologies
# ============================================================
def enumerate_topologies(X: List[Element]) -> List[Topology]:
    """
    Enumerate all topologies on a finite set X.

    Uses brute-force enumeration over all subfamilies of the power set.
    Practical only for |X| ≤ 4.

    Time complexity: O(2^(2^|X|) * validation_cost)
    Space complexity: O(2^|X|)

    Args:
        X: The ground set (list of elements)

    Returns:
        List of all valid topologies, each as a set of frozensets
    """
    all_subsets = [tuple(sorted(s)) for s in powerset(X)]
    topologies = []

    for r in range(len(all_subsets) + 1):
        for combo in combinations(all_subsets, r):
            candidate = list(combo)
            if is_topology(X, candidate):
                topologies.append(to_frozensets(candidate))

    return topologies


# ============================================================
# Algorithm 3: Consensus Topology
# ============================================================
def consensus_topology(X: List[Element], topologies: List[Topology]) -> Topology:
    """
    Compute the consensus topology of multiple observer topologies.

    The consensus is the intersection of all topologies as families of open sets.
    A set U is consensus-open iff it is open in EVERY observer's topology.

    This corresponds to the supremum (⨆) in the TopologicalSpace lattice.

    Time complexity: O(2^|X| * |topologies|)
    Space complexity: O(2^|X|)

    Args:
        X: The ground set
        topologies: List of observer topologies

    Returns:
        The consensus topology
    """
    if not topologies:
        return {frozenset(), frozenset(X)}

    consensus = topologies[0].copy()
    for top in topologies[1:]:
        consensus = consensus & top

    return consensus


# ============================================================
# Algorithm 4: Phantom Number (Proper)
# ============================================================
def proper_phantom_number(X: List[Element], target: Topology,
                          max_observers: int = 4) -> Optional[int]:
    """
    Compute the proper phantom number: minimum number of topologies,
    each strictly finer than the target, whose consensus equals the target.

    A topology τ₁ is strictly finer than τ₂ if τ₁ ⊃ τ₂ (as sets of opens).

    Time complexity: O(T^max_observers) where T = number of topologies
    Space complexity: O(T)

    Args:
        X: The ground set
        target: The target topology
        max_observers: Maximum number of observers to try

    Returns:
        The proper phantom number, or None if not found within max_observers
    """
    all_tops = enumerate_topologies(X)

    # Filter to topologies strictly finer than target
    finer = [top for top in all_tops if top > target]

    for n in range(1, max_observers + 1):
        for combo in combinations(finer, n):
            if consensus_topology(X, list(combo)) == target:
                return n

    return None


# ============================================================
# Algorithm 5: Disagreement Metric
# ============================================================
def disagreement_metric(top1: Topology, top2: Topology) -> int:
    """
    Compute the disagreement between two topologies: the size of the
    symmetric difference of their open sets.

    This is a pseudo-metric on the space of topologies.

    Time complexity: O(|top1| + |top2|)
    Space complexity: O(|top1| + |top2|)

    Args:
        top1: First topology
        top2: Second topology

    Returns:
        |top1 △ top2| (size of symmetric difference)
    """
    return len(top1.symmetric_difference(top2))


# ============================================================
# Algorithm 6: Phantom Entropy
# ============================================================
def phantom_entropy(topologies: List[Topology], X: List[Element]) -> float:
    """
    Compute the phantom entropy of a phantom system: measures how much
    observers disagree. Defined as the average pairwise disagreement
    normalized by the total number of subsets.

    Time complexity: O(|observers|^2 * 2^|X|)

    Args:
        topologies: List of observer topologies
        X: The ground set

    Returns:
        Normalized entropy value in [0, 1]
    """
    n = len(topologies)
    if n <= 1:
        return 0.0

    total_subsets = 2 ** len(X)
    total_disagreement = 0
    pairs = 0

    for i in range(n):
        for j in range(i + 1, n):
            total_disagreement += disagreement_metric(topologies[i], topologies[j])
            pairs += 1

    if pairs == 0:
        return 0.0

    return total_disagreement / (pairs * total_subsets)


# ============================================================
# Algorithm 7: Observer Lattice
# ============================================================
def observer_refinement_lattice(X: List[Element]) -> Dict[int, List[int]]:
    """
    Build the refinement lattice of all topologies on X.
    An edge from i to j means topology i is strictly finer than topology j.

    Returns adjacency list of the Hasse diagram.

    Time complexity: O(T^2 * 2^|X|)
    """
    all_tops = enumerate_topologies(X)
    n = len(all_tops)

    # Build covering relation
    covers: Dict[int, List[int]] = {i: [] for i in range(n)}

    for i in range(n):
        for j in range(n):
            if i != j and all_tops[i] > all_tops[j]:
                # Check if i covers j (no topology between them)
                is_cover = True
                for k in range(n):
                    if k != i and k != j:
                        if all_tops[i] > all_tops[k] > all_tops[j]:
                            is_cover = False
                            break
                if is_cover:
                    covers[i].append(j)

    return covers


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    X = [0, 1]
    print(f"Ground set: {X}")

    tops = enumerate_topologies(X)
    print(f"\nAll {len(tops)} topologies on {set(X)}:")
    for i, top in enumerate(tops):
        print(f"  τ_{i}: {{{', '.join(str(set(s)) for s in sorted(top, key=len))}}}")

    print("\nPhantom numbers (proper):")
    for i, top in enumerate(tops):
        pn = proper_phantom_number(X, top)
        if pn is None:
            pn_str = "∞ (is already minimal)"
        else:
            pn_str = str(pn)
        print(f"  τ_{i}: proper phantom number = {pn_str}")

    print("\nDisagreement matrix:")
    for i in range(len(tops)):
        row = [disagreement_metric(tops[i], tops[j]) for j in range(len(tops))]
        print(f"  τ_{i}: {row}")

    print("\nPhantom entropy examples:")
    for i in range(len(tops)):
        for j in range(i + 1, len(tops)):
            ent = phantom_entropy([tops[i], tops[j]], X)
            print(f"  {{τ_{i}, τ_{j}}}: entropy = {ent:.3f}")
