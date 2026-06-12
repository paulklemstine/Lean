def observation_complexity(m: int) -> int:
    """Least n with 2**n >= m, i.e. ceil(log2 m); the static = adaptive complexity."""
    if m <= 1:
        return 0
    n: int = 0
    power: int = 1
    while power < m:
        n += 1
        power *= 2
    return n
