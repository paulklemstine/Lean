def lucas_lehmer(p: int) -> bool:
    if p == 2: return True
    M = (1 << p) - 1
    s = 4
    for _ in range(p - 2):
        s = (s * s - 2) % M
    return s == 0