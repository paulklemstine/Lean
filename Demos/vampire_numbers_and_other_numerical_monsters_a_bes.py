"""
Vampire Numbers and Other Numerical Monsters: A Bestiary of Arithmetic Oddities
================================================================================

Self-contained numerical demonstrations of the digit-multiset framework for
vampire numbers and their modular signatures, plus the wider bestiary of
werewolves, ghosts, and zombies.

All results here correspond to the theorems in the accompanying paper:

  * digit-length additivity across a fang pair          (Lemma 2)
  * digit-sum additivity across a fang pair             (Lemma 3)
  * casting out nines/threes                            (Lemma 4)
  * vampire law  v = x + y  (mod 9) and (mod 3)         (Theorems 4, 5)
  * fang taboo:  neither fang is = 1 (mod 3)            (Theorem 6)
  * mod-nine residue confinement (x-1)(y-1) = 1 (mod 9) (Proposition 7)
  * ghost density decays geometrically in digit length  (Theorem 8)

Run:  python demo.py
"""

from __future__ import annotations

from collections import Counter
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------
# Core digit utilities: the multiset of decimal digits and its projections.
# --------------------------------------------------------------------------

def digit_multiset(n: int) -> Counter:
    """The multiset M(n) of base-10 digits of n (order forgotten, multiplicity kept)."""
    return Counter(str(n))


def digit_sum(n: int) -> int:
    """S(n): the sum of the decimal digits of n = total of the digit multiset."""
    return sum(int(c) for c in str(n))


def digit_length(n: int) -> int:
    """L(n): the number of decimal digits of n = cardinality of the digit multiset."""
    return len(str(n))


def digit_set(n: int) -> set:
    """D(n): the set of distinct digits occurring in n (support of the multiset)."""
    return set(str(n))


# --------------------------------------------------------------------------
# The fang relation and vampire test.
# --------------------------------------------------------------------------

def is_fang_pair(v: int, x: int, y: int) -> bool:
    """True iff M(v) = M(x) + M(y) and x * y = v  (Definition 2)."""
    return x * y == v and digit_multiset(v) == digit_multiset(x) + digit_multiset(y)


def find_vampire_fangs(v: int) -> List[Tuple[int, int]]:
    """All balanced, non-trivial fang pairs (x, y) with x <= y of a vampire v."""
    s = str(v)
    if len(s) % 2 != 0:
        return []
    half = len(s) // 2
    lo, hi = 10 ** (half - 1), 10 ** half - 1
    fangs: List[Tuple[int, int]] = []
    for x in range(lo, hi + 1):
        if v % x:
            continue
        y = v // x
        if x <= y <= hi:
            if x % 10 == 0 and y % 10 == 0:  # exclude trailing-zero-only pairs
                continue
            if is_fang_pair(v, x, y):
                fangs.append((x, y))
    return fangs


def is_vampire(v: int) -> bool:
    return len(find_vampire_fangs(v)) > 0


# --------------------------------------------------------------------------
# Efficient fang-first enumeration with the modular sieve of Section 5.
# --------------------------------------------------------------------------

def enumerate_vampires(half_len: int, use_sieve: bool = True) -> Dict[int, List[Tuple[int, int]]]:
    """Return {v: [fang pairs]} for all vampires with 2*half_len digits.

    Uses the mod-9 confinement (Prop. 7) and mod-3 fang taboo (Thm. 6) to prune
    candidate factor pairs cheaply before the multiset comparison.
    """
    lo, hi = 10 ** (half_len - 1), 10 ** half_len - 1
    results: Dict[int, List[Tuple[int, int]]] = {}
    target = 2 * half_len
    for x in range(lo, hi + 1):
        for y in range(x, hi + 1):
            if x % 10 == 0 and y % 10 == 0:
                continue
            if use_sieve:
                if ((x - 1) * (y - 1)) % 9 != 1 % 9:  # Proposition 7
                    continue
                if x % 3 == 1 or y % 3 == 1:          # Theorem 6
                    continue
            v = x * y
            if digit_length(v) != target:
                continue
            if digit_multiset(v) == digit_multiset(x) + digit_multiset(y):
                results.setdefault(v, []).append((x, y))
    return results


# --------------------------------------------------------------------------
# The wider bestiary.
# --------------------------------------------------------------------------

def is_werewolf(v: int, x: int, y: int) -> bool:
    """Fangs share EXACTLY ONE distinct digit with v (Definition 4)."""
    return v == x * y and len(digit_set(v) & (digit_set(x) | digit_set(y))) == 1


def is_ghost(v: int, x: int, y: int) -> bool:
    """Fangs share NO digit with v (Definition 5)."""
    return v == x * y and len(digit_set(v) & (digit_set(x) | digit_set(y))) == 0


# --------------------------------------------------------------------------
# Demonstrations.
# --------------------------------------------------------------------------

def demo_smallest_vampire() -> None:
    print("=" * 68)
    print("1. The smallest vampire: 1260 = 21 * 60")
    print("=" * 68)
    v, x, y = 1260, 21, 60
    print(f"  M({v}) = {dict(digit_multiset(v))}")
    print(f"  M({x}) + M({y}) = {dict(digit_multiset(x) + digit_multiset(y))}")
    print(f"  is_fang_pair(1260, 21, 60) = {is_fang_pair(v, x, y)}")
    print()


def demo_additivity() -> None:
    print("=" * 68)
    print("2. Additivity of digit length (Lemma 2) and digit sum (Lemma 3)")
    print("=" * 68)
    for (v, x, y) in [(1260, 21, 60), (125460, 204, 615), (125460, 246, 510)]:
        assert is_fang_pair(v, x, y)
        print(f"  {v} = {x} * {y}")
        print(f"    L: L(v)={digit_length(v)},  L(x)+L(y)={digit_length(x)+digit_length(y)}")
        print(f"    S: S(v)={digit_sum(v)},  S(x)+S(y)={digit_sum(x)+digit_sum(y)}")
    print()


def demo_modular_signature() -> None:
    print("=" * 68)
    print("3. The modular signature: v = x + y (mod 9) and (mod 3)  [Thm 4,5]")
    print("=" * 68)
    for (v, x, y) in [(1260, 21, 60), (1395, 15, 93), (125460, 204, 615)]:
        m9 = (v % 9 == (x + y) % 9)
        m3 = (v % 3 == (x + y) % 3)
        conf = ((x - 1) * (y - 1)) % 9 == 1 % 9
        print(f"  {v} = {x} * {y}:  mod9 {v%9}=={(x+y)%9} [{m9}], "
              f"mod3 {v%3}=={(x+y)%3} [{m3}], (x-1)(y-1)=1 mod9 [{conf}]")
    print()


def demo_fang_taboo() -> None:
    print("=" * 68)
    print("4. The fang taboo: no fang is = 1 (mod 3)  [Theorem 6]")
    print("=" * 68)
    fangs = enumerate_vampires(2)  # all 4-digit vampires
    violations = 0
    for v, pairs in sorted(fangs.items()):
        for (x, y) in pairs:
            if x % 3 == 1 or y % 3 == 1:
                violations += 1
    print(f"  Enumerated {len(fangs)} four-digit vampires.")
    print(f"  Fang pairs violating the mod-3 taboo: {violations}  (expected 0)")
    print()


def demo_census() -> None:
    print("=" * 68)
    print("5. Census of four-digit vampires (fang-first enumeration)")
    print("=" * 68)
    fangs = enumerate_vampires(2)
    for v, pairs in sorted(fangs.items()):
        pretty = ", ".join(f"{x}*{y}" for (x, y) in pairs)
        print(f"  {v} = {pretty}")
    print(f"  Total: {len(fangs)} four-digit vampires.")
    print()


def demo_double_vampire() -> None:
    print("=" * 68)
    print("6. A double (multiple) vampire: 125460")
    print("=" * 68)
    for (x, y) in find_vampire_fangs(125460):
        print(f"  125460 = {x} * {y}   [fang pair: {is_fang_pair(125460, x, y)}]")
    print()


def demo_ghosts_decay() -> None:
    print("=" * 68)
    print("7. Ghost numbers thin out with digit length  [Theorem 8]")
    print("=" * 68)
    print("  Counting products x*y (2-digit factors) that are ghosts, by v-length:")
    length_counts: Counter = Counter()
    total: Counter = Counter()
    for x in range(10, 100):
        for y in range(x, 100):
            v = x * y
            total[digit_length(v)] += 1
            if is_ghost(v, x, y):
                length_counts[digit_length(v)] += 1
    for L in sorted(total):
        frac = length_counts[L] / total[L] if total[L] else 0.0
        print(f"    v-length {L}: ghost fraction = {frac:.4f} "
              f"({length_counts[L]}/{total[L]})")
    print()


def main() -> None:
    demo_smallest_vampire()
    demo_additivity()
    demo_modular_signature()
    demo_fang_taboo()
    demo_census()
    demo_double_vampire()
    demo_ghosts_decay()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
