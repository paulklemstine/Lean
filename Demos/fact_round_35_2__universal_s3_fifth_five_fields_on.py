#!/usr/bin/env python3
"""
Five Fields, One Law -- numerical companion.

Everything here concerns the cubic f(x) = x^3 - 4x + 1 (discriminant 229, a prime)
and the "type channel" between the splitting type of f modulo a prime p and the
residue class of p modulo the conductor 229.

Sections
  1. The discriminant identities, checked on the three real roots.
  2. The splitting-type law: exactly one root mod p  <=>  (p/229) = -1,
     and the root count is never 2.
  3. The witness pair p = 3 and p = 461 (same class mod 229, different types).
  4. The exact fibre-product law: I(type ; class) = log2 |Delta|, computed by
     brute force on finite models (S3, S4, S5 with conductors 5, 7, 229).
  5. The entropy split  H(T) = 2/3 + (1/2) log2 3,  H(T | class) = (1/2) log2 3 - 1/3.
  6. The plug-in estimate over the first N primes and its finite-sample excess.

Pure Python 3 (standard library only).
"""
from __future__ import annotations

import math
from collections import Counter
from itertools import permutations
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple

D: int = 229  # discriminant of x^3 - 4x + 1


# ---------------------------------------------------------------------------
# Basic arithmetic helpers
# ---------------------------------------------------------------------------

def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i:: i] = bytearray(len(sieve[i * i:: i]))
    return [i for i in range(n + 1) if sieve[i]]


def legendre(a: int, p: int) -> int:
    """Legendre symbol (a/p) for an odd prime p, via Euler's criterion."""
    a %= p
    if a == 0:
        return 0
    return 1 if pow(a, (p - 1) // 2, p) == 1 else -1


def cub(x: int, p: int) -> int:
    """f(x) = x^3 - 4x + 1 mod p."""
    return (x * x * x - 4 * x + 1) % p


def roots_bruteforce(p: int) -> List[int]:
    """All roots of f modulo p (O(p); fine for small p)."""
    return [x for x in range(p) if cub(x, p) == 0]


# --- fast root counting: deg gcd(x^p - x, f) over F_p ------------------------

Poly = List[int]  # coefficients, lowest degree first


def _mulmod_f(a: Poly, b: Poly, p: int) -> Poly:
    """Multiply two polynomials of degree < 3 modulo f = x^3 - 4x + 1 over F_p."""
    prod = [0] * 5
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                prod[i + j] = (prod[i + j] + ai * bj) % p
    # reduce with x^3 = 4x - 1
    for k in (4, 3):
        c = prod[k]
        if c:
            prod[k] = 0
            prod[k - 2] = (prod[k - 2] + 4 * c) % p
            prod[k - 3] = (prod[k - 3] - c) % p
    return prod[:3]


def _xpow_mod_f(e: int, p: int) -> Poly:
    result: Poly = [1, 0, 0]
    base: Poly = [0, 1, 0]
    while e:
        if e & 1:
            result = _mulmod_f(result, base, p)
        base = _mulmod_f(base, base, p)
        e >>= 1
    return result


def _trim(a: Poly) -> Poly:
    a = a[:]
    while a and a[-1] == 0:
        a.pop()
    return a


def _polymod(a: Poly, b: Poly, p: int) -> Poly:
    a = _trim(a)
    b = _trim(b)
    inv = pow(b[-1], p - 2, p)
    while len(a) >= len(b):
        c = a[-1] * inv % p
        shift = len(a) - len(b)
        for i, bi in enumerate(b):
            a[shift + i] = (a[shift + i] - c * bi) % p
        a = _trim(a)
    return a


def _gcd_deg(a: Poly, b: Poly, p: int) -> int:
    a, b = _trim(a), _trim(b)
    while b:
        a, b = b, _polymod(a, b, p)
    return len(a) - 1


def root_count(p: int) -> int:
    """Number of distinct roots of f mod p, for p not dividing 2*229."""
    if p < 50:
        return len(roots_bruteforce(p))
    g = _xpow_mod_f(p, p)
    g[1] = (g[1] - 1) % p          # x^p - x  mod f
    f: Poly = [1, (-4) % p, 0, 1]
    if not _trim(g):
        return 3                     # f divides x^p - x: splits completely
    return _gcd_deg(f, g, p)


# ---------------------------------------------------------------------------
# Entropy on finite uniform models (counting entropy)
# ---------------------------------------------------------------------------

def entropy(counts: Iterable[int]) -> float:
    c = [x for x in counts if x > 0]
    n = sum(c)
    return math.log2(n) - sum(x * math.log2(x) for x in c) / n


def mutual_information(pairs: Sequence[Tuple[Hashable, Hashable]]) -> float:
    """Plug-in mutual information I(X;Y) for the uniform law on a list of pairs."""
    hx = entropy(Counter(x for x, _ in pairs).values())
    hy = entropy(Counter(y for _, y in pairs).values())
    hxy = entropy(Counter(pairs).values())
    return hx + hy - hxy


# ---------------------------------------------------------------------------
# Permutation helpers
# ---------------------------------------------------------------------------

Perm = Tuple[int, ...]


def sign(s: Perm) -> int:
    seen, sgn = set(), 1
    for i in range(len(s)):
        if i not in seen:
            j, length = i, 0
            while j not in seen:
                seen.add(j)
                j = s[j]
                length += 1
            if length % 2 == 0:
                sgn = -sgn
    return sgn


def cycle_type(s: Perm) -> Tuple[int, ...]:
    seen, lens = set(), []
    for i in range(len(s)):
        if i not in seen:
            j, length = i, 0
            while j not in seen:
                seen.add(j)
                j = s[j]
                length += 1
            lens.append(length)
    return tuple(sorted(lens, reverse=True))


def fixed_points(s: Perm) -> int:
    return sum(1 for i, j in enumerate(s) if i == j)


def fibre_product_mi(n: int, ell: int, readout: Callable[[Perm], Hashable]) -> float:
    """Exact I(readout(sigma) ; r) on the uniform fibre product
    {(sigma, r) in S_n x (Z/ell)^* : sign(sigma) = (r/ell)}."""
    pairs = []
    for s in permutations(range(n)):
        e = sign(s)
        t = readout(s)
        for r in range(1, ell):
            if legendre(r, ell) == e:
                pairs.append((t, r))
    return mutual_information(pairs)


# ---------------------------------------------------------------------------
# Section 1: discriminant identities
# ---------------------------------------------------------------------------

def real_roots() -> List[float]:
    """Three real roots of x^3 - 4x + 1 via the trigonometric formula."""
    # x^3 + px + q with p=-4, q=1
    pp, qq = -4.0, 1.0
    m = 2 * math.sqrt(-pp / 3)
    theta = math.acos(3 * qq / (pp * m)) / 3
    return sorted(m * math.cos(theta - 2 * math.pi * k / 3) for k in range(3))


def section1() -> None:
    print("=" * 72)
    print("1. Discriminant identities for f = x^3 - 4x + 1")
    print("=" * 72)
    a, b, c = real_roots()
    print(f"   real roots: {a:.9f}, {b:.9f}, {c:.9f}")
    print("   (intervals (-3,-2), (0,1), (1,2) as claimed)")
    r, s = a, b
    print(f"   r^2 + rs + s^2      = {r*r + r*s + s*s:.12f}   (should be 4)")
    print(f"   rs(r+s)             = {r*s*(r+s):.12f}   (should be 1)")
    print(f"   -(r+s) - third root = {-(r+s) - c:.2e}")
    delta = (r - s) * (r + 2 * s) * (2 * r + s)
    print(f"   delta^2             = {delta**2:.9f}   (should be 229)")
    for x in (a, b, c):
        print(f"   (16-3x^2)(3x^2-4)^2 = {(16-3*x*x)*(3*x*x-4)**2:.9f} at x={x:+.4f}")
    print("   229 is prime and not a square:", all(229 % k for k in range(2, 16)),
          math.isqrt(229) ** 2 != 229)
    print()


# ---------------------------------------------------------------------------
# Section 2: splitting-type law
# ---------------------------------------------------------------------------

def section2(limit: int = 200_000) -> List[Tuple[int, int]]:
    print("=" * 72)
    print(f"2. Splitting-type law for primes 3 <= p <= {limit}, p != 229")
    print("=" * 72)
    data: List[Tuple[int, int]] = []
    violations = 0
    hist: Counter = Counter()
    for p in primes_up_to(limit):
        if p in (2, D):
            continue
        k = root_count(p)
        data.append((p, k))
        hist[k] += 1
        one_root = (k == 1)
        nonres = (legendre(p, D) == -1)
        nonsq229 = (legendre(D, p) == -1)
        if one_root != nonres or one_root != nonsq229 or k == 2:
            violations += 1
    n = len(data)
    print(f"   primes tested       : {n}")
    print(f"   violations          : {violations}   (law predicts 0)")
    for k in (0, 1, 2, 3):
        print(f"   root count {k}: {hist[k]:7d}  ({hist[k]/n:.4f})"
              f"   Chebotarev density {['1/3','1/2','0','1/6'][k]}")
    print()
    return data


# ---------------------------------------------------------------------------
# Section 3: witness pair
# ---------------------------------------------------------------------------

def section3() -> None:
    print("=" * 72)
    print("3. Same class, different type: p = 3 and p = 461")
    print("=" * 72)
    print(f"   461 mod 229 = {461 % 229},  3 mod 229 = {3 % 229}")
    print(f"   roots mod 3   : {roots_bruteforce(3)}   (none: inert, type 3)")
    print(f"   roots mod 461 : {roots_bruteforce(461)}   (three: type 1+1+1)")
    print(f"   Legendre (3/229) = {legendre(3, D)}")
    print()


# ---------------------------------------------------------------------------
# Section 4: exact fibre-product law
# ---------------------------------------------------------------------------

def section4() -> None:
    print("=" * 72)
    print("4. Exact fibre-product law  I(type ; class) = log2|Delta| = 1 bit")
    print("=" * 72)
    for n in (2, 3, 4, 5):
        for ell in (5, 7, 13):
            mi = fibre_product_mi(n, ell, cycle_type)
            print(f"   S_{n}, conductor {ell:3d}, read-out = cycle type : I = {mi:.12f}")
    mi229 = fibre_product_mi(3, D, fixed_points)
    print(f"   S_3, conductor 229, read-out = root count : I = {mi229:.12f}")
    # a read-out that does NOT determine the sign: fixed points in S_4
    mi_bad = fibre_product_mi(4, 7, fixed_points)
    print(f"   S_4, conductor 7, read-out = #fixed points (does not determine sign): "
          f"I = {mi_bad:.6f} < 1")
    # trivial quotient: couple through nothing (independent product)
    pairs = [(fixed_points(s), r) for s in permutations(range(3)) for r in range(1, 8)]
    print(f"   trivial quotient (independent product)       : I = {mutual_information(pairs):.12f}")
    print()


# ---------------------------------------------------------------------------
# Section 5: entropy split
# ---------------------------------------------------------------------------

def section5() -> None:
    print("=" * 72)
    print("5. Entropy split of the S3 law")
    print("=" * 72)
    counts = Counter(fixed_points(s) for s in permutations(range(3)))
    h_t = entropy(counts.values())
    print(f"   root-count distribution on S3: {dict(sorted(counts.items()))}")
    print(f"   H(T)          = {h_t:.12f}   formula 2/3 + log2(3)/2 = {2/3 + math.log2(3)/2:.12f}")
    h_cond = h_t - 1.0
    print(f"   H(T | class)  = {h_cond:.12f}   formula log2(3)/2 - 1/3 = {math.log2(3)/2 - 1/3:.12f}")
    h13 = -(1/3) * math.log2(1/3) - (2/3) * math.log2(2/3)
    print(f"   check: (1/2) * h(1/3) = {0.5 * h13:.12f}")
    print()


# ---------------------------------------------------------------------------
# Section 6: plug-in estimate and finite-sample excess
# ---------------------------------------------------------------------------

def section6(data: List[Tuple[int, int]]) -> None:
    print("=" * 72)
    print("6. Plug-in estimate over the first N primes  (true value: exactly 1 bit)")
    print("=" * 72)
    print("   N        I_hat(N)     excess       (D-1)/2 * 1/(2 N ln 2)")
    for N in (1000, 2000, 5000, 10000, len(data)):
        pairs = [(p % D, k) for p, k in data[:N]]
        mi = mutual_information(pairs)
        pred = (D - 1) / 2 / (2 * N * math.log(2))
        print(f"   {N:7d}  {mi:.6f}   {mi-1:+.6f}    {pred:.6f}")
    print("   (an empirical illustration; the excess shrinks roughly like 1/N)")
    print()


def main() -> None:
    section1()
    data = section2()
    section3()
    section4()
    section5()
    section6(data)


if __name__ == "__main__":
    main()
