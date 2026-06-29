"""
Numerical demonstration of arithmetic and global tameness of the Mukai maximal
symplectic groups on the superspecial K3 surface in characteristic p > 11.

This script is fully self-contained (standard library only) and exercises the
main theorems of the package:

  * mukaiOrder_dvd_lcm                 -- every Mukai order divides 40320
  * mukaiOrder_prime_factor_le_seven   -- every prime factor of a Mukai order is <= 7
  * mukaiOrder_tame                    -- for prime p > 11, p does not divide any Mukai order
  * mukaiOrder_coprime                 -- equivalently, gcd(p, N) = 1
  * aut_order_not_dvd_char             -- global tameness: p does not divide #G = #G_s * [G:G_s]

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd
from functools import reduce
from typing import Dict, List, Tuple

# ---------------------------------------------------------------------------
# Definition 1 (mukaiOrders): the orders of the 11 Mukai maximal symplectic groups.
# Listed with multiplicity (192 and 72 each occur twice), matching the Lean list.
# ---------------------------------------------------------------------------
MUKAI_NAMES: List[str] = [
    "M20", "F384", "A4,4", "T192", "H192", "N72", "M9", "T48", "L2(7)", "A6", "S5",
]
MUKAI_ORDERS: List[int] = [960, 384, 288, 192, 192, 72, 72, 48, 168, 360, 120]

# Definition 2 (mukaiLcm): 40320 = 2^7 * 3^2 * 5 * 7.
MUKAI_LCM: int = 40320


# ---------------------------------------------------------------------------
# Elementary number theory helpers (all inlined).
# ---------------------------------------------------------------------------
def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def prime_factorization(n: int) -> Dict[int, int]:
    """Return the prime-power factorization of n as {prime: exponent}."""
    factors: Dict[int, int] = {}
    m = n
    d = 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def lcm_list(values: List[int]) -> int:
    """Least common multiple of a list of positive integers."""
    return reduce(lambda a, b: a * b // gcd(a, b), values, 1)


# ---------------------------------------------------------------------------
# Theorem checks.
# ---------------------------------------------------------------------------
def check_lcm_definition() -> int:
    """Verify mukaiLcm = lcm(mukaiOrders) = 40320 = 2^7 * 3^2 * 5 * 7."""
    computed = lcm_list(MUKAI_ORDERS)
    assert computed == MUKAI_LCM, f"lcm mismatch: {computed} != {MUKAI_LCM}"
    assert prime_factorization(MUKAI_LCM) == {2: 7, 3: 2, 5: 1, 7: 1}
    return computed


def check_dvd_lcm() -> List[Tuple[str, int, int]]:
    """mukaiOrder_dvd_lcm: every Mukai order divides 40320. Returns (name, N, 40320/N)."""
    rows: List[Tuple[str, int, int]] = []
    for name, N in zip(MUKAI_NAMES, MUKAI_ORDERS):
        assert MUKAI_LCM % N == 0, f"{N} does not divide {MUKAI_LCM}"
        rows.append((name, N, MUKAI_LCM // N))
    return rows


def check_prime_factor_le_seven() -> int:
    """mukaiOrder_prime_factor_le_seven: every prime factor of every order is <= 7."""
    max_prime = 0
    for N in MUKAI_ORDERS:
        for q in prime_factorization(N):
            assert q <= 7, f"prime factor {q} of {N} exceeds 7"
            max_prime = max(max_prime, q)
    return max_prime


def is_tame_symplectic(p: int) -> bool:
    """mukaiOrder_tame (numerical): for prime p > 11, p divides no Mukai order."""
    assert is_prime(p) and p > 11
    return all(N % p != 0 for N in MUKAI_ORDERS)


def aut_order_is_tame(p: int, symplectic_order: int, nonsymplectic_index: int) -> bool:
    """
    aut_order_not_dvd_char (numerical model): for prime p > 11, a Mukai symplectic
    order #G_s, and a non-symplectic index n = [G:G_s] coprime to p,
    the full order #G = #G_s * n is not divisible by p.
    """
    assert is_prime(p) and p > 11
    assert symplectic_order in MUKAI_ORDERS
    assert gcd(p, nonsymplectic_index) == 1  # tameness of the non-symplectic index
    full_order = symplectic_order * nonsymplectic_index
    return full_order % p != 0


# ---------------------------------------------------------------------------
# Main demonstration.
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 72)
    print("Tameness of the Mukai maximal symplectic groups (characteristic p > 11)")
    print("=" * 72)

    print("\n[Definition] mukaiOrders =", MUKAI_ORDERS)
    lcm = check_lcm_definition()
    print(f"[Definition] mukaiLcm = lcm(mukaiOrders) = {lcm} = 2^7 * 3^2 * 5 * 7")

    print("\n[Theorem mukaiOrder_dvd_lcm] every order divides 40320:")
    for name, N, q in check_dvd_lcm():
        print(f"    {name:<7} order {N:>4}  |  40320 = {N} * {q}")

    max_prime = check_prime_factor_le_seven()
    print(f"\n[Theorem mukaiOrder_prime_factor_le_seven] largest prime factor = {max_prime} (<= 7) OK")

    print("\n[Theorem mukaiOrder_tame / mukaiOrder_coprime] primes p > 11:")
    for p in [13, 17, 19, 23, 29, 31, 101, 9973]:
        tame = is_tame_symplectic(p)
        coprimes = all(gcd(p, N) == 1 for N in MUKAI_ORDERS)
        print(f"    p = {p:<5}  p divides no Mukai order: {tame}   all coprime: {coprimes}")

    print("\n[Boundary] arithmetic threshold is p > 7, not p >= 7:")
    for N in MUKAI_ORDERS:
        if N % 7 == 0:
            print(f"    7 divides {N}  -> p = 7 is NOT tame for this order")

    print("\n[Theorem aut_order_not_dvd_char] global tameness #G = #G_s * [G:G_s]:")
    scenarios = [
        (13, 960, 5),    # M20 with a C5 non-symplectic extension
        (17, 168, 3),    # L2(7) with a C3 extension
        (19, 360, 4),    # A6 with a C4 extension
        (23, 120, 6),    # S5 with a C6 extension
        (13, 384, 1),    # F384 with trivial extension (the conjectured maximal case)
    ]
    for p, gs, n in scenarios:
        ok = aut_order_is_tame(p, gs, n)
        print(f"    p={p:<3} #G_s={gs:<4} [G:G_s]={n}  ->  #G={gs * n:<5} "
              f"p divides #G: {(gs * n) % p == 0}  (tame: {ok})")

    print("\nAll theorem checks passed.")


if __name__ == "__main__":
    main()
