"""
Numerical demonstrations for
"The Modal Logic of the Forcing Multiverse".

This self-contained script illustrates the three main strands of the work:

  1. Frame correspondences: on a finite Kripke frame, each modal axiom
     (T, 4, B, 5, .2) is valid exactly when the accessibility relation
     satisfies its corresponding first-order property (reflexive,
     transitive, symmetric, euclidean, confluent). We verify this on the
     directed antisymmetric order {0,1,2} under <=, obtaining S4.2 (not S5).

  2. Buttons and switches: over a finite frame, buttons are the assertions
     monotone along accessibility; switches are those with both an
     accessible witness and counterwitness from every world. We confirm the
     fixed-point characterization of buttons and that switches and buttons
     are disjoint on the nontrivial part.

  3. Quantitative independence: over n independent atoms there are 2^n
     branches and 2^(2^n) sentences, of which exactly 2 are settled, so
     2^(2^n) - 2 are independent, and that fraction tends to 1.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, List, Tuple

World = int
Assertion = Callable[[World], bool]
Relation = Callable[[World, World], bool]


# ----------------------------------------------------------------------
# 1. Modal operators and frame correspondences
# ----------------------------------------------------------------------

def box(worlds: List[World], R: Relation, P: Assertion) -> Assertion:
    """Necessity: (box P)(w) holds iff P holds in every world accessible from w."""
    return lambda w: all(P(v) for v in worlds if R(w, v))


def dia(worlds: List[World], R: Relation, P: Assertion) -> Assertion:
    """Possibility: (dia P)(w) holds iff P holds in some world accessible from w."""
    return lambda w: any(P(v) for v in worlds if R(w, v))


def all_assertions(worlds: List[World]) -> List[Assertion]:
    """Enumerate every predicate W -> Bool as a truth vector over the worlds."""
    out: List[Assertion] = []
    for bits in product([False, True], repeat=len(worlds)):
        table = dict(zip(worlds, bits))
        out.append(lambda w, table=table: table[w])
    return out


def valid_T(worlds: List[World], R: Relation) -> bool:
    """Axiom T: box p -> p holds for every assertion and world."""
    return all(
        box(worlds, R, P)(w) <= P(w)  # implication as boolean <=
        for P in all_assertions(worlds) for w in worlds
    )


def valid_4(worlds: List[World], R: Relation) -> bool:
    """Axiom 4: box p -> box box p."""
    return all(
        box(worlds, R, P)(w) <= box(worlds, R, box(worlds, R, P))(w)
        for P in all_assertions(worlds) for w in worlds
    )


def valid_B(worlds: List[World], R: Relation) -> bool:
    """Axiom B: p -> box dia p."""
    return all(
        P(w) <= box(worlds, R, dia(worlds, R, P))(w)
        for P in all_assertions(worlds) for w in worlds
    )


def valid_5(worlds: List[World], R: Relation) -> bool:
    """Axiom 5: dia p -> box dia p."""
    return all(
        dia(worlds, R, P)(w) <= box(worlds, R, dia(worlds, R, P))(w)
        for P in all_assertions(worlds) for w in worlds
    )


def valid_dot2(worlds: List[World], R: Relation) -> bool:
    """Axiom .2: dia box p -> box dia p."""
    return all(
        dia(worlds, R, box(worlds, R, P))(w) <= box(worlds, R, dia(worlds, R, P))(w)
        for P in all_assertions(worlds) for w in worlds
    )


def is_reflexive(worlds: List[World], R: Relation) -> bool:
    return all(R(x, x) for x in worlds)


def is_transitive(worlds: List[World], R: Relation) -> bool:
    return all(
        (not (R(x, y) and R(y, z))) or R(x, z)
        for x in worlds for y in worlds for z in worlds
    )


def is_symmetric(worlds: List[World], R: Relation) -> bool:
    return all((not R(x, y)) or R(y, x) for x in worlds for y in worlds)


def is_euclidean(worlds: List[World], R: Relation) -> bool:
    return all(
        (not (R(x, y) and R(x, z))) or R(y, z)
        for x in worlds for y in worlds for z in worlds
    )


def is_confluent(worlds: List[World], R: Relation) -> bool:
    return all(
        (not (R(x, y) and R(x, z)))
        or any(R(y, u) and R(z, u) for u in worlds)
        for x in worlds for y in worlds for z in worlds
    )


def demo_frame_correspondences() -> None:
    print("=" * 70)
    print("1. FRAME CORRESPONDENCES on the directed order ({0,1,2}, <=)")
    print("=" * 70)
    worlds = [0, 1, 2]
    R: Relation = lambda x, y: x <= y

    checks: List[Tuple[str, bool, bool]] = [
        ("T   (reflexive)", valid_T(worlds, R), is_reflexive(worlds, R)),
        ("4   (transitive)", valid_4(worlds, R), is_transitive(worlds, R)),
        ("B   (symmetric)", valid_B(worlds, R), is_symmetric(worlds, R)),
        ("5   (euclidean)", valid_5(worlds, R), is_euclidean(worlds, R)),
        (".2  (confluent)", valid_dot2(worlds, R), is_confluent(worlds, R)),
    ]
    print(f"{'axiom':22}{'valid?':>8}{'frame cond?':>14}{'agree?':>9}")
    for name, valid, cond in checks:
        print(f"{name:22}{str(valid):>8}{str(cond):>14}{str(valid == cond):>9}")
    print("\nT, 4, .2 hold; B, 5 fail  =>  logic is S4.2, not S5.\n")


# ----------------------------------------------------------------------
# 2. Buttons and switches
# ----------------------------------------------------------------------

def is_button(worlds: List[World], R: Relation, P: Assertion) -> bool:
    """Monotone along accessibility: once true, true in every extension."""
    return all(
        (not (R(w, v) and P(w))) or P(v)
        for w in worlds for v in worlds
    )


def is_switch(worlds: List[World], R: Relation, P: Assertion) -> bool:
    """From every world both P and not-P remain possible."""
    return all(
        dia(worlds, R, P)(w) and dia(worlds, R, lambda x: not P(x))(w)
        for w in worlds
    )


def is_box_fixed(worlds: List[World], R: Relation, P: Assertion) -> bool:
    """box P = P pointwise."""
    return all(box(worlds, R, P)(w) == P(w) for w in worlds)


def demo_buttons_switches() -> None:
    print("=" * 70)
    print("2. BUTTONS AND SWITCHES")
    print("=" * 70)
    worlds = [0, 1, 2]
    R: Relation = lambda x, y: x <= y  # reflexive frame

    buttons = 0
    fixed_matches = 0
    both_switch_and_button_nontrivial = 0
    for P in all_assertions(worlds):
        b = is_button(worlds, R, P)
        f = is_box_fixed(worlds, R, P)
        if b:
            buttons += 1
        if b == f:
            fixed_matches += 1
        if is_switch(worlds, R, P) and b and any(P(w) for w in worlds):
            both_switch_and_button_nontrivial += 1

    total = 2 ** len(worlds)
    print(f"Total assertions over 3 worlds : {total}")
    print(f"Buttons (monotone)             : {buttons}")
    print(f"button  <=>  (box P = P)       : {fixed_matches}/{total} agree")
    print(f"Nontrivial switch & button     : {both_switch_and_button_nontrivial}"
          "  (theory predicts 0)")

    # Fully connected multiverse: switches are exactly non-constant assertions.
    Rc: Relation = lambda x, y: True
    switches = sum(1 for P in all_assertions(worlds) if is_switch(worlds, Rc, P))
    nonconstant = sum(
        1 for P in all_assertions(worlds)
        if any(P(w) for w in worlds) and any(not P(w) for w in worlds)
    )
    print(f"Complete frame: switches       : {switches}")
    print(f"Complete frame: non-constant   : {nonconstant}  (should match)\n")


# ----------------------------------------------------------------------
# 3. Quantitative independence
# ----------------------------------------------------------------------

def count_branches(n: int) -> int:
    """Number of branches (truth assignments) over n atoms: 2^n."""
    return 2 ** n


def count_sentences(n: int) -> int:
    """Number of sentences (Boolean functions of branches): 2^(2^n)."""
    return 2 ** (2 ** n)


def count_settled(n: int) -> int:
    """Settled sentences are exactly the two constants."""
    return 2


def count_independent(n: int) -> int:
    """Independent sentences: total minus settled."""
    return count_sentences(n) - count_settled(n)


def independent_ratio(n: int) -> float:
    return count_independent(n) / count_sentences(n)


def verify_settled_by_enumeration(n: int) -> int:
    """Brute-force count of settled sentences for small n as a cross-check."""
    branches = list(product([False, True], repeat=n))
    settled = 0
    for outputs in product([False, True], repeat=len(branches)):
        if all(outputs) or not any(outputs):
            settled += 1
    return settled


def demo_independence() -> None:
    print("=" * 70)
    print("3. QUANTITATIVE INDEPENDENCE (independence is generic)")
    print("=" * 70)
    print(f"{'n':>3}{'branches':>12}{'sentences':>16}{'independent':>18}"
          f"{'indep ratio':>16}")
    for n in range(0, 6):
        print(f"{n:>3}{count_branches(n):>12}{count_sentences(n):>16}"
              f"{count_independent(n):>18}{independent_ratio(n):>16.10f}")

    print("\nCross-check (brute force) that exactly 2 sentences are settled:")
    for n in range(0, 4):
        print(f"  n={n}: enumerated settled = {verify_settled_by_enumeration(n)}"
              f"  (formula: {count_settled(n)})")
    print("\nRatio -> 1 as n grows: undecidability is the typical case.\n")


def main() -> None:
    demo_frame_correspondences()
    demo_buttons_switches()
    demo_independence()


if __name__ == "__main__":
    main()
