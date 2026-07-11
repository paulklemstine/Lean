"""
Anti-Mathematics: numerical demonstrations of the negated set-theory axioms.

This self-contained script realizes the three "anti-universes" described in the
accompanying paper, all built on Ackermann's binary coding of the hereditarily
finite sets by the natural numbers:

    a is a member of b   <=>   the a-th binary digit of b is 1.

We then demonstrate, with concrete computations:

    I.   Negating Infinity  -> the hereditarily finite universe (no inductive set).
    II.  Negating Extensionality -> distinct objects with identical members.
    III. Negating Foundation -> a Quine atom Omega = {Omega} (a membership loop).

Run:  python demo.py
"""

from __future__ import annotations

from typing import Iterator, List, Optional, Set, Tuple


# ---------------------------------------------------------------------------
# I. The Ackermann coding: natural numbers ARE hereditarily finite sets.
# ---------------------------------------------------------------------------

def mem(a: int, b: int) -> bool:
    """Ackermann membership: a in b iff the a-th binary digit of b is 1."""
    return (b >> a) & 1 == 1


def members(b: int) -> List[int]:
    """The (finite) list of members of the set coded by b, in increasing order."""
    return [a for a in range(b.bit_length()) if mem(a, b)]


def decode(b: int) -> str:
    """Render the set coded by b in braces notation, recursively."""
    return "{" + ", ".join(decode(a) for a in members(b)) + "}"


def adjoin(a: int, b: int) -> int:
    """b union {a}: switch on bit a of b."""
    return b | (1 << a)


def bin_union(a: int, b: int) -> int:
    """a union b as a bitwise OR."""
    return a | b


def is_subset(x: int, a: int) -> bool:
    """x subset of a  <=>  x & a == x  (Theorem: subset via bitmask)."""
    return (x & a) == x


def union_axiom(a: int) -> int:
    """Big union of a: members of members of a."""
    u = 0
    for b in members(a):
        u |= b
    return u


def power_set(a: int) -> int:
    """Power set of a: the code whose members are exactly the subsets of a."""
    p = 0
    for x in range(a + 1):
        if is_subset(x, a):
            p |= (1 << x)
    return p


def succ(a: int) -> int:
    """von Neumann successor a union {a}."""
    return adjoin(a, a)


def numeral(n: int) -> int:
    """The n-th von Neumann numeral, coded in the Ackermann model."""
    x = 0
    for _ in range(n):
        x = succ(x)
    return x


# ---------------------------------------------------------------------------
# Demonstration helpers for each result.
# ---------------------------------------------------------------------------

def demo_coding() -> None:
    print("=" * 70)
    print("Ackermann coding: every natural number IS a hereditarily finite set")
    print("=" * 70)
    for b in range(11):
        print(f"  {b:2d} = {format(b, '06b')}_2  ->  {decode(b)}")

    print("\n  Empty set is 0:", members(0) == [])
    print("  Extensionality check (0..63 all distinct as sets):",
          len({decode(b) for b in range(64)}) == 64)

    # Verify the ZF operations on random-ish samples.
    ok_pair = ok_union = ok_pow = True
    for a in range(8):
        for b in range(8):
            p = adjoin(a, adjoin(b, 0))          # pairing {a, b}
            ok_pair &= set(members(p)) == {a, b}
            u = bin_union(a, b)
            ok_union &= set(members(u)) == set(members(a)) | set(members(b))
    for a in range(8):
        want = {x for x in range(a + 1) if is_subset(x, a)}
        ok_pow &= set(members(power_set(a))) == want
    print("  Pairing correct on all pairs (0..7):", ok_pair)
    print("  Binary union correct on all pairs (0..7):", ok_union)
    print("  Power set correct (0..7):", ok_pow)


def demo_anti_infinity(bound: int = 200) -> None:
    print("\n" + "=" * 70)
    print("I. NEGATING INFINITY -> hereditarily finite sets (no inductive set)")
    print("=" * 70)

    print("  von Neumann numerals grow at least as fast as their index")
    print("  (in fact they explode super-exponentially):")
    for n in range(5):
        print(f"    numeral({n}) = {numeral(n):4d}   (n <= numeral(n): {n <= numeral(n)})")

    # Search for an inductive set below `bound`: contains 0 and closed under succ.
    def is_inductive(I: int) -> bool:
        if not mem(0, I):
            return False
        for x in members(I):
            if not mem(succ(x), I):
                return False
        return True

    witnesses = [I for I in range(bound) if is_inductive(I)]
    print(f"\n  Inductive sets found below {bound}: {witnesses}")
    print("  Theorem (Anti-Infinity): NONE exist, for the sharp reason that an")
    print("  inductive I would contain numeral(I), forcing numeral(I) < I <= numeral(I).")
    # Illustrate the contradiction concretely for a small candidate:
    I = 4
    print(f"\n  Example obstruction at I = {I}:")
    print(f"    numeral({I}) = {numeral(I)}  and  I = {I}  =>  I <= numeral(I): "
          f"{I <= numeral(I)}")
    print("    so numeral(I) can never satisfy numeral(I) < I; no I is inductive.")


def demo_anti_extensionality() -> None:
    print("\n" + "=" * 70)
    print("II. NEGATING EXTENSIONALITY -> indistinguishable sets")
    print("=" * 70)
    # Universe V = {STAR} u N.  STAR is a second, distinct empty object.
    STAR: Optional[int] = None  # the extra element

    def nmem(x: Optional[int], y: Optional[int]) -> bool:
        if x is None or y is None:
            return False  # STAR is never a member and has no members
        return mem(x, y)

    def indist(a: Optional[int], b: Optional[int], probe: int = 16) -> bool:
        cands: List[Optional[int]] = [STAR] + list(range(probe))
        return all(nmem(x, a) == nmem(x, b) for x in cands)

    print("  0 and STAR are distinct objects, both with no members:")
    print("    members of 0   :", [x for x in range(16) if nmem(x, 0)])
    print("    members of STAR:", [x for x in range(16) if nmem(x, STAR)])
    print("    0 == STAR ?", 0 == STAR, " | indistinguishable(0, STAR)?",
          indist(0, STAR))

    print("\n  Indistinguishability collapses ONLY {0, STAR}:")
    for n in range(1, 6):
        print(f"    indistinguishable(some {n}, STAR)? {indist(n, STAR)} "
              f"(only true for n=0)")

    print("\n  Membership is NOT a congruence (obstruction to quotienting):")
    print(f"    0 ~ STAR, and 0 in 1 = {{0}}:  nmem(0, 1) = {nmem(0, 1)}")
    print(f"    but STAR not in 1:            nmem(STAR, 1) = {nmem(STAR, 1)}")
    print("    => cannot glue indistinguishables to recover Extensionality.")


def demo_anti_foundation() -> None:
    print("\n" + "=" * 70)
    print("III. NEGATING FOUNDATION -> a Quine atom  Omega = {Omega}")
    print("=" * 70)
    # Universe W = {OMEGA} u N.  OMEGA's only member is itself.
    OMEGA: Optional[int] = None

    def wmem(x: Optional[int], y: Optional[int]) -> bool:
        if x is None and y is None:
            return True          # Omega in Omega
        if x is None or y is None:
            return False         # no other membership involving Omega
        return mem(x, y)

    print("  Omega in Omega ?", wmem(OMEGA, OMEGA))
    print("  Omega's members:", "{Omega}" if wmem(OMEGA, OMEGA) else "{}")
    print("  Genuine sets never contain themselves:")
    print("    any n with n in n (n=0..63)?",
          [n for n in range(64) if wmem(n, n)])

    print("\n  Regularity fails: Omega is nonempty but has no in-minimal member,")
    print("  since its only member Omega satisfies Omega in Omega.")

    print("\n  An infinite descending membership chain (well-foundedness fails):")
    chain = " in ".join(["Omega"] * 6) + " in ..."
    print("    " + chain)


def main() -> None:
    demo_coding()
    demo_anti_infinity()
    demo_anti_extensionality()
    demo_anti_foundation()
    print("\n" + "=" * 70)
    print("All three anti-universes realized concretely over the natural numbers.")
    print("=" * 70)


if __name__ == "__main__":
    main()
