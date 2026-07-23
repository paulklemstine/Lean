from typing import List, Sequence

def cdf(p: Sequence[float]) -> List[float]:
    out: List[float] = []
    running = 0.0
    for value in p:
        running += value
        out.append(running)
    return out

def w1_cdf(p: Sequence[float], q: Sequence[float]) -> float:
    """W1 via the CDF closed form on {0,...,n-1}, in O(n) time."""
    fp, fq = cdf(p), cdf(q)
    return sum(abs(a - b) for a, b in zip(fp[:-1], fq[:-1]))
