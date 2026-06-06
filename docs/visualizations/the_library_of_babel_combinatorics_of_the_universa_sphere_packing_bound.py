def sphere_packing_bound(A: int, L: int, d: int) -> int:
    r = (d - 1) // 2
    return A ** L // hamming_ball_volume(A, L, r)