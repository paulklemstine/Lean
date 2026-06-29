"""
Alien Number Systems: Beyond Base-N
===================================

Numerical demonstration of the mixed-radix (variable-base) positional system
formalized in MixedRadix.lean.

A system is given by a list of bases bs = [b0, b1, ..., b_{k-1}] (least
significant first). A digit list ds = [d0, ..., d_{k-1}] denotes the value

    mval(bs, ds) = d0 + b0*(d1 + b1*(d2 + ...))   (Horner evaluation)

and digit extraction is greedy Euclidean division:

    mdigits(bs, n) = (n % b0) :: mdigits(rest, n // b0)

This file reproduces, as runnable Python, the theory's headline facts:

  * mval_mdigits         : mval(bs, mdigits(bs, n)) == n % prod(bs)
  * mval_mdigits_of_lt   : exact round trip for n < prod(bs)
  * mdigits_forall2_lt   : extracted digits are valid (d_i < b_i)
  * mval_lt_prod         : valid digit lists stay below capacity
  * mdigits_mval         : uniqueness (valid digits round-trip back)
  * mixedRadixEquiv      : the bijection Fin(prod bs) <-> valid digit lists
  * uniform / factorial / primorial specializations
"""

from __future__ import annotations

from math import prod, factorial
from itertools import product as iproduct
from typing import List


# --------------------------------------------------------------------------
# Core operations (direct translations of the Lean definitions)
# --------------------------------------------------------------------------

def mval(bs: List[int], ds: List[int]) -> int:
    """Horner value of digit list ds under bases bs (least significant first)."""
    acc = 0
    # fold from most significant downward; pad bs/ds to the matching prefix
    n = min(len(bs), len(ds)) if len(ds) > len(bs) else len(ds)
    # Lean's mval ignores extra bases and, when bases run out, treats the
    # remaining single head digit literally. For valid same-length lists the
    # straightforward Horner fold below is exact.
    for i in range(len(ds) - 1, -1, -1):
        b = bs[i] if i < len(bs) else 1
        acc = ds[i] + b * acc
    return acc


def mdigits(bs: List[int], n: int) -> List[int]:
    """Greedy digit extraction of n under bases bs (least significant first)."""
    digits: List[int] = []
    for b in bs:
        digits.append(n % b)
        n //= b
    return digits


def capacity(bs: List[int]) -> int:
    """Capacity of the system = product of all bases (empty product = 1)."""
    return prod(bs) if bs else 1


def is_valid(bs: List[int], ds: List[int]) -> bool:
    """Validity: same length and each digit strictly below its base."""
    return len(ds) == len(bs) and all(d < b for d, b in zip(ds, bs))


# --------------------------------------------------------------------------
# Theorem checks
# --------------------------------------------------------------------------

def check_master_law(bs: List[int], n: int) -> bool:
    """mval(bs, mdigits(bs, n)) == n % prod(bs)   (mval_mdigits)."""
    return mval(bs, mdigits(bs, n)) == n % capacity(bs)


def check_exact_roundtrip(bs: List[int], n: int) -> bool:
    """For n < capacity, encode/decode is the identity (mval_mdigits_of_lt)."""
    assert n < capacity(bs)
    return mval(bs, mdigits(bs, n)) == n


def check_digits_valid(bs: List[int], n: int) -> bool:
    """Extracted digits are valid when bases are positive (mdigits_forall2_lt)."""
    return is_valid(bs, mdigits(bs, n))


def check_value_bound(bs: List[int], ds: List[int]) -> bool:
    """A valid digit list denotes a value < capacity (mval_lt_prod)."""
    assert is_valid(bs, ds)
    return mval(bs, ds) < capacity(bs)


def check_uniqueness(bs: List[int], ds: List[int]) -> bool:
    """Valid digits round-trip through their value (mdigits_mval)."""
    assert is_valid(bs, ds)
    return mdigits(bs, mval(bs, ds)) == ds


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_base_ten() -> None:
    print("== Ordinary base ten as the uniform special case ==")
    bs = [10, 10, 10]
    n = 723
    ds = mdigits(bs, n)
    print(f"  bases   = {bs}   capacity = {capacity(bs)} (= 10^3)")
    print(f"  723 -> digits {ds} (units, tens, hundreds)")
    print(f"  Horner value back = {mval(bs, ds)}")
    print(f"  master law holds: {check_master_law(bs, n)}\n")


def demo_factorial() -> None:
    print("== Factorial number system: bases [2, 3, 4, ...] ==")
    k = 4
    bs = [i + 2 for i in range(k)]            # [2, 3, 4, 5]
    print(f"  bases    = {bs}   capacity = {capacity(bs)} (= {k+1}! = {factorial(k+1)})")
    for n in (4, 100, 119):
        ds = mdigits(bs, n)
        print(f"  {n:>3} -> factoradic {ds}, value back = {mval(bs, ds)}")
    # 100 = 2*2! + 4*4! ?  factoradic places have weights 1!,2!,3!,4! = 1,2,6,24
    print("  weights (place values 1!,2!,3!,4!):", [factorial(i + 1) for i in range(k)])
    print()


def demo_primorial() -> None:
    print("== Primorial base: first primes [2, 3, 5, 7] ==")
    bs = [2, 3, 5, 7]
    print(f"  bases    = {bs}   capacity (primorial) = {capacity(bs)}")
    for n in (0, 41, 209):
        ds = mdigits(bs, n)
        print(f"  {n:>3} -> digits {ds}, residues (n mod p_i) = {[n % p for p in bs]}")
    print()


def demo_clock() -> None:
    print("== Mixed base of a clock: [60 sec, 60 min, 24 hr] ==")
    bs = [60, 60, 24]
    total = 3 * 3600 + 25 * 60 + 45        # 3h 25m 45s in seconds
    ds = mdigits(bs, total)
    print(f"  {total} seconds -> {ds} = {ds[0]}s, {ds[1]}m, {ds[2]}h")
    print(f"  reconstructed seconds = {mval(bs, ds)}\n")


def demo_bijection() -> None:
    print("== The crowning bijection on a small alien base [2, 3, 4] ==")
    bs = [2, 3, 4]
    cap = capacity(bs)
    forward = {n: tuple(mdigits(bs, n)) for n in range(cap)}
    valid = [tuple(d) for d in iproduct(*[range(b) for b in bs])]
    images = set(forward.values())
    print(f"  capacity = {cap}, #valid digit lists = {len(valid)}")
    print(f"  forward map is injective : {len(set(forward.values())) == cap}")
    print(f"  forward map is surjective: {images == set(valid)}")
    for n in range(cap):
        ds = list(forward[n])
        assert mval(bs, ds) == n and mdigits(bs, mval(bs, ds)) == ds
    print("  every n round-trips both ways: True\n")


def stress_test() -> None:
    print("== Stress test of all theorems over many systems ==")
    systems = [[10, 10, 10], [2, 3, 4, 5], [2, 3, 5, 7], [60, 60, 24], [7, 5, 9, 2, 11]]
    ok = True
    for bs in systems:
        cap = capacity(bs)
        for n in range(min(cap, 200)):
            ok &= check_master_law(bs, n)
            ok &= check_exact_roundtrip(bs, n)
            ok &= check_digits_valid(bs, n)
        # uniqueness/bound over a sample of valid digit lists
        sample = list(iproduct(*[range(min(b, 4)) for b in bs]))[:200]
        for ds in sample:
            ds = list(ds) + [0] * (len(bs) - len(ds))
            ds = [min(d, b - 1) for d, b in zip(ds, bs)]
            ok &= check_value_bound(bs, ds)
            ok &= check_uniqueness(bs, ds)
    print(f"  all checks passed: {ok}\n")


if __name__ == "__main__":
    demo_base_ten()
    demo_factorial()
    demo_primorial()
    demo_clock()
    demo_bijection()
    stress_test()
    print("All demonstrations complete.")
