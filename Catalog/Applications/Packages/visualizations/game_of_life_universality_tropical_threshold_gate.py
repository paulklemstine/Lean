def tropical_threshold(s: int, lo: int, hi: int) -> int:
    return min(1, max(0, s + 1 - lo)) * min(1, max(0, hi + 1 - s))