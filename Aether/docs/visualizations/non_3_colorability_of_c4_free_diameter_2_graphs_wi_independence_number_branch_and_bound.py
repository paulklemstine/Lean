from typing import Dict, Set

Graph = Dict[int, Set[int]]


def independence_number(g: Graph) -> int:
    """Exact maximum independent set size via branch and bound.

    Branches on a pivot vertex v: either include v (delete v and N(v)) or
    exclude v. Prunes when size + |candidates| cannot beat the incumbent.
    Worst-case exponential, but effective on structured graphs; drives the
    3-colorability test 3*alpha >= |V|.
    """
    best = 0

    def expand(candidates: Set[int], size: int) -> None:
        nonlocal best
        if size + len(candidates) <= best:
            return
        if not candidates:
            best = max(best, size)
            return
        v = next(iter(candidates))
        expand(candidates - {v} - g[v], size + 1)   # include v
        expand(candidates - {v}, size)              # exclude v

    expand(set(g), 0)
    return best
