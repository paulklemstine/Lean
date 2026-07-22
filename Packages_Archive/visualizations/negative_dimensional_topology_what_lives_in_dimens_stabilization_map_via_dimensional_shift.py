from typing import Dict

VSpace = Dict[int, int]


def stabilize(space: VSpace, n: int) -> VSpace:
    """Apply the stabilization map Sigma^n: shift every dimension by +n.

    For a pure (-n)-space cell(-n, k) this returns cell(0, k), an honest
    0-dimensional space, while the Euler characteristic transforms by
    (-1)^n. Runs in O(m) for m nonzero strata.
    """
    shifted: Dict[int, int] = {}
    for d, b_d in space.items():
        if b_d != 0:
            shifted[d + n] = shifted.get(d + n, 0) + b_d
    return shifted
