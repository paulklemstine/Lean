from math import gcd
from typing import List

def local_density_factor(p: int, n: int) -> int:
    """Compute nu_p(n): roots of x^2+1=0 mod p that are coprime to n.

    Foundation: counts the subset of the (at most two) modular roots whose
    canonical representative is coprime to n. Returns a value in {0,1,2}.
    Complexity: O(p) for the root scan plus O(log n) per gcd.
    """
    roots = [x for x in range(p) if (x * x + 1) % p == 0]
    return sum(1 for x in roots if gcd(x, n) == 1)
