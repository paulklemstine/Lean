from collections import deque
from typing import Dict, List, Set, Tuple

Atom = int
Edge = Tuple[Atom, Atom]

def derivable(edges: Set[Edge], a: Atom, b: Atom) -> bool:
    """Decide Derivable T a b (reflexive-transitive closure) by BFS. O(V+E).
    The visited set is the minimal forward-closed set containing a (the barrier)."""
    if a == b:
        return True
    adj: Dict[Atom, List[Atom]] = {}
    for (x, y) in edges:
        adj.setdefault(x, []).append(y)
    seen: Set[Atom] = {a}
    queue: deque[Atom] = deque([a])
    while queue:
        x = queue.popleft()
        for y in adj.get(x, ()):
            if y not in seen:
                if y == b:
                    return True
                seen.add(y)
                queue.append(y)
    return False
