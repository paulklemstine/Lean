from itertools import product

def good_multiplier_sweep(
    p: int, D: list[tuple[int, int]]
) -> tuple[int, int] | None:
    """First multiplier a with <d,a> != 0 (mod p) for all d in D."""
    for a1, a2 in product(range(p), range(p)):
        if all((d[0] * a1 + d[1] * a2) % p != 0 for d in D):
            return (a1, a2)
    return None  # provably unreachable when len(D) < p
