#!/usr/bin/env python3
"""
Four fields, one answer: the type channel of pure cubics x^3 - c.

Numerical companion to "Universal S3, fourth field".  Everything is self-contained
(standard library only).  Run:  python3 demo.py

What is demonstrated
--------------------
1. The type-channel law: for a prime p not dividing 3c, the cubic x^3 - c has exactly
   one root mod p  <=>  p = 2 (mod 3); otherwise it has 0 or 3 roots.
2. The universal decoder  T = 1 -> 2,  T in {0, 3} -> 1  recovers p mod 3 for every c.
3. The pinning theorem on samples: I(p mod 3 ; T) = H(p mod 3) on every sample, so the
   normalised information I/H is exactly 1, while I itself is exactly 1 bit only on
   samples balanced between the two residue classes (e.g. {5, 11, 13, 19} for c = 7).
4. The S3 Chebotarev model: I(sign ; #Fix) = 1 bit, H(#Fix) = 2/3 + log2(3)/2, and the
   gap log2(3)/2 - 1/3 > 5/12.
5. Constant-aspect Chebotarev: for q = 1 (mod 3), exactly (q-1)/3 nonzero c split and
   2(q-1)/3 are inert.
6. The boundaries: ramified primes, the prime exponent 5, and the non-pure cubic x^3-x-1.
"""
from __future__ import annotations

import itertools
import math
from collections import Counter
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple


# ----------------------------------------------------------------------------
# Elementary arithmetic
# ----------------------------------------------------------------------------
def primes_below(n: int) -> List[int]:
    """Sieve of Eratosthenes: all primes < n."""
    if n < 3:
        return []
    sieve = bytearray([1]) * n
    sieve[0] = sieve[1] = 0
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(range(i * i, n, i)))
    return [i for i in range(n) if sieve[i]]


def root_count(coeffs: Sequence[int], p: int) -> int:
    """Number of x in F_p with f(x) = 0, f given by coefficients (highest degree first)."""
    count = 0
    for x in range(p):
        acc = 0
        for a in coeffs:
            acc = (acc * x + a) % p
        if acc == 0:
            count += 1
    return count


def cube_type(c: int, p: int) -> int:
    """The type channel T(p) = #{x in F_p : x^3 = c}."""
    return root_count([1, 0, 0, -c], p)


def type_decode(t: int) -> int:
    """The universal decoder: type 1 means p = 2 (mod 3), any other type means p = 1."""
    return 2 if t == 1 else 1


def unramified(c: int, p: int) -> bool:
    """p does not divide 3c."""
    return (3 * c) % p != 0


# ----------------------------------------------------------------------------
# Shannon calculus on a uniform finite sample
# ----------------------------------------------------------------------------
def entropy(sample: Sequence[Hashable], f: Callable[[Hashable], Hashable]) -> float:
    """H(f) in bits under the uniform distribution on the sample."""
    n = len(sample)
    counts = Counter(f(a) for a in sample)
    return -sum((k / n) * math.log2(k / n) for k in counts.values())


def mutual_information(
    sample: Sequence[Hashable],
    f: Callable[[Hashable], Hashable],
    g: Callable[[Hashable], Hashable],
) -> float:
    """I(f ; g) = H(f) + H(g) - H(f, g) on the uniform sample."""
    return entropy(sample, f) + entropy(sample, g) - entropy(sample, lambda a: (f(a), g(a)))


# ----------------------------------------------------------------------------
# Permutations of three roots (the S3 model)
# ----------------------------------------------------------------------------
Perm = Tuple[int, int, int]


def sign(sigma: Perm) -> int:
    inversions = sum(1 for i, j in itertools.combinations(range(3), 2) if sigma[i] > sigma[j])
    return -1 if inversions % 2 else 1


def fix_count(sigma: Perm) -> int:
    return sum(1 for i in range(3) if sigma[i] == i)


def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------
def demo_law(bound: int = 1000) -> None:
    rule("1. The type-channel law for x^3 - c, c in {2, 3, 5, 7}, primes p < %d" % bound)
    for c in (2, 3, 5, 7):
        disc = -27 * c * c
        ps = [p for p in primes_below(bound) if unramified(c, p)]
        joint: Counter = Counter((p % 3, cube_type(c, p)) for p in ps)
        violations = [p for p in ps if type_decode(cube_type(c, p)) != p % 3]
        cells = ", ".join(f"(p mod 3={r}, T={t}): {k}" for (r, t), k in sorted(joint.items()))
        print(f"c = {c}  (disc = {disc}):  {cells}")
        print(f"         decoder failures: {len(violations)}")


def demo_information(bound: int = 1000) -> None:
    rule("2. Information on samples: I(p mod 3 ; T) = H(p mod 3), hence I/H = 1")
    print(f"{'c':>3} {'n':>5} {'H(p mod 3)':>12} {'H(T)':>10} {'I':>10} {'I/H':>8}")
    for c in (2, 3, 5, 7):
        ps = [p for p in primes_below(bound) if unramified(c, p)]
        h_res = entropy(ps, lambda p: p % 3)
        h_t = entropy(ps, lambda p, c=c: cube_type(c, p))
        i = mutual_information(ps, lambda p: p % 3, lambda p, c=c: cube_type(c, p))
        print(f"{c:>3} {len(ps):>5} {h_res:>12.5f} {h_t:>10.5f} {i:>10.5f} {i / h_res:>8.5f}")
    sample = [5, 11, 13, 19]
    i_bal = mutual_information(sample, lambda p: p % 3, lambda p: cube_type(7, p))
    print(f"\nBalanced sample {sample} for x^3 - 7: types "
          f"{[cube_type(7, p) for p in sample]},  I = {i_bal:.12f} bits (exactly 1)")


def demo_s3_model() -> None:
    rule("3. The S3 Chebotarev model: sigma uniform on the 6 permutations of 3 roots")
    perms: List[Perm] = list(itertools.permutations(range(3)))  # type: ignore[assignment]
    for s in perms:
        print(f"  sigma = {s}:  sign = {sign(s):+d},  #Fix = {fix_count(s)}")
    i = mutual_information(perms, sign, fix_count)
    h_fix = entropy(perms, fix_count)
    closed = 2 / 3 + math.log2(3) / 2
    gap = math.log2(3) / 2 - 1 / 3
    print(f"  I(sign ; #Fix)            = {i:.12f}   (exactly 1)")
    print(f"  H(#Fix)                   = {h_fix:.12f}")
    print(f"  2/3 + log2(3)/2           = {closed:.12f}")
    print(f"  gap H(T) - I = log2(3)/2 - 1/3 = {gap:.6f}  >  5/12 = {5 / 12:.6f}")


def demo_constant_aspect() -> None:
    rule("4. Constant aspect: for q = 1 (mod 3), split : inert = 1 : 2 among c != 0")
    for q in (7, 13, 19, 31, 37, 43):
        split = sum(1 for c in range(1, q) if cube_type(c, q) == 3)
        inert = sum(1 for c in range(1, q) if cube_type(c, q) == 0)
        print(f"  q = {q:>2}:  split = {split:>2} = (q-1)/3,  inert = {inert:>2} = 2(q-1)/3")


def demo_boundaries() -> None:
    rule("5. Where the law stops")
    print(f"  Ramified p = 7: T = {cube_type(7, 7)} but 7 mod 3 = {7 % 3}")
    print(f"  Ramified p = 3: T = {cube_type(7, 3)} but 3 mod 3 = {3 % 3}")
    q5 = [root_count([1, 0, 0, 0, 0, -2], p) for p in (7, 13)]
    print(f"  x^5 - 2: roots mod 7 = {q5[0]}, mod 13 = {q5[1]}, but 7 mod 5 = 2, 13 mod 5 = 3")
    n5 = root_count([1, 0, -1, -1], 5)
    n7 = root_count([1, 0, -1, -1], 7)
    print(f"  x^3 - x - 1 (disc -23): roots mod 5 = {n5}, mod 7 = {n7}, "
          f"but 5 mod 3 = 2, 7 mod 3 = 1")
    # The discriminant sign law holds for x^3 - x - 1: one root <=> (-23 / p) = -1.
    bad = 0
    for p in primes_below(500):
        if p in (2, 23):
            continue
        leg = pow(-23 % p, (p - 1) // 2, p)
        leg = -1 if leg == p - 1 else leg
        if (root_count([1, 0, -1, -1], p) == 1) != (leg == -1):
            bad += 1
    print(f"  Discriminant sign law for x^3 - x - 1 on primes < 500: {bad} failures")


def demo_explicit_seven() -> None:
    rule("6. Explicit data for the fourth field x^3 - 7 (disc -1323 = -27 * 7^2)")
    print(f"  T(5)  = {cube_type(7, 5)}   (5 = 2 mod 3)")
    print(f"  T(13) = {cube_type(7, 13)}   (cubes mod 13: {sorted({x ** 3 % 13 for x in range(1, 13)})})")
    roots19 = [x for x in range(19) if (x ** 3 - 7) % 19 == 0]
    print(f"  T(19) = {cube_type(7, 19)}   roots {roots19}")


if __name__ == "__main__":
    demo_law()
    demo_information()
    demo_s3_model()
    demo_constant_aspect()
    demo_boundaries()
    demo_explicit_seven()
