from typing import Callable, Optional


def dominates_polynomially(a: Callable[[int], int],
                           b: Callable[[int], int],
                           max_k: int = 8,
                           n_max: int = 40) -> Optional[int]:
    """Minimal exponent k with a(n) <= (b(n)+2)^k for all n<=n_max."""
    for k in range(max_k + 1):
        if all(a(n) <= (b(n) + 2) ** k for n in range(n_max + 1)):
            return k
    return None
