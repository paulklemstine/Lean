from __future__ import annotations

import itertools
from typing import Iterator, List, Tuple


def cube_points(n: int) -> Iterator[Tuple[int, ...]]:
    """Yield each of the 2^n corners of {-1,1}^n as a tuple of +-1 integers."""
    for bits in itertools.product((1, -1), repeat=n):
        yield bits


def exact_covariance_kernel(n: int) -> List[List[int]]:
    """Compute T(k,l) = sum_x coord(x,k) coord(x,l) by exhaustive enumeration.

    Returns the integer matrix T. By the covariance theorem it equals 2^n * I_n:
    diagonal entries are 2^n and off-diagonal entries are 0, in every dimension.

    Complexity: Theta(2^n * n^2) time, Theta(n^2) space.
    """
    T: List[List[int]] = [[0] * n for _ in range(n)]
    for x in cube_points(n):
        for k in range(n):
            xk = x[k]
            for l in range(n):
                T[k][l] += xk * x[l]
    return T


def is_identity_times(T: List[List[int]], scale: int) -> bool:
    """Check that T equals scale * I (the covariance theorem's prediction)."""
    n = len(T)
    for k in range(n):
        for l in range(n):
            expected = scale if k == l else 0
            if T[k][l] != expected:
                return False
    return True


def verify_covariance(n: int) -> bool:
    """Verify T = 2^n * I_n for the discrete cube of dimension n."""
    return is_identity_times(exact_covariance_kernel(n), 2 ** n)
