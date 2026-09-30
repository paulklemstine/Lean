#!/usr/bin/env python3
"""
The conductor of the dihedral quintic x^5 + 20x + 32 is 20, not 320.

Self-contained numerical companion.  Sections:
  1. The trinomial discriminant 5^5 b^4 + 4^4 a^5 and its squareness.
  2. Quadratic field discriminants: no quadratic field has discriminant +-320.
  3. The fork character N -> (-5 | N) and the minimal-modulus theorem
     ("determined by N mod m  <=>  20 | m"), including the explicit witnesses.
  4. Reciprocity factorisation (-5 | N) = chi_4(N) * (N | 5).
  5. Frobenius statistics: root counts of f mod p, fork agreement, and
     Chebotarev frequencies 1/2 : 2/5 : 1/10.
  6. The information-theoretic "conductor scan": I(N mod m ; fork) in bits.
"""
from __future__ import annotations

import math
from collections import Counter
from typing import Callable, Dict, List, Tuple


# ---------------------------------------------------------------- utilities
def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    r = int(math.isqrt(n))
    for d in range(3, r + 1, 2):
        if n % d == 0:
            return False
    return True


def primes_below(n: int) -> List[int]:
    return [p for p in range(2, n) if is_prime(p)]


def is_squarefree(n: int) -> bool:
    n = abs(n)
    if n == 0:
        return False
    d = 2
    while d * d <= n:
        if n % (d * d) == 0:
            return False
        d += 1
    return True


def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a | n) for odd positive n."""
    assert n > 0 and n % 2 == 1
    a %= n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


# ------------------------------------------------ 1. trinomial discriminant
def trinomial_disc(a: int, b: int) -> int:
    """Discriminant of x^5 + a x + b."""
    return 5**5 * b**4 + 4**4 * a**5


def section_discriminant() -> None:
    print("=" * 72)
    print("1. Discriminant of x^5 + 20x + 32")
    D = trinomial_disc(20, 32)
    r = math.isqrt(D)
    print(f"   5^5*32^4 + 4^4*20^5 = {D}")
    print(f"   sqrt = {r} = 2^9 * 5^3 = {2**9 * 5**3};  perfect square: {r * r == D}")
    print(f"   factorisation 2^18 * 5^6 = {2**18 * 5**6}")
    for t in range(1, 5):
        Dt = trinomial_disc(20 * t**4, 32 * t**5)
        print(f"   t={t}: disc(x^5+20t^4x+32t^5) = (64000 t^10)^2 ? {Dt == (64000 * t**10) ** 2}")


# --------------------------------------------- 2. quadratic discriminants
def quad_disc(d: int) -> int:
    """Discriminant of Q(sqrt d), d squarefree, d != 1."""
    return d if d % 4 == 1 else 4 * d


def section_quadratic() -> None:
    print("=" * 72)
    print("2. Quadratic field discriminants")
    hits = [d for d in range(-2000, 2001)
            if d not in (0, 1) and is_squarefree(d) and abs(quad_disc(d)) == 320]
    print(f"   squarefree d in [-2000,2000] with |d(Q(sqrt d))| = 320: {hits}  (none)")
    print(f"   320 = 4*80, 80 = 16*5 is not squarefree: squarefree(80) = {is_squarefree(80)}")
    print(f"   d(Q(sqrt -5)) = {quad_disc(-5)}")


# ------------------------------------------------------- 3. the fork
def fork(N: int) -> int:
    return jacobi(-5, N)


def determined_mod(m: int, bound: int = 4000) -> bool:
    """Is fork(N), N odd < bound, a function of N mod m?"""
    seen: Dict[int, int] = {}
    for N in range(1, bound, 2):
        v = fork(N)
        r = N % m
        if seen.setdefault(r, v) != v:
            return False
    return True


def witness(m: int) -> Tuple[int, int] | None:
    """The explicit pair from the proof of the minimal-modulus theorem."""
    if m % 20 == 0:
        return None
    if m % 5 == 0:  # then 4 does not divide m
        L = math.lcm(m, 2)
        return (1, 1 + 5 * L)  # = 11 mod 20
    return (1, 1 + (4 * m) ** 4)  # = 17 mod 20


def section_fork() -> None:
    print("=" * 72)
    print("3. Minimal-modulus theorem: fork determined mod m  <=>  20 | m")
    ok = all(determined_mod(m) == (m % 20 == 0) for m in range(1, 401))
    print(f"   checked for m = 1..400 on odd N < 4000: {ok}")
    good = [m for m in range(1, 401) if determined_mod(m)]
    print(f"   determining moduli <= 400: {good}")
    print(f"   least one (conductor) = {good[0]};  320 among them: {320 in good}")
    for m in (4, 5, 10, 15, 16, 25, 30, 32, 64, 319):
        w = witness(m)
        assert w is not None
        a, b = w
        print(f"   m={m:4d}: N={a} and N={b} agree mod m ({(b - a) % m == 0}), "
              f"b mod 20 = {b % 20}, forks {fork(a)} vs {fork(b)}")
    table = {r: fork(r) for r in range(1, 20, 2)}
    print(f"   fork on odd residues mod 20: {table}")


# ------------------------------------------------ 4. reciprocity split
def chi4(N: int) -> int:
    return 0 if N % 2 == 0 else (1 if N % 4 == 1 else -1)


def section_reciprocity() -> None:
    print("=" * 72)
    print("4. (-5 | N) = chi_4(N) * (N | 5)")
    ok = all(fork(N) == chi4(N) * jacobi(N, 5) for N in range(1, 20001, 2))
    print(f"   verified for all odd N < 20000: {ok}")
    print("   residue | chi4 | (N|5) | fork")
    for r in range(1, 20, 2):
        print(f"   {r:7d} | {chi4(r):4d} | {jacobi(r, 5):5d} | {fork(r):4d}")


# --------------------------------------------- 5. Frobenius statistics
def root_count(p: int) -> int:
    return sum(1 for t in range(p) if (t**5 + 20 * t + 32) % p == 0)


def section_frobenius(bound: int = 3000) -> None:
    print("=" * 72)
    print(f"5. Frobenius at primes p < {bound}, p not 2 or 5")
    ps = [p for p in primes_below(bound) if p not in (2, 5)]
    counts = Counter(root_count(p) for p in ps)
    agree = all((root_count(p) in (0, 5)) == (fork(p) == 1) for p in ps)
    print(f"   root-count histogram: {dict(sorted(counts.items()))}")
    print(f"   rotation (0 or 5 roots)  <=>  (-5|p) = 1 for every such p: {agree}")
    n = len(ps)
    print(f"   observed  reflection : 5-cycle : identity = "
          f"{counts[1]/n:.3f} : {counts[0]/n:.3f} : {counts[5]/n:.3f}")
    print(f"   Chebotarev prediction                   = 0.500 : 0.400 : 0.100")
    print(f"   first split primes (5 roots): {[p for p in ps if root_count(p) == 5][:8]}")


# ------------------------------------------ 6. conductor scan in bits
def mutual_information(m: int, bound: int = 20000) -> float:
    """I(N mod m ; fork(N)) over primes N < bound, N not dividing 10."""
    ps = [p for p in primes_below(bound) if p not in (2, 5)]
    joint = Counter((p % m, fork(p)) for p in ps)
    px = Counter(p % m for p in ps)
    py = Counter(fork(p) for p in ps)
    n = len(ps)
    return sum(c / n * math.log2((c / n) / ((px[x] / n) * (py[y] / n)))
               for (x, y), c in joint.items())


def section_scan() -> None:
    print("=" * 72)
    print("6. Conductor scan: I(p mod m ; fork) in bits, primes < 20000")
    for m in (4, 5, 10, 16, 20, 40, 60, 64, 160, 320):
        print(f"   m = {m:3d}: {mutual_information(m):.4f} bits")
    ps = [p for p in primes_below(20000) if p not in (2, 5)]
    c = Counter(fork(p) for p in ps)
    print(f"   balance of (-5|p) below 20000: +1 -> {c[1]}, -1 -> {c[-1]}")


if __name__ == "__main__":
    section_discriminant()
    section_quadratic()
    section_fork()
    section_reciprocity()
    section_frobenius()
    section_scan()
