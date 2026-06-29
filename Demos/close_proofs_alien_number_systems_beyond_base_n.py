"""Alien Number Systems: Beyond Base-N.

A self-contained numerical demonstration of mixed-radix (variable-base) positional
number systems and their two classical specializations: uniform base-b and the
factorial number system (factoradic).

Every function mirrors a machine-checked Lean theorem:

* ``mval``                -> MixedRadix.mval            (Horner evaluation)
* ``mdigits``             -> MixedRadix.mdigits         (greedy extraction)
* ``capacity``            -> List.prod of bases
* ``mval_mdigits``        -> MixedRadix.mval_mdigits    (master reconstruction law)
* ``is_valid``            -> List.Forall2 (<)           (validity predicate)
* ``mval_lt_prod``        -> MixedRadix.mval_lt_prod    (telescoping value bound)
* ``mdigits_mval``        -> MixedRadix.mdigits_mval    (uniqueness of digits)
* factorial bases         -> MixedRadix.Factorial.bases / prod_bases
* ``factoradic_digit``    -> FactorialNumberSystem.digit
* ``factoradic_value``    -> FactorialNumberSystem.value

Run ``python demo.py`` to see all checks pass.
"""

from __future__ import annotations

from math import factorial, prod
from typing import List


# --------------------------------------------------------------------------- #
# Core mixed-radix operations                                                  #
# --------------------------------------------------------------------------- #
def mval(bases: List[int], digits: List[int]) -> int:
    """Horner evaluation d0 + b0*(d1 + b1*(d2 + ...)), least significant first.

    Mirrors ``MixedRadix.mval``.
    """
    acc = 0
    # Walk most-significant first so the running base product is built correctly.
    for i in reversed(range(len(digits))):
        b = bases[i] if i < len(bases) else 1
        acc = digits[i] + b * acc
    return acc


def mdigits(bases: List[int], n: int) -> List[int]:
    """Greedy digit extraction: (n % b0) :: mdigits(rest, n // b0).

    Mirrors ``MixedRadix.mdigits``.
    """
    out: List[int] = []
    for b in bases:
        out.append(n % b)
        n //= b
    return out


def capacity(bases: List[int]) -> int:
    """The capacity prod(bases) -- the number of representable residues."""
    return prod(bases)


def is_valid(bases: List[int], digits: List[int]) -> bool:
    """Validity: equal length and each digit strictly below its base.

    Mirrors ``List.Forall2 (.< .)``.
    """
    return len(bases) == len(digits) and all(d < b for d, b in zip(digits, bases))


# --------------------------------------------------------------------------- #
# Theorem witnesses                                                            #
# --------------------------------------------------------------------------- #
def check_master_law(bases: List[int], n: int) -> bool:
    """``mval(bases, mdigits(bases, n)) == n % capacity(bases)`` (Theorem 3.2)."""
    return mval(bases, mdigits(bases, n)) == n % capacity(bases)


def check_roundtrip_below_capacity(bases: List[int]) -> bool:
    """Every ``n < capacity`` round-trips exactly (Corollary 3.3)."""
    cap = capacity(bases)
    return all(mval(bases, mdigits(bases, n)) == n for n in range(cap))


def check_value_bound(bases: List[int], digits: List[int]) -> bool:
    """A valid digit list denotes a value below the capacity (Lemma 3.5)."""
    return mval(bases, digits) < capacity(bases) if is_valid(bases, digits) else True


def check_uniqueness(bases: List[int]) -> bool:
    """Distinct valid digit lists denote distinct values (Theorem 3.6).

    Verified by enumerating every valid digit list and confirming
    ``mdigits(bases, mval(bases, ds)) == ds``.
    """
    def all_valid(bs: List[int]) -> List[List[int]]:
        if not bs:
            return [[]]
        return [[d] + rest for d in range(bs[0]) for rest in all_valid(bs[1:])]

    return all(mdigits(bases, mval(bases, ds)) == ds for ds in all_valid(bases))


# --------------------------------------------------------------------------- #
# Specialization 1: uniform base-b                                            #
# --------------------------------------------------------------------------- #
def of_digits(b: int, digits: List[int]) -> int:
    """Standard base-b evaluation sum_i d_i * b**i (Mathlib's Nat.ofDigits)."""
    return sum(d * b**i for i, d in enumerate(digits))


def check_uniform_restriction(b: int, k: int, n: int) -> bool:
    """On uniform bases, ``mval`` restricts to ``of_digits`` (Theorem 4.2)."""
    bases = [b] * k
    ds = mdigits(bases, n)
    return mval(bases, ds) == of_digits(b, ds)


# --------------------------------------------------------------------------- #
# Specialization 2: factorial number system                                   #
# --------------------------------------------------------------------------- #
def factorial_bases(k: int) -> List[int]:
    """Bases [2, 3, ..., k+1] of the factoradic system (MixedRadix.Factorial.bases)."""
    return [i + 2 for i in range(k)]


def factoradic_digit(n: int, i: int) -> int:
    """Explicit i-th factoradic digit (n // i!) % (i+1) (FactorialNumberSystem.digit)."""
    return (n // factorial(i)) % (i + 1)


def factoradic_value(c: List[int]) -> int:
    """Factoradic value sum_i c_i * i! (FactorialNumberSystem.value)."""
    return sum(c_i * factorial(i) for i, c_i in enumerate(c))


def check_factorial_capacity(k: int) -> bool:
    """Capacity of factorial bases telescopes to (k+1)! (Lemma 4.4)."""
    return capacity(factorial_bases(k)) == factorial(k + 1)


# --------------------------------------------------------------------------- #
# Demonstration driver                                                         #
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 70)
    print("ALIEN NUMBER SYSTEMS: BEYOND BASE-N")
    print("=" * 70)

    # 1. Decimal as a mixed-radix instance.
    dec = [10, 10, 10]
    print("\n[1] Decimal (bases [10,10,10]) for 723:")
    print(f"    mdigits          = {mdigits(dec, 723)}   (least significant first)")
    print(f"    mval back        = {mval(dec, mdigits(dec, 723))}")

    # 2. Factorial system.
    fb = factorial_bases(4)  # bases [2,3,4,5], capacity 120 = 5!
    print(f"\n[2] Factorial (bases {fb}), capacity = {capacity(fb)} = 5!:")
    print(f"    100 -> factoradic {mdigits(fb, 100)}  (= 2*2! + 4*4! = {mval(fb, mdigits(fb, 100))})")
    fac100 = [factoradic_digit(100, i) for i in range(5)]
    print(f"    explicit factoradic digits of 100 (c_i <= i): {fac100}")
    print(f"    reconstruct: sum c_i*i! = {factoradic_value(fac100)}")

    # 3. A genuinely alien base.
    alien = [3, 5, 2, 7]
    print(f"\n[3] Alien bases {alien}, capacity = {capacity(alien)}:")
    print(f"    73 -> digits {mdigits(alien, 73)} -> back {mval(alien, mdigits(alien, 73))}")

    # 4. Theorem checks.
    print("\n[4] Theorem verifications:")
    print(f"    master law (alien, n=73)        : {check_master_law(alien, 73)}")
    print(f"    round-trip below capacity       : {check_roundtrip_below_capacity(alien)}")
    print(f"    uniqueness of digits (alien)    : {check_uniqueness(alien)}")
    print(f"    uniform restriction (b=10,k=3)  : {check_uniform_restriction(10, 3, 723)}")
    print(f"    factorial capacity = (k+1)!     : {all(check_factorial_capacity(k) for k in range(8))}")

    # 5. Permutation indexing via factoradic (Lehmer code).
    print("\n[5] Factoradic ranking of permutations of {0,1,2,3} (24 = 4!):")
    for rank in (0, 5, 17, 23):
        code = mdigits(factorial_bases(3), rank)  # 3 digits index 4! perms
        print(f"    rank {rank:2d} -> factoradic {code}")

    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
