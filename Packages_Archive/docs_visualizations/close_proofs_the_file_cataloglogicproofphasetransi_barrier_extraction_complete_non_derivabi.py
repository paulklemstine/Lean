from typing import Callable, FrozenSet, Iterable, Optional

Theory = Callable[[int, int], bool]

def find_barrier(theory: Theory, universe: Iterable[int], a: int, b: int
                 ) -> Optional[FrozenSet[int]]:
    """Return a closed barrier R(a) certifying a -/-> b, or None if a derives b."""
    r = reachable_set(theory, universe, a)   # Algorithm A
    return None if b in r else r
