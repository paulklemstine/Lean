from typing import List, Tuple

def proof_cost(d: int) -> int:
    m, p, c = d, 2, 0
    while p * p <= m:
        while m % p == 0:
            c += 1
            m //= p
        p += 1
    if m > 1:
        c += 1
    return c

def top_anti_gravity(n: int, cost_budget: int, top: int = 10) -> List[Tuple[int, int, int]]:
    """List the most load-bearing results of proof cost <= cost_budget.

    Returns up to `top` triples (d, proofCost(d), support(N,d)) sorted by
    descending support; smallest d (largest support) come first.
    """
    out: List[Tuple[int, int, int]] = []
    d = 1
    while len(out) < top and d <= n:
        c = proof_cost(d)
        if c <= cost_budget:
            out.append((d, c, n // d))
        d += 1
    return out
