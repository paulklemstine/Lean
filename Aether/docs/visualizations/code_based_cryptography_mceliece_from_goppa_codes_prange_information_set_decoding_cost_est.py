from math import comb, log2

def isd_log2_work(n: int, k: int, t: int) -> float:
    """log2 of Prange ISD expected iteration count C(n,t)/C(n-k,t)."""
    if not (0 <= t <= n - k):
        raise ValueError("require 0 <= t <= n - k")
    return log2(comb(n, t)) - log2(comb(n - k, t))