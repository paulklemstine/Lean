"""
demo.py — Numerical demonstrations for:

    The Rank of Apparition as a Divisibility-Lattice Morphism
    (Abstract theory of strong divisibility sequences)

This script demonstrates, with concrete numbers, the main results of the
accompanying article and research paper:

  * Strong divisibility sequences (SDS):  gcd(u(m), u(n)) = u(gcd(m, n)).
  * The entry point / rank of apparition.
  * The law of apparition:        m | u(k)  <=>  entry(m) | k.
  * Rigidity:                      appearance set = multiples of entry(m).
  * Order preservation:           d | m  =>  entry(d) | entry(m).
  * The join law (multiplicativity):
                                   entry(a*b) = lcm(entry a, entry b), gcd(a,b)=1.
  * Two SDS instances: Fibonacci, and Mersenne u(n) = a^n - 1
    (where the entry point IS the multiplicative order).

Self-contained, standard library only. Run:  python demo.py
"""

from __future__ import annotations

from math import gcd, lcm
from typing import Callable, Dict, List, Optional, Tuple


# --------------------------------------------------------------------------
# Strong divisibility sequences
# --------------------------------------------------------------------------

def fibonacci(n: int) -> int:
    """The n-th Fibonacci number, with F(0) = 0, F(1) = 1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne(a: int) -> Callable[[int], int]:
    """Return the base-`a` repunit/Mersenne sequence u(n) = a^n - 1 (u(0) = 0)."""
    def u(n: int) -> int:
        return a ** n - 1
    return u


def is_strong_divisibility_sequence(u: Callable[[int], int], bound: int = 20) -> bool:
    """
    Empirically verify the SDS identity gcd(u(m), u(n)) = u(gcd(m, n))
    for all 0 <= m, n <= bound.
    """
    for m in range(bound + 1):
        for n in range(bound + 1):
            if gcd(u(m), u(n)) != u(gcd(m, n)):
                return False
    return True


# --------------------------------------------------------------------------
# Entry point (rank of apparition)
# --------------------------------------------------------------------------

def entry_point(u: Callable[[int], int], m: int, search_limit: int = 5000) -> Optional[int]:
    """
    The least k > 0 with m | u(k), or None if none is found within search_limit.
    This is the only place a search is ever needed (see prime-power reduction).
    """
    if m == 0:
        return None
    for k in range(1, search_limit + 1):
        if u(k) % m == 0:
            return k
    return None


# --------------------------------------------------------------------------
# Verifications of the main theorems
# --------------------------------------------------------------------------

def verify_law_of_apparition(
    u: Callable[[int], int], m: int, k_max: int = 60
) -> bool:
    """
    Theorem 5.1: for 0 <= k <= k_max,  m | u(k)  <=>  entry(m) | k.
    """
    e = entry_point(u, m)
    if e is None:
        return True  # vacuous: m does not appear in the searched range
    for k in range(k_max + 1):
        lhs = (u(k) % m == 0)
        rhs = (k % e == 0)
        if lhs != rhs:
            return False
    return True


def verify_rigidity(u: Callable[[int], int], m: int, k_max: int = 60) -> bool:
    """
    Theorem 6.1: the appearance set {k : m | u(k)} restricted to [1, k_max]
    is exactly the multiples of entry(m).
    """
    e = entry_point(u, m)
    if e is None:
        return True
    appears = {k for k in range(1, k_max + 1) if u(k) % m == 0}
    multiples = {k for k in range(1, k_max + 1) if k % e == 0}
    return appears == multiples


def verify_order_preservation(
    u: Callable[[int], int], d: int, m: int
) -> Optional[bool]:
    """
    Theorem 7.1: if d | m then entry(d) | entry(m).
    Returns None if either does not appear (so the claim is not tested).
    """
    if m % d != 0:
        raise ValueError("d must divide m")
    ed, em = entry_point(u, d), entry_point(u, m)
    if ed is None or em is None:
        return None
    return em % ed == 0


def verify_join_law(u: Callable[[int], int], a: int, b: int) -> Optional[bool]:
    """
    Theorem 7.3: if gcd(a, b) = 1 then entry(a*b) = lcm(entry a, entry b).
    Returns None if any required entry point is not found.
    """
    if gcd(a, b) != 1:
        raise ValueError("a and b must be coprime")
    ea, eb, eab = entry_point(u, a), entry_point(u, b), entry_point(u, a * b)
    if ea is None or eb is None or eab is None:
        return None
    return eab == lcm(ea, eb)


# --------------------------------------------------------------------------
# Algorithm A: entry point via prime-power reduction (Corollary 7.4)
# --------------------------------------------------------------------------

def factorize(n: int) -> Dict[int, int]:
    """Prime-power factorization of n >= 1 as {prime: exponent}."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def entry_point_via_reduction(
    u: Callable[[int], int], n: int, search_limit: int = 5000
) -> Optional[int]:
    """
    Compute entry(n) by reducing to prime powers and taking an lcm.
    Searches only over prime powers, never over the (possibly large) n.
    """
    if n <= 1:
        return 1 if n == 1 else None
    result = 1
    for p, e in factorize(n).items():
        q = p ** e
        eq = entry_point(u, q, search_limit)
        if eq is None:
            return None
        result = lcm(result, eq)
    return result


# --------------------------------------------------------------------------
# Multiplicative order specialization (Corollary 8.1)
# --------------------------------------------------------------------------

def multiplicative_order(a: int, m: int) -> Optional[int]:
    """Least k > 0 with a^k = 1 (mod m); equals entry_point of the Mersenne SDS."""
    if gcd(a, m) != 1:
        return None
    k, val = 1, a % m
    while val != 1 % m:
        val = (val * a) % m
        k += 1
        if k > m + 1:
            return None
    return k


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------

def main() -> None:
    print("=" * 72)
    print("THE RANK OF APPARITION AS A DIVISIBILITY-LATTICE MORPHISM")
    print("=" * 72)

    # ---- Fibonacci is a strong divisibility sequence -------------------
    print("\n[1] Fibonacci is a strong divisibility sequence")
    print("    gcd(F(m), F(n)) = F(gcd(m, n))?  ->",
          is_strong_divisibility_sequence(fibonacci, bound=18))
    print("    e.g. gcd(F(12), F(8)) = gcd(144, 21) =", gcd(144, 21),
          "= F(4) = F(gcd(12,8))")

    # ---- Entry points table -------------------------------------------
    print("\n[2] Fibonacci entry points (rank of apparition)")
    for m in [2, 3, 4, 5, 6, 7, 8, 12]:
        print(f"    entry_F({m:>2}) = {entry_point(fibonacci, m)}")

    # ---- Law of apparition --------------------------------------------
    print("\n[3] Law of apparition:  m | F(k)  <=>  entry(m) | k")
    for m in [2, 3, 6, 7, 8]:
        ok = verify_law_of_apparition(fibonacci, m, k_max=60)
        print(f"    m = {m:>2}:  verified for k <= 60  ->  {ok}")

    # ---- Rigidity -----------------------------------------------------
    print("\n[4] Rigidity: appearance set = multiples of entry(m)")
    for m in [4, 6, 7]:
        print(f"    m = {m}:  ->  {verify_rigidity(fibonacci, m)}")

    # ---- Order preservation -------------------------------------------
    print("\n[5] Order preservation:  d | m  =>  entry(d) | entry(m)")
    for d, m in [(2, 6), (3, 6), (2, 4), (2, 8)]:
        print(f"    {d} | {m}:  entry({d})={entry_point(fibonacci,d)}, "
              f"entry({m})={entry_point(fibonacci,m)}  ->  "
              f"{verify_order_preservation(fibonacci, d, m)}")

    # ---- Join law (multiplicativity) ----------------------------------
    print("\n[6] Join law:  entry(a*b) = lcm(entry a, entry b),  gcd(a,b)=1")
    for a, b in [(2, 3), (3, 5), (4, 7), (5, 8)]:
        ea, eb = entry_point(fibonacci, a), entry_point(fibonacci, b)
        eab = entry_point(fibonacci, a * b)
        print(f"    a={a}, b={b}:  lcm({ea},{eb})={lcm(ea,eb)}, "
              f"entry({a*b})={eab}  ->  {verify_join_law(fibonacci, a, b)}")

    # ---- Prime-power reduction matches direct search ------------------
    print("\n[7] Algorithm A: entry via prime-power reduction == direct search")
    for n in [6, 12, 30, 60, 35]:
        direct = entry_point(fibonacci, n)
        reduced = entry_point_via_reduction(fibonacci, n)
        print(f"    n={n:>2}:  direct={direct}, reduced={reduced}  ->  "
              f"{direct == reduced}")

    # ---- Mersenne / multiplicative order ------------------------------
    print("\n[8] Mersenne SDS  u(n) = 2^n - 1:  entry = multiplicative order")
    u2 = mersenne(2)
    print("    u(n)=2^n-1 is an SDS?  ->",
          is_strong_divisibility_sequence(u2, bound=14))
    for m in [5, 7, 35]:
        e = entry_point(u2, m)
        o = multiplicative_order(2, m)
        print(f"    entry(2^n-1, {m:>2}) = {e},  ord_{m}(2) = {o}  ->  {e == o}")
    print("    Corollary 8.1:  ord_35(2) = lcm(ord_5(2), ord_7(2))"
          f" = lcm(4,3) = {lcm(4,3)};  2^12 - 1 = {2**12 - 1} = 35 * {(2**12-1)//35}")

    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
