from collections import deque
from typing import Dict, List, Set, Tuple

Atom = int
Theory = Set[Tuple[Atom, Atom]]

def least_closed_set(theory: Theory, a: Atom) -> Set[Atom]:
    adj: Dict[Atom, List[Atom]] = {}
    for u, v in theory:
        adj.setdefault(u, []).append(v)
    S: Set[Atom] = {a}
    queue: deque[Atom] = deque([a])
    while queue:
        x = queue.popleft()
        for y in adj.get(x, []):
            if y not in S:
                S.add(y)
                queue.append(y)
    return S

def barrier_certify(theory: Theory, a: Atom, b: Atom
                    ) -> Tuple[str, Set[Atom]]:
    """Return ('NOT_DERIVABLE', closed cut) or ('DERIVABLE', conclusion set)."""
    S = least_closed_set(theory, a)
    return (('DERIVABLE' if b in S else 'NOT_DERIVABLE'), S)
