import math
from typing import List

def ising_1d_partition_recursion(beta: float, J: float, n: int) -> List[float]:
    """Build Z_0, Z_1, ..., Z_n by the transfer recursion Z_{k+1} = (2 cosh(beta J)) Z_k.

    Args:
        beta: inverse temperature.
        J:    coupling.
        n:    number of bonds.

    Returns:
        The list [Z_0, ..., Z_n]; each step multiplies by the dominant
        transfer-matrix eigenvalue 2 cosh(beta J).
    """
    eigenvalue: float = 2.0 * math.cosh(beta * J)
    z: List[float] = [2.0]            # Z_0 = 2 (single site, two states)
    for _ in range(n):
        z.append(eigenvalue * z[-1])
    return z
