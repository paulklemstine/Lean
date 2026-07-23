from math import comb
from typing import Tuple


def riordan_row_sums_direct(n: int) -> Tuple[int, int]:
    """Evaluate the Riordan row sum A(n) and companion B(n) from the definitions.

    A(n) = sum_{k=0}^{n} C(n+k, 2k)      (Definition pascalRiordanA)
    B(n) = sum_{k=0}^{n} C(n+k, 2k+1)    (Definition pascalRiordanB)

    Terms with k > n vanish automatically because the lower index exceeds the
    upper one, so the finite range 0..n captures the whole (formally infinite)
    sum.  Complexity: O(n^2) integer multiplications via binomial evaluation.
    """
    A = sum(comb(n + k, 2 * k) for k in range(n + 1))
    B = sum(comb(n + k, 2 * k + 1) for k in range(n + 1))
    return A, B
