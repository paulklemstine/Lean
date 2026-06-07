def cantor_diagonal(f, length: int) -> tuple:
    return tuple(1 if f(n)(n) == 0 else 0 for n in range(length))