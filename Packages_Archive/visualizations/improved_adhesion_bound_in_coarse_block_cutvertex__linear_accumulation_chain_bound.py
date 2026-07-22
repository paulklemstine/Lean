from typing import Dict, List, Set

Vertex = int
Graph = Dict[Vertex, Set[Vertex]]


def chain_bound(n: int, d: int) -> int:
    """Return the linear-accumulation bound (n+1)*D + n for a chain of n hops.

    This is the closed form of the chain law: along a chain S_0,...,S_n of sets
    each of diameter <= d with consecutive overlaps, dist(u, v) <= (n+1)*d + n
    for u in S_0, v in S_n. Slope in n is exactly d + 1. Complexity O(1).
    """
    return (n + 1) * d + n


def verify_chain(g: Graph, chain: List[Set[Vertex]], set_diam, bfs) -> bool:
    """Empirically verify the chain law on an explicit chain of bags.

    `set_diam(g, S)` returns the diameter of S; `bfs(g, u, v)` the distance.
    Returns True iff every observed dist(S_0, S_n) respects the bound.
    """
    n = len(chain) - 1
    d = max(set_diam(g, s) for s in chain)
    for i in range(n):
        if not (chain[i] & chain[i + 1]):
            raise ValueError(f"sets {i},{i+1} do not overlap")
    bound = chain_bound(n, d)
    return all(bfs(g, u, v) <= bound for u in chain[0] for v in chain[-1])
