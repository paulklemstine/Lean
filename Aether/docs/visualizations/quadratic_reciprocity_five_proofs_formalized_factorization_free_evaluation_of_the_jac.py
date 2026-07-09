from __future__ import annotations


def jacobi_symbol(a: int, n: int) -> int:
    """Fast, factorization-free Jacobi symbol (a/n) for odd n > 0.

    Uses the second supplementary law to remove factors of 2 and
    quadratic reciprocity to swap the arguments, running in
    O(log^2 n) bit operations, exactly mirroring the Euclidean algorithm.
    """
    if n <= 0 or n % 2 == 0:
        raise ValueError("n must be a positive odd integer")
    a %= n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):   # second supplement: (2/n) = -1 here
                result = -result
        a, n = n, a               # reciprocity swap
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0
