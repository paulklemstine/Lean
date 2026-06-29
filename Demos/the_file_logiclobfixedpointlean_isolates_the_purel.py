"""
Numerical demonstration of the order-theoretic core of Gödel-Löb provability logic.

This script realizes the abstract Gödel-Löb (Magari) algebra concretely on finite
truncations of the converse-well-founded frame (N, <).  Propositions are modeled as
subsets of {0, 1, ..., N-1}; the provability operator is

        box(S) = { n | for all m < n, m in S }.

We verify, purely by computation, every theorem from the formal development:

  * box_top            : box(TOP) = TOP
  * box_inf  (axiom K) : box(A & B) = box(A) & box(B)
  * loeb               : box(box(A) -> A) <= box(A)
  * box_mono           : A <= B  =>  box(A) <= box(B)
  * loeb_fixed_point   : box(box(A) -> A) = box(A)        (de Jongh-Sambin)
  * loeb_rule          : box(A) <= A  =>  A = TOP         (Lob's theorem)
  * box_transitive     : box(A) <= box(box(A))            (modal axiom 4)
  * godel_second       : box(box(BOT) -> BOT) = box(BOT)  (Godel II)
  * natGL_consistent   : box(BOT) = {0} != TOP
  * iterate            : box^k(BOT) = {0,...,k-1}          (provability rank)
  * godel_hierarchy    : strictly increasing unprovable consistency spectrum

Everything is self-contained; no imports beyond the standard library.
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, Iterable, List, Tuple

# A "proposition" is a frozenset of natural numbers (stages) in {0, ..., N-1}.
Prop = FrozenSet[int]


# ----------------------------------------------------------------------------- #
#  Heyting / Boolean algebra of subsets of {0, ..., N-1}
# ----------------------------------------------------------------------------- #
def top(n: int) -> Prop:
    """The TOP element: the full universe {0, ..., n-1}."""
    return frozenset(range(n))


def bot() -> Prop:
    """The BOT element: the empty set (contradiction)."""
    return frozenset()


def meet(a: Prop, b: Prop) -> Prop:
    """Lattice meet (conjunction): intersection."""
    return a & b


def join(a: Prop, b: Prop) -> Prop:
    """Lattice join (disjunction): union."""
    return a | b


def himp(a: Prop, b: Prop, n: int) -> Prop:
    """Heyting (here Boolean) implication a => b  =  complement(a) | b."""
    universe = top(n)
    return (universe - a) | b


def le(a: Prop, b: Prop) -> bool:
    """Order: a <= b  iff  a is a subset of b."""
    return a <= b


# ----------------------------------------------------------------------------- #
#  The Gödel-Löb provability operator of the frame (N, <)
# ----------------------------------------------------------------------------- #
def box(s: Prop, n: int) -> Prop:
    """
    Provability operator: n proves S iff every strictly earlier stage is in S.

        box(S) = { k in {0,...,n-1} | for all m < k, m in S }.
    """
    result = []
    for k in range(n):
        if all((m in s) for m in range(k)):
            result.append(k)
    return frozenset(result)


def box_iter(s: Prop, k: int, n: int) -> Prop:
    """Apply the box operator k times."""
    cur = s
    for _ in range(k):
        cur = box(cur, n)
    return cur


# ----------------------------------------------------------------------------- #
#  Enumerate all propositions (for exhaustive axiom checking)
# ----------------------------------------------------------------------------- #
def all_props(n: int) -> List[Prop]:
    """All 2^n subsets of {0, ..., n-1}."""
    elements = list(range(n))
    subsets: List[Prop] = []
    for size in range(n + 1):
        for combo in combinations(elements, size):
            subsets.append(frozenset(combo))
    return subsets


def fmt(s: Prop) -> str:
    """Pretty-print a proposition as a sorted set."""
    return "{" + ", ".join(str(x) for x in sorted(s)) + "}" if s else "{}"


# ----------------------------------------------------------------------------- #
#  Axiom and theorem verification
# ----------------------------------------------------------------------------- #
def check_axioms(n: int) -> bool:
    """Exhaustively verify the three GL axioms on all subsets of {0,...,n-1}."""
    props = all_props(n)
    universe = top(n)

    # box_top
    assert box(universe, n) == universe, "box_top failed"

    ok = True
    for a in props:
        # Löb: box(box A => A) <= box A
        lhs = box(himp(box(a, n), a, n), n)
        assert le(lhs, box(a, n)), "loeb failed"
        # de Jongh-Sambin fixed point: equality, not just <=
        assert lhs == box(a, n), "loeb_fixed_point failed"
        # modal axiom 4: box A <= box box A
        assert le(box(a, n), box(box(a, n), n)), "box_transitive failed"
        for b in props:
            # axiom K: box(A & B) = box A & box B
            assert box(meet(a, b), n) == meet(box(a, n), box(b, n)), "box_inf failed"
            # monotonicity
            if le(a, b):
                assert le(box(a, n), box(b, n)), "box_mono failed"
    return ok


def check_loeb_rule(n: int) -> List[Prop]:
    """Return all A with box A <= A; Löb's theorem predicts only A = TOP."""
    reflexive = [a for a in all_props(n) if le(box(a, n), a)]
    return reflexive


def godel_second(n: int) -> Tuple[Prop, Prop]:
    """Godel II: box(box BOT => BOT) should equal box BOT."""
    b = bot()
    lhs = box(himp(box(b, n), b, n), n)
    rhs = box(b, n)
    return lhs, rhs


def consistency_spectrum(n: int, kmax: int) -> List[Tuple[int, Prop]]:
    """The strictly increasing chain box^k(BOT) = {0,...,k-1}."""
    return [(k, box_iter(bot(), k, n)) for k in range(kmax + 1)]


# ----------------------------------------------------------------------------- #
#  Driver
# ----------------------------------------------------------------------------- #
def main() -> None:
    N = 8  # work in the frame {0, ..., 7}

    print("=" * 70)
    print(" Godel-Lob provability algebra on the frame (N, <),  N =", N)
    print("=" * 70)

    print("\n[1] Verifying the three GL axioms on all", 2 ** N, "subsets ...")
    check_axioms(N)
    print("    box_top, box_inf (axiom K), and Lob's axiom all hold.")
    print("    Derived: monotonicity, fixed point, axiom 4 all verified.")

    print("\n[2] Lob's theorem (no nontrivial reflexive points):")
    reflexive = check_loeb_rule(N)
    print("    Sets A with box(A) <= A:", [fmt(a) for a in reflexive])
    print("    Predicted by loeb_rule: only TOP =", fmt(top(N)))
    assert reflexive == [top(N)]
    print("    Confirmed: the ONLY self-justifying sentence is TOP.")

    print("\n[3] de Jongh-Sambin fixed point  box(box A => A) = box A:")
    for a in [frozenset({1, 3}), frozenset({0, 2, 4}), bot()]:
        lhs = box(himp(box(a, N), a, N), N)
        print(f"    A = {fmt(a):>14} :  box(box A => A) = {fmt(lhs):>16}"
              f"  =?  box A = {fmt(box(a, N))}")
        assert lhs == box(a, N)

    print("\n[4] Godel's Second Incompleteness Theorem  box(box BOT => BOT) = box BOT:")
    lhs, rhs = godel_second(N)
    print("    box(Con) =", fmt(lhs), "   box(BOT) =", fmt(rhs))
    assert lhs == rhs
    print("    Provability of consistency = provability of falsity.")
    print("    Consistency holds: box(BOT) =", fmt(rhs), "!= TOP, so Con is UNPROVABLE.")

    print("\n[5] Provability rank  box^k(BOT) = {0, ..., k-1}  (frame depth = index):")
    spectrum = consistency_spectrum(N, N)
    for k, s in spectrum:
        print(f"    box^{k}(BOT) = {fmt(s)}")
    # strict monotonicity, never reaching TOP
    for (k1, s1), (k2, s2) in zip(spectrum, spectrum[1:]):
        assert s1 < s2 or (s1 == s2 == top(N))
    print("    Strictly increasing consistency strengths; none equals TOP (until")
    print("    the finite truncation saturates) -- an explicit unprovability spectrum.")

    print("\nAll computational checks passed. The order-theoretic core is sound.")


if __name__ == "__main__":
    main()
