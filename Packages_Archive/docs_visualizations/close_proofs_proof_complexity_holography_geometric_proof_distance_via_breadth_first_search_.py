from collections import deque
from typing import Dict, List, Optional, Hashable

Atom = Hashable
Theory = Dict[Atom, List[Atom]]  # axioms: a -> list of b with axiom a->b


def min_deriv_len(axioms: Theory, a: Atom, b: Atom) -> Optional[int]:
    """minDerivLen T a b: the shortest derivation length (directed BFS).

    Returns None when b is not derivable from a. Runs in O(V + E)."""
    if a == b:
        return 0
    dist: Dict[Atom, int] = {a: 0}
    queue: deque = deque([a])
    while queue:
        x = queue.popleft()
        for y in axioms.get(x, []):
            if y not in dist:
                dist[y] = dist[x] + 1
                if y == b:
                    return dist[y]
                queue.append(y)
    return None
