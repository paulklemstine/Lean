from math import log
from typing import Final

BOLTZMANN_K: Final[float] = 1.380649e-23  # J / K
LN2: Final[float] = log(2.0)


def landauer_cost(bits: float, kB: float = BOLTZMANN_K, T: float = 300.0) -> float:
    """Minimum heat (joules) dissipated by erasing `bits` bits at temperature T (K).

    Implements Landauer's principle: cost = bits * kB * T * ln 2. Strictly
    positive whenever bits > 0 and T > 0.
    """
    if bits < 0.0:
        raise ValueError("erased bits must be nonnegative")
    return bits * kB * T * LN2
