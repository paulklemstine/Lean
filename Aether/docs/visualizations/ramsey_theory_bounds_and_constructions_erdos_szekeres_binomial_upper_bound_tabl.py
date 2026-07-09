from math import comb
from typing import Dict, Tuple

def erdos_szekeres_table(max_sum: int) -> Dict[Tuple[int, int], int]:
    """
    Build a table of Erdos--Szekeres upper bounds U(s, t) = C(s + t - 2, s - 1)
    for all 1 <= s, t with s + t <= max_sum, using the Pascal recurrence
        U(s, t) <= U(s - 1, t) + U(s, t - 1),  U(1, t) = U(s, 1) = 1.
    """
    table: Dict[Tuple[int, int], int] = {}
    for s in range(1, max_sum):
        for t in range(1, max_sum):
            if s + t > max_sum:
                continue
            if s == 1 or t == 1:
                table[(s, t)] = 1
            else:
                table[(s, t)] = table[(s - 1, t)] + table[(s, t - 1)]
    return table

def diagonal_ceiling(k: int) -> int:
    """Diagonal exponential ceiling R(k + 1, k + 1) <= 4^k."""
    assert comb(2 * k, k) <= 4 ** k
    return 4 ** k
