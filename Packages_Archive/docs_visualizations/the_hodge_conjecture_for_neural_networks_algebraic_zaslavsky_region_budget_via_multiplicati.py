from math import comb

def region_bound(m: int, n: int) -> int:
    """Zaslavsky region budget sum_{i<=n} C(m,i) via multiplicative update.

    Runs in O(min(n, m)) using C(m,i) = C(m,i-1) * (m-i+1)/i and the fact
    that C(m,i) = 0 for i > m (so we stop early at min(n, m)).
    """
    total: int = 0
    term: int = 1  # C(m, 0)
    upper: int = min(n, m)
    for i in range(0, upper + 1):
        total += term
        # advance to C(m, i+1)
        term = term * (m - i) // (i + 1)
    return total
