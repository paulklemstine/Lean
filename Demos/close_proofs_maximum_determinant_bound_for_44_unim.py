"""Numerical demonstrations for the unified theory of positional number systems.

This self-contained script illustrates the main results of the accompanying
paper:

  * mixed-radix value and validity for an arbitrary sequence of bases,
  * the digit-bound estimate  value < running_product,
  * the Euclidean splitting identities (divide -> top digit, mod -> tail),
  * uniqueness and existence of valid representations,
  * the factorial number system as the mixed-radix instance b(i) = i + 1,
  * base-N numerals as the instance b(i) = N,
  * the Lehmer-code bijection between integers and permutations.

Every function is inlined and uses only the Python standard library.
"""

from __future__ import annotations

from itertools import permutations
from math import factorial
from typing import Callable, List


# --------------------------------------------------------------------------- #
# Core mixed-radix machinery
# --------------------------------------------------------------------------- #
def running_product(b: Callable[[int], int], k: int) -> int:
    """Place value P_b(k) = product of b(0..k-1);  P_b(0) = 1."""
    prod = 1
    for i in range(k):
        prod *= b(i)
    return prod


def value(b: Callable[[int], int], c: List[int], k: int) -> int:
    """Length-k mixed-radix value  sum_{i<k} c[i] * P_b(i)."""
    return sum(c[i] * running_product(b, i) for i in range(k))


def is_valid(b: Callable[[int], int], c: List[int], k: int) -> bool:
    """Validity: every digit is strictly below its local base, 0 <= c[i] < b(i)."""
    return all(0 <= c[i] < b(i) for i in range(k))


def extract_digits(b: Callable[[int], int], n: int, k: int) -> List[int]:
    """Greedy digit extraction  digit(i) = (n // P_b(i)) mod b(i)."""
    return [(n // running_product(b, i)) % b(i) for i in range(k)]


# --------------------------------------------------------------------------- #
# Concrete base sequences
# --------------------------------------------------------------------------- #
def factorial_base(i: int) -> int:
    """Factorial number system: base of column i is i + 1."""
    return i + 1


def constant_base(n: int) -> Callable[[int], int]:
    """Ordinary base-n numerals: every column has base n."""
    return lambda _i: n


# --------------------------------------------------------------------------- #
# Lehmer code: factoradic <-> permutation
# --------------------------------------------------------------------------- #
def unrank_permutation(n: int, k: int) -> List[int]:
    """Map n in {0,...,k!-1} to a permutation of {0,...,k-1} via its Lehmer code.

    The factoradic digit c[i] (place value i!) counts how many still-unused
    symbols are skipped at step (k-1-i).
    """
    digits = extract_digits(factorial_base, n, k)  # digits[i] has place value i!
    lehmer = list(reversed(digits))                # most significant first
    pool = list(range(k))
    perm: List[int] = []
    for d in lehmer:
        perm.append(pool.pop(d))
    return perm


def rank_permutation(perm: List[int]) -> int:
    """Inverse of unrank_permutation: permutation -> integer index."""
    k = len(perm)
    pool = list(range(k))
    n = 0
    for idx, symbol in enumerate(perm):
        pos = pool.index(symbol)
        n += pos * factorial(k - 1 - idx)
        pool.pop(pos)
    return n


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_factorial_is_mixed_radix(k: int = 6) -> None:
    print("=" * 70)
    print("1. The factorial system IS the mixed-radix system with b(i) = i+1")
    print("=" * 70)
    for i in range(k):
        pv = running_product(factorial_base, i)
        print(f"  place value of column {i}: running product = {pv:4d}   i! = {factorial(i):4d}")
    assert all(running_product(factorial_base, i) == factorial(i) for i in range(k))
    print("  -> running product of (i+1) equals i!  (verified).\n")


def demo_bound_and_splitting(k: int = 5) -> None:
    print("=" * 70)
    print("2. Digit-bound estimate and Euclidean splitting identities")
    print("=" * 70)
    c = [0, 1, 2, 3, 4]  # a valid factoradic string (c[i] <= i)
    assert is_valid(factorial_base, c, k)
    v = value(factorial_base, c, k)
    Pk = running_product(factorial_base, k)
    print(f"  digits {c}  ->  value = {v},   k! = {Pk}")
    print(f"  digit bound:  value < k!  ?  {v} < {Pk}  ->  {v < Pk}")
    Pkm1 = running_product(factorial_base, k - 1)
    print(f"  split by division:  value // (k-1)! = {v // Pkm1}  (top digit c[k-1] = {c[k-1]})")
    print(f"  split by remainder: value %% (k-1)! = {v % Pkm1}  (tail value = {value(factorial_base, c, k - 1)})")
    print()


def demo_bijection(k: int = 4) -> None:
    print("=" * 70)
    print(f"3. Bijection: valid factoradic strings <-> {{0, ..., {k}!-1}}")
    print("=" * 70)
    seen = {}
    for n in range(factorial(k)):
        d = extract_digits(factorial_base, n, k)
        assert is_valid(factorial_base, d, k)          # existence of a valid string
        assert value(factorial_base, d, k) == n         # it reconstructs n
        key = tuple(d)
        assert key not in seen                          # uniqueness
        seen[key] = n
    print(f"  all {factorial(k)} integers 0..{factorial(k)-1} have a unique valid string.")
    for n in range(min(6, factorial(k))):
        print(f"    {n:2d}  ->  digits {extract_digits(factorial_base, n, k)}")
    print()


def demo_base_n(n: int = 2, k: int = 5) -> None:
    print("=" * 70)
    print(f"4. Base-{n} numerals as the mixed-radix instance b(i) = {n}")
    print("=" * 70)
    b = constant_base(n)
    for m in range(6):
        d = extract_digits(b, m, k)
        assert value(b, d, k) == m
        print(f"    {m:2d}  ->  digits {d}   (little-endian base {n})")
    assert running_product(b, k) == n ** k
    print(f"  running product = {n}^{k} = {n ** k}  (verified).\n")


def demo_lehmer(k: int = 4) -> None:
    print("=" * 70)
    print("5. Lehmer code: counting in factoradic enumerates permutations")
    print("=" * 70)
    lex = sorted(permutations(range(k)))
    for n in range(factorial(k)):
        perm = unrank_permutation(n, k)
        assert tuple(perm) == lex[n]                    # lexicographic order
        assert rank_permutation(perm) == n              # round-trip
    print(f"  unranking 0..{factorial(k)-1} reproduces all {factorial(k)} permutations in lex order.")
    big = 23
    print(f"    permutation #{big} of {k} symbols = {unrank_permutation(big, k)}")
    print()


def main() -> None:
    demo_factorial_is_mixed_radix()
    demo_bound_and_splitting()
    demo_bijection()
    demo_base_n()
    demo_lehmer()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
