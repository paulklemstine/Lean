"""
Paradoxes as Theorems: The Liar, Berry, and Russell Made Consistent
===================================================================

Self-contained numerical demonstrations of the results:

  * The classical (Boolean) obstruction: a negation fixed point collapses a
    Boolean algebra to a single point, so no nontrivial Boolean algebra admits
    a self-negating value.
  * Belnap's four-valued logic: negation, designation, meet/join, involutivity,
    De Morgan laws, and the Glut Characterization pinning the paradox to the
    single value B.
  * An explicit six-sentence paraconsistent theory in which the Liar, Russell,
    and Berry sentences are all provable gluts, the theory is nontrivial and
    non-explosive, and the inconsistency degree is exactly three.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Tuple

# ---------------------------------------------------------------------------
# 1. The classical (Boolean) obstruction
# ---------------------------------------------------------------------------

def boolean2_complement(x: bool) -> bool:
    """Complement in the two-element Boolean algebra {False=bot, True=top}."""
    return not x


def has_boolean_negation_fixpoint() -> bool:
    """Return True iff some element x of the two-element Boolean algebra
    satisfies x^c = x. The Boolean Collapse Theorem predicts this is False
    in any nontrivial Boolean algebra."""
    return any(boolean2_complement(x) == x for x in (False, True))


def boolean_collapse_check(x: bool) -> bool:
    """Given a *hypothetical* fixed point x (x^c = x) in the 2-element algebra,
    verify the collapse bot = top would follow via x = x&x^c = bot and
    x = x|x^c = top. Returns True iff the collapse identity holds."""
    meet = x and boolean2_complement(x)   # x & x^c  == bot
    join = x or boolean2_complement(x)    # x | x^c  == top
    # If x were a fixed point, meet would equal x would equal join,
    # forcing bot == top.
    return meet == join  # only possible when the algebra is trivial


def no_liar_prop() -> bool:
    """Classical fact: no proposition P satisfies P <-> not P. We check the
    biconditional (P == (not P)) is False for both truth values of P."""
    return all((P == (not P)) is False for P in (False, True))


# ---------------------------------------------------------------------------
# 2. Belnap's four-valued logic
# ---------------------------------------------------------------------------

# Values encoded as strings for readability.
VALUES: Tuple[str, str, str, str] = ("T", "F", "B", "N")

NEG: Dict[str, str] = {"T": "F", "F": "T", "B": "B", "N": "N"}

DESIGNATED: Dict[str, bool] = {"T": True, "F": False, "B": True, "N": False}

# Truth order F <= N,B <= T ; conjunction = meet, disjunction = join.
CONJ: Dict[Tuple[str, str], str] = {
    ("T", "T"): "T", ("T", "F"): "F", ("T", "B"): "B", ("T", "N"): "N",
    ("F", "T"): "F", ("F", "F"): "F", ("F", "B"): "F", ("F", "N"): "F",
    ("B", "T"): "B", ("B", "F"): "F", ("B", "B"): "B", ("B", "N"): "F",
    ("N", "T"): "N", ("N", "F"): "F", ("N", "B"): "F", ("N", "N"): "N",
}

DISJ: Dict[Tuple[str, str], str] = {
    ("T", "T"): "T", ("T", "F"): "T", ("T", "B"): "T", ("T", "N"): "T",
    ("F", "T"): "T", ("F", "F"): "F", ("F", "B"): "B", ("F", "N"): "N",
    ("B", "T"): "T", ("B", "F"): "B", ("B", "B"): "B", ("B", "N"): "T",
    ("N", "T"): "T", ("N", "F"): "N", ("N", "B"): "T", ("N", "N"): "N",
}


def neg(v: str) -> str:
    return NEG[v]


def designated(v: str) -> bool:
    return DESIGNATED[v]


def conj(a: str, b: str) -> str:
    return CONJ[(a, b)]


def disj(a: str, b: str) -> str:
    return DISJ[(a, b)]


def involutivity_holds() -> bool:
    return all(neg(neg(v)) == v for v in VALUES)


def de_morgan_holds() -> bool:
    conj_law = all(
        neg(conj(a, b)) == disj(neg(a), neg(b)) for a, b in product(VALUES, VALUES)
    )
    disj_law = all(
        neg(disj(a, b)) == conj(neg(a), neg(b)) for a, b in product(VALUES, VALUES)
    )
    return conj_law and disj_law


def glut_values() -> List[str]:
    """Values v with both v and neg(v) designated -- the semantic signature of
    a paradox. The Glut Characterization predicts this is exactly {B}."""
    return [v for v in VALUES if designated(v) and designated(neg(v))]


def designated_neg_fixpoints() -> List[str]:
    return [v for v in VALUES if neg(v) == v and designated(v)]


# ---------------------------------------------------------------------------
# 3. The explicit six-sentence paraconsistent theory
# ---------------------------------------------------------------------------

# Sentences 0..5:  Liar, Russell, Berry, plain-truth, plain-falsehood, gap.
SENTENCE_NAMES: List[str] = [
    "Liar (s0)", "Russell (s1)", "Berry (s2)",
    "plain truth (s3)", "plain falsehood (s4)", "gap (s5)",
]

VAL: List[str] = ["B", "B", "B", "T", "F", "N"]
SNEG: List[int] = [0, 1, 2, 4, 3, 5]


def coherent() -> bool:
    """val(sneg(s)) == neg(val(s)) for every sentence."""
    return all(VAL[SNEG[s]] == neg(VAL[s]) for s in range(len(VAL)))


def provable(s: int) -> bool:
    return designated(VAL[s])


def is_glut(s: int) -> bool:
    return provable(s) and provable(SNEG[s])


def gluts() -> List[int]:
    return [s for s in range(len(VAL)) if is_glut(s)]


def nontrivial() -> bool:
    return any(not provable(s) for s in range(len(VAL)))


def non_explosion() -> bool:
    """A glut exists AND some sentence is unprovable."""
    return len(gluts()) > 0 and any(not provable(s) for s in range(len(VAL)))


def inconsistency_degree() -> int:
    return sum(1 for s in range(len(VAL)) if VAL[s] == "B")


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    line = "-" * 66
    print(line)
    print("1. CLASSICAL (BOOLEAN) OBSTRUCTION")
    print(line)
    print(f"  Two-element Boolean algebra has negation fixed point?  "
          f"{has_boolean_negation_fixpoint()}   (expected False)")
    print(f"  No proposition P satisfies P <-> not P?                "
          f"{no_liar_prop()}   (expected True)")
    print("  => A nontrivial classical logic cannot host a Liar.")

    print(line)
    print("2. BELNAP FOUR-VALUED LOGIC")
    print(line)
    print(f"  Negation involutive (neg neg v = v)?      {involutivity_holds()}")
    print(f"  De Morgan laws hold?                       {de_morgan_holds()}")
    print(f"  Values that are gluts (v & neg v desig.):  {glut_values()}"
          f"   (expected ['B'])")
    print(f"  Designated negation fixed points:          "
          f"{designated_neg_fixpoints()}   (expected ['B'])")
    print("  => The single value B is the unique consistent-Liar witness.")

    print(line)
    print("3. SIX-SENTENCE PARACONSISTENT THEORY")
    print(line)
    for s, name in enumerate(SENTENCE_NAMES):
        print(f"  s{s}: {name:22s} value={VAL[s]}  "
              f"neg->s{SNEG[s]}  provable={provable(s)}  glut={is_glut(s)}")
    print()
    print(f"  Coherent theory?                           {coherent()}")
    print(f"  Provable gluts (indices):                  {gluts()}   "
          f"(Liar, Russell, Berry)")
    print(f"  Nontrivial (some sentence unprovable)?     {nontrivial()}")
    print(f"  Non-explosive?                             {non_explosion()}")
    print(f"  Inconsistency degree (# gluts):            "
          f"{inconsistency_degree()}   (expected 3)")

    print(line)
    print("4. THE DICHOTOMY")
    print(line)
    boolean_ok = not has_boolean_negation_fixpoint()
    belnap_ok = designated_neg_fixpoints() == ["B"]
    print(f"  Belnap admits a designated negation fixed point:  {belnap_ok}")
    print(f"  No nontrivial Boolean algebra does:               {boolean_ok}")
    print("  => Consistent paradox-theorems exist iff classical logic")
    print("     (Boolean bivalence / non-contradiction) is rejected.")
    print(line)

    # Assert every predicted result, so the demo doubles as a check.
    assert not has_boolean_negation_fixpoint()
    assert no_liar_prop()
    assert involutivity_holds()
    assert de_morgan_holds()
    assert glut_values() == ["B"]
    assert designated_neg_fixpoints() == ["B"]
    assert coherent()
    assert gluts() == [0, 1, 2]
    assert nontrivial()
    assert non_explosion()
    assert inconsistency_degree() == 3
    print("All predicted results verified. \u2713")


if __name__ == "__main__":
    main()
