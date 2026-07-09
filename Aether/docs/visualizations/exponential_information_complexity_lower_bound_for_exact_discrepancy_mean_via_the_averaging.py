from math import comb
from typing import Sequence

def exact_discrepancy_mean(code_size: int, n: int, q: int, r: int) -> tuple[int, float]:
    """Exact mean of |C n B_r(z)| over all q^n centres, WITHOUT enumeration.

    Uses sum_inter_ball (sum_z |C n B_r(z)| = |C|*|B_r(0)|) and the closed-form
    ball volume ball_card_formula. Returns (|C|*|B_r(0)|, mean-per-centre).
    Complexity: O(r) for the volume sum, O(1) for the product -- vs Theta(q^n) naive.
    """
    volume: int = sum(comb(n, i) * (q - 1) ** i for i in range(r + 1))
    total: int = code_size * volume
    mean: float = total / (q ** n)
    return total, mean
