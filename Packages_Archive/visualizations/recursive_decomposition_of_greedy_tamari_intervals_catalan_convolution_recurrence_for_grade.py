from functools import lru_cache


@lru_cache(maxsize=None)
def catalan_convolution(n: int) -> int:
    """Compute the n-th Catalan number by the convolution recurrence
    C_0 = 1,  C_{n+1} = sum_{i=0}^{n} C_i * C_{n-i}.

    This is exactly the recurrence satisfied, in parallel, by the number of
    plane forests, binary trees, and Dyck paths of the given size, so the
    same routine enumerates all three families.
    """
    if n == 0:
        return 1
    return sum(catalan_convolution(i) * catalan_convolution(n - 1 - i)
               for i in range(n))
