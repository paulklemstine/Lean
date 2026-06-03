"""
Phantom Topology: Algorithms for Observer-Dependent Topological Spaces

Type-hinted implementations of core phantom topology algorithms.
"""

from typing import FrozenSet, Set, List, Tuple, Optional
from itertools import combinations, chain


# A topology on a finite set X is represented as a frozenset of frozensets.
Topology = FrozenSet[FrozenSet[int]]
SetOfInts = FrozenSet[int]


def is_topology(X: FrozenSet[int], opens: Set[FrozenSet[int]]) -> bool:
    """Check if a collection of sets forms a valid topology on X."""
    # Must contain empty set and X
    if frozenset() not in opens:
        return False
    if X not in opens:
        return False
    # Closed under finite intersection
    for u in opens:
        for v in opens:
            if u & v not in opens:
                return False
    # Closed under arbitrary union (for finite case, pairwise suffices
    # since closure under pairwise union + empty union gives arbitrary)
    for u in opens:
        for v in opens:
            if u | v not in opens:
                return False
    return True


def generate_topology(X: FrozenSet[int], generators: Set[FrozenSet[int]]) -> Topology:
    """Generate the smallest topology on X containing the given generators.
    
    Corresponds to TopologicalSpace.generateFrom in Lean/Mathlib.
    """
    opens: Set[FrozenSet[int]] = {frozenset(), X}
    opens.update(generators)
    
    # Close under finite intersection and arbitrary union
    changed = True
    while changed:
        changed = False
        new_opens: Set[FrozenSet[int]] = set(opens)
        for u in opens:
            for v in opens:
                inter = u & v
                union = u | v
                if inter not in new_opens:
                    new_opens.add(inter)
                    changed = True
                if union not in new_opens:
                    new_opens.add(union)
                    changed = True
        opens = new_opens
    
    return frozenset(opens)


def consensus_topology(X: FrozenSet[int], observers: List[Topology]) -> Topology:
    """Compute the consensus topology (intersection of open set families).
    
    In Mathlib's lattice: this is the supremum ⨆ of the observer topologies.
    A set is open in the consensus iff it's open for every observer.
    """
    if not observers:
        # Empty family: consensus is indiscrete (only ∅ and X)
        return frozenset({frozenset(), X})
    
    result = set(observers[0])
    for obs in observers[1:]:
        result &= set(obs)
    
    return frozenset(result)


def is_strictly_finer(t1: Topology, t2: Topology) -> bool:
    """Check if t1 is strictly finer than t2 (t1 < t2 in Mathlib).
    
    t1 < t2 means t1 has strictly more open sets: t2 ⊂ t1 (proper subset).
    In Mathlib's convention: t1 ≤ t2 means t1 is finer (more open sets),
    so t1.IsOpen ⊇ t2.IsOpen.
    """
    return set(t2) < set(t1)  # proper subset: t2's opens ⊊ t1's opens


def is_phantom_decomposition(
    tau: Topology,
    observers: List[Topology],
    strict: bool = True
) -> bool:
    """Verify if a list of observer topologies forms a (strict) phantom decomposition of tau.
    
    Checks:
    1. Each observer is finer than tau (has more open sets)
    2. If strict=True, each observer is STRICTLY finer
    3. The consensus (intersection of opens) equals tau
    """
    if not observers:
        return False
    
    for obs in observers:
        if strict:
            if not is_strictly_finer(obs, tau):
                return False
        else:
            if not set(tau).issubset(set(obs)):
                return False
    
    return consensus_topology(
        max(tau, key=len),  # X is the largest element
        observers
    ) == tau


def find_phantom_decomposition(
    X: FrozenSet[int],
    tau: Topology,
    all_topologies: List[Topology],
    max_observers: int = 4
) -> Optional[List[Topology]]:
    """Find a strict phantom decomposition of tau with minimum observers.
    
    Returns None if tau is phantom-irreducible (or if max_observers is too small).
    """
    # Filter to strictly finer topologies
    finer = [t for t in all_topologies if is_strictly_finer(t, tau)]
    
    if not finer:
        return None  # Phantom-irreducible (no strictly finer topology exists)
    
    # Try increasing numbers of observers
    for k in range(2, max_observers + 1):
        for combo in combinations(finer, k):
            observers = list(combo)
            if is_phantom_decomposition(tau, observers, strict=True):
                return observers
    
    return None


def phantom_number(
    X: FrozenSet[int],
    tau: Topology,
    all_topologies: List[Topology]
) -> int:
    """Compute the phantom number of a topology.
    
    Returns 0 if phantom-irreducible, otherwise the minimum number of observers.
    """
    decomp = find_phantom_decomposition(X, tau, all_topologies)
    if decomp is None:
        return 0
    return len(decomp)


def enumerate_topologies_on(n: int) -> List[Topology]:
    """Enumerate all topologies on {0, 1, ..., n-1}.
    
    Warning: The number of topologies grows extremely fast.
    Only practical for n ≤ 4.
    """
    X = frozenset(range(n))
    subsets = [frozenset(s) for k in range(n + 1) 
               for s in combinations(range(n), k)]
    subsets_set = set(subsets)
    
    topologies: List[Topology] = []
    
    # Generate all possible collections of subsets and check if they're topologies
    # This is exponential, so we use a smarter approach: build up from generators
    for num_generators in range(len(subsets) + 1):
        for gens in combinations(subsets, num_generators):
            topo = generate_topology(X, set(gens))
            if topo not in topologies:
                topologies.append(topo)
    
    # Deduplicate
    return list(set(topologies))


def sierpinski_decomposition(X: FrozenSet[int], a: int, b: int) -> Tuple[Topology, Topology]:
    """Construct the Sierpiński-style 2-observer decomposition of the indiscrete topology.
    
    Observer 1 sees {a} as open; Observer 2 sees {b} as open.
    Their consensus is the indiscrete topology {∅, X}.
    
    This corresponds to the construction in indiscrete_not_phantomIrreducible.
    """
    t1 = generate_topology(X, {frozenset({a})})
    t2 = generate_topology(X, {frozenset({b})})
    return t1, t2


def phantom_profile(X: FrozenSet[int], all_topos: List[Topology]) -> dict:
    """Compute the phantom profile of a finite set: 
    for each topology, compute its phantom number."""
    profile: dict = {}
    for tau in all_topos:
        pn = phantom_number(X, tau, all_topos)
        key = len(tau)  # Number of open sets as a rough classifier
        profile[frozenset(tau)] = {
            'num_opens': len(tau),
            'phantom_number': pn,
            'is_irreducible': pn == 0
        }
    return profile
