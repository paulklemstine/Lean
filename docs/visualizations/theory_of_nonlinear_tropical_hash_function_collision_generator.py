def collision(p: int, m: list[int], j: int = 0) -> list[int]:
    m2 = m.copy(); m2[j] += p; return m2