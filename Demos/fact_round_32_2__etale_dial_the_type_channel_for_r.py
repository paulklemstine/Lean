#!/usr/bin/env python3
"""
The type channel for reducible polynomials: numerical companion.

Everything here is a finite, exhaustive computation over residue rings Z/mZ.
The "hinted view" of an unordered pair {p, q} of units mod m is the pair
    (s, n) = (p + q mod m, p * q mod m).
A "type map" f on the units mod m is *sum-sufficient* (readable) when the hinted
view determines the unordered pair of types {f(p), f(q)}.

Sections
  1. The conductor classification (when does (s, n) determine {p, q}?)
  2. The half-conductor law at prime powers (resolution l^ceil(k/2))
  3. Conductor 8: the refuted claim, the exact criterion, the three quadratic
     channels of Q(zeta_8), and reducible polynomials
  4. Join failure at conductor 15
  5. The general classification, tested against brute force
  6. The Hensel form: pairs with p != q (mod l) are never confused
"""
from __future__ import annotations

import itertools
import random
from collections import defaultdict
from math import gcd
from typing import Callable, Dict, Hashable, List, Tuple

TypeMap = Callable[[int], Hashable]


# ----------------------------------------------------------------------------
# Basic arithmetic helpers
# ----------------------------------------------------------------------------

def units(m: int) -> List[int]:
    """Units of Z/mZ as integers in [0, m)."""
    if m == 1:
        return [0]
    return [a for a in range(m) if gcd(a, m) == 1]


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


def factorize(m: int) -> Dict[int, int]:
    """Prime factorisation m = prod l^k as a dict {l: k}."""
    out: Dict[int, int] = {}
    d = 2
    while d * d <= m:
        while m % d == 0:
            out[d] = out.get(d, 0) + 1
            m //= d
        d += 1
    if m > 1:
        out[m] = out.get(m, 0) + 1
    return out


def ceil_half(k: int) -> int:
    return (k + 1) // 2


# ----------------------------------------------------------------------------
# Hinted-view cells
# ----------------------------------------------------------------------------

def cells(m: int) -> Dict[Tuple[int, int], List[Tuple[int, int]]]:
    """Group all unordered unit pairs {p, q} by their hinted view (p+q, pq) mod m."""
    table: Dict[Tuple[int, int], List[Tuple[int, int]]] = defaultdict(list)
    U = units(m)
    for i, p in enumerate(U):
        for q in U[i:]:
            table[((p + q) % m, (p * q) % m)].append((p, q))
    return table


def colliding_cells(m: int) -> List[List[Tuple[int, int]]]:
    """Cells hosting more than one unordered pair."""
    return [v for v in cells(m).values() if len(v) > 1]


def is_vieta_injective(m: int) -> bool:
    return not colliding_cells(m)


def predicted_vieta_injective(m: int) -> bool:
    """The conductor classification: m in {1, 2} or m = l, 2l with l an odd prime."""
    if m in (1, 2):
        return True
    if is_prime(m) and m != 2:
        return True
    return m % 2 == 0 and is_prime(m // 2) and m // 2 != 2


# ----------------------------------------------------------------------------
# Sum-sufficiency and the classification criterion
# ----------------------------------------------------------------------------

def is_sum_sufficient(f: TypeMap, m: int) -> bool:
    """Brute force: in every cell, the multiset {f(p), f(q)} is the same."""
    for pairs in cells(m).values():
        types = {tuple(sorted((repr(f(p)), repr(f(q))))) for p, q in pairs}
        if len(types) > 1:
            return False
    return True


def factors_through(f: TypeMap, m: int, r: int) -> bool:
    """Does f (on units mod m) depend only on the residue mod r?"""
    seen: Dict[int, Hashable] = {}
    for u in units(m):
        key = u % r
        if key in seen and seen[key] != f(u):
            return False
        seen.setdefault(key, f(u))
    return True


def criterion(f: TypeMap, m: int) -> bool:
    """General classification: some prime power l^k || m such that f depends
    only on the residue mod l^ceil(k/2).  (m = 1 is trivially readable.)"""
    if m == 1:
        return True
    return any(factors_through(f, m, l ** ceil_half(k)) for l, k in factorize(m).items())


def max_resolution(m: int) -> int:
    """Largest divisor r of m such that the hinted view mod m determines {p, q} mod r."""
    best = 1
    for r in range(1, m + 1):
        if m % r == 0 and is_sum_sufficient(lambda x, r=r: x % r, m):
            best = max(best, r)
    return best


# ----------------------------------------------------------------------------
# Quadratic characters of conductor 4 and 8
# ----------------------------------------------------------------------------

def chi4(p: int) -> int:
    """Legendre symbol (-1 | p): the Q(i) channel."""
    return 1 if p % 4 == 1 else -1


def chi8(p: int) -> int:
    """Legendre symbol (2 | p): the Q(sqrt 2) channel."""
    return 1 if p % 8 in (1, 7) else -1


def chi8p(p: int) -> int:
    """Legendre symbol (-2 | p): the Q(sqrt -2) channel."""
    return 1 if p % 8 in (1, 3) else -1


def banner(title: str) -> None:
    print("\n" + "=" * 78 + f"\n{title}\n" + "=" * 78)


# ----------------------------------------------------------------------------
# 1. Conductor classification
# ----------------------------------------------------------------------------

def section_classification(limit: int = 60) -> None:
    banner("1. Conductor classification: when does (p+q, pq) mod m determine {p, q}?")
    good = [m for m in range(1, limit + 1) if is_vieta_injective(m)]
    print(f"Vieta-injective conductors m <= {limit}:\n  {good}")
    agree = all(is_vieta_injective(m) == predicted_vieta_injective(m) for m in range(1, limit + 1))
    print(f"Matches the prediction m in {{1, 2, l, 2l}} (l odd prime): {agree}")
    for m in (8, 9, 15, 16):
        cc = colliding_cells(m)
        print(f"  m = {m:2d}: {len(cc):2d} colliding cells, e.g. {cc[0]}")
    # the two obstructions
    print("Nilpotent obstruction at m = 9 (a = 3, a^2 = 0): {1,1} vs {4,7}:",
          ((1 + 1) % 9, 1 % 9), "=", ((4 + 7) % 9, (4 * 7) % 9))
    print("Matching obstruction at m = 15 (CRT swap of (1,1),(2,4) <-> (1,4),(2,1) mod (3,5)):")
    crt = {(a % 3, a % 5): a for a in range(15)}
    P, Q, P2, Q2 = crt[(1, 1)], crt[(2, 4)], crt[(1, 4)], crt[(2, 1)]
    print(f"  {{{P},{Q}}} -> {((P + Q) % 15, (P * Q) % 15)},  {{{P2},{Q2}}} -> {((P2 + Q2) % 15, (P2 * Q2) % 15)}")


# ----------------------------------------------------------------------------
# 2. Half-conductor law
# ----------------------------------------------------------------------------

def section_half_conductor() -> None:
    banner("2. Half-conductor law: at l^k the pair is visible exactly mod l^ceil(k/2)")
    for l, k in [(2, 3), (2, 4), (2, 5), (2, 6), (3, 2), (3, 3), (5, 2), (3, 4)]:
        m = l ** k
        r = max_resolution(m)
        print(f"  m = {l}^{k} = {m:3d}: maximal resolution {r:3d}   predicted {l ** ceil_half(k):3d}"
              f"   {'OK' if r == l ** ceil_half(k) else 'MISMATCH'}")
    # sharpness witness
    l, k = 2, 5
    j = ceil_half(k)
    a = l ** j
    m = l ** k
    print(f"Sharpness witness at 2^5: {{1,1}} and {{1+{a}, 1-{a}}} = {{{(1 + a) % m}, {(1 - a) % m}}} "
          f"share (s, n) = ({2 % m}, {1 % m}) vs ({(2) % m}, {((1 + a) * (1 - a)) % m});"
          f" they differ mod 2^{j + 1} = {2 ** (j + 1)}.")


# ----------------------------------------------------------------------------
# 3. Conductor 8
# ----------------------------------------------------------------------------

def section_conductor_eight() -> None:
    banner("3. Conductor 8: the refuted claim and the exact criterion")
    for (p, q) in [(17, 41), (13, 29)]:
        print(f"  p={p:2d}, q={q:2d} (both prime: {is_prime(p) and is_prime(q)}):"
              f"  pq mod 8 = {(p * q) % 8},  p+q mod 8 = {(p + q) % 8},"
              f"  (p mod 8, q mod 8) = ({p % 8}, {q % 8})")
    print("  -> same hinted view, different residues: 'the sum determines p mod 8' is FALSE.")
    print("Colliding cells at m = 8 (each a pair of pairs related by x -> 5x):")
    for c in colliding_cells(8):
        print("   ", " ~ ".join("{%d,%d}" % pq for pq in c))

    channels: Dict[str, TypeMap] = {
        "Q(i)       chi_4 ": chi4,
        "Q(sqrt 2)  chi_8 ": chi8,
        "Q(sqrt -2) chi_8'": chi8p,
        "etale type of (x^2+1)(x^2-2) = (chi_4, chi_8)": lambda p: (chi4(p), chi8(p)),
        "partition type of (x^2+1)(x^2-2) (# split factors)":
            lambda p: (chi4(p) == 1) + (chi8(p) == 1),
        "complete splitting of x^4+1 (p = 1 mod 8)": lambda p: p % 8 == 1,
        "p mod 4": lambda p: p % 4,
        "p mod 8 (identity)": lambda p: p % 8,
    }
    print("\nChannel                                              brute force   invariant under x5")
    for name, f in channels.items():
        bf = is_sum_sufficient(f, 8)
        inv = all(f((5 * u) % 8) == f(u) for u in units(8))
        print(f"  {name:52s} {str(bf):6s}        {str(inv):6s}")
    print("Exactly one quadratic channel (Q(i)) is readable; the reducible étale type is not.")


# ----------------------------------------------------------------------------
# 4. Join failure
# ----------------------------------------------------------------------------

def section_join_failure() -> None:
    banner("4. Join failure at conductor 15 = 3 * 5")
    m = 15
    f3: TypeMap = lambda p: p % 3
    f5: TypeMap = lambda p: p % 5
    joint: TypeMap = lambda p: (p % 3, p % 5)
    print(f"  mod-3 channel readable: {is_sum_sufficient(f3, m)}")
    print(f"  mod-5 channel readable: {is_sum_sufficient(f5, m)}")
    print(f"  joint channel readable: {is_sum_sufficient(joint, m)}")
    print(f"  colliding cells at 15: {len(colliding_cells(m))} (all of CRT-matching type)")


# ----------------------------------------------------------------------------
# 5. General classification vs brute force
# ----------------------------------------------------------------------------

def section_general(seed: int = 2026, trials_per_m: int = 60) -> None:
    banner("5. General classification: readable <=> depends on one l^ceil(k/2), l^k || m")
    rng = random.Random(seed)
    total = agree = readable = 0
    for m in range(2, 49):
        U = units(m)
        tests: List[TypeMap] = []
        for d in range(1, m + 1):
            if m % d == 0:
                tests.append(lambda x, d=d: x % d)
        for _ in range(trials_per_m):
            # random map factoring through a random divisor, with a random palette
            d = rng.choice([d for d in range(1, m + 1) if m % d == 0])
            palette = {r: rng.randint(0, 2) for r in range(d)}
            tests.append(lambda x, d=d, pal=palette: pal[x % d])
        for _ in range(10):
            table = {u: rng.randint(0, 1) for u in U}
            tests.append(lambda x, t=table: t[x])
        for f in tests:
            b = is_sum_sufficient(f, m)
            c = criterion(f, m)
            total += 1
            agree += (b == c)
            readable += b
    print(f"  tested {total} type maps on conductors 2..48: criterion agrees with brute force "
          f"in {agree}/{total} cases ({readable} readable)")
    print("  Examples at m = 24 = 2^3 * 3: readable residues are p mod 4 or p mod 3, never both:")
    for d in (2, 3, 4, 6, 8, 12, 24):
        print(f"    p mod {d:2d}: readable = {is_sum_sufficient(lambda x, d=d: x % d, 24)}")


# ----------------------------------------------------------------------------
# 6. Hensel form
# ----------------------------------------------------------------------------

def section_hensel() -> None:
    banner("6. Hensel form: if p != q (mod l), the view mod l^k pins {p, q} mod l^k")
    for l, k in [(3, 3), (5, 2), (7, 2)]:
        m = l ** k
        bad = 0
        for pairs in cells(m).values():
            sep = [pq for pq in pairs if (pq[0] - pq[1]) % l != 0]
            if sep and len(pairs) > 1:
                bad += 1
        print(f"  m = {l}^{k}: cells containing a pair with p != q (mod {l}) and a second pair: {bad}")


if __name__ == "__main__":
    section_classification()
    section_half_conductor()
    section_conductor_eight()
    section_join_failure()
    section_general()
    section_hensel()
