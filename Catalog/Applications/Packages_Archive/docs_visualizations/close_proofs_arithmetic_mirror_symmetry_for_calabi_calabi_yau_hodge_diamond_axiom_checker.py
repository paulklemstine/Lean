from typing import Callable

Diamond = Callable[[int, int], int]

def is_calabi_yau(h: Diamond, d: int) -> bool:
    """Verify conjugation symmetry, Serre duality and finite support."""
    for p in range(d + 1):
        for q in range(d + 1):
            if h(p, q) != h(q, p):          # conjugation symmetry
                return False
            if h(p, q) != h(d - p, d - q):  # Serre duality
                return False
    for p in range(d + 2):
        for q in range(d + 2):
            if (p > d or q > d) and h(p, q) != 0:   # finite support
                return False
    return True
