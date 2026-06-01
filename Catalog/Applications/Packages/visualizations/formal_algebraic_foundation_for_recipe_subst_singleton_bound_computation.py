def singleton_bound(n: int, m: int, d: int) -> int:
    return m ** max(n - d + 1, 0)