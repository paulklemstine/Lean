from itertools import product
from typing import Dict, List, Tuple

def de_bruijn_tour(A: int, k: int) -> List[int]:
    """Return the shortest single volume (length A^k + k - 1) that exhibits
    every length-k code over {0,...,A-1} exactly once, computed by Hierholzer's
    Eulerian-circuit algorithm on the de Bruijn graph in O(A^k) time."""
    graph: Dict[Tuple[int, ...], List[int]] = {
        v: list(range(A)) for v in product(range(A), repeat=k - 1)
    }
    stack: List[Tuple[int, ...]] = [tuple([0] * (k - 1))]
    path: List[int] = []
    circuit: List[int] = []
    while stack:
        v = stack[-1]
        if graph[v]:
            s = graph[v].pop()
            stack.append(v[1:] + (s,))
            path.append(s)
        else:
            stack.pop()
            if path:
                circuit.append(path.pop())
    circuit.reverse()
    return circuit + circuit[: k - 1]
