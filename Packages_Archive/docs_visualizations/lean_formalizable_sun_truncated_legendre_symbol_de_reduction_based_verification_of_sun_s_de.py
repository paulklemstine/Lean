from typing import List, Tuple

def legendre(a: int, p: int) -> int:
    a %= p
    return 0 if a == 0 else (1 if pow(a, (p - 1) // 2, p) == 1 else -1)

def det_int(matrix: List[List[int]]) -> int:
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

def verify_sun_identity(p: int) -> Tuple[int, int, int]:
    """Verify det A = floor((p-2)/3)^2 * X for a prime p == 3 (mod 4), p >= 7.

    Returns (det C, det(C+J), expected coefficient).  Uses the proven affine
    reduction det A = det C + (det(C+J) - det C) * X together with det C = 0.
    """
    assert p >= 7 and p % 4 == 3, "need p >= 7 with p == 3 (mod 4)"
    m = (p - 5) // 2
    C = [[legendre(j - k, p) for k in range(m)] for j in range(m)]
    CJ = [[1 + C[j][k] for k in range(m)] for j in range(m)]
    detC, detCJ = det_int(C), det_int(CJ)
    coeff = ((p - 2) // 3) ** 2
    assert detC == 0 and detCJ == coeff
    return detC, detCJ, coeff
