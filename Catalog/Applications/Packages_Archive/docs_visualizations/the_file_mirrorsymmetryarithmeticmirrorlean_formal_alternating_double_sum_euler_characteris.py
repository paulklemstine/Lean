from typing import Callable

Diamond = Callable[[int, int], int]

def euler_char(n: int, h: Diamond) -> int:
    """chi_n(h) = sum_{p,q in 0..n} (-1)^(p+q) h(p,q).  O(n^2) ring ops."""
    return sum(((-1) ** (p + q)) * h(p, q)
               for p in range(n + 1) for q in range(n + 1))

def mirror(n: int, h: Diamond) -> Diamond:
    return lambda p, q: h(n - p, q)

def verify_mirror_law(n: int, h: Diamond) -> bool:
    """Check chi(mirror h) == (-1)^n chi(h)."""
    return euler_char(n, mirror(n, h)) == ((-1) ** n) * euler_char(n, h)
