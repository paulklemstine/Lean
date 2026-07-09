from functools import lru_cache
from typing import List

@lru_cache(maxsize=None)
def eulerian(n: int, k: int) -> int:
    if k < 0 or k >= max(n, 1):
        return 0
    if n == 0:
        return 1 if k == 0 else 0
    if k == 0:
        return 1
    return (k + 1) * eulerian(n - 1, k) + (n - k) * eulerian(n - 1, k - 1)

def squared_row_polynomial(n: int) -> List[int]:
    """Coefficients (low->high) of S_n(x)=sum_k (sum_j A(n,j)A(j,k)) x^k, trailing zeros trimmed."""
    top = max(n, 1)
    coeffs = [sum(eulerian(n, j) * eulerian(j, k) for j in range(top)) for k in range(top)]
    while len(coeffs) > 1 and coeffs[-1] == 0:
        coeffs.pop()
    return coeffs
