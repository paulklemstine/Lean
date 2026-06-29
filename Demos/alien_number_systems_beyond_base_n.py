"""
Alien Number Systems: Beyond Base-N
===================================

Numerical demonstrations of the factorial number system (factoradic) and the
theorems formalized in the accompanying Lean development:

    value_lt        : a valid length-k value is strictly below k!
    splitting_div   : the top digit is the quotient by k!
    splitting_mod   : the lower part is the remainder mod k!
    value_unique    : valid representations are unique (injectivity)
    digit_valid     : extracted digits are valid
    value_digit     : every n < k! is the value of its extracted digits (surjectivity)

Everything is self-contained: standard library only.

Run:  python demo.py
"""

from __future__ import annotations

from math import factorial
from itertools import permutations
from typing import List


# ---------------------------------------------------------------------------
# Core definitions (mirroring the Lean file)
# ---------------------------------------------------------------------------

def value(c: List[int], k: int) -> int:
    """Length-k factoradic value: sum_{i<k} c[i] * i!.

    Mirrors `FactorialNumberSystem.value`.
    """
    return sum(c[i] * factorial(i) for i in range(k))


def is_valid(c: List[int], k: int) -> bool:
    """Validity up to length k: c[i] <= i for all i < k.

    Mirrors `FactorialNumberSystem.Valid`.
    """
    return all(c[i] <= i for i in range(k))


def digit(n: int, i: int) -> int:
    """Explicit factoradic digit extraction: floor(n / i!) mod (i+1).

    Mirrors `FactorialNumberSystem.digit`.
    """
    return (n // factorial(i)) % (i + 1)


def extract(n: int, k: int) -> List[int]:
    """The length-k extracted digit vector of n (index i -> digit n i)."""
    return [digit(n, i) for i in range(k)]


# ---------------------------------------------------------------------------
# Efficient streaming algorithms (Section 4 of the paper)
# ---------------------------------------------------------------------------

def encode_stream(n: int, k: int) -> List[int]:
    """Streaming encoder: repeatedly divide by 1, 2, 3, ... (O(k) divisions)."""
    c = [0] * k
    for i in range(1, k + 1):
        c[i - 1] = n % i
        n //= i
    return c


def decode_horner(c: List[int], k: int) -> int:
    """Horner-style decoder: reconstruct value without computing factorials."""
    acc = 0
    for i in range(k - 1, 0, -1):
        acc = (acc + c[i]) * i
    return acc + (c[0] if k > 0 else 0)


# ---------------------------------------------------------------------------
# Lehmer code: permutation <-> integer rank
# ---------------------------------------------------------------------------

def lehmer_rank(perm: List[int]) -> int:
    """Rank a permutation of {0,...,n-1} in lexicographic order via factoradics."""
    n = len(perm)
    lehmer = []
    for i in range(n):
        smaller_after = sum(1 for j in range(i + 1, n) if perm[j] < perm[i])
        lehmer.append(smaller_after)
    # lehmer[i] is bounded by n-1-i; convert via descending factorials.
    return sum(lehmer[i] * factorial(n - 1 - i) for i in range(n))


def lehmer_unrank(rank: int, n: int) -> List[int]:
    """Recover the lexicographically rank-th permutation of {0,...,n-1}."""
    lehmer = []
    for i in range(n):
        f = factorial(n - 1 - i)
        lehmer.append(rank // f)
        rank %= f
    available = list(range(n))
    perm = []
    for code in lehmer:
        perm.append(available.pop(code))
    return perm


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_decode_examples() -> None:
    print("=" * 64)
    print("1.  Decoding factoradic strings to integers")
    print("=" * 64)
    examples = {
        "(c3,c2,c1,c0) = 3,0,1,0": [0, 1, 0, 3],   # stored low-index first
        "(c2,c1,c0)    = 2,1,0":   [0, 1, 2],
        "(c2,c1,c0)    = 0,0,0":   [0, 0, 0],
    }
    for label, c in examples.items():
        k = len(c)
        print(f"  {label:30s} -> value = {value(c, k)}   valid={is_valid(c, k)}")
    print()


def demo_value_lt() -> None:
    print("=" * 64)
    print("2.  value_lt : a valid length-k value is < k!   (tight bound)")
    print("=" * 64)
    for k in range(1, 8):
        max_digits = [i for i in range(k)]          # maximal valid digits c[i]=i
        v = value(max_digits, k)
        print(f"  k={k}: max value = {v:6d},  k! = {factorial(k):6d},  "
              f"k!-1 = {factorial(k) - 1:6d}  (equal? {v == factorial(k) - 1})")
    print()


def demo_splitting() -> None:
    print("=" * 64)
    print("3.  splitting_div / splitting_mod")
    print("=" * 64)
    c = [0, 1, 2, 1, 4]          # valid up to length 5: c[i] <= i
    k = 4
    full = value(c, k + 1)
    print(f"  value(c, {k+1}) = {full}")
    print(f"  splitting_div:  value // {k}! = {full // factorial(k)}  ==  c[{k}] = {c[k]}")
    print(f"  splitting_mod:  value %  {k}! = {full % factorial(k)}  ==  value(c,{k}) = {value(c, k)}")
    print()


def demo_uniqueness_and_bijection() -> None:
    print("=" * 64)
    print("4.  value_unique + value_digit : bijection with {0,...,k!-1}")
    print("=" * 64)
    k = 5
    seen = {}
    ok = True
    for n in range(factorial(k)):
        c = extract(n, k)
        assert is_valid(c, k), f"digit_valid failed at n={n}"           # digit_valid
        assert value(c, k) == n, f"value_digit failed at n={n}"         # value_digit
        key = tuple(c)
        if key in seen:                                                 # value_unique
            ok = False
        seen[key] = n
    print(f"  k={k}: enumerated {factorial(k)} integers in [0, {k}!).")
    print(f"  All extracted digit vectors valid (digit_valid):        True")
    print(f"  value(extract(n)) == n for all n (value_digit):         True")
    print(f"  All {len(seen)} digit vectors distinct (value_unique):  {ok}")
    print()


def demo_streaming_agreement() -> None:
    print("=" * 64)
    print("5.  Streaming encode/decode agree with the definitional maps")
    print("=" * 64)
    k = 6
    ok = True
    for n in range(factorial(k)):
        c1 = extract(n, k)
        c2 = encode_stream(n, k)
        if c1 != c2 or decode_horner(c1, k) != n:
            ok = False
            break
    print(f"  k={k}: encode_stream == extract and decode_horner inverts, for all "
          f"n in [0,{k}!):  {ok}")
    print()


def demo_lehmer() -> None:
    print("=" * 64)
    print("6.  Lehmer code: ranking and unranking permutations")
    print("=" * 64)
    n = 4
    ok = True
    ranks = []
    for perm in permutations(range(n)):
        r = lehmer_rank(list(perm))
        ranks.append((r, perm))
        if lehmer_unrank(r, n) != list(perm):
            ok = False
    ranks.sort()
    print(f"  n={n}: rank/unrank are mutual inverses for all {factorial(n)} "
          f"permutations:  {ok}")
    print(f"  Ranks are exactly 0..{factorial(n) - 1} (a bijection): "
          f"{[r for r, _ in ranks] == list(range(factorial(n)))}")
    print("  A few (rank -> permutation) pairs:")
    for r, perm in ranks[:6]:
        print(f"    {r:2d} -> {perm}")
    print()
    # Unrank a specific large index without enumerating predecessors.
    big_n = 6
    target = 500
    print(f"  Unranking index {target} among {big_n}! = {factorial(big_n)} "
          f"permutations of {{0..{big_n - 1}}}:")
    print(f"    permutation = {lehmer_unrank(target, big_n)}")
    print(f"    re-ranked   = {lehmer_rank(lehmer_unrank(target, big_n))}")
    print()


def main() -> None:
    demo_decode_examples()
    demo_value_lt()
    demo_splitting()
    demo_uniqueness_and_bijection()
    demo_streaming_agreement()
    demo_lehmer()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
