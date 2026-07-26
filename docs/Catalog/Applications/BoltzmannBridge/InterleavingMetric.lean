/-
# The Boltzmann Bridge V — The Extended Interleaving Metric

This file closes the persistent-homology arc of the catalog by repairing the one
structural defect that its predecessor recorded but could not fix.  The arc is:

* **II — `HigherPersistence`**: the filtration calculus (`Filtration`,
  `sublevelFaces`, `sublevel_mono`, the Vietoris–Rips `diamWeight`).
* **III — `PersistenceStability`**: the set-inclusion interleaving lemmas
  (`stability_interleaving`, `stability_compose`, `stability_two_sided`).
* **IV — `BottleneckStability`**: the relational interleaving preorder
  (`Interleaved`, `Interleaved_refl/symm/mono/trans`), a *real*-valued
  `interleavingDist`, and the `1`-Lipschitz diameter estimate
  `diamWeightOf_dist_le`.  Its Lab Notebook recorded an honest failure: with the
  Lean convention `sInf ∅ = 0` in `ℝ`, two never-interleaved filtrations are
  reported at distance `0`, so the **triangle inequality is false in `ℝ`**.
* **V — `InterleavingMetric` (this file)**: move the codomain to `ℝ≥0∞`.  Now
  `sInf ∅ = ⊤` is the *correct* value, the triangle inequality holds
  **unconditionally** (`eInterleavingDist_triangle`), and we obtain a genuine
  representation theorem `interleavingPseudoEMetric : PseudoEMetricSpace
  (Filtration α)`: the abstract relational interleaving preorder is faithfully
  represented as a concrete extended-metric geometry.

The decisive observation is dual: the metric axiom (triangle) is the shadow of
the relational axiom (`Interleaved_trans`), and the bridge between them is
exactly the `ℝ≥0∞`-algebra `ENNReal.add_iInf` / `ENNReal.iInf_add` that the real
`sInf` lacked.

## Main results

* `eInterleavingDist` — the `ℝ≥0∞`-valued interleaving distance
* `eInterleavingDist_le` — every interleaving witness bounds the distance
* `eInterleavingDist_self`, `eInterleavingDist_comm` — diagonal vanishing, symmetry
* `eInterleavingDist_triangle` — the **unconditional** triangle inequality
* `interleavingPseudoEMetric` — filtrations form an extended pseudometric space
* `eInterleavingDist_le_supDist` — CESH stability in extended `1`-Lipschitz form
* `vr_eStability`, `cloud_eInterleavingDist_le` — VR and concrete point-cloud forms
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability
import Applications.BoltzmannBridge.BottleneckStability

open Finset BigOperators
open scoped ENNReal

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

/-! ## The extended interleaving distance -/

/-- **The extended interleaving distance** between two filtrations: the infimum,
taken in `ℝ≥0∞`, of `ENNReal.ofReal δ` over all admissible interleaving shifts
`δ`.  When no interleaving exists the infimum is over the empty type and equals
`⊤` — the *correct* value, in contrast to the `ℝ`-valued `interleavingDist`,
where `sInf ∅ = 0` corrupted the triangle inequality. -/
noncomputable def eInterleavingDist (F G : Filtration α) : ℝ≥0∞ :=
  ⨅ δ : {x : ℝ // Interleaved F G x}, ENNReal.ofReal (δ : ℝ)

-- !-- `⟨δ, h⟩` is an element of the index subtype, so `iInf_le` gives the bound. -- !--
/-- **Upper bound by any witness.**  Any admissible interleaving shift `δ` bounds
the extended interleaving distance from above by `ENNReal.ofReal δ`. -/
theorem eInterleavingDist_le (F G : Filtration α) {δ : ℝ} (h : Interleaved F G δ) :
    eInterleavingDist F G ≤ ENNReal.ofReal δ := by
  refine iInf_le (fun x : {x : ℝ // Interleaved F G x} => ENNReal.ofReal (x : ℝ)) ⟨δ, h⟩

-- !-- `≤ ofReal 0 = 0` from `eInterleavingDist_le` with `Interleaved_refl`; `≥ 0` is
-- !-- automatic in `ℝ≥0∞`. -- !--
/-- The extended interleaving distance vanishes on the diagonal. -/
theorem eInterleavingDist_self (F : Filtration α) : eInterleavingDist F F = 0 := by
  refine le_antisymm ?_ (by simp)
  have := eInterleavingDist_le F F (Interleaved_refl F)
  simpa using this

-- !-- `Interleaved_symm` is a bijection between the two index subtypes preserving
-- !-- the value `ofReal δ`, so the two infima are equal. -- !--
/-- The extended interleaving distance is symmetric. -/
theorem eInterleavingDist_comm (F G : Filtration α) :
    eInterleavingDist F G = eInterleavingDist G F := by
  refine le_antisymm ?_ ?_ <;>
    · refine le_iInf fun δ => ?_
      exact le_trans (eInterleavingDist_le _ _ (Interleaved_symm δ.2)) (le_refl _)

-- !-- Rewrite `dFG + dGH` as `⨅ a, ⨅ b, (ofReal a + ofReal b)` via `ENNReal.iInf_add`
-- !-- and `ENNReal.add_iInf`; for each pair `ofReal a + ofReal b = ofReal (a+b)`
-- !-- (both shifts `≥ 0`), and `Interleaved_trans` makes `a+b` an `F,H`-witness, so
-- !-- `eInterleavingDist_le` bounds `dFH` by it.  `le_iInf` twice finishes. -- !--
/-- **The unconditional triangle inequality.**  Moving to the `ℝ≥0∞` codomain
makes the triangle inequality hold for *all* filtrations — the metric shadow of
the relational `Interleaved_trans`. -/
theorem eInterleavingDist_triangle (F G H : Filtration α) :
    eInterleavingDist F H ≤ eInterleavingDist F G + eInterleavingDist G H := by
  rw [eInterleavingDist, eInterleavingDist, eInterleavingDist,
      ENNReal.iInf_add]
  refine le_iInf fun a => ?_
  rw [ENNReal.add_iInf]
  refine le_iInf fun b => ?_
  have hsum : ENNReal.ofReal (a : ℝ) + ENNReal.ofReal (b : ℝ)
      = ENNReal.ofReal ((a : ℝ) + (b : ℝ)) :=
    (ENNReal.ofReal_add a.2.1 b.2.1).symm
  rw [hsum]
  exact eInterleavingDist_le F H (Interleaved_trans a.2 b.2)

/-! ## The representation theorem -/

-- !-- Package `eInterleavingDist_self/comm/triangle` as the three `edist` axioms;
-- !-- `PseudoEMetricSpace` auto-fills the uniformity/topology fields. -- !--
/-- **The representation theorem.**  Filtrations form an extended pseudometric
space under `eInterleavingDist`.  The purely relational interleaving preorder of
`BottleneckStability` is faithfully represented as a concrete metric geometry. -/
noncomputable def interleavingPseudoEMetric : PseudoEMetricSpace (Filtration α) where
  edist := eInterleavingDist
  edist_self := eInterleavingDist_self
  edist_comm := eInterleavingDist_comm
  edist_triangle := eInterleavingDist_triangle

/-! ## CESH stability, extended form -/

-- !-- `stability_supDist` produces a `D`-interleaving; `eInterleavingDist_le` turns
-- !-- it into the `ofReal D` bound. -- !--
/-- **CESH stability, extended `1`-Lipschitz form.**  Uniform `D`-closeness of the
weights bounds the extended interleaving distance by `ENNReal.ofReal D`. -/
theorem eInterleavingDist_le_supDist (F G : Filtration α) {D : ℝ}
    (hD : 0 ≤ D) (h : WeightCloseBy F G D) :
    eInterleavingDist F G ≤ ENNReal.ofReal D :=
  eInterleavingDist_le _ _ (stability_supDist _ _ hD h)

end Filtration

/-! ## Vietoris–Rips, extended form -/

section VR

variable {α : Type*}

-- !-- `vr_stability_interleaved` gives an `ε`-interleaving of the VR filtrations;
-- !-- feed it to `eInterleavingDist_le`. -- !--
/-- **Vietoris–Rips stability (extended form).**  Uniformly `ε`-close distance
matrices give VR filtrations within extended interleaving distance
`ENNReal.ofReal ε`. -/
theorem vr_eStability (d₁ d₂ : α → α → ℝ) {ε : ℝ}
    (hε : 0 ≤ ε) (h : ∀ x y, |d₁ x y - d₂ x y| ≤ ε) :
    Filtration.eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂)
      ≤ ENNReal.ofReal ε :=
  Filtration.eInterleavingDist_le _ _ (vr_stability_interleaved d₁ d₂ hε h)

end VR

/-! ## The concrete point-cloud certificate, extended form -/

section Cloud

-- !-- `vr_eStability` applied to the `cloud_distortion` `(1/10)`-bound. -- !--
/-- The extended interleaving distance of the two concrete `3`-point clouds is at
most `ENNReal.ofReal (1/10)`. -/
theorem cloud_eInterleavingDist_le :
    Filtration.eInterleavingDist (diamFiltrationOf cloud₁) (diamFiltrationOf cloud₂)
      ≤ ENNReal.ofReal (1/10) :=
  vr_eStability cloud₁ cloud₂ (by norm_num) cloud_distortion

end Cloud

/-
-- !-- Lab Notebook -- !--

## Hypothesis
The triangle-inequality failure of the `ℝ`-valued `interleavingDist`
(BottleneckStability, Failure analysis) is an artefact of the codomain, not of
the mathematics: with `sInf ∅ = 0` in `ℝ`, never-interleaved filtrations collapse
to distance `0`.  Moving the codomain to `ℝ≥0∞`, where `sInf ∅ = ⊤`, should make
the triangle inequality hold unconditionally and upgrade the relational
interleaving preorder to a genuine `PseudoEMetricSpace`.

## Result
Confirmed.  `eInterleavingDist : Filtration α → Filtration α → ℝ≥0∞` is bounded
above by every witness (`eInterleavingDist_le`), vanishes on the diagonal
(`eInterleavingDist_self`), is symmetric (`eInterleavingDist_comm`), and satisfies
the **unconditional** triangle inequality (`eInterleavingDist_triangle`).  These
package into `interleavingPseudoEMetric`.  The CESH `1`-Lipschitz bound
(`eInterleavingDist_le_supDist`), the Vietoris–Rips form (`vr_eStability`), and
the concrete cloud certificate (`cloud_eInterleavingDist_le`) all carry over.

## Insight
The triangle inequality is *exactly* the relational `Interleaved_trans` viewed
through the order-isomorphism `δ ↦ ENNReal.ofReal δ`.  The only algebraic input
that the real `sInf` lacked is the distributivity of `+` over `⨅` in `ℝ≥0∞`
(`ENNReal.add_iInf`, `ENNReal.iInf_add`), which hold with **no nonemptiness
hypothesis** — precisely because `⊤` absorbs `+`.  This is why the empty-witness
(never-interleaved) case, fatal in `ℝ`, is automatic in `ℝ≥0∞`.

## Failure analysis
The space is a *pseudo*metric, not a metric: distinct filtrations can sit at
distance `0` (any two filtrations with identical sublevel families at every
scale).  Identifying this distance-zero kernel with "same persistence content,"
and thereby producing a genuine `EMetricSpace` on the quotient, requires a
limiting/approximation argument (squeeze the shift to `0`); it is deferred to
Future Direction 1.
-/

end BoltzmannBridge