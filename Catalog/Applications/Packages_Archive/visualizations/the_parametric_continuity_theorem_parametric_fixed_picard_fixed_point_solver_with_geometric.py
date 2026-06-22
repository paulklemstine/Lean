from typing import Callable, Tuple

def picard_fixed_point(
    f: Callable[[float], float],
    K: float,
    x0: float = 0.0,
    tol: float = 1e-12,
    max_iters: int = 10_000,
) -> Tuple[float, int]:
    """Solve x = f(x) for a K-contraction f via Picard iteration.

    Returns the fixed point and the number of iterations used. Convergence is
    geometric: after n steps the error is at most K**n * dist(x0, x_star).
    """
    assert 0.0 <= K < 1.0, "f must be a genuine contraction (0 <= K < 1)"
    x = x0
    for n in range(1, max_iters + 1):
        x_next = f(x)
        if abs(x_next - x) <= tol:
            return x_next, n
        x = x_next
    return x, max_iters
