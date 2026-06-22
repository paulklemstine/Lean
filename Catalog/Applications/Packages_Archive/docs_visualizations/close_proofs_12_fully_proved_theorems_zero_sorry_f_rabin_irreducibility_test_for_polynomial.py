from typing import Set, Tuple
Poly = Tuple[int, ...]

def poly_pow_mod(base: Poly, e: int, m: Poly, p: int) -> Poly:
    result: Poly = (1,)
    while e:
        if e & 1:
            result = _mulmod(result, base, m, p)
        base = _mulmod(base, base, m, p)
        e >>= 1
    return result

def is_irreducible(f: Poly, p: int) -> bool:
    f = _trim(f, p); d = len(f) - 1
    if d <= 0: return False
    if d == 1: return True
    x: Poly = (0, 1)
    if _trim(_sub(poly_pow_mod(x, p ** d, f, p), x), p) != (0,):
        return False
    for q in _prime_divisors(d):
        h = poly_pow_mod(x, p ** (d // q), f, p)
        if len(_gcd(_sub(h, x), f, p)) - 1 != 0:
            return False
    return True
# helpers _mulmod, _trim, _sub, _gcd, _prime_divisors: see demo.py
