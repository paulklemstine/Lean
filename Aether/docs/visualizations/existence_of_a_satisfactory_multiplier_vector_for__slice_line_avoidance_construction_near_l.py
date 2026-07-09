def good_multiplier_slice(
    p: int, D: list[tuple[int, int]]
) -> tuple[int, int] | None:
    """Find a good multiplier by scanning the slice a=(1,t)."""
    forbidden: set[int] = set()
    for d1, d2 in D:
        if d2 % p != 0:
            forbidden.add((-d1 * pow(d2 % p, p - 2, p)) % p)
        elif d1 % p == 0:
            return None  # d == 0 not allowed
    for t in range(p):
        if t not in forbidden:
            if all((d[0] + d[1] * t) % p != 0 for d in D):
                return (1, t)
    for t in range(p):
        if all((d[0] * t + d[1]) % p != 0 for d in D):
            return (t, 1)
    return None
