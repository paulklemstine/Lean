from fractions import Fraction
from itertools import product
from typing import Sequence

def expected_occurrences_exhaustive(pattern: Sequence[int], b: int, L: int) -> Fraction:
    """Exact E[occurrences] by enumerating the entire library of b**L volumes.

    Implements Definition 8 directly and must equal (L-k+1)*b**(-k).
    Complexity: Theta(b**L * (L-k+1) * k).
    """
    k = len(pattern)
    total = 0
    for volume in product(range(b), repeat=L):           # all b**L volumes
        for i in range(L - k + 1):                       # admissible positions
            if all(volume[i + j] == pattern[j] for j in range(k)):
                total += 1
    return Fraction(total, b ** L)
