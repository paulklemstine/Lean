def wedge_capacity(n: int, sizes: list) -> int:
    return sum(min(s, n-s) for s in sizes)