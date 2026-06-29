from typing import Callable, List, Tuple
import math

TWO_PI = 2.0 * math.pi

def detect_forced_discontinuity(
    rule: Callable[[float], float], samples: int = 4000, jump_thresh: float = 0.5
) -> List[Tuple[float, float]]:
    """Discontinuity detector for a decisive, reversal-respecting rule.

    The impossibility theorem implies such a rule cannot be continuous; this scans
    consecutive samples for jumps exceeding jump_thresh and returns the
    (location, magnitude) of each detected discontinuity boundary."""
    jumps: List[Tuple[float, float]] = []
    prev_t = 0.0
    prev_v = rule(prev_t)
    for k in range(1, samples + 1):
        t = TWO_PI * k / samples
        v = rule(t)
        if abs(v - prev_v) > jump_thresh:
            jumps.append((0.5 * (prev_t + t), abs(v - prev_v)))
        prev_t, prev_v = t, v
    return jumps
