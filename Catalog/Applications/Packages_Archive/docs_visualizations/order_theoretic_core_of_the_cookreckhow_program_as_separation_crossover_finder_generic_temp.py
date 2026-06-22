from typing import Callable, Optional

def separation_crossover(s: Callable[[int], int], k: int, n_max: int) -> Optional[int]:
    """Least n <= n_max with s(n) > (n+2)^k (the budget-exceeded point), else None."""
    for n in range(n_max + 1):
        if s(n) > (n + 2) ** k:
            return n
    return None