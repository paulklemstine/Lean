from __future__ import annotations
from typing import List, Sequence, Tuple

Matrix = Tuple[Tuple[int, ...], ...]
Poly = List[int]  # low-degree-first

def inv_mod(a: int, p: int) -> int:
    return pow(a % p, p - 2, p)

def det_mod(M: Matrix, p: int) -> int:
    n = len(M); a = [list(r) for r in M]; det = 1
    for c in range(n):
        piv = next((r for r in range(c, n) if a[r][c] % p), None)
        if piv is None: return 0
        if piv != c: a[c], a[piv] = a[piv], a[c]; det = -det
        det = (det * a[c][c]) % p; iv = inv_mod(a[c][c], p)
        for r in range(c + 1, n):
            f = (a[r][c] * iv) % p
            for k in range(c, n): a[r][k] = (a[r][k] - f * a[c][k]) % p
    return det % p

def poly_mul(a: Sequence[int], b: Sequence[int], p: int) -> Poly:
    r = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b): r[i + j] = (r[i + j] + ai * bj) % p
    return r

def poly_mod(a: Poly, m: Poly, p: int) -> Poly:
    a = [x % p for x in a]; dm = len(m) - 1; il = inv_mod(m[-1], p)
    while len(a) - 1 >= dm and any(a):
        if a[-1] == 0: a.pop(); continue
        s = len(a) - 1 - dm; f = (a[-1] * il) % p
        for i in range(len(m)): a[i + s] = (a[i + s] - f * m[i]) % p
        while a and a[-1] == 0: a.pop()
    return a or [0]

def poly_powmod(b: Poly, e: int, m: Poly, p: int) -> Poly:
    res = [1]; b = poly_mod(b, m, p)
    while e:
        if e & 1: res = poly_mod(poly_mul(res, b, p), m, p)
        b = poly_mod(poly_mul(b, b, p), m, p); e >>= 1
    return res

def poly_gcd(a: Poly, b: Poly, p: int) -> Poly:
    a = [x % p for x in a]; b = [x % p for x in b]
    def strip(z): 
        while len(z) > 1 and z[-1] == 0: z.pop()
        return z or [0]
    a, b = strip(a), strip(b)
    while any(b): a = strip(poly_mod(a, b, p)); a, b = b, a
    return strip(a)

def prime_divisors(n: int) -> List[int]:
    ds, d = [], 2
    while d * d <= n:
        if n % d == 0:
            ds.append(d)
            while n % d == 0: n //= d
        d += 1
    if n > 1: ds.append(n)
    return ds

def is_irreducible(f: Poly, p: int) -> bool:
    f = list(f)
    while f and f[-1] == 0: f.pop()
    n = len(f) - 1
    if n <= 1: return n == 1
    x = [0, 1]
    h = poly_powmod(x, p ** n, f, p)
    if poly_gcd([(h[i] if i < len(h) else 0) - (x[i] if i < 2 else 0)
                 for i in range(max(len(h), 2))], f, p) and \
       any((h[i] if i < len(h) else 0) != (x[i] if i < 2 else 0)
           for i in range(max(len(h), 2))):
        return False
    for r in prime_divisors(n):
        h = poly_powmod(x, p ** (n // r), f, p)
        sub = [(h[i] if i < len(h) else 0) - (x[i] if i < 2 else 0)
               for i in range(max(len(h), 2))]
        if len(poly_gcd(sub, f, p)) - 1 != 0: return False
    return True

def char_poly(M: Matrix, p: int) -> Poly:
    n = len(M); xs = list(range(n + 1)); ys = []
    for x in xs:
        A = tuple(tuple((x if i == j else 0) - M[i][j] for j in range(n))
                  for i in range(n))
        ys.append(det_mod(A, p))
    co = [0] * (n + 1)
    for i in range(len(xs)):
        num, den = [1], 1
        for j in range(len(xs)):
            if j == i: continue
            num = poly_mul(num, [(-xs[j]) % p, 1], p)
            den = (den * (xs[i] - xs[j])) % p
        sc = (ys[i] * inv_mod(den, p)) % p
        for d2, cv in enumerate(num):
            if d2 <= n: co[d2] = (co[d2] + sc * cv) % p
    return co

def verify_certificate(M: Matrix, p: int) -> bool:
    if det_mod(M, p) == 0: return False
    return is_irreducible(char_poly(M, p), p)
