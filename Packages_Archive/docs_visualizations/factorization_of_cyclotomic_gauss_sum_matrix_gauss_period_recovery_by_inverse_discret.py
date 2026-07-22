from __future__ import annotations
import cmath, math
from typing import List


def recover_gauss_periods(column0: List[complex], omega: complex) -> List[complex]:
    """Recover eta from the zeroth column of A by the inverse DFT.

    Uses eta[c] = (1/n) * sum_i (omega ** (c * i)) ** (-1) * column0[i], which is
    valid because column0[i] = sum_a eta[a] * omega ** (a i) is exactly the DFT of
    the period vector. Cost O(n^2) directly, or O(n log n) with an FFT.
    """
    n = len(column0)
    eta: List[complex] = []
    for c in range(n):
        acc = 0j
        for i in range(n):
            acc += (omega ** (c * i)) ** (-1) * column0[i]
        eta.append(acc / n)
    return eta
