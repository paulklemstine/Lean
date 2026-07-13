"""Numerical demonstrations for mixed-radix number systems and the
factorial (factoradic) number system as a special case.

The theory: fix a sequence of bases b_0, b_1, b_2, ...  The place value of
position i is the running product P_i = b_0 * b_1 * ... * b_{i-1} (with P_0 = 1).
A digit string c_0, c_1, ..., c_{k-1} has value

    value(b, c, k) = sum_{i < k} c_i * P_i,

and is valid when 0 <= c_i < b_i for every i.  Two special cases:

    * base N        : b_i = N        =>  P_i = N^i,   digit rule  c_i < N
    * factorial     : b_i = i + 1    =>  P_i = i!,    digit rule  c_i <= i

Main facts demonstrated here:
    - value agreement:   the b_i = i+1 mixed-radix value equals the factoradic value
    - validity agreement:  c_i < i+1  <=>  c_i <= i
    - uniqueness:        distinct valid strings have distinct values (a bijection)
    - existence:         every n < P_k is the value of its extracted digits
    - application:       ranking / unranking permutations via the Lehmer code
"""

from __future__ import annotations

from itertools import permutations
from math import factorial
from typing import Callable, List


# --------------------------------------------------------------------------
# Core mixed-radix primitives
# --------------------------------------------------------------------------

def radix_prod(b: Callable[[int], int], k: int) -> int:
    """Running product P_k = b_0 * b_1 * ... * b_{k-1} (P_0 = 1)."""
    p = 1
    for i in range(k):
        p *= b(i)
    return p


def value(b: Callable[[int], int], c: List[int], k: int) -> int:
    """Mixed-radix value sum_{i<k} c_i * P_i."""
    total = 0
    p = 1
    for i in range(k):
        total += c[i] * p
        p *= b(i)
    return total


def is_valid(b: Callable[[int], int], c: List[int], k: int) -> bool:
    """Validity: 0 <= c_i < b_i for all i < k."""
    return all(0 <= c[i] < b(i) for i in range(k))


def extract_digits(b: Callable[[int], int], n: int, k: int) -> List[int]:
    """digit(b, n, i) = floor(n / P_i) mod b_i, for i < k."""
    digits: List[int] = []
    p = 1
    for i in range(k):
        digits.append((n // p) % b(i))
        p *= b(i)
    return digits


# --------------------------------------------------------------------------
# Named base sequences
# --------------------------------------------------------------------------

def factorial_base(i: int) -> int:
    """b_i = i + 1 gives the factorial number system (P_i = i!)."""
    return i + 1


def const_base(N: int) -> Callable[[int], int]:
    """b_i = N gives ordinary base N (P_i = N^i)."""
    return lambda _i: N


def factoradic_value(c: List[int], k: int) -> int:
    """Direct factoradic value sum_{i<k} c_i * i! (the special-case formula)."""
    return sum(c[i] * factorial(i) for i in range(k))


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_place_values(k: int = 8) -> None:
    print("== Place values: factorial bases b_i = i+1 give P_i = i! ==")
    for i in range(k):
        p = radix_prod(factorial_base, i)
        assert p == factorial(i)
        print(f"  P_{i} = prod_(j<{i}) (j+1) = {p} = {i}!")
    print()


def demo_value_and_validity_agreement(k: int = 6) -> None:
    print("== Value & validity agreement (factorial system = mixed radix b_i=i+1) ==")
    c = [0, 1, 2, 1, 3, 0]  # valid factoradic: c_i <= i
    mr = value(factorial_base, c, k)
    fa = factoradic_value(c, k)
    assert mr == fa
    print(f"  digits c        = {c[:k]}")
    print(f"  mixed-radix val = {mr}")
    print(f"  factoradic val  = {fa}  (agree: {mr == fa})")
    # validity agreement: c_i < i+1  <=>  c_i <= i
    for i in range(k):
        assert (c[i] < factorial_base(i)) == (c[i] <= i)
    print("  validity agreement c_i < i+1 <=> c_i <= i:  verified for all positions")
    print()


def demo_bijection(k: int = 4) -> None:
    """Uniqueness + existence: value() is a bijection onto {0,...,k!-1}."""
    print(f"== Perfect dictionary: factoradic length {k} <-> 0..{factorial(k)-1} ==")
    seen = {}
    for n in range(factorial(k)):
        c = extract_digits(factorial_base, n, k)
        assert is_valid(factorial_base, c, k)
        v = value(factorial_base, c, k)
        assert v == n, "existence: decode(encode(n)) == n"
        key = tuple(c)
        assert key not in seen, "uniqueness: no two n share a digit string"
        seen[key] = n
    assert len(seen) == factorial(k)
    print(f"  all {factorial(k)} numbers encode to distinct valid strings and decode back")
    # show a few
    for n in [0, 1, 5, 17, 23]:
        if n < factorial(k):
            c = extract_digits(factorial_base, n, k)
            print(f"  {n:2d} -> factoradic digits {c}  (value back = {value(factorial_base, c, k)})")
    print()


def demo_base_n(N: int = 10, k: int = 4) -> None:
    print(f"== Base {N} as the same theory (b_i = {N}, P_i = {N}^i) ==")
    b = const_base(N)
    for i in range(k):
        assert radix_prod(b, i) == N ** i
    n = 2025
    c = extract_digits(b, n, k)
    assert value(b, c, k) == n
    # digits come out least-significant first
    print(f"  {n} in base {N}: digits (LSB first) = {c}, reversed = {c[::-1]}")
    print()


# --------------------------------------------------------------------------
# Application: ranking / unranking permutations via the Lehmer code
# --------------------------------------------------------------------------

def lehmer_code(perm: List[int]) -> List[int]:
    """L_i = #{ j > i : perm[j] < perm[i] }, a valid factoradic digit string
    (with digits listed most-significant first)."""
    k = len(perm)
    return [sum(1 for j in range(i + 1, k) if perm[j] < perm[i]) for i in range(k)]


def rank_permutation(perm: List[int]) -> int:
    """Lexicographic rank of a permutation of {0,...,k-1} via factoradic value.
    The Lehmer code is MSB-first; the factoradic value uses place value (k-1-p)!."""
    k = len(perm)
    code = lehmer_code(perm)
    return sum(code[p] * factorial(k - 1 - p) for p in range(k))


def unrank_permutation(r: int, k: int) -> List[int]:
    """Inverse of rank_permutation: the r-th permutation of {0,...,k-1}."""
    # recover Lehmer code (MSB-first) by successive division
    code: List[int] = []
    for p in range(k):
        f = factorial(k - 1 - p)
        code.append(r // f)
        r %= f
    # rebuild permutation from the Lehmer code
    available = list(range(k))
    perm: List[int] = []
    for d in code:
        perm.append(available.pop(d))
    return perm


def demo_permutations(k: int = 4) -> None:
    print(f"== Ranking / unranking all {factorial(k)} permutations of 0..{k-1} ==")
    for r, perm in enumerate(permutations(range(k))):
        perm = list(perm)
        assert rank_permutation(perm) == r, "rank matches lexicographic order"
        assert unrank_permutation(r, k) == perm, "unrank inverts rank"
    print(f"  verified rank/unrank round-trip and lexicographic ordering for all {factorial(k)}")
    # spotlight
    r = 13
    perm = unrank_permutation(r, k)
    print(f"  the {r}-th permutation of 0..{k-1} is {perm} with Lehmer code {lehmer_code(perm)}")
    print()


def main() -> None:
    demo_place_values()
    demo_value_and_validity_agreement()
    demo_bijection()
    demo_base_n()
    demo_permutations()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
