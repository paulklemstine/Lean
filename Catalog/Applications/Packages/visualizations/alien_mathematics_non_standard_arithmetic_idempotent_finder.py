def find_idempotents(N: int):
    add_idemp = [0] + ([N] if N > 0 else [])
    mul_idemp = [0] + ([1] if N >= 1 else []) + ([N] if N >= 2 else [])
    return add_idemp, mul_idemp