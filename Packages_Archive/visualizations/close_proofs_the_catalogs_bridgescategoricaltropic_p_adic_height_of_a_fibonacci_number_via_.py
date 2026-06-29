from math import exp, log

def p_adic_valuation(p: int, x: int) -> int:
    """v_p(x): exponent of prime p in x (x != 0)."""
    if x == 0:
        raise ValueError("v_p(0) is +infinity")
    v, x = 0, abs(x)
    while x % p == 0:
        x //= p
        v += 1
    return v

def p_adic_norm_via_valuation(p: int, x: int) -> float:
    """|x|_p computed through the tropical-valuation bridge:
        |x|_p = exp(-v_p(x) * log p).
    Realises the p-adic arithmetic height as the exponential of the
    (tropical, min-plus) p-adic valuation."""
    if x == 0:
        return 0.0
    return exp(-p_adic_valuation(p, x) * log(p))
