from typing import Optional, Tuple

def is_perfect_cube(m: int) -> Optional[int]:
    """Return the integer cube root of m if m is a perfect cube, else None."""
    if m == 0:
        return 0
    sign = 1 if m > 0 else -1
    a = abs(m)
    r = round(a ** (1.0 / 3.0))
    for cand in (r - 1, r, r + 1):
        if cand >= 0 and cand ** 3 == a:
            return sign * cand
    return None

def is_locally_obstructed(n: int) -> bool:
    """True iff n is provably NOT a sum of three cubes (n = 4 or 5 mod 9)."""
    return (n % 9) in (4, 5)

def find_representation(n: int, bound: int) -> Optional[Tuple[int, int, int]]:
    """Search for x^3 + y^3 + z^3 = n with |x|, |z| <= bound.

    First applies the O(1) modular obstruction test; if n = 4 or 5 mod 9 no
    representation exists. Otherwise fixes x and z and tests whether the
    remainder n - x^3 - z^3 is a perfect cube.
    """
    if is_locally_obstructed(n):
        return None
    for x in range(-bound, bound + 1):
        x3 = x ** 3
        for z in range(x, bound + 1):
            y = is_perfect_cube(n - x3 - z ** 3)
            if y is not None:
                return (x, y, z)
    return None
