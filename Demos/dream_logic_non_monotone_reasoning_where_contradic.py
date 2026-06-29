"""
Visualization: The Contradiction Set as a Frontier
==================================================

Plots a closed interval [0,1] on the real line together with its
paraconsistent valuation:
  - green  : interior points  (value `true`,  robustly inside)
  - red    : exterior points  (value `false`, robustly outside)
  - gold   : frontier points  (value `both`,  the gluts / dialetheias)

This illustrates the bridge theorem `val_both_iff_frontier`: a point is a
glut exactly when it lies on the boundary of the set.

Run:  python3 _viz.py    (saves dream_logic_frontier.png)
Requires matplotlib and numpy.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def belnap_value(x: float, a: float = 0.0, b: float = 1.0) -> str:
    """Pointwise valuation of [a, b]: 'true', 'false', or 'both'."""
    if a < x < b:
        return "true"
    if x < a or x > b:
        return "false"
    return "both"


def main() -> None:
    a, b = 0.0, 1.0
    xs = np.linspace(-0.6, 1.6, 4001)
    colors = {"true": "#2e7d32", "false": "#c62828", "both": "#f9a825"}

    fig, ax = plt.subplots(figsize=(11, 2.6))
    for x in xs:
        v = belnap_value(float(x), a, b)
        ax.plot([x], [0], marker="|", markersize=24,
                color=colors[v], alpha=0.6)

    # Mark the two frontier gluts explicitly.
    for fx in (a, b):
        ax.plot([fx], [0], marker="o", markersize=14,
                color=colors["both"], markeredgecolor="black", zorder=5)
        ax.annotate("glut (both)", (fx, 0.0), textcoords="offset points",
                    xytext=(0, 18), ha="center", fontsize=10, weight="bold")

    ax.set_yticks([])
    ax.set_xlabel("real line")
    ax.set_title("Dream Logic: valuation of the closed interval [0,1]\n"
                 "interior = true (green), exterior = false (red), "
                 "frontier = both (gold)")
    handles = [plt.Line2D([0], [0], color=c, lw=6, label=k)
               for k, c in colors.items()]
    ax.legend(handles=handles, loc="upper center", ncol=3, frameon=False,
              bbox_to_anchor=(0.5, -0.35))
    fig.tight_layout()
    fig.savefig("dream_logic_frontier.png", dpi=150, bbox_inches="tight")
    print("Saved dream_logic_frontier.png")


if __name__ == "__main__":
    main()


"""
Dream Logic: Numerical Demonstrations
=====================================

Self-contained Python demonstrations of the verified results in the
"Dream Logic" development:

  1. Belnap's four-valued paraconsistent logic FOUR (algebra layer):
       - negation, conjunction, disjunction in the diamond truth order
       - designation (acceptance)
       - failure of Non-Contradiction, failure of Excluded Middle
       - failure of explosion (ex contradictione quodlibet)
       - uniqueness of the glut (both) and gap (neither)
       - classical (Boolean) contrast: no gluts, and explosion holds

  2. Topological model (geometry layer):
       - contradiction set = frontier of a closed set
       - Law of Non-Contradiction holds iff the set is clopen
       - concrete real dialetheia: 0 is both inside and outside [0,1]

  3. The bridge (logic <-> geometry):
       - pointwise Belnap valuation of a set
       - a point is a glut (value `both`) iff it lies on the frontier

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Callable


# ---------------------------------------------------------------------------
# 1. Belnap's four-valued logic FOUR
# ---------------------------------------------------------------------------


class Belnap(Enum):
    """The four truth values of Belnap's FOUR (FDE)."""

    TRUE = "true"        # established to hold
    FALSE = "false"      # established to fail
    BOTH = "both"        # glut / dialetheia: holds AND fails
    NEITHER = "neither"  # gap: no information either way


def neg(x: Belnap) -> Belnap:
    """Paraconsistent negation: swap true/false, fix the impossible objects."""
    return {
        Belnap.TRUE: Belnap.FALSE,
        Belnap.FALSE: Belnap.TRUE,
        Belnap.BOTH: Belnap.BOTH,
        Belnap.NEITHER: Belnap.NEITHER,
    }[x]


def conj(x: Belnap, y: Belnap) -> Belnap:
    """Conjunction = meet in the truth order false < {both, neither} < true."""
    if x is Belnap.FALSE or y is Belnap.FALSE:
        return Belnap.FALSE
    if x is Belnap.TRUE:
        return y
    if y is Belnap.TRUE:
        return x
    if x is y:                       # both/both or neither/neither
        return x
    return Belnap.FALSE              # both meet neither = false


def disj(x: Belnap, y: Belnap) -> Belnap:
    """Disjunction = join in the truth order."""
    if x is Belnap.TRUE or y is Belnap.TRUE:
        return Belnap.TRUE
    if x is Belnap.FALSE:
        return y
    if y is Belnap.FALSE:
        return x
    if x is y:                       # both/both or neither/neither
        return x
    return Belnap.TRUE              # both join neither = true


def designated(x: Belnap) -> bool:
    """A value is accepted (designated) iff it carries affirming evidence."""
    return x in (Belnap.TRUE, Belnap.BOTH)


ALL_VALUES = list(Belnap)


def demo_belnap_algebra() -> None:
    print("=" * 70)
    print("1. BELNAP FOUR — algebra of dream logic")
    print("=" * 70)

    print("\nNegation table:")
    for x in ALL_VALUES:
        print(f"   neg({x.value:8}) = {neg(x).value}")

    print("\nConjunction (and) table:")
    header = "        " + "".join(f"{y.value:9}" for y in ALL_VALUES)
    print(header)
    for x in ALL_VALUES:
        row = f"{x.value:8}" + "".join(f"{conj(x, y).value:9}" for y in ALL_VALUES)
        print("   " + row)

    print("\nDesignation (acceptance):")
    for x in ALL_VALUES:
        print(f"   designated({x.value:8}) = {designated(x)}")


def demo_law_failures() -> None:
    print("\n" + "=" * 70)
    print("2. FAILURE OF THE CLASSICAL LAWS (lnc_can_fail / lem_can_fail)")
    print("=" * 70)

    # Law of Non-Contradiction: is x AND not-x ever accepted?
    lnc_failures = [x for x in ALL_VALUES if designated(conj(x, neg(x)))]
    print("\nValues x for which (x AND not-x) is ACCEPTED  [LNC fails]:")
    for x in lnc_failures:
        print(f"   x = {x.value:8}: x ∧ ¬x = {conj(x, neg(x)).value}  (accepted)")
    assert lnc_failures == [Belnap.BOTH], "glut_iff: both is the unique glut"
    print("   => unique witness is `both` (theorem glut_iff)")

    # Law of Excluded Middle: is x OR not-x ever NOT accepted?
    lem_failures = [x for x in ALL_VALUES if not designated(disj(x, neg(x)))]
    print("\nValues x for which (x OR not-x) is NOT accepted  [LEM fails]:")
    for x in lem_failures:
        print(f"   x = {x.value:8}: x ∨ ¬x = {disj(x, neg(x)).value}  (not accepted)")
    assert lem_failures == [Belnap.NEITHER], "gap_iff: neither is the unique gap"
    print("   => unique witness is `neither` (theorem gap_iff)")


def demo_explosion_fails() -> None:
    print("\n" + "=" * 70)
    print("3. EXPLOSION FAILS (explosion_fails) — heart of paraconsistency")
    print("=" * 70)

    # Explosion would say: if (x AND not-x) is accepted, then EVERY y is accepted.
    explosion_holds = all(
        designated(y)
        for x in ALL_VALUES
        if designated(conj(x, neg(x)))
        for y in ALL_VALUES
    )
    print(f"\nDoes an accepted contradiction entail everything? {explosion_holds}")

    # Exhibit the counterexample pair (both, false).
    x, y = Belnap.BOTH, Belnap.FALSE
    print(f"   Counterexample: x = {x.value}, y = {y.value}")
    print(f"     (x ∧ ¬x) accepted? {designated(conj(x, neg(x)))}")
    print(f"     y accepted?        {designated(y)}")
    print("   => an accepted contradiction does NOT make `false` accepted.")
    assert not explosion_holds


def demo_classical_contrast() -> None:
    print("\n" + "=" * 70)
    print("4. CLASSICAL CONTRAST (classical_no_glut / classical_explosion)")
    print("=" * 70)

    # No Boolean glut.
    no_glut = all(not (b and (not b)) for b in (False, True))
    print(f"\nBoolean logic has any glut (b and not-b)? {not no_glut}")

    # Classical explosion holds vacuously.
    explosion = all(
        (not (b and (not b))) or q
        for b in (False, True)
        for q in (False, True)
    )
    print(f"Boolean (b and not-b) -> q holds for all b, q? {explosion}")
    print("   => two-valued logic has no gluts and DOES explode.")
    assert no_glut and explosion


# ---------------------------------------------------------------------------
# 2. Topological model on the real line
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class ClosedInterval:
    """A closed interval [a, b] in the real line (a <= b)."""

    a: float
    b: float

    def contains(self, x: float) -> bool:
        return self.a <= x <= self.b

    def interior_contains(self, x: float) -> bool:
        return self.a < x < self.b

    def frontier(self) -> tuple[float, float]:
        """Frontier (boundary) of [a, b] is the endpoint pair {a, b}."""
        return (self.a, self.b)


def in_contradiction_set(iv: ClosedInterval, x: float) -> bool:
    """
    For a closed set A = [a, b], the contradiction set
    A ∩ closure(complement) equals the frontier {a, b}
    (theorem contradiction_eq_frontier).
    """
    return x in iv.frontier()


def lnc_holds(iv: ClosedInterval) -> bool:
    """
    Law of Non-Contradiction holds iff the contradiction set is empty,
    i.e. iff A is clopen (theorem lnc_holds_iff_clopen). A nondegenerate
    closed interval is never clopen in R, so LNC fails for it.
    """
    a, b = iv.frontier()
    return a == b  # degenerate point set [a,a] has empty frontier in this model


def demo_topology() -> None:
    print("\n" + "=" * 70)
    print("5. TOPOLOGICAL MODEL — contradiction set = frontier")
    print("=" * 70)

    unit = ClosedInterval(0.0, 1.0)
    print(f"\nClosed set A = [{unit.a}, {unit.b}] in R")
    print(f"   frontier(A) = {set(unit.frontier())}")

    # The concrete dialetheia: 0 is both inside and outside [0,1].
    print("\nConcrete impossible object (dream_object_real):")
    print(f"   0 ∈ A ?                       {unit.contains(0.0)}")
    print(f"   0 ∈ contradiction(A) (frontier)? {in_contradiction_set(unit, 0.0)}")
    assert in_contradiction_set(unit, 0.0)
    print("   => 0 is a verified dialetheia: inside AND on the boundary.")

    print(f"\nLNC holds for A = [0,1] (i.e. A clopen)? {lnc_holds(unit)}")
    print("   => false: [0,1] is closed but not clopen, so it is paraconsistent.")
    assert not lnc_holds(unit)


# ---------------------------------------------------------------------------
# 3. The bridge: pointwise Belnap valuation of a set
# ---------------------------------------------------------------------------


def val(iv: ClosedInterval, x: float) -> Belnap:
    """
    Pointwise four-valued valuation (Definition: val).
      true    if x is in the interior of A
      false   if x is in the interior of the complement
      both    otherwise (i.e. on the frontier)
    """
    if iv.interior_contains(x):
        return Belnap.TRUE
    if x < iv.a or x > iv.b:        # interior of complement (closed A on the line)
        return Belnap.FALSE
    return Belnap.BOTH             # frontier point


def demo_bridge() -> None:
    print("\n" + "=" * 70)
    print("6. THE BRIDGE — frontier points are exactly the gluts")
    print("=" * 70)
    print("   (val_both_iff_frontier, designated_iff_mem, dream_object_real_is_glut)")

    unit = ClosedInterval(0.0, 1.0)
    sample = [-0.5, 0.0, 0.5, 1.0, 1.5]
    print(f"\nValuation of A = [0,1] at sample points:")
    for x in sample:
        v = val(unit, x)
        is_frontier = in_contradiction_set(unit, x)
        is_glut = v is Belnap.BOTH
        # val_both_iff_frontier
        assert is_glut == is_frontier
        # designated_iff_mem
        assert designated(v) == unit.contains(x)
        print(f"   x = {x:5}: val = {v.value:8}  frontier? {is_frontier}  "
              f"accepted? {designated(v)}")

    print("\nCapstone (dream_object_real_is_glut) at x = 0:")
    v0 = val(unit, 0.0)
    print(f"   val(0)            = {v0.value}")
    print(f"   neg(val(0))       = {neg(v0).value}   (fixed point of negation)")
    accepted_contradiction = designated(conj(v0, neg(v0)))
    print(f"   designated(val(0) ∧ ¬val(0)) = {accepted_contradiction}")
    assert v0 is Belnap.BOTH
    assert neg(v0) is v0
    assert accepted_contradiction
    print("   => the boundary point 0 carries the glut value `both`,")
    print("      equals its own negation, and is an ACCEPTED contradiction.")


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------


def main() -> None:
    demo_belnap_algebra()
    demo_law_failures()
    demo_explosion_fails()
    demo_classical_contrast()
    demo_topology()
    demo_bridge()
    print("\n" + "=" * 70)
    print("All assertions passed — the verified results reproduce numerically.")
    print("=" * 70)


if __name__ == "__main__":
    main()
