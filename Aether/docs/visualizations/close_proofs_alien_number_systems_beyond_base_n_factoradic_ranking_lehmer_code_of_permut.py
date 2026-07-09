from math import factorial
from typing import List

def factoradic_rank(n: int, k: int) -> List[int]:
    """Lehmer/factoradic code of rank n among permutations (n < (k+1)!).

    Uses the factorial bases [2, 3, ..., k+1] (capacity (k+1)!), peeling off
    n % (i+2) at each step. Specialization of mixed_radix_encode that indexes
    permutations in lexicographic order.
    """
    bases = [i + 2 for i in range(k)]
    digits: List[int] = []
    for b in bases:
        digits.append(n % b)
        n //= b
    return digits
