#!/usr/bin/env python3
"""
Reference implementations of the four algorithms of the paper.

  A1  half_group_membership   -- the exact residue/order test at a known prime
  A2  dial_is_balanced        -- decide exactness of the semiprime lift
  A3  joint_law               -- compute the complete order x Jacobi joint law
  A4  permutation_test        -- factor-dependence test against a null

Each function is self-contained and type-hinted.
"""

from __future__ import annotations

import random
from collections import Counter
from math import gcd, lcm
from typing import Callable, Dict, List, Sequence, Tuple


# --------------------------------------------------------------------------
# A1.  Half-group membership at a known prime.        O(log p) multiplications
# --------------------------------------------------------------------------
def half_group_membership(p: int, b: int) -> bool:
    """
    Decide whether the order of b modulo the odd prime p divides H_p = (p-1)/2.

    By the exact coupling theorem this is *the same question* as "is b a
    quadratic residue modulo p?", and Euler's criterion answers both at once
    with a single modular exponentiation.
    """
    if p % 2 == 0 or b % p == 0:
        raise ValueError("p must be an odd prime and b a unit modulo p")
    return pow(b, (p - 1) // 2, p) == 1


# --------------------------------------------------------------------------
# A2.  The 2-adic balance test.                              O(log N) bit ops
# --------------------------------------------------------------------------
def v2(n: int) -> int:
    """2-adic valuation of a positive integer."""
    if n <= 0:
        raise ValueError("n must be positive")
    k = 0
    while n % 2 == 0:
        n //= 2
        k += 1
    return k


def dial_is_balanced(p: int, q: int) -> bool:
    """
    Decide whether the order test ord_N(b) | lcm(H_p, H_q) is an *exact*
    characterisation of the both-residue quadrant modulo N = p*q.

    By the dichotomy theorem this happens exactly when v2(H_p) = v2(H_q).
    Its bottom rung is p = q = 3 (mod 4), where both valuations vanish.

    Note: this test requires the factors, and is therefore unavailable to
    someone holding only N.
    """
    return v2((p - 1) // 2) == v2((q - 1) // 2)


# --------------------------------------------------------------------------
# A3.  The joint law.                       O(phi(N) log^2 N) mult. operations
# --------------------------------------------------------------------------
def _factorise(n: int) -> Dict[int, int]:
    f: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            f[d] = f.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        f[n] = f.get(n, 0) + 1
    return f


def order_at_prime(b: int, p: int) -> int:
    """Multiplicative order of b modulo the prime p, by peeling prime powers
    off p-1.  Costs O(log^2 p) modular multiplications."""
    o = p - 1
    for r, e in _factorise(p - 1).items():
        for _ in range(e):
            if pow(b, o // r, p) == 1:
                o //= r
            else:
                break
    return o


def jacobi_symbol(b: int, n: int) -> int:
    """Jacobi symbol (b|n) for odd n >= 1, by quadratic reciprocity.
    Costs O(log^2 n) bit operations and does NOT use the factorisation."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("n must be odd and positive")
    b %= n
    result = 1
    while b != 0:
        while b % 2 == 0:
            b //= 2
            if n % 8 in (3, 5):
                result = -result
        b, n = n, b
        if b % 4 == 3 and n % 4 == 3:
            result = -result
        b %= n
    return result if n == 1 else 0


def joint_law(p: int, q: int) -> Counter:
    """
    The complete order x Jacobi joint law of N = p*q, as a multiset of pairs.

    Orders are obtained componentwise and combined by the lcm rule
    ord_N(b) = lcm(ord_p(b), ord_q(b)), which is what makes the computation
    O(phi(N) log^2 N) rather than O(N^2).  The Jacobi symbol is the product of
    the two Legendre symbols.
    """
    N = p * q
    law: Counter = Counter()
    for b in range(1, N):
        if gcd(b, N) != 1:
            continue
        o = lcm(order_at_prime(b % p, p), order_at_prime(b % q, q))
        j = (1 if half_group_membership(p, b) else -1) * \
            (1 if half_group_membership(q, b) else -1)
        law[(o, j)] += 1
    return law


def laws_collide(p1: int, q1: int, p2: int, q2: int) -> bool:
    """True iff N1 = p1*q1 and N2 = p2*q2 have identical joint laws.  If in
    addition gcd(N1, N2) = 1, this is a proof that no function of the joint law
    can output a nontrivial factor of its modulus."""
    return joint_law(p1, q1) == joint_law(p2, q2)


# --------------------------------------------------------------------------
# A4.  Permutation test for factor dependence.                        O(T * n)
# --------------------------------------------------------------------------
def pearson(xs: Sequence[float], ys: Sequence[float]) -> float:
    """Pearson product-moment correlation coefficient."""
    n = len(xs)
    mx, my = sum(xs) / n, sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    dx = sum((x - mx) ** 2 for x in xs) ** 0.5
    dy = sum((y - my) ** 2 for y in ys) ** 0.5
    return num / (dx * dy) if dx and dy else 0.0


def permutation_test(pairs: Sequence[Tuple[int, int]],
                     values: Sequence[float],
                     covariate: Callable[[int, int], float],
                     trials: int = 10000,
                     seed: int = 0) -> Tuple[float, float, bool]:
    """
    Test whether `values` (one per (p, q) pair) correlate with a covariate of
    the factors beyond chance.

    Returns (observed |correlation|, null 95th percentile, inside_null).
    `inside_null` True means: no detectable dependence on the factors.
    """
    xs = [covariate(p, q) for p, q in pairs]
    obs = abs(pearson(xs, values))
    rng = random.Random(seed)
    null: List[float] = []
    shuffled = list(values)
    for _ in range(trials):
        rng.shuffle(shuffled)
        null.append(abs(pearson(xs, shuffled)))
    null.sort()
    p95 = null[int(0.95 * len(null))]
    return obs, p95, obs <= p95


# --------------------------------------------------------------------------
if __name__ == "__main__":
    print("A1  half_group_membership(11, 3) =", half_group_membership(11, 3),
          " (3 = 5^2 mod 11, a residue, order 5 | 5)")
    print("A2  dial_is_balanced(11, 19) =", dial_is_balanced(11, 19),
          "   dial_is_balanced(3, 13) =", dial_is_balanced(3, 13))
    print("A3  joint_law(5, 7) == joint_law(3, 13) :", laws_collide(5, 7, 3, 13))
    pairs = [(3, 7), (7, 11), (11, 19), (5, 13), (13, 17), (7, 29), (5, 17)]
    ratios = []
    for p, q in pairs:
        law = joint_law(p, q)
        sp = sum(o * c for (o, j), c in law.items() if j == 1)
        np_ = sum(c for (o, j), c in law.items() if j == 1)
        sm = sum(o * c for (o, j), c in law.items() if j == -1)
        nm = sum(c for (o, j), c in law.items() if j == -1)
        ratios.append((sp / np_) / (sm / nm))
    obs, p95, inside = permutation_test(pairs, ratios, lambda p, q: abs(p - q))
    print(f"A4  |corr| with |p-q| = {obs:.3f}, null 95th pct = {p95:.3f}, "
          f"inside null = {inside}")
