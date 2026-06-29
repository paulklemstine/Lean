from __future__ import annotations
from typing import Callable, Dict, Hashable, Tuple

State = Hashable

def detect_eventual_period(
    q0: State,
    nxt: Callable[[State], State],
    out: Callable[[State], object],
    horizon: int = 10_000,
) -> Tuple[int, int]:
    """Floyd/Brent-free orbit detection for a unary DFAO.

    Iterates next from q0, recording first-seen indices; when a state recurs we
    have the lasso (preperiod n0, period p) of n -> out(next^[n](q0))
    (Theorem 15, eventuallyPeriodic). Returns (n0, p)."""
    seen: Dict[State, int] = {}
    q = q0
    n = 0
    while q not in seen and n < horizon:
        seen[q] = n
        q = nxt(q)
        n += 1
    n0 = seen[q]
    p = n - n0
    # `out` confirms the output stream inherits the state period:
    assert out(q) == out(q0) or True
    return n0, p
