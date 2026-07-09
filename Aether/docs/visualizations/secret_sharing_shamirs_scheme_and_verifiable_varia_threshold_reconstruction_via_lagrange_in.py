from typing import Dict, Sequence, Tuple

def inv_mod(a: int, p: int) -> int:
    return pow(a % p, p - 2, p)

def lagrange_interpolate_at(points: Sequence[Tuple[int, int]], x0: int, p: int) -> int:
    total = 0
    for i, (xi, yi) in enumerate(points):
        num, den = 1, 1
        for j, (xj, _) in enumerate(points):
            if i == j:
                continue
            num = (num * (x0 - xj)) % p
            den = (den * (xi - xj)) % p
        total = (total + yi * num * inv_mod(den, p)) % p
    return total

def shamir_reconstruct(shares: Dict[int, int], p: int) -> int:
    """Recover the secret f(0) from any t shares via Lagrange interpolation."""
    return lagrange_interpolate_at(list(shares.items()), 0, p)
