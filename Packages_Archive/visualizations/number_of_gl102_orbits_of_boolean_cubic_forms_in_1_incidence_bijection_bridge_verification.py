from __future__ import annotations
from typing import Callable, Sequence, Tuple

def bridge_check(group: Sequence[object],
                 domain: Sequence[object],
                 act: Callable[[object, object], object]) -> Tuple[int, int, bool]:
    """Evaluate both sides of the incidence identity and confirm they agree.

    Returns (burnside_side, stabilizer_side, they_are_equal), where
        burnside_side   = sum_{g in G} |Fix(g)|,
        stabilizer_side = sum_{x in X} |Stab(x)|.
    Equality is guaranteed by the incidence bijection on {(g,x) : g.x = x}.
    """
    burnside = sum(sum(1 for x in domain if act(g, x) == x) for g in group)
    stab = sum(sum(1 for g in group if act(g, x) == x) for x in domain)
    return burnside, stab, burnside == stab
