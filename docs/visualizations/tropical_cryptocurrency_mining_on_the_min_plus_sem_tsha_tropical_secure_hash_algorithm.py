def tsha(m: list[int], h: list[int]) -> int:
    return min(m[i] + h[i] for i in range(len(m)))