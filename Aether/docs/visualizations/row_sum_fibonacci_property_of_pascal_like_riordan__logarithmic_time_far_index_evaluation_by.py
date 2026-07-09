from typing import Tuple

Mat = Tuple[int, int, int, int]  # row-major 2x2 matrix (a, b, c, d)

def _mul(p: Mat, q: Mat) -> Mat:
    return (p[0]*q[0] + p[1]*q[2], p[0]*q[1] + p[1]*q[3],
            p[2]*q[0] + p[3]*q[2], p[2]*q[1] + p[3]*q[3])

def row_sum_logarithmic(n: int) -> int:
    """Compute A(n) = F_{2n+1} in O(log n) multiplications by fast exponentiation
    of the transfer matrix M = [[2,1],[1,1]] acting on (A,B)=(1,0)."""
    result: Mat = (1, 0, 0, 1)      # identity
    base: Mat = (2, 1, 1, 1)        # M
    e = n
    while e > 0:
        if e & 1:
            result = _mul(result, base)
        base = _mul(base, base)
        e >>= 1
    a0, b0 = 1, 0                    # (A(0), B(0))
    return result[0] * a0 + result[1] * b0
