/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.ChromaticPolynomial.Counting

/-!
# The four-color statement through the chromatic polynomial

The Four Color Theorem says every planar graph is `4`-colorable.  Two phrasings are
standard:

* combinatorial: `G.Colorable 4`;
* polynomial: the chromatic polynomial of `G` does not vanish at `4`, i.e.
  `chromCount G 4 ≠ 0`.

This file proves these are equivalent (for every finite graph), and that the two
standard phrasings of the Four Color Theorem itself — over an *arbitrary* planarity
predicate — coincide.  We deliberately abstract planarity as a predicate `Planar`
since planarity is orthogonal to the equivalence being proved (and the FCT itself is
not formalized in Mathlib).

## Main results

* `ChromaticFourColor.colorable_iff_chromCount_ne_zero` : `G.Colorable k ↔
  chromCount G k ≠ 0`.  The chromatic-polynomial criterion for `k`-colorability.
* `ChromaticFourColor.fourColorable_iff_chromCount_four_ne_zero` : the `k = 4`
  specialization — the polynomial form of being four-colorable.
* `ChromaticFourColor.fourColorTheorem_formulations_equiv` : for any planarity
  predicate, "every planar graph is 4-colorable" is equivalent to "every planar graph
  has chromatic number ≤ 4".

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): four-colorability of `G` is detected exactly by the
non-vanishing of the chromatic polynomial at `4`; therefore the Four Color Theorem is
equivalent to a statement purely about the chromatic polynomial.

Experiment (Experimenter): `chromCount_eq_zero_iff` from `Counting.lean` already says
`chromCount G k = 0 ↔ ¬ G.Colorable k`.  Negating gives the criterion directly.  For
the FCT phrasings we used Mathlib's `chromaticNumber_le_iff_colorable`.

Analysis (Analyst): the equivalence of phrasings is robust — it needs no finiteness
and no decidability beyond what `chromCount` already requires, and it isolates the
genuinely hard content of the FCT (planarity ⇒ 4-colorability) behind the abstract
predicate `Planar`.

Critique (Critic): nothing here secretly proves the FCT; the planar predicate is a
free variable.  The criterion theorem genuinely reuses the project's own
`chromCount_eq_zero_iff`, not a Mathlib black box.
-/

open ChromaticPoly

namespace ChromaticFourColor

variable {V : Type*} [Fintype V] [DecidableEq V]

/-
**Chromatic-polynomial criterion for colorability.**  A finite graph is
`k`-colorable iff its chromatic polynomial does not vanish at `k`.
-/
theorem colorable_iff_chromCount_ne_zero (G : SimpleGraph V) [DecidableRel G.Adj]
    (k : ℕ) : G.Colorable k ↔ chromCount G k ≠ 0 := by
  grind +suggestions

/-
**Polynomial form of four-colorability.**  A finite graph is `4`-colorable iff its
chromatic polynomial is nonzero at `4`.
-/
theorem fourColorable_iff_chromCount_four_ne_zero (G : SimpleGraph V)
    [DecidableRel G.Adj] : G.Colorable 4 ↔ chromCount G 4 ≠ 0 := by
  exact colorable_iff_chromCount_ne_zero G 4

/-
**Equivalence of the two phrasings of the Four Color Theorem.**  For an arbitrary
planarity predicate, "every planar graph is `4`-colorable" is equivalent to "every
planar graph has chromatic number `≤ 4`".
-/
theorem fourColorTheorem_formulations_equiv {W : Type*} (Planar : SimpleGraph W → Prop) :
    (∀ G : SimpleGraph W, Planar G → G.Colorable 4)
      ↔ (∀ G : SimpleGraph W, Planar G → G.chromaticNumber ≤ 4) := by
  constructor
  · intro h G hG
    simpa using (h G hG).chromaticNumber_le
  · intro h G hG
    exact SimpleGraph.chromaticNumber_le_iff_colorable.mp (by simpa using h G hG)

end ChromaticFourColor