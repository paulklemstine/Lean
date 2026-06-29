from typing import Callable, FrozenSet, Sequence, Tuple

Edge = Tuple[int, int]

def is_interleaved(
    obj_M: Callable[[float], FrozenSet[Edge]],
    obj_N: Callable[[float], FrozenSet[Edge]],
    eps: float,
    probe: Sequence[float],
) -> bool:
    """Certify an eps-interleaving by checking both shifted dominations."""
    for t in probe:
        if not obj_M(t) <= obj_N(t + eps):
            return False
        if not obj_N(t) <= obj_M(t + eps):
            return False
    return True