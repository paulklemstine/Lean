def base_p_carries(a: int, b: int, p: int) -> int:
    """Carries when adding a and b in base p (Kummer's theorem)."""
    carries = carry = 0
    while a > 0 or b > 0 or carry > 0:
        s = (a % p) + (b % p) + carry
        carry = 1 if s >= p else 0
        carries += carry
        a //= p
        b //= p
    return carries

def kummer_valuation(k: int, q: int, p: int) -> int:
    """v_p( C(q*k, k) ) = carries adding k and (q-1)*k in base p."""
    return base_p_carries(k, (q - 1) * k, p)
