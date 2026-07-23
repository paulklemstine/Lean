from typing import Dict, List, Set, Tuple

Graph = Dict[int, Set[int]]


def path_graph(n: int) -> Graph:
    g: Graph = {i: set() for i in range(n)}
    for i in range(n - 1):
        g[i].add(i + 1)
        g[i + 1].add(i)
    return g


def aligned_packing_isolating_path(n: int) -> Set[int]:
    """Period-three aligned construction: O(n) time, output {1, 4, 7, ...}."""
    return {i for i in range(n) if i % 3 == 1}


def covering_witness(n: int, a: int) -> int:
    """For edge {a, a+1} of P_n, return the residue-1-mod-3 vertex that covers it."""
    if a % 3 == 0:
        return a + 1          # right endpoint is itself selected
    if a % 3 == 1:
        return a              # left endpoint is itself selected
    return a - 1              # backward witness covers a from the left
