from typing import Callable, List, Optional

def circuit_lower_bound_from_obstruction(
        objects: List[str],
        orbit_dim: Callable[[str], int],
        circuit_size: Callable[[str], int],
        repMult: Callable,
        indices: List["RepIndex"],
        f: str, B: int) -> Optional[int]:
    """Algorithm B: circuit lower bound from an obstruction catalog (Theorem 2).

    For the budget B, enumerate every competitor g with orbit_dim(g) <= B*B and
    attempt an obstruction of f against g (Algorithm A). If EVERY such competitor
    receives a certificate, the small-circuit axiom forces circuit_size(f) > B.
    Returns the certified bound B on success, else None.
    """
    for g in objects:
        if orbit_dim(g) <= B * B:
            if find_obstruction(repMult, f, g, indices) is None:
                return None
    return B
