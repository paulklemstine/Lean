from math import gcd
from typing import Tuple

def is_unit(a: int, n: int) -> bool:
    """Return True iff a is a unit of Z_n, i.e. gcd(a mod n, n) == 1."""
    return gcd(a % n, n) == 1

def is_panmagic(a: int, b: int, n: int) -> bool:
    """Decide whether the affine map sigma(x) = a*x + b is panmagic on Z_n.

    By the algebraic characterization, this holds iff a, a-1, a+1 are all
    units of Z_n. The additive shift b is irrelevant to panmagicness.
    Complexity: O(log n) via three Euclidean gcd computations.
    """
    return is_unit(a, n) and is_unit(a - 1, n) and is_unit(a + 1, n)
