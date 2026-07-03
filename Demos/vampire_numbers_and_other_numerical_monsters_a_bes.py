"""
A Bestiary of Arithmetic Monsters: Vampire Numbers and Their Congruences.

This self-contained script demonstrates the mathematical results of the paper:

  * The fang relation (digit-permutation condition) defining vampire numbers.
  * The additive congruence law:  x * y == x + y   (mod b - 1).
  * The unit reformulation:      (x-1)*(y-1) == 1  (mod b - 1).
  * The base-10 corollary: no fang is congruent to 1 modulo 3.
  * General casting out nines: n == digitsum_b(n) (mod b - 1).
  * The multi-fang generalization: prod(L) == sum(L) (mod b - 1).

Run:  python demo.py
"""

from __future__ import annotations

from collections import Counter
from typing import List, Tuple


# --------------------------------------------------------------------------- #
# Digit utilities
# --------------------------------------------------------------------------- #
def digits(b: int, n: int) -> List[int]:
    """Base-b digits of n, least significant first (digits(b, 0) == [])."""
    if b < 2:
        raise ValueError("base must be >= 2")
    out: List[int] = []
    while n > 0:
        out.append(n % b)
        n //= b
    return out


def digit_multiset(b: int, n: int) -> Counter:
    """Multiset (Counter) of the base-b digits of n."""
    return Counter(digits(b, n))


def digit_sum(b: int, n: int) -> int:
    """Sum of the base-b digits of n."""
    return sum(digits(b, n))


# --------------------------------------------------------------------------- #
# The fang relation and the bestiary
# --------------------------------------------------------------------------- #
def is_fang_pair(b: int, x: int, y: int) -> bool:
    """True iff digits of x*y are a permutation of digits(x) ++ digits(y)."""
    return digit_multiset(b, x * y) == digit_multiset(b, x) + digit_multiset(b, y)


def is_fang_list(b: int, factors: List[int]) -> bool:
    """Multi-fang generalization: digits of the product are a permutation of
    all digits of all factors pooled together."""
    prod = 1
    pooled: Counter = Counter()
    for f in factors:
        prod *= f
        pooled += digit_multiset(b, f)
    return digit_multiset(b, prod) == pooled


def is_vampire(v: int) -> List[Tuple[int, int]]:
    """Return all valid base-10 vampire fang factorizations of v (possibly
    empty). Requires v to have an even number 2n of digits, each fang to have
    n digits, and the fangs not both divisible by 10."""
    s = str(v)
    if len(s) % 2 != 0:
        return []
    n = len(s) // 2
    lo, hi = 10 ** (n - 1), 10 ** n
    found: List[Tuple[int, int]] = []
    x = lo
    while x * x <= v:
        if v % x == 0:
            y = v // x
            if lo <= y < hi and not (x % 10 == 0 and y % 10 == 0):
                if is_fang_pair(10, x, y):
                    found.append((x, y))
        x += 1
    return found


def is_ghost(v: int, x: int, y: int) -> bool:
    """Ghost: digits of v = x*y are disjoint from digits of x and of y."""
    dv = set(digits(10, v))
    return v == x * y and dv.isdisjoint(digits(10, x)) and dv.isdisjoint(digits(10, y))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_smallest_vampire() -> None:
    print("== The smallest vampire number ==")
    v, x, y = 1260, 21, 60
    print(f"{v} = {x} * {y}")
    print(f"  digits({v})      = {sorted(digits(10, v))}")
    print(f"  digits({x})+({y}) = {sorted(digits(10, x) + digits(10, y))}")
    print(f"  is_fang_pair     = {is_fang_pair(10, x, y)}")
    print()


def demo_congruence_laws() -> None:
    print("== Congruence laws on vampire fangs (base 10, modulus 9) ==")
    vampires = enumerate_vampires(10 ** 4)
    print(f"{'v':>7} {'x':>4} {'y':>4}  xy%9  (x+y)%9  (x-1)(y-1)%9")
    for v, x, y in vampires[:10]:
        a = (x * y) % 9
        s = (x + y) % 9
        u = ((x - 1) * (y - 1)) % 9
        assert a == s, "additive law violated!"
        assert u == 1, "unit law violated!"
        assert x % 3 != 1 and y % 3 != 1, "fang == 1 mod 3!"
        print(f"{v:>7} {x:>4} {y:>4}  {a:>4}  {s:>7}  {u:>11}")
    print("  All laws verified: xy==x+y (mod 9), (x-1)(y-1)==1 (mod 9),")
    print("  and no fang is 1 (mod 3).")
    print()


def demo_casting_out_nines() -> None:
    print("== General casting out nines: n == digitsum_b(n) (mod b-1) ==")
    for b in (2, 3, 10, 16):
        ok = all((n - digit_sum(b, n)) % (b - 1) == 0 for n in range(0, 500))
        print(f"  base {b:>2}: holds for n in [0,500) -> {ok}")
    print()


def demo_multifang() -> None:
    print("== Multi-fang law: prod(L) == sum(L) (mod b-1) ==")
    # 1260 as a three-factor fang list with digits conserved.
    examples = [[21, 60], [15, 93], [27, 81]]
    for L in examples:
        prod = 1
        for f in L:
            prod *= f
        tag = "fang list" if is_fang_list(10, L) else "not a fang list"
        print(f"  L={L}: prod={prod}, prod%9={prod % 9}, sum%9={sum(L) % 9}  ({tag})")
    print()


def demo_ghosts() -> None:
    print("== Ghost numbers thin out as digits grow ==")
    for width in (2, 3, 4):
        lo, hi = 10 ** (width - 1), 10 ** width
        count = 0
        total = 0
        for v in range(lo, hi):
            x = 2
            found = False
            while x * x <= v:
                if v % x == 0 and is_ghost(v, x, v // x):
                    found = True
                    break
                x += 1
            total += 1
            count += int(found)
        print(f"  {width}-digit numbers: {count}/{total} admit a ghost factorization "
              f"({100 * count / total:.2f}%)")
    print()


def enumerate_vampires(limit: int) -> List[Tuple[int, int, int]]:
    """All (v, x, y) vampire triples with v < limit."""
    out: List[Tuple[int, int, int]] = []
    width = 2
    while 10 ** width <= limit:
        lo, hi = 10 ** (width - 1), min(10 ** width, limit)
        for v in range(lo, hi):
            for (x, y) in is_vampire(v):
                out.append((v, x, y))
        width += 2
    return out


def main() -> None:
    demo_smallest_vampire()
    demo_congruence_laws()
    demo_casting_out_nines()
    demo_multifang()
    demo_ghosts()
    print("== First vampire numbers below 10000 ==")
    for v, x, y in enumerate_vampires(10 ** 4):
        print(f"  {v} = {x} * {y}")


if __name__ == "__main__":
    main()
