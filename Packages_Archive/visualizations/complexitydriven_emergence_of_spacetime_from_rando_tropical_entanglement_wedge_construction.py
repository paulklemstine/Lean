from typing import Dict, List, Sequence, Tuple


def dist_to_set(d: Dict[Tuple[int, int], float], s: Sequence[int], v: int) -> float:
    """Min-plus distance from v to a nonempty set s: min over members."""
    return min(d[(v, b)] for b in s)


def entanglement_wedge(bulk: Sequence[int], boundary: Sequence[int],
                       B: Sequence[int],
                       d: Dict[Tuple[int, int], float]) -> List[int]:
    """Compute the tropical entanglement wedge of B: bulk vertices strictly closer
    to B than to boundary \ B (mem_entanglementWedge_iff)."""
    Bc = [b for b in boundary if b not in B]
    return [v for v in bulk if dist_to_set(d, B, v) < dist_to_set(d, Bc, v)]


def wedge_stable_under(bulk: Sequence[int], boundary: Sequence[int],
                       B: Sequence[int], d: Dict[Tuple[int, int], float],
                       d2: Dict[Tuple[int, int], float]) -> bool:
    """Check that the wedge is unchanged after a perturbation d -> d2
    (the finite content of wedge_membership_stable_under_uniform_perturbation)."""
    return entanglement_wedge(bulk, boundary, B, d) == \
        entanglement_wedge(bulk, boundary, B, d2)
