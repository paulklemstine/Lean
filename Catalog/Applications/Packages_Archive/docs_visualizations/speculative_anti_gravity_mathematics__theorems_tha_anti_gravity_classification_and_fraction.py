from typing import Dict, Tuple


def antigravity_fraction(
    weight: Dict[str, int],
    length: Dict[str, int],
    tau: int,
    ell: int,
) -> Tuple[int, float]:
    """Classify heavy-yet-cheap theorems and return (count, fraction)."""
    verts = list(weight)
    count = sum(
        1 for b in verts if weight[b] >= tau and length[b] <= ell
    )
    fraction = count / len(verts) if verts else 0.0
    return count, fraction
