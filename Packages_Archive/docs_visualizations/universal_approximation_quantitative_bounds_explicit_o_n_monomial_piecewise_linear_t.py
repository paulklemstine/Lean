from typing import Callable, List


def pl_interpolant(g: Callable[[float], float], N: int) -> Callable[[float], float]:
    """Piecewise-linear interpolant of g at nodes k/N on [0,1] (O(N) pieces).

    A continuous piecewise-linear function is a tropical rational function;
    this realizes the explicit O(N)-monomial approximation family."""
    nodes: List[float] = [k / N for k in range(N + 1)]
    vals: List[float] = [g(t) for t in nodes]

    def f(x: float) -> float:
        x = min(1.0, max(0.0, x))
        k = min(N - 1, int(x * N))
        t0, t1 = nodes[k], nodes[k + 1]
        w = 0.0 if t1 == t0 else (x - t0) / (t1 - t0)
        return (1 - w) * vals[k] + w * vals[k + 1]

    return f
