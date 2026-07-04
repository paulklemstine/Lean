"""Knots That Think: Cognition as Braiding — Numerical Demonstrations.

This self-contained script demonstrates the core mathematical results of the
"cognition as braiding" model:

  * Braid words over signed Artin generators model cognitive processes.
  * The WRITHE (signed crossing number) is additive and invariant under the
    Artin braid moves (distant commutation and the braid relation), hence a
    well-defined invariant of cognitive equivalence.
  * The writhe descends to a homomorphism B_n -> Z (net directed charge).
  * The Jones polynomial and its quantum dimension distinguish trivial,
    creative (trefoil), and confused (figure-eight) thoughts, assigning
    positive information only to the trefoil.

Run with:  python demo.py
No third-party dependencies required.
"""

from __future__ import annotations

import cmath
import math
from typing import List, Tuple

# A letter is (generator_index, sign): sign True = sigma_i, False = sigma_i^{-1}.
Letter = Tuple[int, bool]
BraidWord = List[Letter]


# ----------------------------------------------------------------------------
# Writhe
# ----------------------------------------------------------------------------
def letter_writhe(letter: Letter) -> int:
    """Signed contribution of a single letter: +1 for sigma_i, -1 for its inverse."""
    return 1 if letter[1] else -1


def writhe(word: BraidWord) -> int:
    """The writhe of a braid word: sum of the signed contributions of its letters."""
    return sum(letter_writhe(l) for l in word)


# ----------------------------------------------------------------------------
# Artin braid moves (cognitive equivalence)
# ----------------------------------------------------------------------------
def apply_far(p: BraidWord, i: int, s: bool, j: int, t: bool, q: BraidWord) -> Tuple[BraidWord, BraidWord]:
    """Distant commutation: sigma_i sigma_j = sigma_j sigma_i for |i - j| > 1.

    Returns the (before, after) words with the two-letter subword swapped.
    """
    assert i + 1 < j, "distant commutation requires i + 1 < j"
    before = p + [(i, s), (j, t)] + q
    after = p + [(j, t), (i, s)] + q
    return before, after


def apply_braid(p: BraidWord, i: int, q: BraidWord) -> Tuple[BraidWord, BraidWord]:
    """Braid relation: sigma_i sigma_{i+1} sigma_i = sigma_{i+1} sigma_i sigma_{i+1}."""
    j = i + 1
    before = p + [(i, True), (j, True), (i, True)] + q
    after = p + [(j, True), (i, True), (j, True)] + q
    return before, after


# ----------------------------------------------------------------------------
# Jones polynomial data (standard normalizations) and information content
# ----------------------------------------------------------------------------
def jones_trivial(t: complex) -> complex:
    """Jones polynomial of the unknot / trivial thought: V(t) = 1."""
    return 1.0 + 0.0j


def jones_trefoil(t: complex) -> complex:
    """Jones polynomial of the trefoil (creative thought), standard normalization:

        V(t) = -t^{-4} + t^{-3} + t^{-1}.
    """
    return -t**-4 + t**-3 + t**-1


def jones_figure_eight(t: complex) -> complex:
    """Jones polynomial of the figure-eight knot (confused thought):

        V(t) = t^{-2} - t^{-1} + 1 - t + t^2.
    """
    return t**-2 - t**-1 + 1.0 - t + t**2


def information_content(jones) -> float:
    """I = log|V(e^{i pi / 3})|, the log quantum dimension.

    Evaluated at the primitive 6th root of unity t = e^{i pi / 3}, where
    |V| = (sqrt 3)^d with d the number of independent Z/3 cycles in the
    double branched cover.
    """
    t = cmath.exp(1j * math.pi / 3)
    v = jones(t)
    modulus = abs(v)
    if modulus <= 0:
        return float("-inf")
    return math.log(modulus)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------
def demo_additivity() -> None:
    print("=" * 64)
    print("Writhe additivity:  writhe(u ++ v) = writhe(u) + writhe(v)")
    print("=" * 64)
    u: BraidWord = [(0, True), (1, False), (2, True)]
    v: BraidWord = [(1, True), (0, True)]
    print(f"  writhe(u)        = {writhe(u)}")
    print(f"  writhe(v)        = {writhe(v)}")
    print(f"  writhe(u ++ v)   = {writhe(u + v)}")
    assert writhe(u + v) == writhe(u) + writhe(v)
    print("  OK: additive.\n")


def demo_invariance() -> None:
    print("=" * 64)
    print("Writhe invariance under the Artin braid moves")
    print("=" * 64)
    p: BraidWord = [(0, True)]
    q: BraidWord = [(3, False)]

    b1, a1 = apply_far(p, 0, True, 2, False, q)
    print("  Distant commutation  sigma_0 sigma_2 -> sigma_2 sigma_0")
    print(f"    writhe before = {writhe(b1)}, after = {writhe(a1)}")
    assert writhe(b1) == writhe(a1)

    b2, a2 = apply_braid(p, 1, q)
    print("  Braid relation  s1 s2 s1 -> s2 s1 s2")
    print(f"    writhe before = {writhe(b2)}, after = {writhe(a2)}")
    assert writhe(b2) == writhe(a2)
    print("  OK: writhe is invariant under both moves.\n")


def demo_homomorphism() -> None:
    print("=" * 64)
    print("Writhe as a homomorphism B_n -> Z (relators map to 0)")
    print("=" * 64)
    # Far-commutation commutator: x_i x_j x_i^{-1} x_j^{-1}, i+1<j.
    commutator: BraidWord = [(0, True), (2, True), (0, False), (2, False)]
    # Braid relator: x_i x_j x_i (x_j x_i x_j)^{-1}, j = i+1.
    braid_relator: BraidWord = [
        (0, True), (1, True), (0, True),
        (1, False), (0, False), (1, False),
    ]
    print(f"  writhe(far-commutator) = {writhe(commutator)}")
    print(f"  writhe(braid relator)  = {writhe(braid_relator)}")
    assert writhe(commutator) == 0
    assert writhe(braid_relator) == 0
    print("  OK: both relators have writhe 0, so writhe descends to B_n.\n")


def demo_information_content() -> None:
    print("=" * 64)
    print("Information content  I = log|V(e^{i pi / 3})|  of thought archetypes")
    print("=" * 64)
    for name, jones in (
        ("trivial thought (unknot)", jones_trivial),
        ("creative thought (trefoil)", jones_trefoil),
        ("confused thought (figure-eight)", jones_figure_eight),
    ):
        i = information_content(jones)
        print(f"  {name:34s}  I = {i:+.6f}")
    half_log3 = 0.5 * math.log(3)
    print(f"\n  Note: trefoil information equals (1/2) log 3 = {half_log3:.6f}")
    print("  Only the trefoil carries positive information; the figure-eight")
    print("  collapses to 0, matching the trivial thought.\n")
    assert abs(information_content(jones_trefoil) - half_log3) < 1e-9
    assert abs(information_content(jones_figure_eight)) < 1e-9


def main() -> None:
    demo_additivity()
    demo_invariance()
    demo_homomorphism()
    demo_information_content()


if __name__ == "__main__":
    main()
