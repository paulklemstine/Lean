from math import comb

def ballot_good_paths(m: int, n: int) -> int:
    """Paths from (0,0) to (m,n) staying strictly ahead (m >= n)."""
    assert m >= n
    if m + n == 0:
        return 1
    return comb(m + n - 1, n) - comb(m + n - 1, n - 1)

def ballot_identity(m: int, n: int) -> bool:
    """Verify the formally proved ballot reflection identity (m >= n)."""
    assert n <= m
    diff = max(comb(m + n, n) - comb(m + n, m + 1), 0)   # truncated subtraction
    lhs = (m + n + 1) * diff
    rhs = (m + 1 - n) * comb(m + n + 1, n)
    return lhs == rhs
