def is_prime(n: int) -> bool:
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True

def mod_pow(base: int, exp: int, m: int) -> int:
    result = 1
    base %= m
    while exp > 0:
        if exp & 1:
            result = (result * base) % m
        exp >>= 1
        base = (base * base) % m
    return result

def fermat_divides(p: int, a: int) -> bool:
    """Return True iff p | a^p - a (p prime), certified via (a mod p)^p == a mod p."""
    assert is_prime(p), 'p must be prime'
    r = a % p
    return mod_pow(r, p, p) == r
