"""
Isomorphisms of Meaning: When Structures Collide
=================================================

Numerical demonstrations of the results:

  * Transport of truth: isomorphisms preserve element order, cyclicity, and
    cardinality.
  * Non-preservation of meaning: negation is a nontrivial automorphism of
    Z/nZ for n >= 3, so +1 and -1 are interchangeable.
  * The measure of ambiguity: the number of self-identifications of Z/nZ is
    Euler's totient phi(n).
  * Collision: the Chinese Remainder Theorem identifies Z/6Z with Z/2Z x Z/3Z.
  * Non-collision: Z/4Z is not isomorphic to the Klein four-group Z/2Z x Z/2Z.

The whole file is self-contained: no third-party dependencies.
"""

from __future__ import annotations

from math import gcd
from typing import Callable, Dict, List, Tuple


# ---------------------------------------------------------------------------
# Core number theory
# ---------------------------------------------------------------------------

def euler_totient(n: int) -> int:
    """Euler's totient phi(n): count of 1 <= k <= n with gcd(k, n) = 1."""
    if n < 1:
        raise ValueError("n must be a positive integer")
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def units_mod_n(n: int) -> List[int]:
    """The residues that are units mod n; these index Aut(Z/nZ)."""
    return [k for k in range(1, n + 1) if gcd(k, n) == 1]


# ---------------------------------------------------------------------------
# Additive order in Z/nZ
# ---------------------------------------------------------------------------

def additive_order(a: int, n: int) -> int:
    """Least m >= 1 with m*a = 0 in Z/nZ."""
    a %= n
    if a == 0:
        return 1
    return n // gcd(a, n)


def order_spectrum_cyclic(n: int) -> Dict[int, int]:
    """Multiset (as {order: count}) of element orders of Z/nZ."""
    spec: Dict[int, int] = {}
    for a in range(n):
        o = additive_order(a, n)
        spec[o] = spec.get(o, 0) + 1
    return spec


def order_spectrum_product(m: int, n: int) -> Dict[int, int]:
    """Multiset of element orders of Z/mZ x Z/nZ (additive, componentwise)."""
    from math import lcm

    spec: Dict[int, int] = {}
    for a in range(m):
        for b in range(n):
            oa = additive_order(a, m)
            ob = additive_order(b, n)
            o = lcm(oa, ob)
            spec[o] = spec.get(o, 0) + 1
    return spec


# ---------------------------------------------------------------------------
# Automorphisms of Z/nZ  (x -> k*x for k a unit)
# ---------------------------------------------------------------------------

def automorphisms_zmod(n: int) -> List[Callable[[int], int]]:
    """All additive automorphisms of Z/nZ, one per unit k: x -> (k*x) mod n."""
    return [(lambda x, k=k: (k * x) % n) for k in units_mod_n(n)]


def is_automorphism(f: Callable[[int], int], n: int) -> bool:
    """Check f is an additive bijection of Z/nZ preserving addition."""
    values = [f(x) % n for x in range(n)]
    if sorted(values) != list(range(n)):
        return False  # not a bijection
    for x in range(n):
        for y in range(n):
            if f((x + y) % n) % n != (f(x) + f(y)) % n:
                return False
    return True


# ---------------------------------------------------------------------------
# Chinese Remainder collision:  Z/6Z  <->  Z/2Z x Z/3Z
# ---------------------------------------------------------------------------

def crt_forward(x: int) -> Tuple[int, int]:
    """The CRT isomorphism Z/6Z -> Z/2Z x Z/3Z."""
    return (x % 2, x % 3)


def crt_backward(pair: Tuple[int, int]) -> int:
    """Inverse map Z/2Z x Z/3Z -> Z/6Z by search (6 elements)."""
    for x in range(6):
        if crt_forward(x) == (pair[0] % 2, pair[1] % 3):
            return x
    raise ValueError("no preimage (should never happen)")


def verify_crt_isomorphism() -> bool:
    """Confirm crt_forward is an additive bijection Z/6Z -> Z/2Z x Z/3Z."""
    images = [crt_forward(x) for x in range(6)]
    if len(set(images)) != 6:
        return False  # not injective
    for x in range(6):
        for y in range(6):
            lhs = crt_forward((x + y) % 6)
            rx, ry = crt_forward(x), crt_forward(y)
            rhs = ((rx[0] + ry[0]) % 2, (rx[1] + ry[1]) % 3)
            if lhs != rhs:
                return False
    return True


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_transport_of_truth() -> None:
    print("=" * 68)
    print("TRANSPORT OF TRUTH: isomorphisms preserve element order")
    print("=" * 68)
    n = 12
    # Use the automorphism x -> 5x (5 is a unit mod 12).
    e = lambda x: (5 * x) % n
    print(f"Automorphism e(x) = 5x on Z/{n}Z; checking ord(e(a)) == ord(a):")
    ok = True
    for a in range(n):
        oa, oea = additive_order(a, n), additive_order(e(a), n)
        ok = ok and (oa == oea)
        print(f"  a={a:2d}: ord(a)={oa:2d}, e(a)={e(a):2d}, ord(e(a))={oea:2d}")
    print(f"  All orders preserved: {ok}\n")


def demo_meaning_not_preserved() -> None:
    print("=" * 68)
    print("MEANING IS NOT PRESERVED: negation is a nontrivial automorphism")
    print("=" * 68)
    for n in (2, 3, 5, 12):
        neg = lambda x, n=n: (-x) % n
        nontrivial = any(neg(x) != x for x in range(n))
        print(f"  Z/{n}Z: negation is an automorphism = {is_automorphism(neg, n)}; "
              f"nontrivial = {nontrivial}  (+1 <-> {neg(1)})")
    print("  For n >= 3, +1 and -1 are structurally interchangeable.\n")


def demo_totient_measures_ambiguity() -> None:
    print("=" * 68)
    print("THE MEASURE OF MEANING: #self-identifications of Z/nZ = phi(n)")
    print("=" * 68)
    for n in range(1, 16):
        autos = automorphisms_zmod(n)
        assert all(is_automorphism(f, n) for f in autos)
        phi = euler_totient(n)
        print(f"  n={n:2d}: |Aut(Z/nZ)|={len(autos):2d}, phi(n)={phi:2d}, "
              f"match={len(autos) == phi}, units={units_mod_n(n)}")
    print()


def demo_crt_collision() -> None:
    print("=" * 68)
    print("COLLISION: Z/6Z  ~=  Z/2Z x Z/3Z  (Chinese Remainder Theorem)")
    print("=" * 68)
    print(f"  Is an additive isomorphism: {verify_crt_isomorphism()}")
    for x in range(6):
        print(f"  {x} (mod 6)  <->  {crt_forward(x)}  (mod 2, mod 3)")
    print()


def demo_non_collision() -> None:
    print("=" * 68)
    print("NON-COLLISION: Z/4Z  is NOT  ~=  Z/2Z x Z/2Z (Klein four-group)")
    print("=" * 68)
    spec_c4 = order_spectrum_cyclic(4)
    spec_v4 = order_spectrum_product(2, 2)
    print(f"  Order spectrum of Z/4Z          : {spec_c4}")
    print(f"  Order spectrum of Z/2Z x Z/2Z   : {spec_v4}")
    print(f"  Z/4Z has an element of order 4  : {4 in spec_c4}")
    print(f"  V4   has an element of order 4  : {4 in spec_v4}")
    print(f"  Spectra equal (=> could be iso) : {spec_c4 == spec_v4}")
    print("  Different spectra => NOT isomorphic, despite equal cardinality.\n")


def main() -> None:
    demo_transport_of_truth()
    demo_meaning_not_preserved()
    demo_totient_measures_ambiguity()
    demo_crt_collision()
    demo_non_collision()


if __name__ == "__main__":
    main()
