from typing import Callable
import math


def winding_number(
    theta: Callable[[float], float],
    samples: int = 100000,
) -> int:
    """Compute the degree (winding number) of a continuous circle map
    S^1 -> S^1 given by an angle function theta(t) for t in [0, 1),
    where the map sends angle 2*pi*t to angle theta(t).

    The degree is the net number of times the image wraps around the
    circle. It is the homotopy invariant obstructing continuous,
    anonymous, unanimity-respecting aggregation on the circle: any such
    aggregator would have to be degree-consistent across all agents at
    once and simultaneously non-dictatorial, which is impossible on S^1.
    Complexity: O(samples) evaluations; the result is rounded to the
    nearest integer, exact for sufficiently fine sampling.
    """
    total = 0.0
    prev = theta(0.0)
    for k in range(1, samples + 1):
        cur = theta(k / samples)
        d = cur - prev
        # unwrap into (-pi, pi]
        while d > math.pi:
            d -= 2 * math.pi
        while d <= -math.pi:
            d += 2 * math.pi
        total += d
        prev = cur
    return round(total / (2 * math.pi))
