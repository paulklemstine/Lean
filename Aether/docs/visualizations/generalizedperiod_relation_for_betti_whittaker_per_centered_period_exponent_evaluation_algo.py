from typing import List

def period_exp(lam: List[int]) -> int:
    """Centered period exponent e(L) = sum_i (2i+1-n)*L_i."""
    n = len(lam)
    return sum((2 * i + 1 - n) * lam[i] for i in range(n))
