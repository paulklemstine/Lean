import math
from typing import Optional, Tuple

def classify_prime_in_gaussian(p: int) -> Tuple[str, Optional[Tuple[int, int]]]:
    """Classify a rational prime p by its behaviour in Z[i].

    Returns ("split", (a, b)) with a^2+b^2 = p when p % 4 == 1 (Fermat),
    ("inert", None) when p % 4 == 3, and ("ramified", (1, 1)) when p == 2.
    Complexity: O(sqrt(p)) for the two-squares search.
    """
    if p == 2:
        return ("ramified", (1, 1))
    if p % 4 == 3:
        return ("inert", None)
    a = 0
    while a * a <= p:
        b2 = p - a * a
        b = math.isqrt(b2)
        if b * b == b2:
            return ("split", (a, b))
        a += 1
    return ("inert", None)
