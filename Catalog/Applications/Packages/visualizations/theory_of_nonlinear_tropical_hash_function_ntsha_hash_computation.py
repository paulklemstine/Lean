def ntsha(p: int, m: list[int], h: list[int]) -> int:
    return min((mi + hi) % p for mi, hi in zip(m, h))