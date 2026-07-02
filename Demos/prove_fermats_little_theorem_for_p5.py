"""
Numerical demonstrations for the congruence  a^5 - a  ==  0  (mod 5),
the case p = 5 of Fermat's Little Theorem, together with its
field-theoretic, elementary, and combinatorial (necklace) proofs.

Every function is self-contained and type-hinted. Run directly:

    python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Iterable, List, Tuple


# ---------------------------------------------------------------------------
# 1. Direct verification that 5 | a^5 - a
# ---------------------------------------------------------------------------
def five_divides_pow_five_sub_self(a: int) -> bool:
    """Return True iff 5 divides a**5 - a."""
    return (a ** 5 - a) % 5 == 0


def demo_direct(lo: int = -10, hi: int = 10) -> None:
    """Check 5 | a^5 - a for a range of integers and print the quotient."""
    print("== Direct check: 5 | a^5 - a ==")
    for a in range(lo, hi + 1):
        value = a ** 5 - a
        assert five_divides_pow_five_sub_self(a)
        print(f"  a={a:>3}:  a^5 - a = {value:>8}  = 5 * {value // 5}")
    print()


# ---------------------------------------------------------------------------
# 2. Field-theoretic proof: fifth powering is the identity on Z/5Z
# ---------------------------------------------------------------------------
def frobenius_table(p: int) -> List[Tuple[int, int]]:
    """Return the list of pairs (x, x^p mod p) for x in Z/pZ."""
    return [(x, pow(x, p, p)) for x in range(p)]


def demo_frobenius(p: int = 5) -> None:
    """Show that x -> x^p is the identity map on Z/pZ (p prime)."""
    print(f"== Frobenius map x -> x^{p} on Z/{p}Z is the identity ==")
    table = frobenius_table(p)
    for x, xp in table:
        print(f"  {x}^{p} mod {p} = {xp}   (identity: {x == xp})")
    assert all(x == xp for x, xp in table)
    print("  => fifth powering fixes every residue.\n")


# ---------------------------------------------------------------------------
# 3. Elementary proof: factorization + residue witness
# ---------------------------------------------------------------------------
def residue_witness(a: int) -> Tuple[str, int]:
    """
    Using  a^5 - a = (a-1) * a * (a+1) * (a^2 + 1),
    return the name of a factor divisible by 5 and its value.
    """
    r = a % 5
    if r == 0:
        return ("a", a)
    if r == 1:
        return ("a - 1", a - 1)
    if r == 4:
        return ("a + 1", a + 1)
    # r in {2, 3}:  a^2 + 1 == 0 (mod 5)
    return ("a^2 + 1", a * a + 1)


def demo_factorization(lo: int = 0, hi: int = 12) -> None:
    """Verify the factorization and exhibit the divisible-by-5 factor."""
    print("== Elementary proof via factorization ==")
    for a in range(lo, hi + 1):
        lhs = a ** 5 - a
        rhs = (a - 1) * a * (a + 1) * (a * a + 1)
        assert lhs == rhs
        name, val = residue_witness(a)
        assert val % 5 == 0
        print(f"  a={a:>2}:  factor '{name}' = {val:>4} is divisible by 5")
    print()


# ---------------------------------------------------------------------------
# 4. Combinatorial / probabilistic proof: aperiodic necklaces
# ---------------------------------------------------------------------------
def rotations(s: Tuple[int, ...]) -> Iterable[Tuple[int, ...]]:
    """Yield all cyclic rotations of the tuple s."""
    n = len(s)
    for k in range(n):
        yield s[k:] + s[:k]


def aperiodic_necklace_count_bruteforce(alphabet: int, length: int) -> int:
    """Count aperiodic necklaces of given length over an alphabet by orbits."""
    seen: set = set()
    count = 0
    for s in product(range(alphabet), repeat=length):
        if s in seen:
            continue
        orbit = set(rotations(s))
        # aperiodic <=> orbit has full size == length (prime length, non-constant)
        if len(orbit) == length:
            count += 1
        seen |= orbit
    return count


def demo_necklaces(p: int = 5, max_alphabet: int = 4) -> None:
    """
    Show  a^p - a = p * (number of aperiodic necklaces)  for prime p.
    """
    print(f"== Necklace proof: a^{p} - a = {p} * (aperiodic necklaces) ==")
    for a in range(1, max_alphabet + 1):
        closed = (a ** p - a) // p
        brute = aperiodic_necklace_count_bruteforce(a, p)
        assert (a ** p - a) % p == 0
        assert closed == brute
        print(f"  alphabet a={a}:  (a^{p}-a)/{p} = {closed}  "
              f"= brute-force count {brute}")
    print()


# ---------------------------------------------------------------------------
# 5. General Fermat's Little Theorem for several primes
# ---------------------------------------------------------------------------
def demo_general_flt(primes: Tuple[int, ...] = (2, 3, 5, 7, 11)) -> None:
    """Verify p | a^p - a for several primes and integers."""
    print("== General Fermat's Little Theorem: p | a^p - a ==")
    for p in primes:
        ok = all((a ** p - a) % p == 0 for a in range(-6, 7))
        print(f"  p={p:>2}:  holds for all tested a  -> {ok}")
        assert ok
    print()


if __name__ == "__main__":
    demo_direct()
    demo_frobenius()
    demo_factorization()
    demo_necklaces()
    demo_general_flt()
    print("All demonstrations passed.")
