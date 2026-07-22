import math
from typing import List

def ising_1d_partition_transfer(beta: float, J: float, n: int,
                                periodic: bool = False) -> float:
    """Evaluate the 1D Ising partition function via the 2x2 transfer matrix.

    The transfer matrix is
        T = [[exp(bJ), exp(-bJ)], [exp(-bJ), exp(bJ)]],
    with eigenvalues lam_plus = 2 cosh(beta J), lam_minus = 2 sinh(beta J).

    Args:
        beta:     inverse temperature.
        J:        coupling.
        n:        number of bonds.
        periodic: if True compute the ring (trace) partition function
                  Z_per = lam_plus^n + lam_minus^n; otherwise the open chain
                  Z = 2 (2 cosh(beta J))^n.

    Returns:
        The partition function as a float.
    """
    bj: float = beta * J
    lam_plus: float = 2.0 * math.cosh(bj)
    lam_minus: float = 2.0 * math.sinh(bj)
    if periodic:
        return lam_plus ** n + lam_minus ** n
    # Open chain: T acting on the all-ones boundary vector, then summed.
    a: float = math.exp(bj)
    b: float = math.exp(-bj)
    v: List[float] = [1.0, 1.0]
    for _ in range(n):
        v = [a * v[0] + b * v[1], b * v[0] + a * v[1]]
    return v[0] + v[1]
