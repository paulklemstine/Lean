from math import comb

def fuss_catalan(m: int, n: int) -> int:
    """Fuss-Catalan number Cat_m(n) as a two-term binomial difference.

    Cat_m(0) = 1; for n >= 1,
        Cat_m(n) = C((m+1)n, n) - m * C((m+1)n, n-1),
    which is a non-negative integer equal to C((m+1)n, n) / (m*n + 1).
    """
    if n < 0:
        raise ValueError("n must be non-negative")
    if n == 0:
        return 1
    return comb((m + 1) * n, n) - m * comb((m + 1) * n, n - 1)
