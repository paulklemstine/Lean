from typing import Dict, Tuple

Cell = Tuple[int, int, int]
Table = Dict[Cell, int]


def geodesic_distance(u: Table, v: Table) -> int:
    """O(1) closed-form Markov-graph distance for the 2x2x2 no-three-way model.

    Precondition: u, v are nonnegative and share all two-way margins.
    Returns |v(0,0,0) - u(0,0,0)|.
    """
    return abs(v[(0, 0, 0)] - u[(0, 0, 0)])
