"""
Domain Finiteness Bridge --- numerical demonstrations.

Every finite integral domain is a field. This module makes the abstract
theorem concrete over Z/pZ (and detects the failure for composite moduli),
and exhibits the downstream consequences:

  * inverse via the "pigeonhole shuffle" (orbit of left multiplication),
  * Fermat-type identity  a^(q-1) = 1,
  * cyclicity of the unit group (primitive roots),
  * Wilson's theorem  (p-1)! = -1  (mod p).

Pure standard library; type hints throughout; all helpers inlined.

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd
from typing import Optional


# --------------------------------------------------------------------------
# Core bridge over Z/nZ
# --------------------------------------------------------------------------

def left_mul_map(a: int, n: int) -> list[int]:
    """The self-map L_a(x) = a*x (mod n) tabulated over {0,...,n-1}."""
    return [(a * x) % n for x in range(n)]


def is_injective_self_map(table: list[int]) -> bool:
    """A self-map is injective iff its value list has no repeats."""
    return len(set(table)) == len(table)


def is_surjective_self_map(table: list[int]) -> bool:
    """A self-map of {0,...,n-1} is surjective iff it hits every value."""
    return set(table) == set(range(len(table)))


def inverse_by_shuffle(a: int, n: int) -> Optional[int]:
    """
    Constructive inverse of Theorem `exists_inverse`: b = L_a^{-1}(1).

    Returns the unique b with a*b = 1 (mod n) by scanning the orbit of
    left multiplication, or None if a has no inverse (i.e. a is a zero
    divisor / not coprime to n). For a *prime* n and a != 0, the bridge
    guarantees a non-None result.
    """
    table = left_mul_map(a, n)
    for x in range(n):
        if table[x] == 1 % n:
            return x
    return None


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


# --------------------------------------------------------------------------
# Consequences
# --------------------------------------------------------------------------

def fermat_exponent_identity(p: int) -> bool:
    """Verify a^(p-1) = 1 (mod p) for every nonzero a  (Fermat / Thm 7.1)."""
    return all(pow(a, p - 1, p) == 1 for a in range(1, p))


def multiplicative_order(a: int, n: int) -> int:
    """Smallest k>=1 with a^k = 1 (mod n); assumes gcd(a,n)=1."""
    k, cur = 1, a % n
    while cur != 1:
        cur = (cur * a) % n
        k += 1
    return k


def find_primitive_root(p: int) -> Optional[int]:
    """
    A generator of (Z/pZ)^x, guaranteed to exist by `units_isCyclic`.
    Found as the smallest g whose multiplicative order equals p-1.
    """
    for g in range(2, p):
        if multiplicative_order(g, p) == p - 1:
            return g
    return None


def wilson_residue(p: int) -> int:
    """(p-1)! reduced mod p.  Wilson's theorem predicts p-1 (= -1)."""
    acc = 1
    for a in range(1, p):
        acc = (acc * a) % p
    return acc


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_bijection(primes: list[int], composites: list[int]) -> None:
    print("=" * 68)
    print("1. Left multiplication L_a(x)=a*x is a bijection over Z/pZ")
    print("=" * 68)
    for p in primes:
        ok = all(
            is_injective_self_map(left_mul_map(a, p))
            and is_surjective_self_map(left_mul_map(a, p))
            for a in range(1, p)
        )
        print(f"  p = {p:>3} (prime)     : every L_a (a!=0) bijective -> {ok}")
    for n in composites:
        # find a witness zero divisor where injectivity fails
        bad = [a for a in range(1, n)
               if not is_injective_self_map(left_mul_map(a, n))]
        print(f"  n = {n:>3} (composite) : L_a fails to be injective for a in {bad}")
    print()


def demo_inverses(p: int) -> None:
    print("=" * 68)
    print(f"2. Constructive inverses in the field Z/{p}Z  (b = L_a^-1(1))")
    print("=" * 68)
    for a in range(1, p):
        b = inverse_by_shuffle(a, p)
        check = (a * b) % p if b is not None else None
        print(f"  {a}^-1 = {b}   (check a*b mod p = {check})")
    print()


def demo_fermat(primes: list[int]) -> None:
    print("=" * 68)
    print("3. Fermat-type identity  a^(q-1) = 1  (Thm pow_card_sub_one_eq_one)")
    print("=" * 68)
    for p in primes:
        print(f"  p = {p:>3}: a^(p-1)=1 for all nonzero a -> {fermat_exponent_identity(p)}")
    # one explicit trace
    p, a = 7, 3
    print(f"  trace: {a}^{p-1} mod {p} = {pow(a, p-1, p)}")
    print()


def demo_primitive_roots(primes: list[int]) -> None:
    print("=" * 68)
    print("4. Cyclic unit group: primitive roots (Thm units_isCyclic)")
    print("=" * 68)
    for p in primes:
        g = find_primitive_root(p)
        if g is not None:
            powers = []
            cur = 1
            for _ in range(p - 1):
                cur = (cur * g) % p
                powers.append(cur)
            print(f"  p = {p:>3}: generator g = {g}, powers enumerate {sorted(powers)}")
    print()


def demo_wilson(primes: list[int], composites: list[int]) -> None:
    print("=" * 68)
    print("5. Wilson's theorem  (p-1)! = -1 (mod p)   (Thm wilson)")
    print("=" * 68)
    for p in primes:
        r = wilson_residue(p)
        print(f"  p = {p:>3} (prime)     : (p-1)! mod p = {r}  (= p-1 = {p-1})  ok={r == p-1}")
    for n in composites:
        r = wilson_residue(n)
        print(f"  n = {n:>3} (composite) : (n-1)! mod n = {r}  (not p-1)")
    print()


def main() -> None:
    primes = [p for p in range(2, 20) if is_prime(p)]
    composites = [4, 6, 8, 9, 10, 12]

    demo_bijection(primes, composites)
    demo_inverses(7)
    demo_fermat(primes)
    demo_primitive_roots(primes)
    demo_wilson(primes, composites)

    print("All demonstrations consistent with the Domain Finiteness Bridge.")


if __name__ == "__main__":
    main()
