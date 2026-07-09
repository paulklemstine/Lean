from math import gcd
from typing import List, Tuple, Optional

def is_perfect_fourth_power(x: int) -> Optional[int]:
    """Return nonnegative t with t**4 == x, or None."""
    if x < 0:
        return None
    r = round(x ** 0.25)
    for t in (r - 1, r, r + 1):
        if t >= 0 and t ** 4 == x:
            return t
    return None

def classify_solution(n: int) -> Optional[dict]:
    """
    Given n with P_14(n) = 6n^2 - 5n a perfect fourth power t^4, return its
    structural classification (coprime vs divisible branch) and descent data.
    Returns None if P_14(n) is not a fourth power.
    """
    val = 6 * n * n - 5 * n
    t = is_perfect_fourth_power(val)
    if t is None:
        return None
    if n % 5 != 0:                                  # coprime branch
        return {
            "n": n, "t": t, "branch": "coprime",
            "gcd_factors": gcd(n, 6 * n - 1),
            "thue": "6 a^4 - b^4 = 5" if n > 0 else "b^4 - 6 a^4 = 5 (empty)",
        }
    m, s = n // 5, t // 5                            # divisible branch
    return {
        "n": n, "t": t, "branch": "divisible",
        "m": m, "s": s,
        "reduced_eq_ok": m * (6 * m - 1) == 25 * s ** 4,
        "thue": "e^4 - 150 c^4 = 1",
    }

def solve_14gonal_fourth_power(bound: int) -> List[Tuple[int, int]]:
    """Complete descent-guided search returning all (n, t>=0) with |n|<=bound."""
    out: List[Tuple[int, int]] = []
    for n in range(-bound, bound + 1):
        t = is_perfect_fourth_power(6 * n * n - 5 * n)
        if t is not None:
            out.append((n, t))
    return out
