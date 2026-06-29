from typing import Set, Tuple
# requires `derivable` from the reachability algorithm above
Edge = Tuple[int, int]

def critical_edges(edges: Set[Edge], a: int, b: int,
                   derivable) -> Set[Edge]:
    """Return the backbone: all axioms whose removal destroys Derivable T a b.
    Recomputes reachability once per edge: O(E * (V+E)). On the chain this returns
    every axiom (criticality index 1)."""
    if not derivable(edges, a, b):
        return set()
    return {e for e in edges if not derivable(edges - {e}, a, b)}
