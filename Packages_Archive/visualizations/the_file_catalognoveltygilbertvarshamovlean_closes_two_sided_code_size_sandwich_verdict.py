from math import comb
from typing import Tuple

def ball_volume(n: int, q: int, t: int) -> int:
    t = min(t, n)
    return sum(comb(n, i) * (q - 1) ** i for i in range(t + 1))

def sandwich_verdict(n: int, q: int, t: int, code_size: int) -> Tuple[bool, dict]:
    """
    Evaluate the code-size sandwich for a maximal (2t+1)-code of given size.
    Returns (holds, breakdown).
    """
    left = code_size * ball_volume(n, q, t)
    mid = q ** n
    right = code_size * ball_volume(n, q, 2 * t)
    holds = left <= mid <= right
    return holds, {
        "|C|*V(t)": left,
        "q^n": mid,
        "|C|*V(2t)": right,
        "lower_size_estimate": mid / ball_volume(n, q, 2 * t),
        "upper_size_estimate": mid / ball_volume(n, q, t),
    }
