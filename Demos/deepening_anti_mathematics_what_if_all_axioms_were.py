"""
Anti-Mathematics: the Ackermann model of the hereditarily finite sets.

Negating the Axiom of Infinity yields the universe HF = V_omega of
hereditarily finite sets.  The Ackermann coding realizes it inside the
natural numbers:

    a is a member of b   <=>   the a-th binary digit of b is 1.

Under this reading every natural number IS a finite set, and every finite
set of numbers is a unique natural number.  This module demonstrates, with
plain integer arithmetic, all the main results of the accompanying paper:

  * membership decreases the code (a in b => a < b),
  * the finite axioms (empty, pairing, union, power set),
  * the Separation and Replacement schemas as explicit bitmasks,
  * Choice as a theorem: least-member selection builds a genuine choice set,
  * hereditary finiteness, and the rank function with rank(a) <= a.

Everything is self-contained: standard library only, full type hints.
"""

from __future__ import annotations

from typing import Callable, Iterable


# --------------------------------------------------------------------------
# Core: Ackermann membership and decoding
# --------------------------------------------------------------------------

def mem(a: int, b: int) -> bool:
    """Ackermann membership: a in b iff the a-th binary digit of b is 1."""
    return (b >> a) & 1 == 1


def members(b: int) -> list[int]:
    """The finite set of members of the set coded by b (its set-bit indices)."""
    return [a for a in range(b.bit_length()) if mem(a, b)]


def encode(s: Iterable[int]) -> int:
    """Encode a finite set of naturals as its Ackermann code: sum of 2**a."""
    code = 0
    for a in set(s):
        code |= 1 << a
    return code


def show(b: int, depth: int = 3) -> str:
    """Render the set coded by b in ordinary braces notation (bounded depth)."""
    if b == 0:
        return "{}"
    if depth == 0:
        return f"<{b}>"
    return "{" + ", ".join(show(x, depth - 1) for x in members(b)) + "}"


# --------------------------------------------------------------------------
# The fundamental inequality:  a in b  =>  a < b
# --------------------------------------------------------------------------

def check_mem_lt(bound: int = 64) -> bool:
    """Verify a in b => a < b for all codes b < bound."""
    for b in range(bound):
        for a in members(b):
            if not a < b:
                return False
    return True


# --------------------------------------------------------------------------
# Finite ZF axioms
# --------------------------------------------------------------------------

def pair(a: int, b: int) -> int:
    """Pairing: the set {a, b}."""
    return (1 << a) | (1 << b)


def union(a: int) -> int:
    """Union: the set U a = { x : exists y in a, x in y }."""
    result = 0
    for y in members(a):
        result |= y  # the code of y already has exactly y's members' bits on
    return result


def power_set(a: int) -> int:
    """Power set: the set of all subsets of a, as an HF object."""
    ms = members(a)
    subset_codes: list[int] = []
    for mask in range(1 << len(ms)):
        subset = encode(ms[i] for i in range(len(ms)) if (mask >> i) & 1)
        subset_codes.append(subset)
    return encode(subset_codes)


# --------------------------------------------------------------------------
# The schemas: Separation and Replacement, as explicit bitmasks
# --------------------------------------------------------------------------

def separation(a: int, p: Callable[[int], bool]) -> int:
    """Separation schema: { x in a : p(x) }, built by folding a bitmask.

    We fold over the members of a (its set-bit indices).  Every member y
    satisfies y < a, so this is exactly the range-restricted mask of the paper.
    """
    s = 0
    for y in members(a):
        if p(y):
            s |= 1 << y
    return s


def replacement(a: int, f: Callable[[int], int]) -> int:
    """Replacement schema: { f(x) : x in a }, built by folding a bitmask."""
    s = 0
    for x in members(a):
        s |= 1 << f(x)
    return s


# --------------------------------------------------------------------------
# Choice as a theorem: least-member selection
# --------------------------------------------------------------------------

def least_member(b: int) -> int:
    """Least member of a nonempty set (index of the lowest set bit); junk 0 for {}."""
    if b == 0:
        return 0
    return (b & -b).bit_length() - 1  # number of trailing zeros


def choice_set(a: int) -> int:
    """Choice set for a family a of nonempty pairwise-disjoint sets:
    collect the least member of each member of a (Replacement with f = least_member).
    """
    return replacement(a, least_member)


# --------------------------------------------------------------------------
# Hereditary finiteness and rank
# --------------------------------------------------------------------------

def transitive_closure(a: int) -> set[int]:
    """The set of all in-ancestors of a (members, members of members, ...)."""
    seen: set[int] = set()
    stack = list(members(a))
    while stack:
        x = stack.pop()
        if x not in seen:
            seen.add(x)
            stack.extend(members(x))
    return seen


def rank(a: int, _memo: dict[int, int] | None = None) -> int:
    """Set-theoretic rank via in-recursion: rank(a) = sup{ rank(x)+1 : x in a }."""
    if _memo is None:
        _memo = {}
    if a in _memo:
        return _memo[a]
    ms = members(a)
    r = 0 if not ms else max(rank(x, _memo) + 1 for x in ms)
    _memo[a] = r
    return r


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("ANTI-MATHEMATICS: the Ackermann model of the finite universe HF")
    print("=" * 70)

    print("\n[1] Numbers ARE finite sets (Ackermann coding)")
    for b in range(6):
        print(f"    {b:>2} = {show(b)}   members = {members(b)}")
    print(f"    11 = {show(11)}   members = {members(11)}")

    print("\n[2] Fundamental inequality:  a in b  =>  a < b")
    print(f"    holds for all codes below 64: {check_mem_lt(64)}")

    print("\n[3] Finite ZF axioms on codes")
    print(f"    pair(1,3)      = {show(pair(1, 3))}   (code {pair(1,3)})")
    a = encode([1, 2])                 # {1,2} where 1={{}}, 2={ {} ... }
    nested = encode([encode([0]), encode([1])])  # { {0}, {1} }
    print(f"    union({show(nested)}) = {show(union(nested))}")
    p = power_set(pair(0, 1))
    print(f"    power_set({show(pair(0,1))}) = {show(p)}   (has {len(members(p))} subsets)")

    print("\n[4] Separation schema:  { x in a : x is even }")
    a = encode([0, 1, 2, 3, 4, 5])
    s = separation(a, lambda x: x % 2 == 0)
    print(f"    a = {members(a)},  separated = {members(s)}")

    print("\n[5] Replacement schema:  { x+10 : x in a }")
    r = replacement(a, lambda x: x + 10)
    print(f"    a = {members(a)},  image = {members(r)}")

    print("\n[6] Choice is a THEOREM here (least-member selection)")
    # A family of nonempty, pairwise-disjoint sets:
    b1 = encode([3, 5])
    b2 = encode([7, 9, 11])
    b3 = encode([13])
    family = encode([b1, b2, b3])
    c = choice_set(family)
    print(f"    family members: {[members(b) for b in members(family)]}")
    print(f"    choice set:     {members(c)}")
    for b in members(family):
        hit = [x for x in members(c) if mem(x, b)]
        print(f"      meets {members(b)} in exactly one point: {hit}  (|.|={len(hit)})")

    print("\n[7] Hereditary finiteness and rank (rank(a) <= a)")
    for b in [0, 1, 3, 11, 2 ** 8 + 5]:
        tc = transitive_closure(b)
        print(f"    b={b:>4}  rank={rank(b)}  |trans.closure|={len(tc)}  rank<=b: {rank(b) <= b}")

    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
