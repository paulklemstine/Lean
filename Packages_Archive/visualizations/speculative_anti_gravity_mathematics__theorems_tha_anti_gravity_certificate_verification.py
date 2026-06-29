from typing import Tuple

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

def support(n: int, d: int) -> int:
    return n // d

def anti_gravity_certificate(n: int, d: int, c: int) -> Tuple[bool, bool, bool]:
    """Verify the anti-gravity certificate for result d in universe N with budget c.

    Returns (cost_ok, ceiling_ok, tradeoff_holds):
      cost_ok      : proofCost(d) <= c
      ceiling_ok   : support(N,d) <= N // 2**c
      tradeoff_holds: support(N,d) <= N // 2**proofCost(d)   (always True, Thm 4.2)
    """
    cost = proof_cost(d)
    cost_ok = cost <= c
    ceiling_ok = support(n, d) <= n // (2 ** c)
    tradeoff_holds = support(n, d) <= n // (2 ** cost)
    return cost_ok, ceiling_ok, tradeoff_holds
