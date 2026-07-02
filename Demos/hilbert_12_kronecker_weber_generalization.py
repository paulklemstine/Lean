"""
Numerical demonstrations of explicit reciprocity, from roots of unity to class numbers.

This self-contained script illustrates the main results:

  1. Degree of the cyclotomic field Q(zeta_n) equals Euler's totient phi(n):
         [Q(zeta_n) : Q] = #Gal(Q(zeta_n)/Q) = #(Z/nZ)^x = phi(n).
  2. For a prime p, Gal(Q(zeta_p)/Q) is cyclic of order p-1, with a generator
     corresponding to a primitive root modulo p.
  3. The prime hypothesis is necessary: (Z/8Z)^x is the Klein four-group C2 x C2,
     hence Gal(Q(zeta_8)/Q) is NOT cyclic.
  4. Degree of the Hilbert class field equals the class number: [H:K] = h_K,
     and h_K = 1 forces H = K (illustrated for several imaginary quadratic fields).

Everything is computed directly from the arithmetic that reciprocity transports.
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------
# 1. Euler totient and the cyclotomic degree  [Q(zeta_n):Q] = phi(n)
# --------------------------------------------------------------------------

def units_mod(n: int) -> List[int]:
    """The multiplicative group (Z/nZ)^x, as the coprime residues in [1, n]."""
    return [k for k in range(1, n + 1) if gcd(k, n) == 1]


def euler_totient(n: int) -> int:
    """phi(n) = #(Z/nZ)^x, computed via the prime-factorization product formula."""
    result = n
    m = n
    p = 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            result -= result // p
        p += 1
    if m > 1:
        result -= result // m
    return result


def cyclotomic_degree(n: int) -> int:
    """[Q(zeta_n):Q] = #Gal(Q(zeta_n)/Q) = phi(n)."""
    return euler_totient(n)


# --------------------------------------------------------------------------
# 2 & 3. Cyclic structure of (Z/nZ)^x  (== Gal(Q(zeta_n)/Q) by reciprocity)
# --------------------------------------------------------------------------

def multiplicative_order(a: int, n: int) -> int:
    """Order of a in (Z/nZ)^x."""
    assert gcd(a, n) == 1
    order, current = 1, a % n
    while current != 1:
        current = (current * a) % n
        order += 1
    return order


def is_cyclic_units(n: int) -> bool:
    """True iff (Z/nZ)^x is cyclic, i.e. a primitive root mod n exists."""
    order = euler_totient(n)
    return any(multiplicative_order(a, n) == order for a in units_mod(n))


def primitive_root(n: int) -> int | None:
    """A generator of (Z/nZ)^x if one exists, else None."""
    order = euler_totient(n)
    for a in units_mod(n):
        if multiplicative_order(a, n) == order:
            return a
    return None


def element_orders(n: int) -> Dict[int, int]:
    """Map each unit to its multiplicative order (reveals the group's type)."""
    return {a: multiplicative_order(a, n) for a in units_mod(n)}


# --------------------------------------------------------------------------
# 4. Class number of an imaginary quadratic field Q(sqrt(-d)) and [H:K]=h_K
# --------------------------------------------------------------------------

def is_squarefree(m: int) -> bool:
    for p in range(2, isqrt(m) + 1):
        if m % (p * p) == 0:
            return False
    return True


def class_number_imaginary_quadratic(d: int) -> int:
    """
    Class number of K = Q(sqrt(-d)) for squarefree d > 0, computed by counting
    reduced primitive positive-definite binary quadratic forms of the field's
    discriminant D:
        D = -d    if -d = 1 mod 4,   else   D = -4d.
    A form (a, b, c) with b^2 - 4ac = D is reduced iff
        |b| <= a <= c,  and  b >= 0 whenever |b| = a or a = c.
    The number of reduced forms is h_K (the class number).
    """
    assert d > 0 and is_squarefree(d)
    disc = -d if (-d) % 4 == 1 else -4 * d
    count = 0
    a = 1
    while a * a <= -disc // 3 + 1:
        for b in range(-a, a + 1):
            # need c integral: b^2 - 4ac = disc  =>  4ac = b^2 - disc
            num = b * b - disc
            if num % (4 * a) != 0:
                continue
            c = num // (4 * a)
            if c < a:
                continue
            # reduced conditions
            if abs(b) <= a <= c:
                if abs(b) == a or a == c:
                    if b < 0:
                        continue
                count += 1
        a += 1
    return count


def hilbert_class_field_degree(d: int) -> int:
    """[H:K] = h_K for K = Q(sqrt(-d)); H = K exactly when this is 1."""
    return class_number_imaginary_quadratic(d)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_cyclotomic_degrees() -> None:
    print("=" * 70)
    print("1. Cyclotomic degree  [Q(zeta_n):Q] = phi(n)")
    print("=" * 70)
    for n in [1, 2, 3, 4, 5, 6, 8, 12, 15, 20, 100]:
        deg = cyclotomic_degree(n)
        check = len(units_mod(n))
        assert deg == check
        print(f"  n = {n:4d}:  [Q(zeta_n):Q] = phi(n) = {deg:3d}   "
              f"(#(Z/nZ)^x = {check})")
    print()


def demo_prime_cyclicity() -> None:
    print("=" * 70)
    print("2. Prime modulus: Gal(Q(zeta_p)/Q) is cyclic of order p-1")
    print("=" * 70)
    for p in [3, 5, 7, 11, 13, 17]:
        g = primitive_root(p)
        assert is_cyclic_units(p)
        assert cyclotomic_degree(p) == p - 1
        print(f"  p = {p:3d}:  cyclic, order p-1 = {p-1:3d},  "
              f"primitive root (generator) = {g}")
    print()


def demo_prime_hypothesis_necessary() -> None:
    print("=" * 70)
    print("3. Necessity of the prime hypothesis: n = 8 gives C2 x C2")
    print("=" * 70)
    orders = element_orders(8)
    print(f"  (Z/8Z)^x = {units_mod(8)}")
    print(f"  element orders: {orders}")
    print(f"  cyclic? {is_cyclic_units(8)}  ->  NOT cyclic (Klein four-group)")
    print(f"  Every non-identity element has order 2, so no generator exists.")
    print()


def demo_hilbert_class_field() -> None:
    print("=" * 70)
    print("4. Hilbert class field degree  [H:K] = h_K,  K = Q(sqrt(-d))")
    print("=" * 70)
    # d : expected class number (classical values)
    expected: Dict[int, int] = {
        1: 1, 2: 1, 3: 1, 7: 1, 11: 1, 19: 1, 43: 1, 67: 1, 163: 1,  # h=1
        5: 2, 6: 2, 10: 2, 13: 2, 15: 2,                              # h=2
        23: 3, 31: 3,                                                 # h=3
    }
    for d in sorted(expected):
        h = hilbert_class_field_degree(d)
        assert h == expected[d], (d, h, expected[d])
        note = "H = K (unique factorization)" if h == 1 else "nontrivial H"
        print(f"  K = Q(sqrt(-{d:3d})):  h_K = [H:K] = {h}   {note}")
    print()
    print("  Rational witness: K = H = Q, h_Q = 1, [Q:Q] = 1.")
    print()


def main() -> None:
    demo_cyclotomic_degrees()
    demo_prime_cyclicity()
    demo_prime_hypothesis_necessary()
    demo_hilbert_class_field()
    print("All demonstrations completed and internal checks passed.")


if __name__ == "__main__":
    main()
