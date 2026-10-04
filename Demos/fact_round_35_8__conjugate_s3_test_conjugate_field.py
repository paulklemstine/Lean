#!/usr/bin/env python3
"""
The field, not the polynomial: numerical companion.

Three cubics generate the same cubic field of discriminant -23:
    f+(x) = x^3 - x + 1,   f-(x) = x^3 - x - 1,   fr(x) = x^3 + x^2 - 1.
This script checks, by direct computation:
  1. Equal root counts modulo every n up to a bound (the "type function").
  2. Exact equality of the type channel I(p mod 23 ; T) for f+ and f-.
  3. CRT multiplicativity T(pq) = T(p) T(q) and the entropy inequality.
  4. The sign law: one root mod p  <=>  -23 is a non-square mod p.
  5. Ramification at 23 and the separation of fields at p = 3.
  6. Affine invariance for random polynomials and random units.
Pure standard-library Python; all helpers are inlined.
"""
from __future__ import annotations

import math
import random
from collections import Counter
from typing import Callable, Hashable, Iterable, Sequence

Poly = Callable[[int, int], int]  # (x, n) -> f(x) mod n


def f_plus(x: int, n: int) -> int:
    return (x * x * x - x + 1) % n


def f_minus(x: int, n: int) -> int:
    return (x * x * x - x - 1) % n


def f_recip(x: int, n: int) -> int:
    return (x * x * x + x * x - 1) % n


def root_count(f: Poly, n: int) -> int:
    """T_f(n) = #{x in Z/n : f(x) = 0}; T_f(0) = 0 by convention."""
    return sum(1 for x in range(n) if f(x, n) == 0)


def primes_up_to(m: int) -> list[int]:
    sieve = bytearray([1]) * (m + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(m ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
    return [i for i in range(m + 1) if sieve[i]]


def entropy(values: Iterable[Hashable]) -> float:
    """Plug-in Shannon entropy (bits) of the empirical distribution."""
    c = Counter(values)
    total = sum(c.values())
    return -sum(k / total * math.log2(k / total) for k in c.values())


def mutual_information(labels: Sequence[Hashable], types: Sequence[Hashable]) -> float:
    """I(L;T) = H(L) + H(T) - H(L,T) on a finite sample (uniform weights)."""
    return entropy(labels) + entropy(types) - entropy(list(zip(labels, types)))


def is_square_mod_p(a: int, p: int) -> bool:
    a %= p
    return a == 0 or pow(a, (p - 1) // 2, p) == 1


def poly_eval(coeffs: Sequence[int], x: int, n: int) -> int:
    """Horner evaluation; coeffs from highest degree down."""
    acc = 0
    for c in coeffs:
        acc = (acc * x + c) % n
    return acc


def section(title: str) -> None:
    print("\n" + "=" * 72 + "\n" + title + "\n" + "=" * 72)


def demo_type_functions(bound: int = 400) -> None:
    section("1. Type functions agree at EVERY modulus n (not only primes)")
    mismatches = 0
    for n in range(1, bound + 1):
        a, b, c = root_count(f_plus, n), root_count(f_minus, n), root_count(f_recip, n)
        if not (a == b == c):
            mismatches += 1
    print(f"moduli n = 1..{bound}: mismatches between f+, f-, fr = {mismatches}")
    print("sample   n : T+  T-  Tr")
    for n in [3, 5, 7, 23, 25, 59, 69, 101, 125, 299, 1357]:
        print(f"      {n:5d} : {root_count(f_plus, n):2d}  {root_count(f_minus, n):2d}  "
              f"{root_count(f_recip, n):2d}")
    # The bijections behind the theorem, shown mod 59 (where f- splits completely).
    p = 59
    roots_m = [x for x in range(p) if f_minus(x, p) == 0]
    print(f"\nroots of x^3-x-1 mod {p}: {roots_m}")
    print(f"  negated (roots of x^3-x+1): {sorted((-r) % p for r in roots_m)}")
    print(f"  r -> r^2-1 (roots of x^3+x^2-1): {sorted((r * r - 1) % p for r in roots_m)}")
    print(f"  check r*(r^2-1) = 1 mod {p}: {[(r * (r * r - 1)) % p for r in roots_m]}")


def demo_type_channel(prime_bound: int = 20000) -> None:
    section("2. The type channel I(p mod 23 ; T) is IDENTICAL for the conjugates")
    ps = [p for p in primes_up_to(prime_bound) if p not in (2, 23)]
    labels = [p % 23 for p in ps]
    tp = [root_count(f_plus, p) for p in ps]
    tm = [root_count(f_minus, p) for p in ps]
    i_plus, i_minus = mutual_information(labels, tp), mutual_information(labels, tm)
    print(f"N = {len(ps)} primes below {prime_bound}")
    print(f"I(p mod 23 ; T+) = {i_plus:.12f}")
    print(f"I(p mod 23 ; T-) = {i_minus:.12f}")
    print(f"difference       = {i_plus - i_minus:.3e}  (exactly zero: same lists)")
    print(f"type lists identical: {tp == tm}")
    freq = Counter(tm)
    print("type frequencies:", {t: round(k / len(ps), 4) for t, k in sorted(freq.items())},
          " Chebotarev prediction {0: 1/3, 1: 1/2, 3: 1/6}")
    sq = [1 if is_square_mod_p(-23, p) else -1 for p in ps]
    print(f"I(Legendre(-23/p) ; T) = {mutual_information(sq, tm):.6f}  (limit: exactly 1 bit)")
    print("excess over 1 bit with the 22-class label vs N (plug-in bias):")
    for n_sub in [250, 500, 1000, 2000, len(ps)]:
        print(f"   N = {n_sub:5d}: I - 1 = {mutual_information(labels[:n_sub], tm[:n_sub]) - 1:+.6f}")


def demo_crt(bound: int = 120) -> None:
    section("3. Semiprimes: T(pq) = T(p) T(q) and H(T(pq)) <= H(T p, T q)")
    ps = [p for p in primes_up_to(bound)]
    pairs = [(p, q) for i, p in enumerate(ps) for q in ps[i + 1 :]]
    bad = sum(1 for p, q in pairs
              if root_count(f_minus, p * q) != root_count(f_minus, p) * root_count(f_minus, q))
    print(f"{len(pairs)} semiprime pairs p<q<{bound}: CRT failures = {bad}")
    t_pq = [root_count(f_minus, p) * root_count(f_minus, q) for p, q in pairs]
    t_joint = [(root_count(f_minus, p), root_count(f_minus, q)) for p, q in pairs]
    print(f"H(T(pq)) = {entropy(t_pq):.6f}  <=  H(Tp,Tq) = {entropy(t_joint):.6f}")
    plus_pq = [root_count(f_plus, p * q) for p, q in pairs[:300]]
    minus_pq = [root_count(f_minus, p * q) for p, q in pairs[:300]]
    print(f"semiprime type lists for f+ and f- identical (first 300 pairs): {plus_pq == minus_pq}")


def demo_sign_law(bound: int = 5000) -> None:
    section("4. Sign law: exactly one root mod p  <=>  -23 is a non-square mod p")
    viol = 0
    for p in primes_up_to(bound):
        if p in (2, 23):
            continue
        for f in (f_plus, f_minus):
            if (root_count(f, p) == 1) != (not is_square_mod_p(-23, p)):
                viol += 1
    print(f"primes 3..{bound} (excluding 23), both cubics: violations = {viol}")
    print("discriminant of x^3+ax+b is -4a^3-27b^2: for (a,b)=(-1,+-1):",
          -4 * (-1) ** 3 - 27 * 1, -4 * (-1) ** 3 - 27 * 1)


def demo_ramification_and_separation() -> None:
    section("5. Ramification at 23 and separation of fields at p = 3")
    ok = all(f_minus(x, 23) == ((x - 3) * (x - 10) ** 2) % 23 for x in range(23))
    print(f"x^3-x-1 == (x-3)(x-10)^2 mod 23 for all x: {ok}")
    print(f"distinct roots mod 23: {root_count(f_minus, 23)} (multiplicity hidden)")
    g = lambda x, n: (x ** 3 + x + 1) % n  # discriminant -31
    print(f"mod 3: roots of x^3-x-1 = {[x for x in range(3) if f_minus(x, 3) == 0]},"
          f" roots of x^3+x+1 = {[x for x in range(3) if g(x, 3) == 0]}")


def demo_affine(trials: int = 300, seed: int = 127) -> None:
    section("6. Affine invariance: f(ux+c) has as many roots as f, u a unit")
    rng = random.Random(seed)
    fails = 0
    for _ in range(trials):
        n = rng.randint(2, 300)
        coeffs = [rng.randrange(n) for _ in range(rng.randint(2, 6))]
        u = rng.randrange(1, n)
        while math.gcd(u, n) != 1:
            u = rng.randrange(1, n)
        c = rng.randrange(n)
        a = sum(1 for x in range(n) if poly_eval(coeffs, x, n) == 0)
        b = sum(1 for x in range(n) if poly_eval(coeffs, (u * x + c) % n, n) == 0)
        fails += a != b
    print(f"{trials} random (polynomial, modulus, unit, shift): failures = {fails}")


if __name__ == "__main__":
    demo_type_functions()
    demo_type_channel()
    demo_crt()
    demo_sign_law()
    demo_ramification_and_separation()
    demo_affine()
