def hamming_ball_volume(A: int, L: int, r: int) -> int:
    return sum(math.comb(L, i) * (A - 1) ** i for i in range(min(r, L) + 1))