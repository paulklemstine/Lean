def fib_entry(p: int, search_limit: int = 10_000) -> int:
    """Least k > 0 with p | F(k) (the rank of apparition), else 0."""
    if p <= 0:
        return 0
    if p == 1:
        return 1
    a, b = 0, 1
    for k in range(1, search_limit + 1):
        a, b = b, (a + b) % p
        if a == 0:
            return k
    return 0
