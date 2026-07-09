from typing import List, Sequence

def monotone_coupling(p: Sequence[float], q: Sequence[float]) -> List[List[float]]:
    """North-west-corner (quantile) coupling; its cost equals W1(p,q)."""
    n = len(p)
    plan = [[0.0] * n for _ in range(n)]
    rp, rq = list(p), list(q)
    i = j = 0
    while i < n and j < n:
        flow = min(rp[i], rq[j])
        plan[i][j] += flow
        rp[i] -= flow; rq[j] -= flow
        if rp[i] <= 1e-15:
            i += 1
        else:
            j += 1
    return plan
