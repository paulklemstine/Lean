#!/usr/bin/env python3
"""
Numerical companion to "Four Walls Around Factoring".

Demonstrates, on concrete numbers, the four theorems of the paper:

  1. The multi-polynomial split-set theorem: for a prime p not dividing a,
     p divides some value of (a x + b)^2 - N  iff  N is a square mod p,
     for every choice of (a, b); the column density is exactly (p-1)/2.
  2. The Pythagorean leg channel: every triple N^2 + b^2 = c^2 with b > 0 and
     c - b != 1 reveals a nontrivial factor gcd(c - b, N); for odd N,
     N is composite iff such a triple exists.  Also checks the conjectured
     count (tau(N^2) - 1)/2 of leg triples for odd N.
  3. The which-factor wall: with readout N = p q (symmetric) and label "the
     first factor" (order-sensitive), every decoder is right on at most half
     of the ordered pairs; the least-prime-factor decoder attains exactly half.
  4. The rank-two local obstruction: if every difference a - b is a prime > m,
     then A and B occupy disjoint residue classes modulo every prime l <= m,
     and |T| <= |A||B| with equality forcing injectivity.

Pure Python 3, standard library only.
"""
from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, Iterable, List, Sequence, Set, Tuple


# ----------------------------------------------------------------------------
# Small number-theory toolkit
# ----------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (fine for small n)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    r = math.isqrt(n)
    f = 3
    while f <= r:
        if n % f == 0:
            return False
        f += 2
    return True


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    sieve = bytearray([1]) * (n + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, math.isqrt(n) + 1):
        if sieve[i]:
            sieve[i * i:: i] = bytearray(len(sieve[i * i:: i]))
    return [i for i, v in enumerate(sieve) if v]


def min_fac(n: int) -> int:
    """Least prime factor of n >= 2."""
    if n % 2 == 0:
        return 2
    f = 3
    while f * f <= n:
        if n % f == 0:
            return f
        f += 2
    return n


def is_square_mod(n: int, p: int) -> bool:
    """Is n a square in Z/pZ (0 counts as a square)?"""
    n %= p
    return any((x * x) % p == n for x in range(p))


def num_divisors(n: int) -> int:
    """tau(n), the number of positive divisors."""
    count = 0
    for d in range(1, math.isqrt(n) + 1):
        if n % d == 0:
            count += 1 if d * d == n else 2
    return count


# ----------------------------------------------------------------------------
# 1. Multi-polynomial split set
# ----------------------------------------------------------------------------

def is_column(N: int, a: int, b: int, p: int) -> bool:
    """Does p divide (a x + b)^2 - N for some integer x?  (one period suffices)"""
    return any(((a * x + b) ** 2 - N) % p == 0 for x in range(p))


def column_set(N: int, polys: Sequence[Tuple[int, int]], factor_base: Iterable[int]) -> Set[int]:
    """Union of the column sets of the family {(a_i x + b_i)^2 - N}, restricted
    to primes coprime to every leading coefficient a_i."""
    out: Set[int] = set()
    for p in factor_base:
        if any(a % p == 0 for a, _ in polys):
            continue
        if any(is_column(N, a, b, p) for a, b in polys):
            out.add(p)
    return out


def split_set(N: int, factor_base: Iterable[int], exclude: Sequence[int] = ()) -> Set[int]:
    """Primes p (not dividing any element of `exclude`) with N a square mod p."""
    return {p for p in factor_base
            if all(e % p != 0 for e in exclude) and is_square_mod(N, p)}


def column_density_count(p: int, a: int, b: int) -> int:
    """#{ n in (Z/p)^* : p divides some (a x + b)^2 - n }."""
    return sum(1 for n in range(1, p) if is_column(n, a, b, p))


def demo_split_set() -> None:
    print("=" * 72)
    print("1. THE MULTI-POLYNOMIAL COLUMN SET IS THE SPLIT SET")
    print("=" * 72)
    # Lab instance from the paper: p = 7, a = 3, b = 5.
    roots_2 = [x for x in range(7) if ((3 * x + 5) ** 2 - 2) % 7 == 0]
    roots_3 = [x for x in range(7) if ((3 * x + 5) ** 2 - 3) % 7 == 0]
    print(f"p=7, a=3, b=5: roots of (3x+5)^2-2 mod 7 -> {roots_2} "
          f"(2 = 3^2 mod 7 is a square)")
    print(f"               roots of (3x+5)^2-3 mod 7 -> {roots_3} "
          f"(3 is a non-residue mod 7)")
    print(f"   check: 11^2-2 = {11**2-2} = 7*{(11**2-2)//7},  "
          f"17^2-2 = {17**2-2} = 7*{(17**2-2)//7}")

    N = 1000003 * 999983  # a semiprime
    fb = [p for p in primes_up_to(20000) if p > 2 and N % p != 0]
    rng = random.Random(2026)
    family = [(rng.randrange(1, 10 ** 6), rng.randrange(0, 10 ** 6)) for _ in range(6)]
    cols = column_set(N, family, fb)
    split = split_set(N, fb, exclude=[a for a, _ in family])
    print(f"\nN = {N}; factor base = odd primes < 20000 ({len(fb)} primes)")
    print(f"family of {len(family)} random MPQS polynomials (a, b): {family[:3]} ...")
    single = column_set(N, [(1, 0)], fb)
    print(f"column set == split set ?  {cols == split}")
    print(f"family columns == single-polynomial (x^2 - N) columns, on common primes ?  "
          f"{cols == {p for p in single if all(a % p for a, _ in family)}}")
    usable = [p for p in fb if all(a % p for a, _ in family)]
    print(f"column density = {len(cols)}/{len(usable)} = {len(cols)/len(usable):.3f}  "
          f"(theory: ~1/2, NOT ~1/4)")

    print("\nExact density per prime: #{n mod p, n != 0 : p is a column} vs (p-1)/2")
    for p in [3, 5, 7, 11, 13, 17, 19, 23, 101]:
        a, b = rng.randrange(1, p), rng.randrange(0, p)
        c = column_density_count(p, a, b)
        print(f"  p={p:4d}  a={a:3d} b={b:3d}  count={c:3d}   (p-1)/2={(p-1)//2:3d}   "
              f"{'OK' if c == (p - 1) // 2 else 'FAIL'}")


# ----------------------------------------------------------------------------
# 2. Pythagorean leg channel
# ----------------------------------------------------------------------------

def leg_triples(N: int) -> List[Tuple[int, int]]:
    """All (b, c) with N^2 + b^2 = c^2, b > 0, via (c-b)(c+b) = N^2."""
    out: List[Tuple[int, int]] = []
    N2 = N * N
    for u in range(1, N):
        if N2 % u:
            continue
        v = N2 // u
        if (u + v) % 2 == 0 and u < v:
            out.append(((v - u) // 2, (u + v) // 2))
    return sorted(out, reverse=True)


def factor_from_triple(N: int, b: int, c: int) -> int:
    """The coordinate-gcd channel: gcd(c - b, N)."""
    return math.gcd(c - b, N)


def triple_from_factor(d: int, e: int) -> Tuple[int, int, int]:
    """Scaled trivial triple of e = 2m+1 by d: leg d*e, with c - b = d."""
    m = (e - 1) // 2
    return d * e, d * (2 * m * m + 2 * m), d * (2 * m * m + 2 * m + 1)


def demo_pythagorean() -> None:
    print("\n" + "=" * 72)
    print("2. THE PYTHAGOREAN CHANNEL IS A COORDINATE GCD (AND CIRCULAR)")
    print("=" * 72)
    N = 15
    print(f"Leg N = {N}:")
    for b, c in leg_triples(N):
        g = factor_from_triple(N, b, c)
        tag = "trivial (c-b=1), no information" if c - b == 1 else f"factor {g} revealed"
        print(f"  {N}^2 + {b}^2 = {c}^2   c-b = {c-b:3d}   gcd(c-b,N) = {g}   {tag}")

    print("\nTheorem check: every nontrivial triple yields 1 < gcd < N, for all N in [3, 400]")
    bad = 0
    for N in range(3, 401):
        for b, c in leg_triples(N):
            g = factor_from_triple(N, b, c)
            if c - b != 1 and not (1 < g < N):
                bad += 1
    print(f"  violations: {bad}")

    print("\nOdd N: composite <=> a nontrivial leg triple exists   (checked N in [3, 999])")
    mismatch = 0
    for N in range(3, 1000, 2):
        has_nontriv = any(c - b != 1 for b, c in leg_triples(N))
        if has_nontriv != (not is_prime(N)):
            mismatch += 1
    print(f"  mismatches: {mismatch}")

    print("\nConverse construction from a factorization N = d*e (scaled trivial triple):")
    for d, e in [(3, 5), (7, 11), (101, 103)]:
        L, b, c = triple_from_factor(d, e)
        print(f"  d={d}, e={e}:  {L}^2 + {b}^2 = {c}^2 ? {L*L + b*b == c*c};  c-b = {c-b}")

    print("\nConjecture (open): #leg triples for odd N equals (tau(N^2)-1)/2")
    ok = all(len(leg_triples(N)) == (num_divisors(N * N) - 1) // 2 for N in range(3, 800, 2))
    print(f"  holds for all odd N in [3, 799]: {ok}   (numerical evidence only)")


# ----------------------------------------------------------------------------
# 3. The which-factor wall
# ----------------------------------------------------------------------------

Decoder = Callable[[int], int]


def decoder_accuracy(P: Sequence[int], D: Decoder) -> Tuple[int, int]:
    """(#correct, #pairs) for decoder D guessing p from N = p*q over ordered pairs."""
    pairs = [(p, q) for p in P for q in P if p != q]
    correct = sum(1 for p, q in pairs if D(p * q) == p)
    return correct, len(pairs)


def best_possible_decoder(P: Sequence[int]) -> Tuple[int, int]:
    """Brute-force optimum: for each readout N, choose the best single answer."""
    pairs = [(p, q) for p in P for q in P if p != q]
    by_N: Dict[int, List[int]] = {}
    for p, q in pairs:
        by_N.setdefault(p * q, []).append(p)
    best = sum(max(labels.count(z) for z in set(labels)) for labels in by_N.values())
    return best, len(pairs)


def demo_which_factor() -> None:
    print("\n" + "=" * 72)
    print("3. THE WHICH-FACTOR WALL: NO DECODER BEATS 1/2")
    print("=" * 72)
    P = [2, 3, 5, 7]
    decoders: Dict[str, Decoder] = {
        "least prime factor": min_fac,
        "largest prime factor": lambda n: n // min_fac(n),
        "always 3": lambda n: 3,
    }
    for name, D in decoders.items():
        c, t = decoder_accuracy(P, D)
        print(f"  P={P}  decoder={name:24s}  correct {c}/{t} = {c/t:.3f}")
    rng = random.Random(1)
    P2 = primes_up_to(200)[3:]
    best, tot = best_possible_decoder(P2)
    print(f"\n  P = {len(P2)} primes in [7, 200]: optimal decoder (brute force) "
          f"correct {best}/{tot} = {best/tot:.4f}")
    rand_D: Decoder = lambda n: rng.choice([min_fac(n), n // min_fac(n)])
    c, t = decoder_accuracy(P2, rand_D)
    print(f"  random coin-flip decoder: {c}/{t} = {c/t:.4f}")
    c, t = decoder_accuracy(P2, min_fac)
    print(f"  least-prime-factor decoder: {c}/{t} = {c/t:.4f}  (exactly 1/2: the wall is sharp)")


# ----------------------------------------------------------------------------
# 4. Rank-two local obstruction
# ----------------------------------------------------------------------------

def is_prime_diff_pair(A: Sequence[int], B: Sequence[int], m: int) -> bool:
    return all(is_prime(abs(a - b)) and abs(a - b) > m for a in A for b in B)


def residue_report(A: Sequence[int], B: Sequence[int], l: int) -> Tuple[Set[int], Set[int]]:
    return {a % l for a in A}, {b % l for b in B}


def greedy_prime_diff_pair(size: int, m: int, X: int, seed: int = 0) -> Tuple[List[int], List[int]]:
    """Greedy search for A, B in [0, X) with all |a-b| prime > m (small demo)."""
    rng = random.Random(seed)
    A: List[int] = []
    B: List[int] = []
    cand = list(range(X))
    rng.shuffle(cand)
    for x in cand:
        okA = len(A) < size and all(is_prime(abs(x - b)) and abs(x - b) > m for b in B)
        okB = len(B) < size and all(is_prime(abs(a - x)) and abs(a - x) > m for a in A)
        # always feed the smaller side first, so both sets grow together
        if okB and (len(B) < len(A) or not okA):
            B.append(x)
        elif okA:
            A.append(x)
        if len(A) == size and len(B) == size:
            break
    return sorted(A), sorted(B)


def demo_rank_two() -> None:
    print("\n" + "=" * 72)
    print("4. RANK-TWO LOCAL OBSTRUCTION: DISJOINT RESIDUES AND NO SLACK")
    print("=" * 72)
    A, B, m = [0, 6], [-5, -11], 3
    diffs = sorted({abs(a - b) for a in A for b in B})
    print(f"A={A}, B={B}: differences {[abs(a-b) for a in A for b in B]} -> set {diffs}")
    print(f"  prime-difference pair above m={m}: {is_prime_diff_pair(A, B, m)}")
    for l in [2, 3]:
        rA, rB = residue_report(A, B, l)
        print(f"  mod {l}: A -> {sorted(rA)}, B -> {sorted(rB)}, disjoint={rA.isdisjoint(rB)}, "
              f"budget {len(rA)}+{len(rB)} <= {l}")
    print(f"  capacity: |T|={len(diffs)} <= |A||B|={len(A)*len(B)} ; not tight, "
          f"and indeed 11 appears twice (not injective)")

    m = 7
    A, B = greedy_prime_diff_pair(size=5, m=m, X=3000, seed=4)
    print(f"\nGreedy search, m={m}: A={A}\n                      B={B}")
    print(f"  prime-difference pair: {is_prime_diff_pair(A, B, m)}")
    for l in [p for p in primes_up_to(m)]:
        rA, rB = residue_report(A, B, l)
        print(f"  mod {l}: #A-classes={len(rA)}, #B-classes={len(rB)}, "
              f"disjoint={rA.isdisjoint(rB)}, sum={len(rA)+len(rB)} <= {l}")
    T = {abs(a - b) for a in A for b in B}
    print(f"  |T| = {len(T)} <= |A||B| = {len(A)*len(B)}")


if __name__ == "__main__":
    demo_split_set()
    demo_pythagorean()
    demo_which_factor()
    demo_rank_two()
