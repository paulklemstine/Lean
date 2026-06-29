from collections import deque
from typing import Dict, List, Optional, Set, Tuple

Atom = int
Theory = Set[Tuple[Atom, Atom]]

def min_proof_len(theory: Theory, a: Atom, b: Atom) -> Optional[int]:
    """Minimal axiom-application count in a proof a |- b, or None."""
    if a == b:
        return 0
    adj: Dict[Atom, List[Atom]] = {}
    for u, v in theory:
        adj.setdefault(u, []).append(v)
    dist: Dict[Atom, int] = {a: 0}
    queue: deque[Atom] = deque([a])
    while queue:
        x = queue.popleft()
        for y in adj.get(x, []):
            if y not in dist:
                dist[y] = dist[x] + 1
                if y == b:
                    return dist[y]
                queue.append(y)
    return dist.get(b)
