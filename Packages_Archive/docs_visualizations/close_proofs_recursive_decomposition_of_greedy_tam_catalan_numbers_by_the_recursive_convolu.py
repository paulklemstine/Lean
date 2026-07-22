from functools import lru_cache


@lru_cache(maxsize=None)
def catalan_convolution(n: int) -> int:
    """Compute the n-th Catalan number via the recursive decomposition.

    Uses C_0 = 1 and C_{n+1} = sum_{i=0}^{n} C_i * C_{n-i}, the arithmetic
    shadow of splitting a Dyck path at its first return (or a binary tree at
    its root). Memoized; complexity O(n^2) integer multiplications.
    """
    if n == 0:
        return 1
    total: int = 0
    for i in range(n):
        total += catalan_convolution(i) * catalan_convolution(n - 1 - i)
    return total
