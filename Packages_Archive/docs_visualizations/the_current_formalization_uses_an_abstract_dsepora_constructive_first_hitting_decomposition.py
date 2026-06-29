from __future__ import annotations
from typing import Callable, List, Optional, Tuple


def first_hit(walk: List[int],
              predicate: Callable[[int], bool]
              ) -> Tuple[str, List[int], Optional[Tuple[int, int]]]:
    """Constructive first-hitting decomposition (engine of contraction).

    Precondition: walk is non-empty and its first vertex satisfies NOT predicate.
    Returns:
      ("avoid", walk, None)            if predicate never fires on the walk;
      ("hit", prefix, (w_prev, w))     where prefix is the maximal predicate-free
                                       initial segment and (w_prev, w) is the edge
                                       entering the first predicate-vertex w.
    """
    assert walk and not predicate(walk[0])
    prefix: List[int] = [walk[0]]
    for i in range(1, len(walk)):
        if predicate(walk[i]):
            return "hit", prefix, (walk[i - 1], walk[i])
        prefix.append(walk[i])
    return "avoid", walk, None
