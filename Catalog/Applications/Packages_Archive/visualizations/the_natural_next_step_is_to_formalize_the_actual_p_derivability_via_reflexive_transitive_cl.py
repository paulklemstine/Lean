from collections import deque
from typing import Dict, FrozenSet, List, Set, Tuple

Edge = Tuple[int, int]
Theory = FrozenSet[Edge]

def derivable(theory: Theory, a: int, b: int) -> bool:
    """Decide `Derivable T a b` by computing the forward reachable set (closure)."""
    adj: Dict[int, List[int]] = {}
    for x, y in theory:
        adj.setdefault(x, []).append(y)
    seen: Set[int] = {a}
    queue: deque[int] = deque([a])
    while queue:
        x = queue.popleft()
        for y in adj.get(x, ()):
            if y not in seen:
                seen.add(y)
                queue.append(y)
    return b in seen
