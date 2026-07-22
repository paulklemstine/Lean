from itertools import combinations
from typing import Sequence, Tuple

Perm = Tuple[int, ...]


def inversion_length(sigma: Perm) -> int:
    """Coxeter/Bruhat length: number of pairs i < j with sigma[i] > sigma[j].

    Realizes `len` from SchubertLengthChain.lean. Runs in O(n^2).
    """
    n: int = len(sigma)
    return sum(1 for i in range(n) for j in range(i + 1, n)
               if sigma[i] > sigma[j])


def upper_pairs_count(n: int) -> int:
    """Number of position pairs i < j; equals C(n, 2) (upperPairs_card)."""
    return sum(1 for _ in combinations(range(n), 2))
