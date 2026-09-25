#!/usr/bin/env python3
"""
Sum hints, product hints and the precision-halving law.

Numerical companion to "The Routing Is Dial-Dependent -- but Not for the Reason
We Thought".  Everything here is self-contained (standard library only).

Sections
  1. The mod-8 pair-sum table:  u + c*u^{-1} = u*(1+c)  in Z/8.
  2. The classification: the sum mod 8 pins the unordered pair iff N = 5 (mod 8).
  3. The genuine prime counterexample 17*41 versus 5*13.
  4. The precision law: sum and product mod l^k determine the unordered pair
     mod l^ceil(k/2), and this is sharp (exhaustive check for small l, k).
  5. The Hensel (separated) regime: if l does not divide p - q, full precision.
  6. The D4 corollary: mod 32 suffices, mod 16 does not (random semiprimes).
  7. The +-1 symbol contrast: sums of signs do determine the unordered pair.
"""
from __future__ import annotations

import random
from itertools import product
from typing import Dict, FrozenSet, List, Set, Tuple

UNITS8: List[int] = [1, 3, 5, 7]


# ---------------------------------------------------------------- helpers
def inv_mod(a: int, m: int) -> int:
    """Multiplicative inverse of a modulo m (a must be a unit)."""
    return pow(a, -1, m)


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (fine for demo sizes)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    f = 3
    while f * f <= n:
        if n % f == 0:
            return False
        f += 2
    return True


def ceil_half(k: int) -> int:
    return (k + 1) // 2


def upair(a: int, b: int, m: int) -> FrozenSet[int]:
    """Unordered pair {a mod m, b mod m} (a multiset of size <= 2 as a frozenset of tuples)."""
    x, y = sorted((a % m, b % m))
    return frozenset({(x, y)})


# ---------------------------------------------------------------- section 1
def pair_sum(c: int, u: int) -> int:
    """Observable of a sum hint mod 8: factor class u plus partner class c*u^{-1}."""
    return (u + c * inv_mod(u, 8)) % 8


def section1() -> None:
    print("=" * 72)
    print("1. The mod-8 pair-sum table  (rows: c = N mod 8, columns: u = p mod 8)")
    print("=" * 72)
    print("   every unit mod 8 is its own inverse:",
          all((u * u) % 8 == 1 for u in UNITS8))
    print("        u=" + "  ".join(f"{u}" for u in UNITS8) + "     partner of u")
    for c in UNITS8:
        sums = [pair_sum(c, u) for u in UNITS8]
        partners = [(c * inv_mod(u, 8)) % 8 for u in UNITS8]
        assert all(s == (u * (1 + c)) % 8 for s, u in zip(sums, UNITS8))
        print(f"   c={c}:   " + "  ".join(str(s) for s in sums) +
              "     " + " ".join(str(p) for p in partners))
    print("   check: pair sum = u*(1+c) mod 8 for all entries  -> True")
    print("   shift invariance: pair_sum(c, 5u) == pair_sum(c, u) for all c,u:",
          all(pair_sum(c, (5 * u) % 8) == pair_sum(c, u) for c in UNITS8 for u in UNITS8))
    print()


# ---------------------------------------------------------------- section 2
def unordered_determined(c: int) -> bool:
    """Does the pair sum mod 8 determine the unordered pair {u, c u^{-1}}?"""
    for u in UNITS8:
        for v in UNITS8:
            if pair_sum(c, u) == pair_sum(c, v):
                if v != u and v != (c * inv_mod(u, 8)) % 8:
                    return False
    return True


def section2() -> None:
    print("=" * 72)
    print("2. Classification: which classes N mod 8 are sum-sufficient?")
    print("=" * 72)
    for c in UNITS8:
        values = sorted({pair_sum(c, u) for u in UNITS8})
        print(f"   N = {c} mod 8: sum takes values {values}; "
              f"unordered pair determined: {unordered_determined(c)}")
    print("   -> exactly one class (N = 5 mod 8) out of four is sum-sufficient;")
    print("      for N = 3, 7 mod 8 the sum mod 8 carries zero bits.\n")


# ---------------------------------------------------------------- section 3
def section3() -> None:
    print("=" * 72)
    print("3. A genuine prime counterexample")
    print("=" * 72)
    for (p, q) in [(17, 41), (5, 13)]:
        assert is_prime(p) and is_prime(q)
        N = p * q
        print(f"   N = {p}*{q} = {N}:  N mod 8 = {N % 8},  (p+q) mod 8 = {(p + q) % 8},"
              f"  factor classes mod 8 = ({p % 8}, {q % 8}),  N mod 32 = {N % 32}")
    print("   Same N mod 8, same sum mod 8, different factor classes {1,1} vs {5,5}.")
    print("   (p = 1 mod 8 splits completely in Q(zeta_8); p = 5 mod 8 does not.)\n")


# ---------------------------------------------------------------- section 4
def determined_precision(ell: int, k: int, separated_only: bool = False) -> int:
    """
    Largest j <= k such that, for all integer pairs (reduced mod ell^k),
    agreement of (p+q, pq) mod ell^k forces agreement of {p,q} mod ell^j.
    """
    m = ell ** k
    classes: Dict[Tuple[int, int], List[Tuple[int, int]]] = {}
    for p in range(m):
        for q in range(p, m):
            if separated_only and (p - q) % ell == 0:
                continue
            classes.setdefault(((p + q) % m, (p * q) % m), []).append((p, q))
    best = 0
    for j in range(k + 1):
        mj = ell ** j
        ok = True
        for pairs in classes.values():
            images: Set[Tuple[int, int]] = {tuple(sorted((a % mj, b % mj))) for a, b in pairs}
            if len(images) > 1:
                ok = False
                break
        if ok:
            best = j
        else:
            break
    return best


def section4() -> None:
    print("=" * 72)
    print("4. The precision law: exhaustive check of 'determined precision'")
    print("=" * 72)
    print("   (sum, product) mod l^k  ->  unordered pair mod l^j ; predicted j = ceil(k/2)")
    for ell, kmax in [(2, 7), (3, 4), (5, 3)]:
        for k in range(1, kmax + 1):
            j = determined_precision(ell, k)
            print(f"   l={ell}, k={k}:  observed j = {j},  predicted ceil(k/2) = {ceil_half(k)}"
                  f"  {'OK' if j == ceil_half(k) else 'MISMATCH'}")
    print("   Sharpness witnesses p=1, q=1-2l^c, p'=q'=1-l^c:")
    for ell in [2, 3, 5, 7]:
        for c in [1, 2, 3]:
            p, q, pp, qq = 1, 1 - 2 * ell ** c, 1 - ell ** c, 1 - ell ** c
            same_sum = (p + q) == (pp + qq)
            prod_ok = (p * q - pp * qq) % ell ** (2 * c) == 0
            differ = (p - pp) % ell ** (c + 1) != 0
            assert same_sum and prod_ok and differ
        print(f"   l={ell}: equal sums, products agree mod l^(2c), pairs differ mod l^(c+1)"
              f" for c = 1,2,3  -> True")
    print()


# ---------------------------------------------------------------- section 5
def section5() -> None:
    print("=" * 72)
    print("5. The Hensel regime: separated pairs (l does not divide p - q)")
    print("=" * 72)
    for ell, kmax in [(3, 4), (5, 3), (7, 2)]:
        for k in range(1, kmax + 1):
            j = determined_precision(ell, k, separated_only=True)
            print(f"   l={ell}, k={k}: separated pairs determined mod l^{j}  (full precision = l^{k})")
    print("   At l = 2 odd p, q always satisfy 2 | p - q: never separated.\n")


# ---------------------------------------------------------------- section 6
def random_prime(bits: int, rng: random.Random) -> int:
    while True:
        n = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        if is_prime(n):
            return n


def section6(samples: int = 3000, seed: int = 105) -> None:
    print("=" * 72)
    print("6. The D4@8 corollary on random semiprimes")
    print("=" * 72)
    rng = random.Random(seed)
    semis = [(random_prime(20, rng), random_prime(20, rng)) for _ in range(samples)]
    for k in range(3, 8):
        m = 2 ** k
        table: Dict[Tuple[int, int], Set[Tuple[int, int]]] = {}
        for p, q in semis:
            key = ((p + q) % m, (p * q) % m)
            table.setdefault(key, set()).add(tuple(sorted((p % 8, q % 8))))
        ambiguous = sum(1 for p, q in semis
                        if len(table[((p + q) % m, (p * q) % m)]) > 1)
        print(f"   (s, N) mod 2^{k} = {m:3d}: fraction of semiprimes whose type pair "
              f"is pinned = {1 - ambiguous / samples:6.1%}")
    print("   Prediction: < 100% for 2^3, 2^4 ; exactly 100% from 2^5 = 32 on.")
    print("   Explicit mod-16 collision: (1,9) and (13,13): sums",
          (1 + 9) % 16, (13 + 13) % 16, " products", (1 * 9) % 16, (13 * 13) % 16,
          " but {1,1} vs {5,5} mod 8.\n")


# ---------------------------------------------------------------- section 7
def section7() -> None:
    print("=" * 72)
    print("7. Symbols: the sum of two +-1 values determines the unordered pair")
    print("=" * 72)
    by_sum: Dict[int, Set[Tuple[int, int]]] = {}
    for a, b in product([1, -1], repeat=2):
        by_sum.setdefault(a + b, set()).add(tuple(sorted((a, b))))
    for s, pairs in sorted(by_sum.items()):
        print(f"   a + b = {s:+d}  ->  unordered pairs {sorted(pairs)}")
    print("   Each sum has exactly one unordered pair: the claimed S3 contrast is backwards.\n")


if __name__ == "__main__":
    section1()
    section2()
    section3()
    section4()
    section5()
    section6()
    section7()
