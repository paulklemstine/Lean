def kinship_spectrum(n: int) -> list:
    zero = tuple(0 for _ in range(n))
    from itertools import product
    return [g for g in product(range(2), repeat=n) if g != zero]