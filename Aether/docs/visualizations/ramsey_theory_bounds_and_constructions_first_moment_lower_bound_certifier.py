from math import comb
from typing import Optional

def first_moment_certificate(k: int) -> Optional[int]:
    """
    Return the largest n such that the exact first-moment hypothesis
        k <= n  and  2 * C(n, k) < 2 ^ C(k, 2)
    holds, certifying R(k, k) > n. Returns None if no n >= k qualifies.
    Uses exact big-integer arithmetic, so the certificate is rigorous.
    """
    best: Optional[int] = None
    n = k
    while k <= n and 2 * comb(n, k) < 2 ** comb(k, 2):
        best = n
        n += 1
    return best
