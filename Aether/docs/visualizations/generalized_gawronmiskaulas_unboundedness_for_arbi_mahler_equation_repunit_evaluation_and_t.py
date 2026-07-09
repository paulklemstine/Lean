"""
Algorithm: repunit coefficient via the Mahler functional equation, plus the
transfer-matrix builder for the general multiplicity m.

Mathematical foundation. The truncated products Q_N satisfy the Mahler equation
Q_{N+1}(x) = (1-x)^m * Q_N(x^b). Reading the coefficient at the repunit degree
R_{k+1} = b*R_k + 1 expresses T_{b,m}(R_{k+1}) as a fixed linear combination of
the values T_{b,m}(R_k - t) for the surviving interior indices j = 1 + t*b <= m:

    T_{b,m}(R_{k+1}) = sum_{t : 1+tb <= m} (-1)^{1+tb} C(m, 1+tb) * T_{b,m}(R_k - t).

For m = 2 (any b) the only surviving t is 0, giving the single-ratio recurrence
T_{b,2}(R_{k+1}) = -2 * T_{b,2}(R_k), hence T_{b,2}(R_k) = (-2)^k.

Complexity. Building the transfer matrix is O(m/b) work; iterating k steps is
O(k * W^2) with window size W = floor((m-1)/b) + 1. Unboundedness reduces to a
finite spectral-radius check rho(M) > 1.
"""

from __future__ import annotations

from math import comb
from typing import List


def surviving_coeffs(b: int, m: int) -> List[int]:
    """Interior coefficients (-1)^{1+tb} C(m, 1+tb) for t with 1 + t*b <= m."""
    out: List[int] = []
    t = 0
    while 1 + t * b <= m:
        j = 1 + t * b
        out.append(((-1) ** j) * comb(m, j))
        t += 1
    return out


def transfer_matrix(b: int, m: int) -> List[List[int]]:
    """Companion-style transfer matrix M with v_{k+1} = M v_k,
    where v_k = (T_{b,m}(R_k - t))_{0 <= t <= T}, T = floor((m-1)/b).

    Row 0 encodes the multi-term recurrence; the remaining rows are shifts
    that re-expose the neighbouring repunit-window values needed at the next
    step (a structural companion form)."""
    T = (m - 1) // b
    size = T + 1
    M = [[0] * size for _ in range(size)]
    coeffs = surviving_coeffs(b, m)
    for t, c in enumerate(coeffs):
        if t < size:
            M[0][t] = c
    for r in range(1, size):
        M[r][r - 1] = 1
    return M


def repunit_value(b: int, m: int, k: int) -> int:
    """T_{b,m}(R_k) via the single-ratio recurrence when b >= m (exact: (-m)^k),
    falling back to direct polynomial extraction otherwise."""
    if b >= m:
        return (-m) ** k
    return _repunit_value_direct(b, m, k)


def _repunit_value_direct(b: int, m: int, k: int) -> int:
    """Direct coefficient extraction T_{b,m}(R_k) by truncated multiplication."""
    n = 0
    for _ in range(k):
        n = b * n + 1  # R_k
    result = [0] * (n + 1)
    result[0] = 1
    exp = 1
    while exp <= n:
        factor = [0] * (n + 1)
        for j in range(m + 1):
            d = exp * j
            if d > n:
                break
            factor[d] += comb(m, j) * ((-1) ** j)
        nxt = [0] * (n + 1)
        for i, ai in enumerate(result):
            if ai == 0:
                continue
            for d, fd in enumerate(factor):
                if fd == 0 or i + d > n:
                    continue
                nxt[i + d] += ai * fd
        result = nxt
        exp *= b
    return result[n]


if __name__ == "__main__":
    # m = 2: single-ratio, every base.
    print("transfer matrix b=3,m=2:", transfer_matrix(3, 2))
    print("T_{3,2}(R_k):", [repunit_value(3, 2, k) for k in range(6)])
    # m = 4, b = 3 (open corner): multi-term.
    print("surviving coeffs b=3,m=4:", surviving_coeffs(3, 4))
    print("T_{3,4}(R_k):", [_repunit_value_direct(3, 4, k) for k in range(6)])
