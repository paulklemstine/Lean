"""
demo.py -- The Order-Theoretic Core of Gödel-Löb Provability Logic
==================================================================

Self-contained numerical demonstrations of the results in the accompanying
article and research paper. Everything is computed inside the concrete
consistent Gödel-Löb algebra (Set N, natBox), the provability box of the
converse well-founded frame (N, >):

    natBox S = { n | for all m < n, m in S }   ("n proves S iff every
                                                 strictly smaller world is in S")

On a bounded universe {0, 1, ..., N-1} this is fully decidable, so we can
*compute* every theorem rather than merely assert it:

  * Lattice / Boolean algebra operations on Set N (meet, join, complement,
    Heyting implication X => Y = X^c | Y).
  * The three Gödel-Löb axioms (necessitation, normality, Löb) verified.
  * box_transitive (axiom 4), Löb's rule, Gödel II verified numerically.
  * The de Jongh-Sambin fixed point glFix c = box c => c and its uniqueness.
  * The provability-rank computation  box^k(empty) = {0,...,k-1} = Iio k.
  * The strictly increasing consistency hierarchy and graded Gödel II.
  * The de Morgan dual consistency diamond  dia a = (box a^c)^c  as a
    well-founded co-closure (dia_bot, dia_sup, dia_dia_le, dual Löb law).
  * The general frame box wfBox(r) for an arbitrary transitive well-founded r.

No third-party dependencies; standard library only.
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, FrozenSet, List, Set, Tuple

# A "proposition" in the model is a subset of the bounded universe {0,...,N-1}.
Prop = FrozenSet[int]


# ---------------------------------------------------------------------------
# Boolean / Heyting algebra structure on the powerset of {0, ..., N-1}
# ---------------------------------------------------------------------------
def universe(n: int) -> Prop:
    """The top element T = {0, 1, ..., n-1}."""
    return frozenset(range(n))


def bot() -> Prop:
    """The bottom element (falsity) = empty set."""
    return frozenset()


def meet(a: Prop, b: Prop) -> Prop:
    """Lattice meet a ^ b  (logical AND) = intersection."""
    return a & b


def join(a: Prop, b: Prop) -> Prop:
    """Lattice join a v b  (logical OR) = union."""
    return a | b


def compl(a: Prop, n: int) -> Prop:
    """Boolean complement a^c relative to the universe of size n."""
    return universe(n) - a


def himp(a: Prop, b: Prop, n: int) -> Prop:
    """Heyting/Boolean implication a => b = a^c | b."""
    return compl(a, n) | b


def le(a: Prop, b: Prop) -> bool:
    """Lattice order a <= b  iff  a is a subset of b."""
    return a <= b


# ---------------------------------------------------------------------------
# The provability box of the well-founded frame (N, >)
# ---------------------------------------------------------------------------
def nat_box(s: Prop, n: int) -> Prop:
    """natBox S = { k < n | for all m < k, m in S }.

    A single left-to-right sweep: world k is in natBox S iff every world
    0,...,k-1 already lies in S. Runs in O(n).
    """
    result: Set[int] = set()
    prefix_all_in_s = True
    for k in range(n):
        if prefix_all_in_s:
            result.add(k)
        if k not in s:
            prefix_all_in_s = False
    return frozenset(result)


def box_iterate(k: int, s: Prop, n: int) -> Prop:
    """Apply the box k times: box^k(S)."""
    cur = s
    for _ in range(k):
        cur = nat_box(cur, n)
    return cur


def iio(k: int, n: int) -> Prop:
    """The initial segment Iio k = {0, 1, ..., k-1}, capped at the universe."""
    return frozenset(range(min(k, n)))


# ---------------------------------------------------------------------------
# The consistency diamond  dia a = (box a^c)^c  (de Morgan dual of box)
# ---------------------------------------------------------------------------
def dia(a: Prop, n: int) -> Prop:
    """Consistency operator dia a = not box not a = (box a^c)^c."""
    return compl(nat_box(compl(a, n), n), n)


# ---------------------------------------------------------------------------
# A general transitive well-founded frame box (Section 6.2)
# ---------------------------------------------------------------------------
def wf_box(r: Callable[[int, int], bool], s: Prop, n: int) -> Prop:
    """wfBox r S = { x | for all y, r y x -> y in S } on universe {0,...,n-1}."""
    result: Set[int] = set()
    for x in range(n):
        if all((y in s) for y in range(n) if r(y, x)):
            result.add(x)
    return frozenset(result)


# ---------------------------------------------------------------------------
# Verification helpers (exhaustive over all subsets of a small universe)
# ---------------------------------------------------------------------------
def all_subsets(n: int) -> List[Prop]:
    """Enumerate every subset of {0, ..., n-1}."""
    elems = list(range(n))
    out: List[Prop] = []
    for size in range(n + 1):
        for combo in combinations(elems, size):
            out.append(frozenset(combo))
    return out


def show(label: str, ok: bool) -> None:
    print(f"  [{'PASS' if ok else 'FAIL'}] {label}")
    assert ok, f"property failed: {label}"


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_axioms(n: int = 6) -> None:
    """Verify the three Gödel-Löb axioms hold for natBox on universe size n."""
    print(f"\n=== Gödel-Löb axioms for natBox on universe size {n} ===")
    top = universe(n)
    subsets = all_subsets(n)

    # (N) Necessitation of truth: box T = T
    show("box_top:  box(T) = T", nat_box(top, n) == top)

    # (K) Normality: box(a ^ b) = box a ^ box b
    normality = all(
        nat_box(meet(a, b), n) == meet(nat_box(a, n), nat_box(b, n))
        for a in subsets
        for b in subsets
    )
    show("box_inf:  box(a ^ b) = box a ^ box b", normality)

    # (L) Löb's axiom: box(box a => a) <= box a
    loeb = all(
        le(nat_box(himp(nat_box(a, n), a, n), n), nat_box(a, n))
        for a in subsets
    )
    show("loeb:     box(box a => a) <= box a", loeb)

    # Derived: monotonicity and transitivity (axiom 4)
    mono = all(
        (not le(a, b)) or le(nat_box(a, n), nat_box(b, n))
        for a in subsets
        for b in subsets
    )
    show("box_mono: a <= b  =>  box a <= box b", mono)

    trans = all(le(nat_box(a, n), nat_box(nat_box(a, n), n)) for a in subsets)
    show("box_transitive (axiom 4): box a <= box box a", trans)


def demo_loeb_rule_and_godel(n: int = 6) -> None:
    """Löb's rule, the unique self-provable element, and Gödel II."""
    print(f"\n=== Löb's rule and Gödel II on universe size {n} ===")
    top = universe(n)
    subsets = all_subsets(n)

    # Löb's rule: box a <= a  =>  a = T.  (Only T is self-justifying.)
    loeb_rule = all(
        (not le(nat_box(a, n), a)) or (a == top) for a in subsets
    )
    show("loeb_rule: box a <= a  =>  a = T", loeb_rule)

    # Only self-provable element: box a = a  =>  a = T.
    only_top = all((nat_box(a, n) != a) or (a == top) for a in subsets)
    show("box_fixedPoint_eq_top: box a = a  =>  a = T", only_top)

    # Consistency: box(bot) != T.  In fact box(bot) = {0}.
    box_bot = nat_box(bot(), n)
    show("consistency: box(bot) = {0} != T", box_bot == frozenset({0}))

    # Gödel II: box(box bot => bot) != T  (cannot prove own consistency).
    con = himp(box_bot, bot(), n)
    godel = nat_box(con, n) != top
    show("godel_second: box(box bot => bot) != T", godel)


def demo_fixed_point(n: int = 7) -> None:
    """The de Jongh-Sambin fixed point glFix c = box c => c, with uniqueness."""
    print(f"\n=== de Jongh-Sambin fixed point on universe size {n} ===")
    subsets = all_subsets(n)

    def gl_fix(c: Prop) -> Prop:
        return himp(nat_box(c, n), c, n)

    # box(glFix c) = box c
    prov = all(nat_box(gl_fix(c), n) == nat_box(c, n) for c in subsets)
    show("glFix_box: box(glFix c) = box c", prov)

    # Existence: glFix c = box(glFix c) => c
    exists = all(gl_fix(c) == himp(nat_box(gl_fix(c), n), c, n) for c in subsets)
    show("loeb_fixed_point: glFix c = box(glFix c) => c", exists)

    # Uniqueness: any a with a = box a => c equals glFix c.
    unique = True
    for c in subsets:
        for a in subsets:
            if a == himp(nat_box(a, n), c, n):  # a = (box a => c)
                if a != gl_fix(c):
                    unique = False
    show("glFix_unique: a = (box a => c)  =>  a = glFix c", unique)

    # Showcase c = bot: the Gödel consistency sentence is glFix(bot).
    c = bot()
    print(f"    glFix(bot) = consistency sentence = {sorted(gl_fix(c))}")


def demo_rank_and_hierarchy(n: int = 9) -> None:
    """The provability-rank ladder and the strict consistency hierarchy."""
    print(f"\n=== Provability rank box^k(bot) = Iio k  (universe size {n}) ===")
    top = universe(n)
    for k in range(n + 1):
        bk = box_iterate(k, bot(), n)
        match = bk == iio(k, n)
        print(f"    box^{k}(bot) = {str(sorted(bk)):<28} == Iio {k} : {match}")
        assert match

    # Strictly increasing chain, never reaching the top.
    print("\n  Strict consistency hierarchy (each strictly contains the previous):")
    chain = [box_iterate(k, bot(), n) for k in range(n)]
    strict = all(chain[k] < chain[k + 1] for k in range(n - 1))
    never_top = all(c != top for c in chain)
    show("consistency_strength_strictMono: box^k bot  strictly increasing", strict)
    show("never reaches T (the model stays consistent)", never_top)

    # Graded Gödel II: box(box^{k+1} bot => bot) != T  for every k.
    print("\n  Graded Gödel II (every nontrivial consistency strength unprovable):")
    for k in range(n - 1):
        target = box_iterate(k + 1, bot(), n)
        stmt = nat_box(himp(target, bot(), n), n)
        unprovable = stmt != top
        print(f"    k={k}: box(box^{k + 1} bot => bot) != T : {unprovable}")
        assert unprovable
    # Level 0 is provable: box^0 bot = bot, and (bot => bot) = T is provable.
    lvl0 = nat_box(himp(box_iterate(0, bot(), n), bot(), n), n)
    show("level 0 IS provable: box(bot => bot) = T", lvl0 == top)


def demo_diamond(n: int = 6) -> None:
    """The consistency diamond dia a = (box a^c)^c as a well-founded co-closure."""
    print(f"\n=== Consistency diamond dia a = not box not a  (universe size {n}) ===")
    subsets = all_subsets(n)

    # dia(bot) = bot  (dual of necessitation)
    show("dia_bot: dia(bot) = bot", dia(bot(), n) == bot())

    # dia(a v b) = dia a v dia b  (join preservation, dual of normality)
    dsup = all(
        dia(join(a, b), n) == join(dia(a, n), dia(b, n))
        for a in subsets
        for b in subsets
    )
    show("dia_sup: dia(a v b) = dia a v dia b", dsup)

    # Sub-idempotence: dia(dia a) <= dia a  (dual of axiom 4)
    subidem = all(le(dia(dia(a, n), n), dia(a, n)) for a in subsets)
    show("dia_dia_le: dia(dia a) <= dia a", subidem)

    # Dual Löb law: dia a <= dia(a ^ (dia a)^c)
    dual_loeb = all(
        le(dia(a, n), dia(meet(a, compl(dia(a, n), n)), n)) for a in subsets
    )
    show("dia_loeb: dia a <= dia(a ^ (dia a)^c)", dual_loeb)

    # Only fixed point of dia is bot.
    only_bot = all((dia(a, n) != a) or (a == bot()) for a in subsets)
    show("dia_fixedPoint_eq_bot: dia a = a  =>  a = bot", only_bot)


def demo_general_frame(n: int = 6) -> None:
    """wfBox for an arbitrary transitive well-founded relation validates Löb."""
    print(f"\n=== General frame box wfBox(r) on universe size {n} ===")
    # r = (<) is transitive and well-founded; wfBox(<) coincides with natBox.
    lt = lambda y, x: y < x
    coincide = all(
        wf_box(lt, s, n) == nat_box(s, n) for s in all_subsets(n)
    )
    show("natBox_eq_wfBox: wfBox(<) S = natBox S", coincide)

    # A different transitive well-founded relation: divisibility-by-strict-multiple
    # r y x  iff  y < x and y divides x.  Transitive and well-founded.
    div = lambda y, x: y > 0 and x > y and x % y == 0
    loeb_div = all(
        le(wf_box(div, himp(wf_box(div, s, n), s, n), n), wf_box(div, s, n))
        for s in all_subsets(n)
    )
    show("wfBox_loeb holds for the strict-divisibility frame too", loeb_div)


def main() -> None:
    print("=" * 70)
    print(" The Order-Theoretic Core of Gödel-Löb Provability Logic")
    print(" Numerical demonstrations in the model (Set N, natBox)")
    print("=" * 70)
    demo_axioms()
    demo_loeb_rule_and_godel()
    demo_fixed_point()
    demo_rank_and_hierarchy()
    demo_diamond()
    demo_general_frame()
    print("\nAll demonstrations passed.\n")


if __name__ == "__main__":
    main()
