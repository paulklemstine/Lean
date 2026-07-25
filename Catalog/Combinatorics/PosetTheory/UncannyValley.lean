import Mathlib
import Shared.PosetTheory.ProofRefinement

/-!
# Discrete uncanny valleys in confidence profiles

A confidence profile is a real-valued function on an ordered collection of rigor
levels.  This chapter isolates a falsifiable mathematical content for an uncanny
valley: confidence falls strictly up to one level and rises strictly afterwards.
It develops uniqueness, aggregation, robustness under measurement error, and an
exact total-variation law.  The final section connects the order parameter to the
complexity-decreasing refinement relation developed in `Shared.ProofRefinement`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Seven testable claims were ranked by expected impact.
(1) A population sum preserves a common strict valley; (2) a valley with margin
`δ` survives uniform perturbations smaller than `δ/2`; (3) monotone descent and
ascent force an exact variation formula; (4) the same margin theorem holds on an
arbitrary finite type, so spacing of rigor levels is irrelevant; (5) refinement
can preserve meaning while strictly changing the complexity coordinate; (6) a
mixture of populations with different valley locations should have at most as
many valleys as the number of groups; (7) noisy individual valleys concentrated
near one level should force a population valley nearby.  Claims (6) and (7) are
the bold frontier because they require additional quantitative hypotheses.

Experiment (Experimenter): The five-level profile `(8,5,1,4,7)` and a second
profile `(9,6,2,3,8)` both descend to level `2` and then recover; their aggregate
`(17,11,3,7,15)` does likewise.  Direct subtraction gives respective minimum
margins `3`, `1`, and `4`.  In contrast, averaging profiles with minima at
different locations can create a tie, refuting unconditional versions of (6)
and (7).  These calculations suggested the sharp perturbation threshold
`2ε < δ` and the variation identity proved below.

Analysis (Analyst): The unifying invariant is not smoothness but a system of
pairwise inequalities.  Strict inequalities add across respondents, whereas the
triangle inequality controls observational error.  Total variation separates
exactly into descent and recovery costs when every adjacent step has the expected
sign.

Critique (Critic): No psychological conclusion follows without survey data; the
results are conditional laws for a proposed model.  A unique minimum alone does
not imply a valley, and averaging valleys at different locations need not preserve
unimodality.  The perturbation constant is sharp at equality, where ties can occur.

Synthesis (Principal Investigator): The surviving core is a finite combinatorial
model with four independent certificates: strict shape, positive margin,
population aggregation, and path variation.  The refinement bridge supplies a
second coordinate—semantic invariance versus structural complexity—without
identifying complexity itself with confidence.
-- !-- Lab Notes -- !--
-/

namespace UncannyValley

/-- A profile has a strict valley at `v` when it strictly decreases to `v` and
strictly increases after `v`. -/
def StrictValleyAt {ι α : Type*} [LinearOrder ι] [Preorder α]
    (U : ι → α) (v : ι) : Prop :=
  StrictAntiOn U (Set.Iic v) ∧ StrictMonoOn U (Set.Ici v)

/-
A strict valley point is the unique global minimizer.
-/
theorem strictValley_unique_min {ι α : Type*} [LinearOrder ι] [Preorder α]
    {U : ι → α} {v : ι} (h : StrictValleyAt U v) :
    ∀ i, i ≠ v → U v < U i := by
  intro i hi; cases lt_or_gt_of_ne hi <;> have := h.1 <;> have := h.2 <;> simp_all +decide [ StrictAntiOn, StrictMonoOn ] ;
  · exact ‹∀ ⦃a : ι⦄, a ≤ v → ∀ ⦃b : ι⦄, b ≤ v → a < b → U b < U a› ( le_of_lt ‹_› ) le_rfl ‹_›;
  · exact this le_rfl ( le_of_lt ‹_› ) ‹_›

/-
Two strict valley locations for the same profile must coincide.
-/
theorem strictValley_location_unique {ι α : Type*} [LinearOrder ι] [Preorder α]
    {U : ι → α} {v w : ι} (hv : StrictValleyAt U v)
    (hw : StrictValleyAt U w) : v = w := by
  contrapose! hv;
  exact fun h => lt_irrefl _ ( strictValley_unique_min h w hv.symm |> lt_of_lt_of_le <| le_of_lt <| strictValley_unique_min hw v hv )

/-- Quantitative separation of a proposed valley from every competing level. -/
def HasMarginAt {ι : Type*} (U : ι → ℝ) (v : ι) (δ : ℝ) : Prop :=
  ∀ i, i ≠ v → U v + δ ≤ U i

/-
A positive margin implies a unique minimizer.
-/
theorem margin_unique_min {ι : Type*} {U : ι → ℝ} {v : ι} {δ : ℝ}
    (hδ : 0 < δ) (h : HasMarginAt U v δ) :
    ∀ i, i ≠ v → U v < U i := by
  exact fun i hi => lt_of_lt_of_le ( lt_add_of_pos_right _ hδ ) ( h i hi )

/-
Uniform observational error below half the margin cannot move the unique
minimum.  The strict inequality `2ε < δ` is the sharp tie-avoidance threshold.
-/
theorem margin_stable_under_perturbation {ι : Type*} {U V : ι → ℝ}
    {v : ι} {δ ε : ℝ} (hmargin : HasMarginAt U v δ)
    (hclose : ∀ i, |V i - U i| ≤ ε) (hsharp : 2 * ε < δ) :
    ∀ i, i ≠ v → V v < V i := by
  exact fun i hi => by linarith [ abs_le.mp ( hclose i ), abs_le.mp ( hclose v ), hmargin i hi ] ;

/-- The aggregate confidence of a finite population. -/
def aggregate {P ι : Type*} [Fintype P] (U : P → ι → ℝ) (i : ι) : ℝ :=
  ∑ p, U p i

/-
If every respondent has a strict valley at the same level, their aggregate
profile has a strict valley there as well.
-/
theorem aggregate_strictValleyAt {P ι : Type*} [Fintype P] [Nonempty P]
    [LinearOrder ι] (U : P → ι → ℝ) (v : ι)
    (h : ∀ p, StrictValleyAt (U p) v) :
    StrictValleyAt (aggregate U) v := by
  constructor <;> intro x hx y hy hxy;
  · exact Finset.sum_lt_sum_of_nonempty ( Finset.univ_nonempty ) fun p _ => h p |>.1 hx hy hxy;
  · exact Finset.sum_lt_sum_of_nonempty ( Finset.univ_nonempty ) fun p _ => h p |>.2 hx hy hxy

/-
Individual margins add: a population whose members share a candidate valley
has aggregate separation equal to the sum of their certified margins.
-/
theorem aggregate_hasMarginAt {P ι : Type*} [Fintype P]
    (U : P → ι → ℝ) (v : ι) (δ : P → ℝ)
    (h : ∀ p, HasMarginAt (U p) v (δ p)) :
    HasMarginAt (aggregate U) v (∑ p, δ p) := by
  intro i hi
  have h_sum : ∑ p, (U p i) ≥ ∑ p, (U p v + δ p) := by
    exact Finset.sum_le_sum fun p _ => h p i hi
  simp [aggregate] at *;
  rwa [ Finset.sum_add_distrib ] at h_sum

/-- Total variation along the first `n` edges of a profile on natural levels. -/
def pathVariation (U : ℕ → ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => pathVariation U n + |U (n + 1) - U n|

/-
Under adjacent nonincrease, variation is exactly the total drop.
-/
theorem pathVariation_eq_drop (U : ℕ → ℝ) (n : ℕ)
    (hdown : ∀ k, k < n → U (k + 1) ≤ U k) :
    pathVariation U n = U 0 - U n := by
  induction' n with n ih;
  · norm_num [ pathVariation ];
  · rw [ show pathVariation U ( n + 1 ) = pathVariation U n + |U ( n + 1 ) - U n| by rfl, ih fun k hk => hdown k ( Nat.lt_succ_of_lt hk ), abs_of_nonpos ] <;> linarith [ hdown n ( Nat.lt_succ_self n ) ]

/-
Under adjacent nondecrease, variation is exactly the total rise.
-/
theorem pathVariation_eq_rise (U : ℕ → ℝ) (n : ℕ)
    (hup : ∀ k, k < n → U k ≤ U (k + 1)) :
    pathVariation U n = U n - U 0 := by
  induction' n with n ih <;> simp_all +decide [ pathVariation ];
  rw [ abs_of_nonneg ( sub_nonneg_of_le ( hup n le_rfl ) ), ih fun k hk => hup k hk.le, sub_add_eq_add_sub ] ; ring

/-
Exact variation decomposition for a valley with `left` descent steps and
`right` recovery steps.
-/
theorem valley_variation_identity (U : ℕ → ℝ) (left right : ℕ)
    (hdown : ∀ k, k < left → U (k + 1) ≤ U k)
    (hup : ∀ k, k < right → U (left + k) ≤ U (left + k + 1)) :
    pathVariation U left + pathVariation (fun k => U (left + k)) right =
      (U 0 - U left) + (U (left + right) - U left) := by
  convert congr_arg₂ ( · + · ) ( pathVariation_eq_drop U left hdown ) ( pathVariation_eq_rise ( fun k => U ( left + k ) ) right ( fun k hk => hup k hk ) ) using 1

/-! ## Structural refinement bridge -/

open Learning.ProofRefinement
open Learning.ProofRefinement.ProofTerm

/-
One structural refinement step simultaneously preserves the asserted
conclusion and strictly decreases the combined tree complexity.
-/
theorem refinement_semantics_complexity_bridge {p q : ProofTerm}
    (h : Reduces p q) :
    conclusion p = conclusion q ∧ combinedPT q < combinedPT p := by
  exact ⟨ reduces_conclusion h, reduces_combined_lt h ⟩

/-
Aggregation and robustness compose: summed individual margins certify that
an observed population profile still has the same unique minimum.
-/
theorem aggregate_min_stable {P ι : Type*} [Fintype P]
    (U : P → ι → ℝ) (V : ι → ℝ) (v : ι) (δ : P → ℝ) (ε : ℝ)
    (hmargins : ∀ p, HasMarginAt (U p) v (δ p))
    (hclose : ∀ i, |V i - aggregate U i| ≤ ε)
    (hsharp : 2 * ε < ∑ p, δ p) :
    ∀ i, i ≠ v → V v < V i := by
  convert margin_stable_under_perturbation ( aggregate_hasMarginAt U v δ hmargins ) hclose hsharp using 1

end UncannyValley