from __future__ import annotations
from collections import deque
from typing import Dict, List, Tuple, Optional

State = Tuple[int, ...]  # count vector indexed by species order

def fire(reactant: State, product: State, x: State) -> Optional[State]:
    if any(x[i] < reactant[i] for i in range(len(x))):
        return None
    return tuple(x[i] - reactant[i] + product[i] for i in range(len(x)))

def coverable(reactions: List[Tuple[State, State]], start: State,
              target: State, max_states: int = 100000) -> bool:
    """BFS reachability search testing whether some reachable state covers target."""
    seen = {start}
    q: deque[State] = deque([start])
    while q and len(seen) < max_states:
        x = q.popleft()
        if all(x[i] >= target[i] for i in range(len(x))):
            return True
        for reactant, product in reactions:
            y = fire(reactant, product, x)
            if y is not None and y not in seen:
                seen.add(y)
                q.append(y)
    return False
