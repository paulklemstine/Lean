from __future__ import annotations
import math
from typing import Tuple


def ising_critical_constants() -> Tuple[float, float]:
    """Return (beta_c, T_c) for the 2D Ising model in closed form.

    beta_c = (1/2) log(1 + sqrt(2)),  T_c = 2 / log(1 + sqrt(2)).
    Complexity: O(1).
    """
    L: float = math.log(1.0 + math.sqrt(2.0))
    beta_c: float = 0.5 * L
    T_c: float = 2.0 / L
    return beta_c, T_c


def verify() -> bool:
    beta_c, T_c = ising_critical_constants()
    ok_identity: bool = math.isclose(math.sinh(2.0 * beta_c), 1.0, abs_tol=1e-12)
    ok_recip: bool = math.isclose(T_c * beta_c, 1.0, rel_tol=1e-12)
    return ok_identity and ok_recip
