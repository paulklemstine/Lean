#!/usr/bin/env python3
"""
The sign channel of an S3 cubic is universal; its conductor is not.

Numerical companion to "The Law Is Universal: One Bit of Sign in Every S3 Cubic".
Everything here is self-contained (standard library only).

Sections
  1. Splitting types of x^3 - 2 and x^3 + x + 1 modulo primes.
  2. Stickelberger's sign law: "exactly one root"  <=>  disc is a non-square mod p.
  3. The pure cubic x^3 - 2: one root  <=>  p = 2 (mod 3); and -3 is a square <=> p = 1 (mod 3).
  4. The trinomial x^3 + x + 1: one root  <=>  (p/31) = -1   (quadratic reciprocity for -31).
  5. The group picture: I(sign ; cycle type) = 1 bit on S3, on S_n, and on S3 x S3.
  6. Channels over sets of primes: exact one-bit channels, the {5, 11} separation,
     the conductor of each field, and flatness of unrelated moduli.
  7. Chebotarev frequencies 1/6 : 1/2 : 1/3.
"""
from __future__ import annotations

import math
from collections import Counter
from itertools import permutations, product
from typing import Callable, Hashable, Iterable, Sequence, TypeVar

A = TypeVar("A")


# ---------------------------------------------------------------------------
# Basic arithmetic
# ---------------------------------------------------------------------------

def primes_up_to(n: int) -> list[int]:
    """Sieve of Eratosthenes."""
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
    return [i for i in range(n + 1) if sieve[i]]


def legendre(a: int, p: int) -> int:
    """Legendre symbol (a/p) for an odd prime p, via Euler's criterion."""
    a %= p
    if a == 0:
        return 0
    return 1 if pow(a, (p - 1) // 2, p) == 1 else -1


def cubic_roots(a: int, b: int, p: int) -> list[int]:
    """Roots of the depressed cubic x^3 + a x + b in F_p (brute force)."""
    return [x for x in range(p) if (x * x * x + a * x + b) % p == 0]


def disc(a: int, b: int) -> int:
    """Discriminant -4a^3 - 27b^2 of x^3 + a x + b."""
    return -4 * a ** 3 - 27 * b ** 2


def splitting_type(a: int, b: int, p: int) -> str:
    """Splitting type of x^3 + a x + b mod p, from the number of roots
    (valid when p does not divide the discriminant)."""
    return {3: "1+1+1", 1: "1+2", 0: "3"}.get(len(cubic_roots(a, b, p)), "ramified")


# ---------------------------------------------------------------------------
# Entropy on the uniform measure of a finite set
# ---------------------------------------------------------------------------

def entropy(s: Sequence[A], g: Callable[[A], Hashable]) -> float:
    """H(g) = - sum_v (n_v/|s|) log2(n_v/|s|), uniform measure on s."""
    n = len(s)
    if n == 0:
        return 0.0
    counts = Counter(g(x) for x in s)
    return -sum((c / n) * math.log2(c / n) for c in counts.values())


def cond_entropy(s: Sequence[A], g: Callable[[A], Hashable],
                 k: Callable[[A], Hashable]) -> float:
    """H(g | k) = sum_c P(k = c) H(g restricted to the fibre k = c)."""
    n = len(s)
    fibres: dict[Hashable, list[A]] = {}
    for x in s:
        fibres.setdefault(k(x), []).append(x)
    return sum(len(f) / n * entropy(f, g) for f in fibres.values())


def mutual_info(s: Sequence[A], g: Callable[[A], Hashable],
                k: Callable[[A], Hashable]) -> float:
    """I(g ; k) = H(g) - H(g | k)  (tiny negative rounding noise clipped to 0)."""
    value = entropy(s, g) - cond_entropy(s, g, k)
    return 0.0 if abs(value) < 1e-12 else value


# ---------------------------------------------------------------------------
# Permutations
# ---------------------------------------------------------------------------

def sign(perm: tuple[int, ...]) -> int:
    """Sign of a permutation given in one-line notation."""
    n, seen, s = len(perm), [False] * len(perm), 1
    for i in range(n):
        if not seen[i]:
            j, length = i, 0
            while not seen[j]:
                seen[j] = True
                j = perm[j]
                length += 1
            if length % 2 == 0:
                s = -s
    return s


def cycle_type(perm: tuple[int, ...]) -> tuple[int, ...]:
    """Multiset of cycle lengths (sorted, descending)."""
    n, seen, lengths = len(perm), [False] * len(perm), []
    for i in range(n):
        if not seen[i]:
            j, length = i, 0
            while not seen[j]:
                seen[j] = True
                j = perm[j]
                length += 1
            lengths.append(length)
    return tuple(sorted(lengths, reverse=True))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def header(title: str) -> None:
    print("\n" + "=" * 78 + f"\n{title}\n" + "=" * 78)


def demo_splitting_types(primes: Iterable[int]) -> None:
    header("1. Splitting types modulo small primes")
    print(f"{'p':>4} {'p%3':>4} {'p%31':>5} | {'x^3-2':>8} {'roots':>12} | "
          f"{'x^3+x+1':>8} {'roots':>12}")
    for p in primes:
        r1, r2 = cubic_roots(0, -2, p), cubic_roots(1, 1, p)
        print(f"{p:>4} {p % 3:>4} {p % 31:>5} | {splitting_type(0, -2, p):>8} "
              f"{str(r1):>12} | {splitting_type(1, 1, p):>8} {str(r2):>12}")


def demo_sign_law(bound: int) -> None:
    header("2. Stickelberger's sign law: exactly one root  <=>  disc non-square")
    tests = [(0, -2), (1, 1), (-1, 1), (2, 3), (-7, 5), (3, -11)]
    for a, b in tests:
        d = disc(a, b)
        checked = fails = 0
        for p in primes_up_to(bound):
            if p == 2 or d % p == 0:
                continue
            one_root = len(cubic_roots(a, b, p)) == 1
            nonsquare = legendre(d, p) == -1
            checked += 1
            fails += one_root != nonsquare
        print(f"  x^3 + ({a})x + ({b}):  disc = {d:>6},  primes checked = {checked:>4},"
              f"  violations = {fails}")
    # The factorisation identity behind the reducible case
    ok = True
    for a in range(-6, 7):
        for r in range(-6, 7):
            b = -r ** 3 - a * r               # forces r to be a root
            ok &= disc(a, b) == (-3 * r * r - 4 * a) * (3 * r * r + a) ** 2
    print(f"  identity  disc = (-3r^2 - 4a)(3r^2 + a)^2  when f(r)=0 :  {ok}")


def demo_pure_cubic(bound: int) -> None:
    header("3. The pure cubic x^3 - 2 (disc -108 = -3 * 6^2): conductor 3")
    bad_roots = bad_minus3 = 0
    for p in primes_up_to(bound):
        if p <= 3:
            continue
        bad_roots += (len(cubic_roots(0, -2, p)) == 1) != (p % 3 == 2)
        bad_minus3 += (legendre(-3, p) == 1) != (p % 3 == 1)
        # p = 1 mod 3 and a != 0  =>  x^3 = a has 0 or 3 roots
        if p % 3 == 1 and p < 200:
            for a in range(1, p):
                assert len([x for x in range(p) if pow(x, 3, p) == a]) in (0, 3)
    print(f"  one root <=> p = 2 (mod 3):        violations up to {bound}: {bad_roots}")
    print(f"  -3 square <=> p = 1 (mod 3):       violations up to {bound}: {bad_minus3}")
    print("  p = 1 (mod 3): x^3 = a has 0 or 3 roots for every a != 0 (checked p < 200)")


def demo_trinomial(bound: int) -> None:
    header("4. The trinomial x^3 + x + 1 (disc -31): conductor 31")
    bad_rec = bad_law = 0
    table: dict[int, set[int]] = {}
    for p in primes_up_to(bound):
        if p in (2, 31):
            continue
        bad_rec += legendre(-31, p) != legendre(p, 31)
        one = len(cubic_roots(1, 1, p)) == 1
        bad_law += one != (legendre(p, 31) == -1)
        table.setdefault(p % 31, set()).add(int(one))
    consistent = all(len(v) == 1 for v in table.values())
    print(f"  (-31/p) = (p/31):                  violations up to {bound}: {bad_rec}")
    print(f"  one root <=> (p/31) = -1:          violations up to {bound}: {bad_law}")
    print(f"  sign bit is a function of p mod 31: {consistent}")
    print("  counterexample to conductor 3:  5 = 11 = 2 (mod 3) but")
    print(f"    roots mod 5  = {cubic_roots(1, 1, 5)}   (type 3,   even Frobenius)")
    print(f"    roots mod 11 = {cubic_roots(1, 1, 11)}  (type 1+2, odd Frobenius)")
    print(f"    (5/31) = {legendre(5, 31)} (6^2 = 36 = 5 mod 31),  (11/31) = {legendre(11, 31)}")


def demo_group_channel() -> None:
    header("5. The group picture: I(sign ; cycle type) = 1 bit")
    for n in range(2, 7):
        G = list(permutations(range(n)))
        print(f"  S_{n}: |G| = {len(G):>4}   H(sign) = {entropy(G, sign):.4f}   "
              f"I(sign ; cycle type) = {mutual_info(G, sign, cycle_type):.4f}")
    S3 = list(permutations(range(3)))
    fixes0: Callable[[tuple[int, ...]], Hashable] = lambda g: g[0] == 0
    print(f"  S_3, a coarser type 'does g fix 0?':  I = {mutual_info(S3, sign, fixes0):.4f}"
          "  (<= 1, as always)")
    print(f"  S_3, the full element as type:        I = {mutual_info(S3, sign, lambda g: g):.4f}")
    pairs = list(product(S3, S3))
    pair_sign: Callable[[tuple], Hashable] = lambda x: sign(x[0]) * sign(x[1])
    pair_type: Callable[[tuple], Hashable] = lambda x: (cycle_type(x[0]), cycle_type(x[1]))
    print(f"  S_3 x S_3 semiprime pair channel:     I = {mutual_info(pairs, pair_sign, pair_type):.4f}")
    C = list(range(12))
    prod_set = list(product(S3, C))
    flat = mutual_info(prod_set, lambda x: cycle_type(x[0]), lambda x: x[1])
    print(f"  S_3 x C_12, cycle type vs abelian coordinate:  I = {flat:.4f}  (flat)")


def demo_prime_channels(bound: int) -> None:
    header("6. Channels over sets of primes")
    T_pure: Callable[[int], Hashable] = lambda p: len(cubic_roots(0, -2, p))
    T_tri: Callable[[int], Hashable] = lambda p: len(cubic_roots(1, 1, p))
    print(f"  {{5,7,11,13}}:  I(p mod 3 ; T[x^3-2]) = "
          f"{mutual_info([5, 7, 11, 13], lambda p: p % 3, T_pure):.4f}")
    pairs = [(p, q) for p in (5, 7) for q in (5, 7)]
    print(f"  {{5,7}}^2:     I(pq mod 3 ; (T p, T q)) = "
          f"{mutual_info(pairs, lambda x: x[0] * x[1] % 3, lambda x: (T_pure(x[0]), T_pure(x[1]))):.4f}")
    print(f"  {{5,11}}:      I(p mod 3 ; T[x^3+x+1]) = "
          f"{mutual_info([5, 11], lambda p: p % 3, T_tri):.4f}")
    print(f"  {{5,11}}:      I((p/31) ; T[x^3+x+1])  = "
          f"{mutual_info([5, 11], lambda p: legendre(p, 31), T_tri):.4f}")

    P = [p for p in primes_up_to(bound) if p not in (2, 3, 31)]
    bit_pure: Callable[[int], Hashable] = lambda p: len(cubic_roots(0, -2, p)) == 1
    bit_tri: Callable[[int], Hashable] = lambda p: len(cubic_roots(1, 1, p)) == 1
    print(f"\n  All {len(P)} primes up to {bound} (excluding 2, 3, 31):")
    print(f"   {'modulus m':>10} | {'I(bit[x^3-2] ; p mod m)':>24} | {'I(bit[x^3+x+1] ; p mod m)':>26}")
    for m in (3, 4, 5, 7, 8, 12, 31, 62, 93):
        i1 = mutual_info(P, bit_pure, lambda p: p % m)
        i2 = mutual_info(P, bit_tri, lambda p: p % m)
        print(f"   {m:>10} | {i1:>24.4f} | {i2:>26.4f}")
    print("  Full bit only when 3 | m (pure cubic) or 31 | m (trinomial);")
    print("  unrelated moduli give ~0 (the finite-sample residue is not exactly 0).")
    print(f"  H(sign bit): x^3-2 -> {entropy(P, bit_pure):.4f},  x^3+x+1 -> {entropy(P, bit_tri):.4f}")


def demo_chebotarev(bound: int) -> None:
    header("7. Chebotarev: splitting types occur with frequencies 1/6 : 1/2 : 1/3")
    for name, (a, b) in (("x^3 - 2", (0, -2)), ("x^3 + x + 1", (1, 1))):
        d = disc(a, b)
        types = Counter(splitting_type(a, b, p) for p in primes_up_to(bound)
                        if p > 3 and d % p)
        n = sum(types.values())
        print(f"  {name:<12}  1+1+1: {types['1+1+1'] / n:.4f}   1+2: {types['1+2'] / n:.4f}"
              f"   3: {types['3'] / n:.4f}   (n = {n})")
    print("  S_3 prediction:  1+1+1: 0.1667   1+2: 0.5000   3: 0.3333")


def main() -> None:
    demo_splitting_types([5, 7, 11, 13, 17, 19, 23, 29, 37, 41, 43, 47])
    demo_sign_law(2000)
    demo_pure_cubic(5000)
    demo_trinomial(5000)
    demo_group_channel()
    demo_prime_channels(3000)
    demo_chebotarev(20000)


if __name__ == "__main__":
    main()
