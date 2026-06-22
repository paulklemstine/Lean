from __future__ import annotations
from math import ceil
from typing import Callable, List, Tuple


def grid(a: float, b: float, N: int, i: int) -> float:
    """The i-th node of the uniform grid on [a, b]: a + i*(b-a)/N."""
    return a + i * (b - a) / N


def approx_ivt_grid_search(
    f: Callable[[float], float],
    a: float,
    b: float,
    eps: float,
    delta: float,
) -> Tuple[float, float, int]:
    """Constructive approximate IVT by uniform grid search.

    Preconditions:
      a <= b, eps >= 0, delta > 0;
      delta is a valid modulus step for f on [a, b] at tolerance eps,
        i.e.  |y - x| <= delta  =>  |f(y) - f(x)| <= eps;
      f(a) and f(b) straddle zero in some order.

    Postcondition:
      returns (x, f(x), N) with x in [a, b] and |f(x)| <= eps.

    Complexity: O(N) function evaluations and comparisons with
      N = ceil((b - a) / delta).
    """
    assert a <= b and eps >= 0.0 and delta > 0.0
    N: int = max(1, ceil((b - a) / delta))

    fa, fb = f(a), f(b)
    if fa <= 0.0 <= fb:
        g = f
    elif fb <= 0.0 <= fa:
        g = lambda x: -f(x)  # reduce reversed orientation to canonical via -f
    else:
        raise ValueError("endpoints do not straddle zero")

    samples: List[float] = [g(grid(a, b, N, i)) for i in range(N + 1)]
    for i in range(N + 1):
        if samples[i] == 0.0:
            x = grid(a, b, N, i)
            return x, f(x), N
    for i in range(N):
        if samples[i] <= 0.0 <= samples[i + 1]:
            x = grid(a, b, N, i + 1)
            return x, f(x), N
    raise RuntimeError("unreachable: sign change must exist")
