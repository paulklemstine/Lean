from typing import Callable, List, Tuple

def evaluate_fast(
    samples: List[float], n: int, x: float
) -> float:
    """
    O(log n) evaluation of the width-2n ReLU interpolation network using the
    exact-representation identity reluInterpNet_eq_on_cell: on cell k the network
    equals the linear interpolant f(k/n) + cellSlope*(x - k/n). Only the active
    cell matters, so we binary-search for it.

    `samples[k] = f(k/n)` for k = 0..n.
    """
    if x <= 0.0:
        return samples[0]
    if x >= 1.0:
        return samples[n]
    # locate cell k with k/n <= x < (k+1)/n by binary search
    lo, hi = 0, n - 1
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if mid / n <= x:
            lo = mid
        else:
            hi = mid - 1
    k: int = lo
    slope: float = n * (samples[k + 1] - samples[k])   # cellSlope(f, n, k)
    return samples[k] + slope * (x - k / n)
