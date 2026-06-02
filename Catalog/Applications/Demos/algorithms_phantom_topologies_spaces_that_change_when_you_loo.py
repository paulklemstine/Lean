#!/usr/bin/env python3
"""
Phantom Topology Algorithms

Type-hinted implementations of key algorithms for computing with
phantom topologies on finite sets.
"""

from typing import FrozenSet, List, Optional, Set, Dict, Tuple
from itertools import combinations


# Type aliases
Element = int
Subset = FrozenSet[Element]
Topology = FrozenSet[Subset]
PhantomTopology = List[Topology]  # Indexed list of observer topologies


def generate_topology(generators: Set[Subset], universe: Subset) -> Topology:
    """
    Generate the smallest topology on `universe` containing all `generators`.

    Closes the generator set under:
    - Contains ∅ and universe
    - Finite intersections
    - Arbitrary unions

    Args:
        generators: Initial collection of subsets to include as open sets
        universe: The full ground set X

    Returns:
        The generated topology as a frozenset of frozensets
    """
    opens: Set[Subset] = {frozenset(), universe}
    opens.update(generators)

    changed = True
    while changed:
        changed = False
        new_opens = set(opens)

        # Close under pairwise intersection
        opens_list = list(opens)
        for i in range(len(opens_list)):
            for j in range(i, len(opens_list)):
                inter = opens_list[i] & opens_list[j]
                if inter not in new_opens:
                    new_opens.add(inter)
                    changed = True

        # Close under pairwise union
        opens_list = list(new_opens)
        for i in range(len(opens_list)):
            for j in range(i, len(opens_list)):
                union = opens_list[i] | opens_list[j]
                if union not in new_opens:
                    new_opens.add(union)
                    changed = True

        opens = new_opens

    return frozenset(opens)


def compute_consensus(observers: PhantomTopology) -> Topology:
    """
    Compute the consensus topology: intersection of all observer open-set families.

    A set U is consensus-open iff every observer considers U open.

    Args:
        observers: List of topologies, one per observer

    Returns:
        The consensus topology

    Complexity: O(|observers| * max_topology_size)
    """
    if not observers:
        return frozenset()

    result: Set[Subset] = set(observers[0])
    for topology in observers[1:]:
        result &= set(topology)
    return frozenset(result)


def is_strictly_finer(tau1: Topology, tau2: Topology) -> bool:
    """
    Check if tau1 is strictly finer than tau2.

    tau1 is strictly finer iff every tau2-open set is tau1-open,
    but not vice versa (tau1 has extra open sets).

    Args:
        tau1: Candidate finer topology
        tau2: Candidate coarser topology

    Returns:
        True iff tau1 is strictly finer than tau2
    """
    return set(tau2) < set(tau1)


def compute_phantom_spectrum(
    observers: PhantomTopology,
    consensus_top: Topology,
    universe: Subset
) -> Dict[Element, Set[int]]:
    """
    Compute the phantom spectrum at each point.

    The spectrum at x is the set of observer indices i such that
    observer i sees some open set containing x that isn't consensus-open.

    Args:
        observers: List of observer topologies
        consensus_top: The consensus topology
        universe: The ground set X

    Returns:
        Dictionary mapping each x in X to its phantom spectrum
    """
    spectrum: Dict[Element, Set[int]] = {x: set() for x in universe}

    for i, topology in enumerate(observers):
        extra_opens = set(topology) - set(consensus_top)
        for U in extra_opens:
            for x in U:
                spectrum[x].add(i)

    return spectrum


def compute_strict_phantom_number(
    tau: Topology,
    all_topologies: List[Topology],
    max_observers: int = 10
) -> int:
    """
    Compute the strict phantom number of a topology.

    Searches for the minimum number n ≥ 2 of strictly finer topologies
    whose consensus equals tau.

    Args:
        tau: Target topology
        all_topologies: All topologies on the ground set
        max_observers: Maximum number of observers to try

    Returns:
        The strict phantom number (0 if no strict representation exists)

    Complexity: Exponential in the number of finer topologies
    """
    finer = [t for t in all_topologies if is_strictly_finer(t, tau)]
    if not finer:
        return 0  # tau is discrete (or maximal)

    for n in range(2, min(max_observers, len(finer)) + 1):
        for combo in combinations(finer, n):
            if compute_consensus(list(combo)) == tau:
                return n

    return 0  # Not found within max_observers


def phantom_entropy(
    spectrum: Dict[Element, Set[int]],
    num_observers: int
) -> Dict[Element, float]:
    """
    Compute the phantom entropy at each point.

    H(x) = log₂|Spec(x)| / log₂|O| ∈ [0, 1]

    Measures how much observers disagree at each point.
    H(x) = 0 means no observer deviates at x.
    H(x) = 1 means all observers deviate at x.

    Args:
        spectrum: Phantom spectrum at each point
        num_observers: Total number of observers

    Returns:
        Dictionary mapping each point to its phantom entropy
    """
    import math

    if num_observers <= 1:
        return {x: 0.0 for x in spectrum}

    log_n = math.log2(num_observers)
    entropy: Dict[Element, float] = {}

    for x, spec in spectrum.items():
        if len(spec) == 0:
            entropy[x] = 0.0
        else:
            entropy[x] = math.log2(len(spec)) / log_n

    return entropy


def find_phantom_decomposition(
    tau: Topology,
    all_topologies: List[Topology],
    n_observers: int = 2
) -> Optional[PhantomTopology]:
    """
    Find a strict phantom representation with exactly n_observers observers.

    Args:
        tau: Target topology to decompose
        all_topologies: All topologies on the ground set
        n_observers: Desired number of observers

    Returns:
        A list of observer topologies, or None if no decomposition exists
    """
    finer = [t for t in all_topologies if is_strictly_finer(t, tau)]

    for combo in combinations(finer, n_observers):
        if compute_consensus(list(combo)) == tau:
            return list(combo)

    return None


def enumerate_topologies(n: int) -> List[Topology]:
    """
    Enumerate all topologies on {0, 1, ..., n-1}.

    Warning: The number of topologies grows extremely fast:
    n=1: 1, n=2: 4, n=3: 29, n=4: 355, n=5: 6942

    Args:
        n: Size of the ground set

    Returns:
        List of all topologies on {0, ..., n-1}
    """
    X = frozenset(range(n))
    power_set: List[Subset] = []
    for mask in range(1 << n):
        power_set.append(frozenset(i for i in range(n) if mask & (1 << i)))

    required = {frozenset(), X}
    optional = [s for s in power_set if s not in required]

    topologies: List[Topology] = []
    for mask in range(1 << len(optional)):
        candidate: Set[Subset] = set(required)
        for i in range(len(optional)):
            if mask & (1 << i):
                candidate.add(optional[i])

        # Quick validity check
        valid = True
        candidate_list = list(candidate)
        for i in range(len(candidate_list)):
            for j in range(i, len(candidate_list)):
                if candidate_list[i] & candidate_list[j] not in candidate:
                    valid = False
                    break
                if candidate_list[i] | candidate_list[j] not in candidate:
                    valid = False
                    break
            if not valid:
                break

        if valid:
            topologies.append(frozenset(candidate))

    return topologies


if __name__ == "__main__":
    # Quick test
    X = frozenset({0, 1, 2})
    tops = enumerate_topologies(3)
    print(f"Number of topologies on {{0,1,2}}: {len(tops)}")

    # Find discrete topology
    discrete = frozenset(frozenset(s) for mask in range(1 << 3)
                         for s in [frozenset(i for i in range(3) if mask & (1 << i))])
    print(f"Discrete has {len(discrete)} open sets")
    print(f"Discrete phantom number: {compute_strict_phantom_number(discrete, tops)}")

    # Find indiscrete
    indiscrete = frozenset({frozenset(), X})
    spn = compute_strict_phantom_number(indiscrete, tops)
    print(f"Indiscrete phantom number: {spn}")

    # Compute all phantom numbers
    print("\nPhantom number distribution:")
    dist: Dict[int, int] = {}
    for tau in tops:
        spn = compute_strict_phantom_number(tau, tops)
        dist[spn] = dist.get(spn, 0) + 1
    for k in sorted(dist):
        print(f"  spn={k}: {dist[k]} topologies")
