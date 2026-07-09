from __future__ import annotations


def dyadic_exit_stage(x: int) -> int:
    """
    Return the stage at which a nonzero integer x leaves the descending dyadic
    chain (2^0) ⊇ (2^1) ⊇ ..., i.e. v_2(x) + 1 where v_2 is the 2-adic
    valuation. Certifies the Anti-Escher collapse: the stage is always finite,
    so no nonzero x lies in the intersection.
    """
    if x == 0:
        raise ValueError("0 lies in every (2^n); it never exits the chain")
    v = 0
    y = abs(x)
    while y % 2 == 0:
        y //= 2
        v += 1
    return v + 1
