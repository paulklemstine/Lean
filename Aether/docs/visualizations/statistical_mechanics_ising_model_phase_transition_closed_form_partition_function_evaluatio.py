import math

def ising_1d_partition_closed(beta: float, J: float, n: int) -> float:
    """Exact 1D Ising partition function (free boundary), Z_n = 2 (2 cosh(beta J))^n.

    Args:
        beta: inverse temperature 1/(k_B T).
        J:    nearest-neighbour coupling (J > 0 ferromagnetic).
        n:    number of bonds (the chain has n + 1 sites).

    Returns:
        The exact partition function Z_n.
    """
    return 2.0 * (2.0 * math.cosh(beta * J)) ** n
