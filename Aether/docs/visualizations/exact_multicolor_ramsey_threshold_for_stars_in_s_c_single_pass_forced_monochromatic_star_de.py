from typing import List, Optional, Sequence


def forced_star_at_vertex(
    incident_edge_colors: Sequence[int], targets: Sequence[int]
) -> Optional[int]:
    """Return a color j with count(j) >= targets[j], else None.

    Realizes StarRamsey.forcingF: when len(incident_edge_colors) >=
    sum_j (targets[j]-1) + 1, the return value is guaranteed non-None.

    Complexity: O(deg(v) + q) time, O(q) space.
    """
    q: int = len(targets)
    counts: List[int] = [0] * q
    for c in incident_edge_colors:
        counts[c] += 1
        if counts[c] >= targets[c]:
            return c
    return None
