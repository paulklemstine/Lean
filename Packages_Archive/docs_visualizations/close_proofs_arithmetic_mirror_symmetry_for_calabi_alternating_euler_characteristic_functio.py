from typing import Callable

Diamond = Callable[[int, int], int]

def euler_char(h: Diamond, d: int) -> int:
    """Euler characteristic chi = sum_{0<=p,q<=d} (-1)^{p+q} h(p, q)."""
    total = 0
    for p in range(d + 1):
        for q in range(d + 1):
            total += (-1) ** (p + q) * h(p, q)
    return total
