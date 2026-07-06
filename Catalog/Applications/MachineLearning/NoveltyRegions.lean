/-
Copyright (c) 2024 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Catalog.Novelty.CertifiedNovelty

/-!
# Novelty Regions, Filtrations, and the Persistence Barcode

This file extends the *pointwise* novelty-certification framework of
`Catalog/Novelty/CertifiedNovelty.lean` along the **geometry-of-the-certificate** axis:
we pass from the point predicate `IsNovel` and the scalar `noveltyScore` to the
*region* it carves out of the ambient space.

The central object is the **novelty region** `noveltyRegion S ε`, the strict
super-level set `{x | ε < noveltyScore S x}` of the continuous novelty score
`noveltyScore S x = Metric.infDist x S`. Three structural facts make this the right
"dual representation":

* **Openness** (`noveltyRegion_isOpen`): continuity of the score becomes openness of
  every region — certified novelty is *stable* (an open condition).
* **Filtration** (`noveltyRegion_threshold_antitone`): raising the threshold shrinks
  the region, so the family `(noveltyRegion S ε)_ε` is a decreasing filtration of open
  sets, the structure underlying *persistence*.
* **Barcode** (`mem_noveltyRegion_iff_lt_birthTime`): the score doubles as the
  persistence **birth time**, so each point `x` is "alive" exactly on the half-line
  `[0, birthTime S x)`.

Finally we realize **Future Direction 1**: the strict novelty region is *exactly* the
complement of the closed offset / Čech thickening,
`noveltyRegion S ε = (Metric.cthickening ε S)ᶜ` (for nonempty `S` and `0 ≤ ε`). This
identifies the novelty filtration with the order-reversed dual of the union-of-balls
filtration used in persistent homology.

## Main results

* `noveltyRegion_isOpen` — every novelty region is open (stability).
* `noveltyRegion_threshold_antitone` — decreasing filtration in the threshold.
* `noveltyRegion_antitone_set` — more knowledge ⇒ smaller region.
* `mem_noveltyRegion_iff_lt_birthTime` — the persistence barcode of a point.
* `noveltyRegion_subset_isNovel` — bridge back to the `IsNovel` predicate.
* `noveltyRegion_eq_compl_cthickening` — region = complement of the Čech thickening.
-/

namespace CertifiedNovelty

open Metric

variable {α : Type*} [PseudoMetricSpace α]

-- !-- Lab Notebook --------------------------------------------------------------- !--
-- Hypothesis: the scalar novelty score is best understood through its super-level
--   sets, which should inherit topological structure (openness) from continuity of
--   the score and order structure (a filtration) from the threshold.
-- Result: `noveltyRegion` is an open set for every threshold, decreasing in the
--   threshold and in the reference set, and coincides with the complement of the
--   closed offset thickening `cthickening` — tying novelty to persistent homology.
-- Insight: openness of the certificate region is the topological shadow of the
--   1-Lipschitz regularity proved in the catalog (`noveltyScore_lipschitz`); the
--   "birth time" reading turns the catalog's scalar into a barcode.
-- Failure analysis: the thickening identity requires `S.Nonempty` and `0 ≤ ε`; for
--   empty `S` the score collapses to `0` while `infEDist · ∅ = ⊤`, and for `ε < 0` the
--   closed thickening uses `ENNReal.ofReal ε = 0`, so the two sides disagree.
-- ------------------------------------------------------------------------------- !--

/-! ## The novelty region and birth time -/

/-- The **birth time** of a point `x` against reference set `S` is its novelty score.
In the persistence reading, `x` is "novel/alive" on the half-line `[0, birthTime S x)`:
it is born novel at time `0` and dies (stops being `ε`-novel) at `ε = birthTime S x`. -/
noncomputable def birthTime (S : Set α) (x : α) : ℝ := noveltyScore S x

/-- The **novelty region** at threshold `ε` is the strict super-level set of the
novelty score: the set of points strictly more than `ε`-novel relative to `S`. -/
def noveltyRegion (S : Set α) (ε : ℝ) : Set α := {x | ε < noveltyScore S x}

-- !-- `noveltyRegion` is the super-level set `{x | ε < infDist x S}` of the continuous
-- map `noveltyScore S`; `isOpen_lt` with `continuous_infDist_pt` closes it. -- !--
/-- **Stability of certified novelty.** Every novelty region is open: being strictly
more than `ε`-novel is a stable, perturbation-robust condition. -/
theorem noveltyRegion_isOpen (S : Set α) (ε : ℝ) : IsOpen (noveltyRegion S ε) :=
  isOpen_lt continuous_const (Metric.continuous_infDist_pt S)

-- !-- If `ε₁ ≤ ε₂` and `ε₂ < score`, then `ε₁ < score`; pure transitivity. -- !--
/-- **Decreasing filtration in the threshold.** Raising the novelty threshold can only
shrink the certified region: `(noveltyRegion S ε)_ε` is a filtration of open sets. -/
theorem noveltyRegion_threshold_antitone (S : Set α) {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    noveltyRegion S ε₂ ⊆ noveltyRegion S ε₁ :=
  fun _ hx => lt_of_le_of_lt h hx

-- !-- Antitonicity of the score in the reference set (`noveltyScore_antitone`)
-- transports the strict inequality. -- !--
/-- **More knowledge ⇒ smaller region.** Enlarging the reference set shrinks every
novelty region. -/
theorem noveltyRegion_antitone_set {S T : Set α} (hTS : T ⊆ S) (hT : T.Nonempty)
    (ε : ℝ) : noveltyRegion S ε ⊆ noveltyRegion T ε :=
  fun _ hx => lt_of_lt_of_le hx (noveltyScore_antitone hTS hT _)

-- !-- Both sides unfold to `ε < noveltyScore S x = birthTime S x`. -- !--
/-- **Persistence barcode.** A point lies in the region at threshold `ε` exactly when
`ε` is below its birth time; the point's barcode is the half-line `[0, birthTime S x)`. -/
theorem mem_noveltyRegion_iff_lt_birthTime (S : Set α) (ε : ℝ) (x : α) :
    x ∈ noveltyRegion S ε ↔ ε < birthTime S x := Iff.rfl

-- !-- `ε < score` implies `ε ≤ score`, and for nonempty `S` the latter is exactly
-- `IsNovel` by `isNovel_iff_le_noveltyScore`. -- !--
/-- **Bridge to the predicate framework.** Every point of the (strict) novelty region
is genuinely `ε`-novel in the sense of the catalog predicate `IsNovel`. -/
theorem noveltyRegion_subset_isNovel (S : Set α) (ε : ℝ) (hS : S.Nonempty) :
    ∀ x ∈ noveltyRegion S ε, IsNovel ε S x :=
  fun _ hx => (isNovel_iff_le_noveltyScore hS).mpr (le_of_lt hx)

/-! ## Future Direction 1: duality with the Čech / offset filtration -/

-- !-- For nonempty `S` and `0 ≤ ε`, `x ∈ cthickening ε S ↔ infDist x S ≤ ε` (via
-- `mem_cthickening_iff` and `infEDist_ne_top`), so its complement is `ε < infDist`. -- !--
/-- **Novelty region = complement of the Čech thickening.** For a nonempty reference
set, the strict novelty region at threshold `ε` is exactly the complement of the closed
`ε`-offset `Metric.cthickening ε S`. This identifies the novelty filtration with the
order-reversed dual of the union-of-balls (Čech) filtration of persistent homology:
`x` is novel past time `ε` iff it has *not yet* been swallowed by the growing offset.
(The hypothesis `0 ≤ ε` is needed: for `ε < 0` the closed thickening uses
`ENNReal.ofReal ε = 0` and the identity fails.) -/
theorem noveltyRegion_eq_compl_cthickening (S : Set α) {ε : ℝ} (hε : 0 ≤ ε)
    (hS : S.Nonempty) :
    noveltyRegion S ε = (Metric.cthickening ε S)ᶜ := by
  ext x
  simp only [noveltyRegion, Set.mem_setOf_eq, Set.mem_compl_iff, Metric.mem_cthickening_iff,
    not_le, noveltyScore, Metric.infDist]
  rw [← ENNReal.toReal_lt_toReal (by simp) (Metric.infEDist_ne_top hS),
    ENNReal.toReal_ofReal hε]

end CertifiedNovelty