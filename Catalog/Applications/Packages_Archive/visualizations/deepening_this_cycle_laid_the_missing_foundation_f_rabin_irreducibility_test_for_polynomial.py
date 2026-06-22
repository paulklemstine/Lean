from typing import List

Poly = List[int]  # coefficients low-degree first, over F_p


def _trim(c: Poly, p: int) -> Poly:
    c = [x % p for x in c]
    while len(c) > 1 and c[-1] == 0:
        c.pop()
    return c


def _mul(a: Poly, b: Poly, p: int) -> Poly:
    r = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            r[i + j] = (r[i + j] + ai * bj) % p
    return _trim(r, p)


def _mod(a: Poly, b: Poly, p: int) -> Poly:
    a, b = _trim(a[:], p), _trim(b[:], p)
    binv = pow(b[-1], p - 2, p)
    while len(a) >= len(b) and not (len(a) == 1 and a[0] == 0):
        coef = (a[-1] * binv) % p
        sh = len(a) - len(b)
        for i, bi in enumerate(b):
            a[i + sh] = (a[i + sh] - coef * bi) % p
        a = _trim(a, p)
    return _trim(a, p)


def _gcd(a: Poly, b: Poly, p: int) -> Poly:
    a, b = _trim(a[:], p), _trim(b[:], p)
    while not (len(b) == 1 and b[0] == 0):
        a, b = b, _mod(a, b, p)
    inv = pow(a[-1], p - 2, p)
    return _trim([x * inv for x in a], p)


def _powmod(base: Poly, e: int, mod: Poly, p: int) -> Poly:
    res: Poly = [1]
    base = _mod(base, mod, p)
    while e > 0:
        if e & 1:
            res = _mod(_mul(res, base, p), mod, p)
        base = _mod(_mul(base, base, p), mod, p)
        e >>= 1
    return res


def _prime_divisors(n: int) -> List[int]:
    ds, d = [], 2
    while d * d <= n:
        if n % d == 0:
            ds.append(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        ds.append(n)
    return ds


def is_irreducible(f: Poly, p: int) -> bool:
    """Rabin's irreducibility test for a monic polynomial f over F_p."""
    f = _trim(f[:], p)
    n = len(f) - 1
    if n <= 0:
        return False
    if n == 1:
        return True
    xpn = _powmod([0, 1], p ** n, f, p)
    diff = _trim([(xpn[i] if i < len(xpn) else 0) - (1 if i == 1 else 0)
                  for i in range(max(len(xpn), 2))], p)
    if diff != [0]:
        return False
    for q in _prime_divisors(n):
        xpm = _powmod([0, 1], p ** (n // q), f, p)
        d = _trim([(xpm[i] if i < len(xpm) else 0) - (1 if i == 1 else 0)
                   for i in range(max(len(xpm), 2))], p)
        if _gcd(d, f, p) != [1]:
            return False
    return True
