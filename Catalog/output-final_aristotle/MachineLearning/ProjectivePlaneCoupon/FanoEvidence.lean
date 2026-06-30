/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Fano plane (`q = 2`): full coupon-collection slowness, verified

This file makes the `q = 2` case of the projective-plane coupon-collection story
of `Slowness.lean` completely concrete and checks the *entire* expected
cover-time inequality (all orders, not only order `3`).  For `q = 2` the plane
is the **Fano plane** `PG(2,2)`: `n = 7` points, `7` lines, each a `3`-subset.

We reuse the cyclic (Singer) model already used in the catalog file
`Catalog/Novelty/FanoStrongBlocking.lean`:

* points `= ZMod 7`;
* lines `= {i, i+1, i+3}` for `i : ZMod 7` (development of the difference set
  `{0,1,3} mod 7`).

The expected time to collect all `7` coupons under a covering process with
single-draw avoid-probability `p_A` is, by inclusion–exclusion,
`E = Σ_{∅ ≠ A ⊆ points} (-1)^{|A|+1} / (1 - p_A)`.

* `pplane A` — a uniformly random *line* avoids `A` with probability
  `(#lines disjoint from A) / 7`.
* `punif A` — a uniformly random `3`-subset avoids `A` with probability
  `(#3-subsets disjoint from A) / 35` (`35 = C(7,3)`).

## Main results

* `Eplane_value`, `Eunif_value` — the exact rational expected cover times
  `163/30` (plane) and `85691/15810` (uniform).
* `fano_slowness` — `Eunif < Eplane`: the Fano-line mechanism is **strictly
  slower**, the (`q = 2`) disproof of the Grünbaum–Yaakobi conjecture.
* `point_avoid`, `pair_avoid`, `coll_avoid`, `gen_avoid` — the geometric
  avoid-counts that underlie the *general* formulas of `Slowness.lean`,
  verified here against the explicit plane: a point is missed by `q² = 4` lines,
  a pair by `q² - q = 2`, a collinear triple by `q² - 2q = 0`, a generic triple
  by `(q-1)² = 1`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): For the smallest plane (`q = 2`) the plane mechanism
  should already be slower, and the gap `Eplane - Eunif` should be small but
  strictly positive (the original Grünbaum–Yaakobi disproof).
Experiment (Experimenter): Built `E` as a `127`-term inclusion–exclusion sum
  over the nonempty subsets of `ZMod 7` and evaluated both mechanisms exactly in
  ℚ: `Eplane = 163/30 ≈ 5.4333`, `Eunif = 85691/15810 ≈ 5.4200`.  The strict
  inequality is closed by `native_decide` on exact rationals.  Separately
  `decide` confirms the four geometric avoid-counts predicted by the general
  `q`-formulas of `Slowness.lean`.
Analysis (Analyst): The gap is `Eplane - Eunif = 163/30 - 85691/15810 > 0` but
  tiny (~0.013), explaining why the conjecture stood: at order 3 the plane is
  already heavier (`slowness3`), and for `q = 2` the higher-order alternating
  tail does not reverse it.  `q = 3` was checked the same way (see
  `ComputationalEvidence.md`).
Critique (Critic): `fano_slowness` is an exact finite computation, hence
  `native_decide` is the honest tool; it is supporting *evidence*, while the
  insight-bearing general theorems (`meanMatch`, `jensen2`, `slowness3`) live in
  `Slowness.lean` and use `induction`-free but genuine algebra/convexity.  The
  avoid-count lemmas anchor those abstract definitions to a real plane.
Synthesis (PI): `q = 2` is fully nailed down; the avoid-counts confirm the
  general formulas; the general theorem remains open via the higher-order tail.
-/
import Mathlib

open Finset

namespace ProjectivePlaneCouponFano

/-- Lines of the Fano plane in the cyclic (Singer) model, matching the model of
`Catalog/Novelty/FanoStrongBlocking.lean`. -/
def fanoLine (i : ZMod 7) : Finset (ZMod 7) := {i, i + 1, i + 3}

/-- Plane mechanism: probability a uniformly random line avoids `A`. -/
def pplane (A : Finset (ZMod 7)) : ℚ :=
  ((univ.filter (fun i => Disjoint (fanoLine i) A)).card : ℚ) / 7

/-- Uniform mechanism: probability a uniformly random `3`-subset avoids `A`. -/
def punif (A : Finset (ZMod 7)) : ℚ :=
  (((univ : Finset (ZMod 7)).powersetCard 3 |>.filter (fun S => Disjoint S A)).card : ℚ) / 35

/-- Inclusion–exclusion sign `(-1)^{|A|+1}`. -/
def sgn (A : Finset (ZMod 7)) : ℚ := if A.card % 2 = 1 then 1 else -1

/-- Expected cover time of the Fano-line mechanism. -/
def Eplane : ℚ := ∑ A ∈ (univ.powerset.filter (fun A => A.Nonempty)), sgn A / (1 - pplane A)

/-- Expected cover time of the uniform `3`-subset mechanism. -/
def Eunif : ℚ := ∑ A ∈ (univ.powerset.filter (fun A => A.Nonempty)), sgn A / (1 - punif A)

/-- The exact expected cover time of the Fano-line mechanism is `163/30`. -/
theorem Eplane_value : Eplane = 163 / 30 := by native_decide

/-- The exact expected cover time of the uniform mechanism is `85691/15810`. -/
theorem Eunif_value : Eunif = 85691 / 15810 := by native_decide

/-- **Fano-plane slowness (`q = 2`).** The projective-plane line mechanism has a
strictly larger expected cover time than the uniform `(q+1)`-subset mechanism —
the disproof of the Grünbaum–Yaakobi conjecture in the smallest case. -/
theorem fano_slowness : Eunif < Eplane := by native_decide

/-! ### Geometric avoid-counts: the general `q`-formulas at `q = 2` -/

set_option maxRecDepth 10000 in
/-- Each point is missed by exactly `q² = 4` lines. -/
theorem point_avoid :
    ∀ P : ZMod 7, (univ.filter (fun i => P ∉ fanoLine i)).card = 4 := by decide

set_option maxRecDepth 10000 in
/-- Each pair of distinct points is missed by exactly `q² - q = 2` lines. -/
theorem pair_avoid :
    ∀ P Q : ZMod 7, P ≠ Q →
      (univ.filter (fun i => P ∉ fanoLine i ∧ Q ∉ fanoLine i)).card = 2 := by decide

set_option maxRecDepth 10000 in
/-- A collinear triple is missed by exactly `q² - 2q = 0` lines. -/
theorem coll_avoid :
    ∀ A ∈ (univ : Finset (ZMod 7)).powersetCard 3,
      (∃ i, A ⊆ fanoLine i) → (univ.filter (fun i => Disjoint (fanoLine i) A)).card = 0 := by
  decide

set_option maxRecDepth 10000 in
/-- A generic (non-collinear) triple is missed by exactly `(q-1)² = 1` line. -/
theorem gen_avoid :
    ∀ A ∈ (univ : Finset (ZMod 7)).powersetCard 3,
      (¬ ∃ i, A ⊆ fanoLine i) → (univ.filter (fun i => Disjoint (fanoLine i) A)).card = 1 := by
  decide

end ProjectivePlaneCouponFano