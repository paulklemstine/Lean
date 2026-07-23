from typing import Callable, Dict, List, Optional, Tuple

Predicate = Callable[[int], bool]
Profile = Tuple[bool, ...]


def profile(preds: List[Predicate], state: int) -> Profile:
    """The n-tuple of predicate values for `state`."""
    return tuple(p(state) for p in preds)


def find_twin_pair(preds: List[Predicate],
                   states: List[int]) -> Optional[Tuple[int, int]]:
    """Return a distinct pair with identical profiles, or None.

    Guaranteed non-None when len(states) > 2 ** len(preds).
    """
    seen: Dict[Profile, int] = {}
    for s in states:
        sig = profile(preds, s)
        if sig in seen and seen[sig] != s:
            return (seen[sig], s)
        seen.setdefault(sig, s)
    return None
