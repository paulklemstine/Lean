def sparse_bound(n: int, k: int, d: int) -> float:
    from math import comb
    d_eff = min(d, n)
    return float(comb(n, d_eff) ** n) * float((k - 1) ** (n * d_eff))