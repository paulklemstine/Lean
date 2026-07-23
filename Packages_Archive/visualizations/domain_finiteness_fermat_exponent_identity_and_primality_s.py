def fast_pow_mod(base: int, exp: int, mod: int) -> int:
    """Repeated-squaring modular exponentiation: base^exp mod mod in O(log exp)."""
    result = 1
    base %= mod
    while exp > 0:
        if exp & 1:
            result = (result * base) % mod
        base = (base * base) % mod
        exp >>= 1
    return result

def fermat_check(a: int, n: int) -> bool:
    """
    Fermat primality screen built on a^(n-1)=1 (mod n) (Thm pow_card_sub_one_eq_one,
    zmod_pow_card_sub_one). If this returns False, n is certainly composite.
    """
    if n < 2:
        return False
    return fast_pow_mod(a, n - 1, n) == 1
