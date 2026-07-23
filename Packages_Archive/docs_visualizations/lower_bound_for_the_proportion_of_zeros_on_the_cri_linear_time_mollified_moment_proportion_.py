from __future__ import annotations
from typing import Sequence, Iterable, Dict


def certify_lower_bound(weights: Sequence[float], on_line: Iterable[int]) -> Dict[str, float]:
    """Certify proportion >= 1/9 from the mollified moments.

    Runs in O(N) time and O(1) extra space, N = len(weights).
    """
    on = set(on_line)
    n = len(weights)
    k = len(on)
    m1 = 0.0
    m2 = 0.0
    support_ok = True
    for i, w in enumerate(weights):
        m1 += w
        m2 += w * w
        if i not in on and w != 0.0:
            support_ok = False
    moment_ok = (1.0 / 9.0) * m2 * n <= m1 * m1 + 1e-12
    certified = support_ok and moment_ok and m2 > 0.0 and n > 0
    return {
        "M1": m1, "M2": m2, "N": float(n), "onLine": float(k),
        "certified_lower_bound": 1.0 / 9.0 if certified else 0.0,
    }
