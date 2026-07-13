"""
Numerical demonstrations of the unified mixed-radix numeration theory.

This module illustrates, with concrete numbers, the results of the paper
"A Unified Positional Numeration Theory: The Mixed-Radix Bijection and the
Factorial Bridge."

Core objects
------------
Given a base sequence  b_0, b_1, b_2, ...  the running product is

    P_k = prod_{i<k} b_i

and a digit sequence (c_0, ..., c_{k-1}) with 0 <= c_i < b_i has value

    value(b, c, k) = sum_{i<k} c_i * (prod_{j<i} b_j).

The two conversion routines below (encode / decode) implement the mixed-radix
bijection  {0, ..., P_k - 1}  <->  prod_{i<k} {0, ..., b_i - 1}.

Special cases:
    b_i = N     -> ordinary base-N numerals, P_k = N^k
    b_i = i + 1 -> factoradics,             P_k = k!
"""

from __future__ import annotations

from math import factorial, prod
from typing import Callable, List


# ---------------------------------------------------------------------------
# Core mixed-radix machinery
# ---------------------------------------------------------------------------

def radix_prod(b: Callable[[int], int], k: int) -> int:
    """Running product P_k = prod_{i<k} b(i)."""
    return prod(b(i) for i in range(k))


def value(b: Callable[[int], int], c: List[int], k: int) -> int:
    """Value of digit sequence c over k places: sum_{i<k} c_i * prod_{j<i} b_j."""
    total = 0
    weight = 1  # prod_{j<i} b_j, starting at i = 0
    for i in range(k):
        total += c[i] * weight
        weight *= b(i)
    return total


def is_valid(b: Callable[[int], int], c: List[int], k: int) -> bool:
    """A digit sequence is valid if 0 <= c_i < b_i for every place i < k."""
    return all(0 <= c[i] < b(i) for i in range(k))


def encode(b: Callable[[int], int], n: int, k: int) -> List[int]:
    """Integer -> mixed-radix tuple (Proposition: Existence).

    Repeated division extracts digit i as (n div P_i) mod b_i.
    """
    digits: List[int] = []
    for i in range(k):
        digits.append(n % b(i))
        n //= b(i)
    return digits


def decode(b: Callable[[int], int], c: List[int], k: int) -> int:
    """Mixed-radix tuple -> integer, via Horner's rule (== value)."""
    n = 0
    for i in reversed(range(k)):
        n = n * b(i) + c[i]
    return n


# ---------------------------------------------------------------------------
# Demo 1: the general bijection round-trips for an exotic base sequence
# ---------------------------------------------------------------------------

def demo_general_bijection() -> None:
    print("=" * 70)
    print("DEMO 1: The mixed-radix bijection round-trips (exotic bases)")
    print("=" * 70)
    # A deliberately irregular base sequence (e.g. a clock: 60, 60, 24, 7).
    bases = [60, 60, 24, 7]
    b = lambda i: bases[i]
    k = len(bases)
    P = radix_prod(b, k)
    print(f"bases        = {bases}")
    print(f"running prod = {P}  (= number of valid tuples)")

    ok = True
    for n in range(0, P, max(1, P // 11)):  # sample a spread of values
        c = encode(b, n, k)
        assert is_valid(b, c, k), f"digit out of range at n={n}"
        m = decode(b, c, k)
        status = "OK" if m == n else "FAIL"
        ok &= (m == n)
        print(f"  n={n:>7}  ->  digits={c}  ->  {m:>7}   [{status}]")
    print(f"Round-trip holds on all sampled values: {ok}\n")


# ---------------------------------------------------------------------------
# Demo 2: base-N specialization recovers ordinary positional notation
# ---------------------------------------------------------------------------

def demo_base_n() -> None:
    print("=" * 70)
    print("DEMO 2: Base-N specialization (b_i = N), P_k = N^k")
    print("=" * 70)
    for N, k in [(2, 8), (10, 4), (16, 3)]:
        b = lambda i, N=N: N
        P = radix_prod(b, k)
        assert P == N ** k
        n = 12345 % P
        digits = encode(b, n, k)  # little-endian digits
        # Compare with Python's built-in radix rendering (big-endian).
        big_endian = digits[::-1]
        print(f"  N={N:>2}, k={k}:  N^k={P:>7},  {n} -> digits {big_endian}"
              f"  -> {decode(b, digits, k)}")
    print()


# ---------------------------------------------------------------------------
# Demo 3: factoradic specialization and the count k!
# ---------------------------------------------------------------------------

def demo_factoradic() -> None:
    print("=" * 70)
    print("DEMO 3: Factoradic specialization (b_i = i+1), P_k = k!")
    print("=" * 70)
    b = lambda i: i + 1
    for k in range(1, 8):
        P = radix_prod(b, k)
        assert P == factorial(k), "hinge identity prod_{i<k}(i+1) = k! failed"
        print(f"  k={k}:  prod_(i<k)(i+1) = {P:>5}  and  k! = {factorial(k):>5}  (equal)")

    print("\n  Every n < k! has a UNIQUE factoradic tuple (k = 4, k! = 24):")
    k = 4
    seen = {}
    for n in range(factorial(k)):
        c = tuple(encode(b, n, k))
        assert is_valid(b, c, k)
        assert c not in seen, "collision -> not injective!"
        seen[c] = n
    print(f"    distinct tuples produced: {len(seen)}  (= 4! = {factorial(k)})")
    print(f"    bijection {{0..{factorial(k)-1}}} <-> factoradic tuples verified\n")


# ---------------------------------------------------------------------------
# Demo 4: permutation ranking / unranking via the Lehmer code
# ---------------------------------------------------------------------------

def rank_permutation(perm: List[int]) -> int:
    """Rank a permutation of {0,...,k-1} by its Lehmer code (a factoradic tuple)."""
    k = len(perm)
    remaining = list(range(k))
    lehmer: List[int] = []
    for x in perm:
        idx = remaining.index(x)
        lehmer.append(idx)          # lehmer[i] < k - i  (a factoradic digit)
        remaining.pop(idx)
    # value with place weights (k-1-i)!  -- factoradic read most-significant first
    return sum(lehmer[i] * factorial(k - 1 - i) for i in range(k))


def unrank_permutation(rank: int, k: int) -> List[int]:
    """Inverse of rank_permutation: integer in [0, k!) -> permutation."""
    remaining = list(range(k))
    perm: List[int] = []
    for i in range(k):
        f = factorial(k - 1 - i)
        idx, rank = divmod(rank, f)
        perm.append(remaining.pop(idx))
    return perm


def demo_permutation_ranking() -> None:
    print("=" * 70)
    print("DEMO 4: Permutation ranking via factoradics  {0..k!-1} <-> Perm(k)")
    print("=" * 70)
    k = 4
    for r in range(factorial(k)):
        p = unrank_permutation(r, k)
        back = rank_permutation(p)
        tag = "OK" if back == r else "FAIL"
        if r % 4 == 0 or back != r:
            print(f"  rank {r:>2}  <->  permutation {p}   (re-rank {back}) [{tag}]")
        assert back == r
    print(f"  All {factorial(k)} ranks round-trip: bijection confirmed\n")


if __name__ == "__main__":
    demo_general_bijection()
    demo_base_n()
    demo_factoradic()
    demo_permutation_ranking()
    print("All demonstrations completed successfully.")
