from typing import FrozenSet, List

def is_T0(ground: FrozenSet[object],
          tau: FrozenSet[FrozenSet[object]]) -> bool:
    """A finite space is T0 iff every pair of distinct points is separated by an
    open set. A finite non-T0 space cannot be metrizable."""
    pts: List[object] = list(ground)
    for i in range(len(pts)):
        for j in range(i + 1, len(pts)):
            p, q = pts[i], pts[j]
            if not any((p in U) != (q in U) for U in tau):
                return False
    return True

def is_metrizable_certifiable_false(ground, tau) -> bool:
    """Returns True when non-metrizability is certified via the T0 obstruction."""
    return not is_T0(ground, tau)
