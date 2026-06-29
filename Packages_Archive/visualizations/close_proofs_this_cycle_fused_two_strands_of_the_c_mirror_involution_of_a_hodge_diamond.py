from typing import Callable, Tuple


def mirror(n: int, h: Callable[[int, int], int]) -> Tuple[int, Callable[[int, int], int]]:
    """Return the mirror diamond (same n) with h'(p, q) = h(n - p, q)."""
    return n, (lambda p, q: h(n - p, q))
