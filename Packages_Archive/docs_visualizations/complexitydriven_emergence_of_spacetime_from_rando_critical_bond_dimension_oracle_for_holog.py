def critical_bond_dimension(k: int, N: int, b: int) -> int:
    """Least D with D**b >= k**N = ceil((k**N)**(1/b)) = D_c(N)."""
    target = k ** N
    hi = 2
    while hi ** b < target:
        hi *= 2
    lo = 1
    while lo < hi:
        mid = (lo + hi) // 2
        if mid ** b >= target:
            hi = mid
        else:
            lo = mid + 1
    return lo

def encoding_exists(k: int, N: int, b: int, D: int) -> bool:
    """True iff a faithful injection Fin(k**N) -> Fin(D**b) exists."""
    return D ** b >= k ** N
