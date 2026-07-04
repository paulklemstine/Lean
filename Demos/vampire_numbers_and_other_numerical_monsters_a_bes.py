"""Numerical demonstrations for the arithmetic bestiary of digit-permutation factorizations.

This self-contained script demonstrates the main results:

  * Vampire pairs and the classical vampire-number definition.
  * Casting out nines for digit-permutation factorizations:
        x * y == x + y   (mod 9)   and   (x-1)(y-1) == 1 (mod 9).
  * The mod-three fang sieve: no fang is congruent to 1 (mod 3).
  * Length additivity ("no carry shrinkage"): len(x*y) = len(x) + len(y).
  * The base-2 bridge: submultiplicativity of the binary digit sum
        s2(x*y) <= min(y*s2(x), x*s2(y)),
    specialized to vampire numbers.

Run with:  python demo.py
"""

from __future__ import annotations

from typing import Iterator


# ---------------------------------------------------------------------------
# Digit utilities (base 10) and the binary digit sum (base 2).
# ---------------------------------------------------------------------------

def digit_multiset(n: int) -> list[int]:
    """Return the sorted list of base-10 digits of ``n`` (a canonical multiset)."""
    return sorted(int(c) for c in str(n))


def digit_sum(n: int) -> int:
    """Return the base-10 digit sum of ``n``."""
    return sum(int(c) for c in str(n))


def num_digits(n: int) -> int:
    """Return the number of base-10 digits of ``n``."""
    return len(str(n))


def s2(n: int) -> int:
    """Return the binary digit sum (population count) of ``n``."""
    return bin(n).count("1")


# ---------------------------------------------------------------------------
# Digit-permutation factorizations and the classical vampire definition.
# ---------------------------------------------------------------------------

def is_digit_perm_factorization(v: int, x: int, y: int) -> bool:
    """True iff ``v == x*y`` and the digits of x and y permute the digits of v."""
    if x * y != v:
        return False
    return sorted(digit_multiset(x) + digit_multiset(y)) == digit_multiset(v)


def is_vampire_pair(v: int, x: int, y: int) -> bool:
    """True iff (x, y) is a classical vampire pair for ``v``.

    Requires equal-length half-digit fangs and forbids both fangs ending in 0.
    """
    k, r = divmod(num_digits(v), 2)
    if r != 0:  # v must have an even number of digits
        return False
    if num_digits(x) != k or num_digits(y) != k:
        return False
    if x % 10 == 0 and y % 10 == 0:  # no trailing-zero pair
        return False
    return is_digit_perm_factorization(v, x, y)


def vampire_pairs(v: int) -> list[tuple[int, int]]:
    """Return all vampire pairs (x, y) with x <= y for ``v``."""
    pairs: list[tuple[int, int]] = []
    x = 1
    while x * x <= v:
        if v % x == 0:
            y = v // x
            if is_vampire_pair(v, x, y):
                pairs.append((x, y))
        x += 1
    return pairs


def vampire_numbers_up_to(limit: int) -> Iterator[int]:
    """Yield vampire numbers v with 0 < v < ``limit`` in increasing order."""
    for v in range(1, limit):
        if num_digits(v) % 2 == 0 and vampire_pairs(v):
            yield v


# ---------------------------------------------------------------------------
# The three structural obstructions (Theorems 3.1, 4.1, 5.1).
# ---------------------------------------------------------------------------

def check_casting_out_nines(x: int, y: int) -> bool:
    """Verify Theorem 3.1: x*y == x+y (mod 9) and (x-1)(y-1) == 1 (mod 9)."""
    cond_a = (x * y) % 9 == (x + y) % 9
    cond_b = ((x - 1) * (y - 1)) % 9 == 1 % 9
    return cond_a and cond_b


def check_mod_three_sieve(x: int, y: int) -> bool:
    """Verify Theorem 4.1: neither fang is congruent to 1 (mod 3)."""
    return x % 3 != 1 and y % 3 != 1


def check_length_additive(x: int, y: int) -> bool:
    """Verify Theorem 5.1: len(x*y) = len(x) + len(y)."""
    return num_digits(x * y) == num_digits(x) + num_digits(y)


# ---------------------------------------------------------------------------
# The base-2 bridge (Theorems 6.1-6.3).
# ---------------------------------------------------------------------------

def binary_bound(x: int, y: int) -> int:
    """Return the submultiplicative bound min(y*s2(x), x*s2(y))."""
    return min(y * s2(x), x * s2(y))


def check_binary_bound(x: int, y: int) -> bool:
    """Verify Theorem 6.3: s2(x*y) <= min(y*s2(x), x*s2(y))."""
    return s2(x * y) <= binary_bound(x, y)


# ---------------------------------------------------------------------------
# Bestiary variants (equal-length factorizations by digit overlap).
# ---------------------------------------------------------------------------

def shared_digit_count(v: int, x: int, y: int) -> int:
    """Return the number of shared digits (with multiplicity) between D(x)+D(y) and D(v)."""
    from collections import Counter
    factor_digits = Counter(digit_multiset(x) + digit_multiset(y))
    product_digits = Counter(digit_multiset(v))
    return sum((factor_digits & product_digits).values())


# ---------------------------------------------------------------------------
# Driver.
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("A Bestiary of Arithmetic Monsters -- numerical demonstrations")
    print("=" * 70)

    # 1. Enumerate small vampire numbers.
    print("\n[1] Vampire numbers below 10000 and their fang pairs:")
    for v in vampire_numbers_up_to(10000):
        pairs = vampire_pairs(v)
        pretty = ", ".join(f"{x} x {y}" for x, y in pairs)
        print(f"    {v} = {pretty}")

    # 2. The three obstructions on the canonical example.
    v, x, y = 1260, 21, 60
    print(f"\n[2] Structural obstructions on {v} = {x} x {y}:")
    print(f"    digit-permutation factorization : {is_digit_perm_factorization(v, x, y)}")
    print(f"    casting out nines (Thm 3.1)      : {check_casting_out_nines(x, y)}")
    print(f"      x*y mod 9 = {(x*y) % 9}, (x+y) mod 9 = {(x+y) % 9},"
          f" (x-1)(y-1) mod 9 = {((x-1)*(y-1)) % 9}")
    print(f"    mod-three sieve (Thm 4.1)        : {check_mod_three_sieve(x, y)}"
          f"  (x mod 3 = {x % 3}, y mod 3 = {y % 3})")
    print(f"    length additivity (Thm 5.1)      : {check_length_additive(x, y)}"
          f"  (len={num_digits(v)}, {num_digits(x)}+{num_digits(y)})")

    # 3. Verify all obstructions across all vampires below 10^6.
    print("\n[3] Verifying all obstructions for every vampire pair below 10^5 ...")
    total, ok = 0, 0
    for v in vampire_numbers_up_to(10**5):
        for x, y in vampire_pairs(v):
            total += 1
            if (check_casting_out_nines(x, y)
                    and check_mod_three_sieve(x, y)
                    and check_length_additive(x, y)
                    and check_binary_bound(x, y)):
                ok += 1
    print(f"    {ok}/{total} vampire pairs satisfy ALL four theorems.")

    # 4. Binary bridge on the canonical example.
    print("\n[4] Base-2 bridge on 1260 = 21 x 60:")
    print(f"    s2(1260) = {s2(1260)} (1260 = {bin(1260)})")
    print(f"    s2(21) = {s2(21)}, s2(60) = {s2(60)}")
    print(f"    bound min(60*s2(21), 21*s2(60)) = min(60*3, 21*4)"
          f" = {binary_bound(21, 60)}")
    print(f"    bound holds: {check_binary_bound(21, 60)}")

    # 5. Ghost rarity: search equal-length factorizations with zero digit overlap.
    print("\n[5] Ghost search (zero shared digits) among 4-digit products x*y, x<=y:")
    ghosts = 0
    for x in range(10, 100):
        for y in range(x, 100):
            v = x * y
            if num_digits(v) == 4 and shared_digit_count(v, x, y) == 0:
                ghosts += 1
    print(f"    {ghosts} ghost factorizations with 4-digit product from 2-digit factors.")


if __name__ == "__main__":
    main()
