from typing import Callable, Optional

def certify_poly_bounded(f: Callable[[int], int], n_max: int, k_max: int) -> Optional[int]:
    """Least k <= k_max with f(n)+1 <= (n+2)^k for all n <= n_max, else None."""
    for k in range(k_max + 1):
        if all(f(n) + 1 <= (n + 2) ** k for n in range(n_max + 1)):
            return k
    return None