from typing import Callable, Dict, Optional, Tuple

def find_coarse_collision(
    f: Callable[[int], int],
    x: int,
    label: Callable[[int], int],
    k: int,
) -> Optional[Tuple[int, int]]:
    """First (m, n) with 0 <= m < n <= k and label(f^[m](x)) == label(f^[n](x)).
    Guaranteed to exist by exists_iterate_rel_of_card_quotient. O(k) time/space."""
    first_seen: Dict[int, int] = {}
    state: int = x
    for i in range(k + 1):
        lab: int = label(state)
        if lab in first_seen:
            return (first_seen[lab], i)
        first_seen[lab] = i
        state = f(state)
    return None
