from math import comb


def fuss_catalan(m: int, n: int) -> int:
    """Return the Fuss-Catalan number FC(m, n) = C((m+1)n, n) / (m*n + 1).

    The division is exact whenever the cycle lemma applies (always for m = 1),
    so integer floor division returns the true value.
    Complexity: O(n) big-integer multiplications for the binomial coefficient.
    """
    numerator: int = comb((m + 1) * n, n)
    denominator: int = m * n + 1
    return numerator // denominator
