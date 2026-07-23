from typing import List, Sequence

def newton_divided_differences(
    nodes: Sequence[float], labels: Sequence[float]
) -> List[float]:
    """Newton form of the interpolating read-out.

    Returns coefficients c with
        p(t) = c[0] + c[1](t-t0) + c[2](t-t0)(t-t1) + ...
    Supports O(n) incremental update when one new sample is appended, the
    natural primitive for online concept learning. Overall O(n^2).
    """
    n = len(nodes)
    c: List[float] = [float(v) for v in labels]
    for k in range(1, n):
        for i in range(n - 1, k - 1, -1):
            c[i] = (c[i] - c[i - 1]) / (nodes[i] - nodes[i - k])
    return c


def newton_eval(coeffs: Sequence[float], nodes: Sequence[float], t: float) -> float:
    """Horner-style evaluation of the Newton-form read-out."""
    acc = 0.0
    for k in range(len(coeffs) - 1, -1, -1):
        acc = acc * (t - nodes[k]) + coeffs[k]
    return acc
