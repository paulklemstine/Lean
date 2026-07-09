import itertools
import math
from typing import Iterator, Tuple

def ising_1d_partition_bruteforce(beta: float, J: float, n: int) -> float:
    """Brute-force 1D Ising partition function by summing over all 2^(n+1) spins.

    This O(n * 2^(n+1)) reference implementation directly realizes the
    definition Z_n = sum_s prod_i exp(beta J s_i s_{i+1}) and is used to
    validate the O(1) closed form on small chains.

    Args:
        beta: inverse temperature.
        J:    coupling.
        n:    number of bonds (n + 1 sites).

    Returns:
        The partition function Z_n.
    """
    def configs(k: int) -> Iterator[Tuple[int, ...]]:
        return itertools.product((-1, 1), repeat=k)

    total: float = 0.0
    for s in configs(n + 1):
        weight: float = 1.0
        for i in range(n):
            weight *= math.exp(beta * J * s[i] * s[i + 1])
        total += weight
    return total
