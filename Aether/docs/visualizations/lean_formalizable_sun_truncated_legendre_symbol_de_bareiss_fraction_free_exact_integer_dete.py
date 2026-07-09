from typing import List

def det_int(matrix: List[List[int]]) -> int:
    """Exact integer determinant via Bareiss fraction-free Gaussian elimination.

    Every intermediate division is exact, so the computation stays in the
    integers with no round-off and controlled coefficient growth.  Cost O(n^3).
    """
    n = len(matrix)
    if n == 0:
        return 1
    a = [row[:] for row in matrix]
    sign, prev = 1, 1
    for i in range(n - 1):
        if a[i][i] == 0:
            swap = next((r for r in range(i + 1, n) if a[r][i] != 0), None)
            if swap is None:
                return 0
            a[i], a[swap] = a[swap], a[i]
            sign = -sign
        for r in range(i + 1, n):
            for c in range(i + 1, n):
                a[r][c] = (a[r][c] * a[i][i] - a[r][i] * a[i][c]) // prev
        prev = a[i][i]
    return sign * a[n - 1][n - 1]
