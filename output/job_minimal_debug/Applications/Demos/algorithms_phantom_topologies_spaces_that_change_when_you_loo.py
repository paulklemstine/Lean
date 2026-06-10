#!/usr/bin/env python3
"""
Phantom Chromatic Theory: Core Algorithms

Type-hinted implementations of the key algorithms for computing
phantom topological invariants.
"""

from itertools import combinations
from typing import FrozenSet, Set, List, Optional, Tuple, Dict


# Type aliases
Element = int
Subset = FrozenSet[Element]
Topology = FrozenSet[Subset]


def closure_under_unions_and_intersections(
    generators: Set[Subset], universe: Subset
) -> Topology:
    """Generate the smallest topology containing the given generators.

    Closes under finite intersections and arbitrary unions (finite case).
    Always includes ∅ and the universe.

    Args:
        generators: Initial collection of subsets to generate from.
        universe: The full ground set.

    Returns:
        The generated topology as a frozenset of frozensets.
    """
    opens: Set[Subset] = {frozenset(), universe}
    opens.update(generators)

    changed = True
    while changed:
        changed = False
        new_opens: Set[Subset] = set(opens)

        # Close under pairwise intersection
        for a, b in combinations(opens, 2):
            inter = a & b
            if inter not in new_opens:
                new_opens.add(inter)
                changed = True

        # Close under pairwise union (generates all finite unions)
        for a, b in combinations(opens, 2):
            union = a | b
            if union not in new_opens:
                new_opens.add(union)
                changed = True

        opens = new_opens

    return frozenset(opens)


def is_topology(opens: Set[Subset], universe: Subset) -> bool:
    """Verify that a collection of subsets forms a topology.

    Args:
        opens: Candidate collection of open sets.
        universe: The ground set.

    Returns:
        True if opens satisfies the topology axioms.
    """
    if frozenset() not in opens or universe not in opens:
        return False
    for a, b in combinations(opens, 2):
        if a & b not in opens:
            return False
    opens_list = list(opens)
    for r in range(2, len(opens_list) + 1):
        for combo in combinations(opens_list, r):
            if frozenset().union(*combo) not in opens:
                return False
    return True


def is_strictly_finer(tau1: Topology, tau2: Topology) -> bool:
    """Check if tau1 is strictly finer than tau2.

    In the lattice of topologies, finer means more open sets.

    Args:
        tau1: First topology.
        tau2: Second topology.

    Returns:
        True if tau1 has strictly more open sets than tau2.
    """
    return tau1 > tau2


def consensus_topology(topologies: List[Topology]) -> Topology:
    """Compute the consensus (intersection) of multiple topologies.

    The consensus consists of sets open in ALL given topologies.

    Args:
        topologies: List of topologies.

    Returns:
        The consensus topology.
    """
    if not topologies:
        return frozenset()
    result: Set[Subset] = set(topologies[0])
    for t in topologies[1:]:
        result &= set(t)
    return frozenset(result)


def observer_disagreement(
    observer_topo: Topology, consensus: Topology
) -> Set[Subset]:
    """Compute the disagreement set of an observer.

    The disagreement set contains sets that the observer considers open
    but are NOT open in the consensus.

    Args:
        observer_topo: The observer's topology.
        consensus: The consensus topology.

    Returns:
        Set of subsets in disagreement.
    """
    return set(observer_topo) - set(consensus)


def are_observers_independent(
    obs1: Topology, obs2: Topology, consensus: Topology
) -> bool:
    """Check if two observers are independent.

    Two observers are independent iff their disagreement sets are disjoint.

    Args:
        obs1: First observer's topology.
        obs2: Second observer's topology.
        consensus: The consensus topology.

    Returns:
        True if the observers are independent.
    """
    dis1 = observer_disagreement(obs1, consensus)
    dis2 = observer_disagreement(obs2, consensus)
    return len(dis1 & dis2) == 0


def find_strict_decomposition(
    tau: Topology,
    all_topologies: List[Topology],
    k: int,
) -> Optional[List[Topology]]:
    """Find a k-observer strict phantom decomposition of tau.

    Args:
        tau: Target topology to decompose.
        all_topologies: All available topologies on the space.
        k: Number of observers.

    Returns:
        A list of k topologies forming a decomposition, or None.
    """
    finer = [t for t in all_topologies if is_strictly_finer(t, tau)]
    for combo in combinations(finer, k):
        if consensus_topology(list(combo)) == tau:
            return list(combo)
    return None


def phantom_chromatic_number(
    tau: Topology,
    all_topologies: List[Topology],
    max_k: int = 10,
) -> int:
    """Compute the phantom chromatic number of a topology.

    Returns the minimum k >= 2 such that tau admits a k-observer
    strict decomposition, or -1 if irreducible (up to max_k).

    Args:
        tau: The topology.
        all_topologies: All topologies on the space.
        max_k: Maximum k to check.

    Returns:
        The phantom chromatic number, or -1 if irreducible.
    """
    for k in range(2, max_k + 1):
        if find_strict_decomposition(tau, all_topologies, k) is not None:
            return k
    return -1


def phantom_spectrum(
    tau: Topology,
    all_topologies: List[Topology],
    max_k: int = 10,
) -> List[int]:
    """Compute the phantom spectrum of a topology.

    Args:
        tau: The topology.
        all_topologies: All topologies on the space.
        max_k: Maximum k to check.

    Returns:
        List of k values for which a decomposition exists.
    """
    return [
        k for k in range(2, max_k + 1)
        if find_strict_decomposition(tau, all_topologies, k) is not None
    ]


def compose_decompositions(
    level1: List[Topology],
    level2: Dict[int, List[Topology]],
) -> List[Topology]:
    """Compose two levels of phantom decompositions.

    Given a k-observer decomposition (level1) where each observer i
    has an m_i-observer sub-decomposition (level2[i]), flatten into
    a single-level decomposition.

    Args:
        level1: First-level observer topologies.
        level2: Mapping from level1 index to sub-decomposition.

    Returns:
        Flattened list of all sub-observer topologies.
    """
    result: List[Topology] = []
    for i, obs in enumerate(level1):
        if i in level2:
            result.extend(level2[i])
        else:
            result.append(obs)
    return result


if __name__ == "__main__":
    # Example: compute phantom chromatic number on Fin 3
    n = 3
    universe = frozenset(range(n))

    # Generate all subsets
    all_subsets: List[Subset] = []
    for r in range(n + 1):
        for combo in combinations(range(n), r):
            all_subsets.append(frozenset(combo))

    # Generate all topologies (brute force for small n)
    all_topos: List[Topology] = []
    required = {frozenset(), universe}
    optional = [s for s in all_subsets if s not in required]

    for r in range(len(optional) + 1):
        for combo in combinations(optional, r):
            candidate = required | set(combo)
            if is_topology(candidate, universe):
                all_topos.append(frozenset(candidate))

    print(f"Topologies on Fin {n}: {len(all_topos)}")

    for tau in sorted(all_topos, key=len):
        pcn = phantom_chromatic_number(tau, all_topos, max_k=5)
        status = f"χ_ph = {pcn}" if pcn > 0 else "irreducible"
        print(f"  |opens| = {len(tau):2d}: {status}")
