from typing import Tuple

def bottom_degree(n: int, r1: int, r2: int) -> int:
    """Bottom cohomological degree b = r1*floor(n^2/4) + r2*C(n,2)."""
    quarter_square: int = (n // 2) * ((n + 1) // 2)   # floor(n^2/4)
    triangular: int = n * (n - 1) // 2                # C(n,2)
    return r1 * quarter_square + r2 * triangular

def bottom_degree_with_parity(n: int, r1: int, r2: int) -> Tuple[int, int]:
    """Return (b, b mod 2)."""
    b: int = bottom_degree(n, r1, r2)
    return b, b % 2
