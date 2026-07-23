from itertools import combinations
from typing import Callable, FrozenSet, List

Simplex = FrozenSet[int]
WeightFn = Callable[[Simplex], float]


def is_interleaved(
    wf: WeightFn, wg: WeightFn, simplices: List[Simplex], delta: float
) -> bool:
    """Exact finite test of Interleaved(F, G, delta) for finitely many simplices.

    The continuum of scales t collapses to the finite set of weight breakpoints,
    since the two sublevel inclusions can only change there. At each breakpoint t
    we verify both asymmetric inclusions:
        sublevel(F, t)  subset of  sublevel(G, t + delta)   and   (F <-> G).
    Cost: O(B * S) where B = #breakpoints (<= 2S) and S = #simplices.
    """
    if delta < 0:
        return False
    eps = 1e-12
    breakpoints = sorted({wf(s) for s in simplices} | {wg(s) for s in simplices})
    for t in breakpoints:
        f_t = {s for s in simplices if wf(s) <= t + eps}
        g_shift = {s for s in simplices if wg(s) <= t + delta + eps}
        if not f_t.issubset(g_shift):
            return False
        g_t = {s for s in simplices if wg(s) <= t + eps}
        f_shift = {s for s in simplices if wf(s) <= t + delta + eps}
        if not g_t.issubset(f_shift):
            return False
    return True
