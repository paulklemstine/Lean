from typing import FrozenSet, Sequence, Set

Point = int
OpenSet = FrozenSet[Point]
Topology = FrozenSet[OpenSet]


def consensus(topologies: Sequence[Topology]) -> Topology:
    """Consensus (supremum in the lattice of topologies).

    A set is consensus-open iff it is open for EVERY observer, so the consensus
    open family is the intersection of the observers' open families.
    """
    if not topologies:
        raise ValueError("need at least one observer")
    result: Set[OpenSet] = set(topologies[0])
    for t in topologies[1:]:
        result &= set(t)
    return frozenset(result)


def is_finer(t: Topology, s: Topology) -> bool:
    """t <= s in the refinement order: every s-open set is t-open."""
    return set(s) <= set(t)
