from typing import Optional, Sequence

def detect_obstruction(f: Sequence[int], horizon: int) -> Optional[int]:
    """Return a single containing stage for the (finite prefix of a) sequence f,
    or None if the required stage exceeds `horizon` (obstruction certificate)."""
    m = max(f) if len(f) else 0
    return m if m <= horizon else None
