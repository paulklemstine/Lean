from typing import FrozenSet, List, Set, Tuple

Point = int
Topology = FrozenSet[FrozenSet[Point]]


def specialization_matrix(
    carrier: FrozenSet[Point], opens: Topology
) -> Set[Tuple[Point, Point]]:
    """Return {(b, a) : b ~> a} using minimal open neighborhoods."""
    min_nbhd: dict[Point, FrozenSet[Point]] = {}
    for a in carrier:
        u: FrozenSet[Point] = carrier
        for U in opens:
            if a in U:
                u = u & U
        min_nbhd[a] = u
    return {(b, a) for a in carrier for b in min_nbhd[a]}
