def cyc_dist(a: int, b: int, n: int = 12) -> int:
    r = (a - b) % n
    return min(r, n - r)