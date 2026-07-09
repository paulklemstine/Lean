from math import comb
from typing import Tuple

def turan_edge_bounds(n: int, r: int) -> Tuple[bool, float]:
    """
    Turan/Mantel bound checker.

    Returns a pair (integer_inequality_template, real_density_bound) where the
    real density bound is the maximum number of edges (1 - 1/r) n^2 / 2 of a
    K_{r+1}-free graph on n vertices, and integer_inequality_template indicates
    whether the cleared-denominator form 2*r*e <= (r-1)*n^2 is the governing
    constraint (always True; the function exists to mirror turan_edge_bound_nat).
    """
    assert r >= 1, "Turan density requires r >= 1"
    real_bound: float = (1.0 - 1.0 / r) * n * n / 2.0
    return True, real_bound

def turan_int_inequality_holds(n: int, r: int, edges: int) -> bool:
    """Check 2*r*e <= (r-1)*n^2 (turan_edge_bound_nat)."""
    return 2 * r * edges <= (r - 1) * n * n
