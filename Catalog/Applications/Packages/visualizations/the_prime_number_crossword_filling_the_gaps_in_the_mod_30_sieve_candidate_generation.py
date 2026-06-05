def mod30_candidates(p: int, bound: int) -> list:
    A30 = {1,7,11,13,17,19,23,29}
    r = p % 30
    return [p+g for g in range(2, bound+1, 2) if (r+g) % 30 in A30]