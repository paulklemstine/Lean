"""
Numerical demonstrations for the theory of mixed-radix positional number systems.

A mixed-radix system is fixed by a sequence of positive bases b_0, b_1, b_2, ....
The place value of position i is the running product P_i = b_0 * b_1 * ... * b_{i-1}
(with P_0 = 1). A digit c_i is valid when 0 <= c_i < b_i, and a length-k numeral
(c_0, ..., c_{k-1}) represents the integer sum_{i<k} c_i * P_i.

Special cases:
    * base-N   : b_i = N          => P_i = N^i
    * factorial: b_i = i + 1      => P_i = i!

This file demonstrates the two structural theorems:
    * Uniqueness : distinct valid numerals have distinct values.
    * Existence  : every 0 <= n < P_k is represented (greedy extraction).
Together they give the counting bijection  valid length-k numerals  <->  [0, P_k).

All functions are self-contained with type hints.
"""

from __future__ import annotations

from itertools import product
from math import factorial, prod
from typing import Callable, Iterator


# --------------------------------------------------------------------------- #
#  Core mixed-radix primitives
# --------------------------------------------------------------------------- #

def radix_prod(bases: Callable[[int], int], k: int) -> int:
    """Running product P_k = prod_{i<k} bases(i).  P_0 = 1 (empty product)."""
    return prod(bases(i) for i in range(k))


def value(bases: Callable[[int], int], digits: list[int]) -> int:
    """Value sum_{i<k} digits[i] * P_i of a length-k numeral (index 0 = least significant)."""
    total = 0
    running = 1  # running holds P_i
    for i, c in enumerate(digits):
        total += c * running
        running *= bases(i)
    return total


def is_valid(bases: Callable[[int], int], digits: list[int]) -> bool:
    """A numeral is valid iff 0 <= digits[i] < bases(i) for every position i."""
    return all(0 <= c < bases(i) for i, c in enumerate(digits))


def extract_digits(bases: Callable[[int], int], n: int, k: int) -> list[int]:
    """Greedy digit extraction: c_i = (n // P_i) % bases(i).

    Uses the streaming quotient formulation to avoid materializing P_i.
    Returns a length-k list of valid digits representing  n mod P_k.
    """
    digits: list[int] = []
    q = n
    for i in range(k):
        b = bases(i)
        digits.append(q % b)
        q //= b
    return digits


# --------------------------------------------------------------------------- #
#  Convenient base sequences
# --------------------------------------------------------------------------- #

def base_n(n: int) -> Callable[[int], int]:
    """Constant base sequence for ordinary base-n notation:  b_i = n."""
    return lambda _i: n


def factorial_bases(i: int) -> int:
    """Factorial (factoradic) base sequence:  b_i = i + 1, giving P_i = i!."""
    return i + 1


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #

def demo_place_values() -> None:
    """Show that base-N running products are N^k and factorial ones are k!."""
    print("=" * 68)
    print("Running products P_k = prod_{i<k} b_i")
    print("=" * 68)
    for k in range(6):
        bn = radix_prod(base_n(10), k)
        fk = radix_prod(factorial_bases, k)
        print(f"  k={k}:  base-10 P_k = {bn:>7} = 10^{k:<2}   "
              f"factorial P_k = {fk:>4} = {k}!  (check {k}! = {factorial(k)})")
        assert bn == 10 ** k
        assert fk == factorial(k)
    print()


def demo_factoradic_examples() -> None:
    """Encode a few integers in the factorial number system and read them back."""
    print("=" * 68)
    print("Factorial number system: n <-> factoradic digits (most significant first)")
    print("=" * 68)
    k = 5  # covers 0 .. 5! - 1 = 0 .. 119
    for n in [0, 4, 23, 100, 119]:
        digits = extract_digits(factorial_bases, n, k)          # least significant first
        assert is_valid(factorial_bases, digits)
        assert value(factorial_bases, digits) == n
        pretty = "".join(str(d) for d in reversed(digits))
        print(f"  {n:>4}  =  factoradic {pretty}   "
              f"(digits low->high {digits})")
    print()


def demo_counting_bijection(bases: Callable[[int], int], k: int, label: str) -> None:
    """Verify the bijection: valid length-k numerals <-> the interval [0, P_k)."""
    print("=" * 68)
    print(f"Counting bijection for {label}, length k={k}")
    print("=" * 68)
    Pk = radix_prod(bases, k)
    seen: dict[int, tuple[int, ...]] = {}
    ranges = [range(bases(i)) for i in range(k)]
    # product() iterates most-significant first; reverse each tuple to low->high.
    for combo in product(*reversed(ranges)):
        digits = list(reversed(combo))
        assert is_valid(bases, digits)
        v = value(bases, digits)
        assert 0 <= v < Pk, f"value {v} left interval [0,{Pk})"
        assert v not in seen, f"collision at value {v} (uniqueness violated!)"
        seen[v] = tuple(digits)
    # Existence: every target integer is hit.
    assert set(seen.keys()) == set(range(Pk))
    # Round-trip through greedy extraction.
    for n in range(Pk):
        assert value(bases, extract_digits(bases, n, k)) == n
    print(f"  P_k = {Pk}: all {Pk} valid numerals map bijectively onto [0, {Pk}).")
    print(f"  Uniqueness OK (no collisions) and Existence OK (interval fully covered).")
    print()


def demo_successor_carry(bases: Callable[[int], int], k: int, label: str) -> None:
    """Increment-by-one via base-independent carry propagation matches value + 1."""
    print("=" * 68)
    print(f"Successor / carry propagation for {label}, length k={k}")
    print("=" * 68)
    Pk = radix_prod(bases, k)

    def successor(digits: list[int]) -> list[int]:
        out = digits[:]
        i = 0
        carry = 1
        while carry and i < len(out):
            out[i] += carry
            if out[i] >= bases(i):   # carry fires exactly at the local base
                out[i] = 0
                carry = 1
            else:
                carry = 0
            i += 1
        return out

    for n in range(Pk - 1):
        d = extract_digits(bases, n, k)
        s = successor(d)
        assert value(bases, s) == n + 1
    print(f"  Verified: successor(numeral of n) has value n+1 for all n in [0, {Pk - 1}).")
    print()


def demo_permutation_ranking(n: int) -> None:
    """Factoradic digits (Lehmer code) rank/unrank permutations of {0,...,n-1}."""
    print("=" * 68)
    print(f"Permutation ranking via factoradics, n={n} (there are {n}! = {factorial(n)} perms)")
    print("=" * 68)

    def unrank(rank: int) -> list[int]:
        # Lehmer code from factoradic digits, then decode to a permutation.
        digits = extract_digits(factorial_bases, rank, n)  # low->high, digit i in [0,i]
        code = list(reversed(digits))                      # high->low: code[j] in [0, n-1-j]
        pool = list(range(n))
        perm = []
        for c in code:
            perm.append(pool.pop(c))
        return perm

    def rank(perm: list[int]) -> int:
        pool = list(range(n))
        code = []
        for x in perm:
            idx = pool.index(x)
            code.append(idx)
            pool.pop(idx)
        digits = list(reversed(code))
        return value(factorial_bases, digits)

    all_ranks = list(range(factorial(n)))
    perms = [unrank(r) for r in all_ranks]
    # Bijection: ranks -> permutations is injective and round-trips.
    assert len({tuple(p) for p in perms}) == factorial(n)
    for r in all_ranks:
        assert rank(unrank(r)) == r
    for r in [0, factorial(n) // 2, factorial(n) - 1]:
        print(f"  rank {r:>3}  ->  permutation {unrank(r)}")
    print("  Ranking/unranking is a verified bijection [0, n!) <-> permutations.")
    print()


def main() -> None:
    demo_place_values()
    demo_factoradic_examples()
    demo_counting_bijection(base_n(3), 4, "base-3")
    demo_counting_bijection(factorial_bases, 5, "factorial system")
    # A genuinely mixed system: bases 2,3,4,5,...
    demo_counting_bijection(lambda i: i + 2, 4, "mixed bases (2,3,4,5)")
    demo_successor_carry(factorial_bases, 5, "factorial system")
    demo_successor_carry(base_n(2), 6, "binary")
    demo_permutation_ranking(4)
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
