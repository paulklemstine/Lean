from typing import Callable, List, Set, Tuple

def transitive_closure(V: List[object],
                       D: Callable[[object, object], bool]) -> Set[Tuple[object, object]]:
    """
    Compute the reflexive-transitive-free transitive closure of the direct
    dependency relation D by Floyd-Warshall-style reachability.
    Returns the set of pairs (a, b) with a path a -> ... -> b.
    Complexity: O(N^3).
    """
    reach: Set[Tuple[object, object]] = {(a, b) for a in V for b in V if D(a, b)}
    changed = True
    while changed:
        changed = False
        for a in V:
            for b in V:
                if (a, b) in reach:
                    for c in V:
                        if (b, c) in reach and (a, c) not in reach:
                            reach.add((a, c))
                            changed = True
    return reach

def closure_weight(V: List[object],
                   D: Callable[[object, object], bool], a: object) -> int:
    """Weight of a in the transitive closure: number of theorems reachable from a."""
    reach = transitive_closure(V, D)
    return sum(1 for b in V if (a, b) in reach)
