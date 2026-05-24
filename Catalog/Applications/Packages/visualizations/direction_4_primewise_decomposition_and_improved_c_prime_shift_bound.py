def prime_shift_bound_improved(p, delta):
    if p >= 2 and delta % p == 0:
        return delta // p
    return delta