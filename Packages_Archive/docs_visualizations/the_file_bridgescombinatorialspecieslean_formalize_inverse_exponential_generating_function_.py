from fractions import Fraction
from math import factorial
from typing import List

def seq_of(f: List[Fraction]) -> List[Fraction]:
    """Inverse EGF: recover the counting sequence a_n = n! * [X^n] f.

    Foundation: egf is a bijection (N->Q) ~ Q[[X]] with this explicit inverse
    (Theorem 3.2); hence the EGF is a complete invariant for labelled counting.
    Complexity: O(len(f)) rational operations.
    """
    return [factorial(n) * f[n] for n in range(len(f))]
