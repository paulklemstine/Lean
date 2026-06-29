from math import log, log2

def distributed_catalog_feasible(b: int, length: int, n_volumes: int) -> bool:
    """True iff 2^(b^L) <= (b^L)^N, via the overflow-safe log form."""
    v = b ** length
    if v < 2:
        return True
    return v * log(2) <= n_volumes * log(v)

def min_volumes(b: int, length: int) -> float:
    """Minimal real N from N >= b^L / (L * log2 b)."""
    return (b ** length) / (length * log2(b))
