from collections import deque
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

Theory = FrozenSet[Tuple[int, int]]

def barrier_certificate(theory: Theory, a: int, b: int) -> Optional[Set[int]]:
    """Return an axiom-closed cut S with a in S, b not in S (certifying that b is
    NOT derivable from a), or None if b IS derivable.

    The terminal reachable set is, by construction, axiom-closed and contains a;
    this is exactly the invariant cut of the barrier lemma `refl_trans_gen_closed`."""
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
    return None if b in seen else seen
