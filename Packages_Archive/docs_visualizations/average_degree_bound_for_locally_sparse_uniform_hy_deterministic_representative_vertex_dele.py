from typing import FrozenSet, Set

Edge = FrozenSet[int]
Hypergraph = Set[Edge]
Pool = FrozenSet[int]


def contained_edges(E: Hypergraph, S: Pool) -> Set[Edge]:
    """{ e in E : e subseteq S } - edges trapped inside S."""
    return {e for e in E if e <= S}


def deterministic_deletion(E: Hypergraph, S: Pool) -> FrozenSet[int]:
    """Explicit independent subset of S via representative deletion."""
    reps: Set[int] = {min(e) for e in contained_edges(E, S) if e}
    return frozenset(S - reps)
