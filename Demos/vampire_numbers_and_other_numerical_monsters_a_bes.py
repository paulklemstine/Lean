"""
A Bestiary of Numerical Monsters — Numerical Demonstrations
===========================================================

Self-contained demonstrations of the structural laws governing digit-sharing
factorizations (vampires, werewolves, ghosts, zombies).

Each function is inlined and type-hinted. Running this file exercises every
theorem from the paper on concrete data.

    Digit-Length Conservation :  len(x) + len(y) = len(x*y)
    Digit-Length Extremality  :  b^(len x + len y - 1) <= x*y
    Casting-out-(b-1)s         :  x + y == x*y   (mod b-1)
    Unit identity (base 10)    :  (x-1)(y-1) == 1 (mod 9)
    Mod-3 taboo                :  x % 3 != 1 and y % 3 != 1
    No power-of-two fangs (b=2):  popcount(x), popcount(y) >= 2
"""

from __future__ import annotations

from typing import List, Tuple


# --------------------------------------------------------------------------
# Core digit utilities
# --------------------------------------------------------------------------

def digits(b: int, n: int) -> List[int]:
    """Base-b digits of n, least significant first (empty list for n = 0)."""
    if b < 2:
        raise ValueError("base must be >= 2")
    out: List[int] = []
    while n > 0:
        out.append(n % b)
        n //= b
    return out


def digit_len(b: int, n: int) -> int:
    """Number of base-b digits of n (0 has length 0)."""
    return len(digits(b, n))


def digit_sum(b: int, n: int) -> int:
    """Sum of the base-b digits of n."""
    return sum(digits(b, n))


def shares_all_digits(b: int, x: int, y: int) -> bool:
    """True iff digits(x) ++ digits(y) is a permutation of digits(x*y)."""
    return sorted(digits(b, x) + digits(b, y)) == sorted(digits(b, x * y))


def digit_set(b: int, n: int) -> set[int]:
    """Set of distinct digit-values of n in base b."""
    return set(digits(b, n))


def popcount(n: int) -> int:
    """Number of 1-bits in the binary expansion of n."""
    return bin(n).count("1")


# --------------------------------------------------------------------------
# Bestiary classifiers
# --------------------------------------------------------------------------

def is_werewolf(b: int, x: int, y: int) -> bool:
    """Factors share exactly one distinct digit-value with the product."""
    shared = (digit_set(b, x) | digit_set(b, y)) & digit_set(b, x * y)
    return len(shared) == 1


def is_ghost(b: int, x: int, y: int) -> bool:
    """Factors share no digit-value with the product."""
    shared = (digit_set(b, x) | digit_set(b, y)) & digit_set(b, x * y)
    return len(shared) == 0


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


def is_zombie(x: int, y: int) -> bool:
    """Both factors prime."""
    return is_prime(x) and is_prime(y)


# --------------------------------------------------------------------------
# Vampire enumeration with invariant sieve (Algorithm A)
# --------------------------------------------------------------------------

def vampire_numbers(k: int) -> List[Tuple[int, int, int]]:
    """
    All vampire numbers with 2k digits, via balanced digit-sharing factor
    pairs. Returns sorted list of (vampire, x, y). Uses the mod-3 taboo and
    casting-out-nines filters before the digit test.
    """
    lo, hi = 10 ** (k - 1), 10 ** k - 1
    found: dict[int, Tuple[int, int]] = {}
    for x in range(lo, hi + 1):
        if x % 3 == 1:                      # mod-3 taboo prune
            continue
        for y in range(x, hi + 1):
            if y % 3 == 1:                  # mod-3 taboo prune
                continue
            if x % 10 == 0 and y % 10 == 0:  # trailing-zero exclusion
                continue
            v = x * y
            if (x + y) % 9 != v % 9:        # casting-out-nines prune
                continue
            if shares_all_digits(10, x, y):
                found.setdefault(v, (x, y))
    return sorted((v, xy[0], xy[1]) for v, xy in found.items())


# --------------------------------------------------------------------------
# Verification harness for the structural laws
# --------------------------------------------------------------------------

def verify_laws(b: int, x: int, y: int) -> None:
    """Assert every proven law on a digit-sharing pair (x, y)."""
    assert shares_all_digits(b, x, y), "precondition: must be digit-sharing"
    v = x * y

    # Theorem 3.1 — conservation
    assert digit_len(b, x) + digit_len(b, y) == digit_len(b, v)

    # Theorem 3.2 — extremality
    assert b ** (digit_len(b, x) + digit_len(b, y) - 1) <= v

    # Theorem 4.1 — casting out (b-1)s
    assert (x + y) % (b - 1) == v % (b - 1)

    if b == 10:
        # Theorem 4.2 — unit identity mod 9
        assert ((x - 1) * (y - 1)) % 9 == 1 % 9
        # Theorem 4.3 — mod-3 taboo
        assert x % 3 != 1 and y % 3 != 1

    if b == 2:
        # Theorem 5.2 — no power-of-two fangs
        assert popcount(x) >= 2 and popcount(y) >= 2
        # digit-sum conservation and submultiplicativity
        assert popcount(x) + popcount(y) == popcount(v)
        assert popcount(v) <= popcount(x) * popcount(y)


# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

def main() -> None:
    print("=" * 68)
    print("A BESTIARY OF NUMERICAL MONSTERS — DEMONSTRATIONS")
    print("=" * 68)

    print("\n[1] Vampire numbers with 4 digits (2k = 4):")
    vamps = vampire_numbers(2)
    for v, x, y in vamps:
        print(f"    {v} = {x} x {y}")
    print(f"    ... {len(vamps)} four-digit vampires found "
          f"(smallest is {vamps[0][0]}).")

    print("\n[2] Structural laws verified on the smallest vampire 1260 = 21 x 60:")
    verify_laws(10, 21, 60)
    print("    len(21)+len(60) = 2+2 = 4 = len(1260)          [conservation]")
    print("    10^3 = 1000 <= 1260                              [extremality]")
    print("    21+60 = 81 == 1260 (mod 9)  [both 0]             [casting out 9s]")
    print("    (21-1)(20*... ) -> (20)(59) % 9 = 1              [unit identity]")
    print("    21 % 3 = 0, 60 % 3 = 0  (neither is 1)           [mod-3 taboo]")

    print("\n[3] Mod-3 taboo: verify NO vampire fang is 1 mod 3 (4- and 6-digit):")
    ok = all(x % 3 != 1 and y % 3 != 1
             for v, x, y in vampire_numbers(2) + vampire_numbers(3))
    print(f"    All fangs avoid residue 1 mod 3: {ok}")

    print("\n[4] Werewolf / Ghost / Zombie witnesses:")
    print(f"    Werewolf 3 x 5 = 15  (share exactly {{5}}): {is_werewolf(10,3,5)}")
    print(f"    Ghost    7 x 7 = 49  (share nothing):        {is_ghost(10,7,7)}")
    print(f"    Zombie   3 x 5 = 15  (both prime):           {is_zombie(3,5)}")

    print("\n[5] Binary bestiary — no power-of-two fangs:")
    bin_examples = [(x, y) for x in range(1, 64) for y in range(x, 64)
                    if shares_all_digits(2, x, y)]
    sample = bin_examples[:8]
    for x, y in sample:
        verify_laws(2, x, y)
        print(f"    {x} x {y} = {x*y}: popcount fangs = "
              f"({popcount(x)},{popcount(y)}) both >= 2, "
              f"sum = {popcount(x)+popcount(y)} = popcount(product)")
    assert all(popcount(x) >= 2 and popcount(y) >= 2 for x, y in bin_examples)
    print(f"    Verified over {len(bin_examples)} binary digit-sharing pairs "
          f"(x,y < 64): every fang has >= 2 one-bits.")

    print("\n[6] Casting-out-nines sieve efficiency (4-digit factor pairs):")
    lo, hi = 100, 999
    total = passed = 0
    for x in range(lo, hi + 1):
        for y in range(x, hi + 1):
            total += 1
            if x % 3 == 1 or y % 3 == 1:
                continue
            if (x + y) % 9 != (x * y) % 9:
                continue
            passed += 1
    print(f"    Pairs surviving mod-3 + casting-out-9 filters: "
          f"{passed}/{total} = {100*passed/total:.1f}%")
    print(f"    (Filters remove {100*(1-passed/total):.1f}% before any digit test.)")

    print("\nAll structural laws verified. \u2713")


if __name__ == "__main__":
    main()
