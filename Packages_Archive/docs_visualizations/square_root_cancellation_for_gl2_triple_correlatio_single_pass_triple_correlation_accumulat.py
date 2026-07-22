from typing import Callable

def triple_sum(
    f: Callable[[int], float],
    g: Callable[[int], float],
    h: Callable[[int], float],
    N: int,
) -> float:
    """Compute S(N) = sum_{n=0}^{N} f(n) g(n+1) h(n+2) in a single O(N) pass.
    By the triple envelope theorem, if |f|,|g|,|h| <= 1 then |S(N)| <= N+1,
    with equality for the constant sequences f = g = h = 1.
    """
    total = 0.0
    for n in range(N + 1):
        total += f(n) * g(n + 1) * h(n + 2)
    return total
