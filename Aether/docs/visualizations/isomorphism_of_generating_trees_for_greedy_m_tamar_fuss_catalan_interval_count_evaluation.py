def binom(n: int, k: int) -> int:
    """Exact integer binomial coefficient C(n, k)."""
    if k < 0 or k > n:
        return 0
    num = 1
    den = 1
    for i in range(k):
        num *= n - i
        den *= i + 1
    return num // den


def tamari_interval_count(m: int, n: int) -> int:
    """Number of m-Tamari intervals (= planar (m+1)-constellations) of size n.

    Uses the closed form  (m+1)/(n(mn+1)) * C((m+1)^2 n + m, n-1).
    The result is always a positive integer; the assertion certifies the exact
    division for the supplied (m, n).
    """
    top = (m + 1) * binom((m + 1) ** 2 * n + m, n - 1)
    bot = n * (m * n + 1)
    assert top % bot == 0, "closed form must divide exactly"
    return top // bot
