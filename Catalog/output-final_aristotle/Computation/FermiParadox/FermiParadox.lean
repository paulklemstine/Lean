import Mathlib

/-!
# A finite probabilistic core for the Fermi question

This file separates conclusions that really follow from a sparse Drake-style model
from conclusions that do not.  For `N` candidate planets and per-planet probability
`p`, the independent model gives probability `(1-p)^N` that all planets are empty.
The central theorem proves the rigorous union-bound estimate

`1 - (1-p)^N ≤ N p`.

Consequently, an expected count `N p ≤ 1/10` implies at least `9/10` probability of
an empty universe in this model.  Merely knowing `N p < 1`, however, does not prove
certainty of emptiness; an explicit two-outcome countermodel records that limitation.
The final results give the genuinely applicable sparse pigeonhole statement: few
civilizations force many planets to be empty, rather than forcing a collision.
-/

namespace FermiParadox

/-- Probability that no success occurs in `N` independent Bernoulli trials. -/
def emptyProbability (N : ℕ) (p : ℝ) : ℝ := (1 - p) ^ N

/-- Expected number of successes in `N` identical Bernoulli trials. -/
def expectedCount (N : ℕ) (p : ℝ) : ℝ := N * p

/-- The product form of a four-filter Drake-style estimate. -/
def drakeProbability (abiogenesis intelligence technology longevity : ℝ) : ℝ :=
  abiogenesis * intelligence * technology * longevity

/-
A product of nonnegative filters is bounded by the product of their individual
upper estimates.
-/
theorem drake_product_mono
    {a i t l A I T L : ℝ}
    (ha0 : 0 ≤ a) (hi0 : 0 ≤ i) (ht0 : 0 ≤ t) (hl0 : 0 ≤ l)
    (ha : a ≤ A) (hi : i ≤ I) (ht : t ≤ T) (hl : l ≤ L) :
    drakeProbability a i t l ≤ drakeProbability A I T L := by
  apply_rules [ mul_le_mul ];
  · linarith;
  · exact mul_nonneg ( by linarith ) ( by linarith );
  · exact mul_nonneg ( mul_nonneg ( by linarith ) ( by linarith ) ) ( by linarith )

/-
Bernoulli's inequality in the exact form needed for the empty-universe bound.
-/
theorem one_sub_pow_lower (N : ℕ) {p : ℝ} (hp1 : p ≤ 1) :
    1 - N * p ≤ (1 - p) ^ N := by
  exact one_add_mul_le_pow (by linarith) _ |> le_trans (by linarith)

/-
**Main theorem (finite Fermi union bound).** In the independent equal-rate model,
the chance that at least one civilization exists is at most the expected number.
-/
theorem nonemptyProbability_le_expected
    (N : ℕ) {p : ℝ} (hp1 : p ≤ 1) :
    1 - emptyProbability N p ≤ expectedCount N p := by
  unfold emptyProbability expectedCount;
  linarith [one_sub_pow_lower N hp1]

/-
If the expected count is at most `ε`, the model assigns probability at least
`1-ε` to complete emptiness.
-/
theorem emptyProbability_lower_of_expected_le
    (N : ℕ) {p ε : ℝ} (hp1 : p ≤ 1)
    (hE : expectedCount N p ≤ ε) :
    1 - ε ≤ emptyProbability N p := by
  linarith [nonemptyProbability_le_expected N hp1]

/-
Four explicit conservative filters yield per-planet probability `10⁻¹¹`.
-/
theorem conservative_drake_value :
    drakeProbability (1 / 10 : ℝ) (1 / 100) (1 / 100) (1 / 1000000) =
      1 / 100000000000 := by
  norm_num [ drakeProbability ]

/-
With ten billion candidate planets and the explicit filters above, the expected
number is exactly one tenth.
-/
theorem conservative_expected_value :
    expectedCount 10000000000
      (drakeProbability (1 / 10 : ℝ) (1 / 100) (1 / 100) (1 / 1000000)) = 1 / 10 := by
  unfold expectedCount drakeProbability; norm_num;

/-
The concrete conservative model therefore gives at least `90%` probability that
all ten billion candidates are empty.
-/
theorem conservative_empty_probability :
    (9 / 10 : ℝ) ≤ emptyProbability 10000000000
      (drakeProbability (1 / 10 : ℝ) (1 / 100) (1 / 100) (1 / 1000000)) := by
  convert emptyProbability_lower_of_expected_le 10000000000 _
    conservative_expected_value.le using 1
  · norm_num
  · unfold drakeProbability
    norm_num

/-
Expectation below one does **not** logically imply certain emptiness.  This
explicit two-outcome random count is nonzero with probability `9/10`, while its
expectation is still below one.
-/
theorem expectation_below_one_not_certainty :
    let probability : Bool → ℝ := fun b => if b then 9 / 10 else 1 / 10
    let count : Bool → ℕ := fun b => if b then 1 else 0
    (∑ b : Bool, probability b * count b) < 1 ∧
      (∑ b : Bool, probability b) = 1 ∧
      probability true > 0 := by
  norm_num [ Finset.sum_pair ]

/-
Sparse pigeonhole principle: the occupied planets are no more numerous than the
civilizations that choose them.
-/
theorem occupied_planets_le_civilizations
    {C P : Type*} [Fintype C] [Fintype P] [DecidableEq P] (home : C → P) :
    (Finset.univ.image home).card ≤ Fintype.card C := by
  exact Finset.card_image_le.trans_eq ( Finset.card_univ )

/-
Dual pigeonhole conclusion appropriate to a sparse cosmos: at least `P-C` planets
are empty (expressed without truncated subtraction).
-/
theorem many_planets_empty
    {C P : Type*} [Fintype C] [Fintype P] [DecidableEq P] (home : C → P) :
    Fintype.card P ≤
      (Finset.univ.filter fun p : P => p ∉ Finset.univ.image home).card + Fintype.card C := by
  -- The cardinality of the set of occupied planets is at most the cardinality of C.
  have h_occupied_card : Finset.card (Finset.image home Finset.univ) ≤ Fintype.card C := by
    exact Finset.card_image_le.trans_eq ( Finset.card_univ );
  rw [ Finset.filter_not, Finset.card_sdiff ] ; norm_num;
  omega

/-
By contrast, the usual collision conclusion only begins when civilizations
outnumber planets.
-/
theorem collision_of_more_civilizations
    {C P : Type*} [Fintype C] [Fintype P] (home : C → P)
    (hmore : Fintype.card P < Fintype.card C) :
    ∃ c₁ c₂, c₁ ≠ c₂ ∧ home c₁ = home c₂ := by
  contrapose! hmore;
  exact Fintype.card_le_of_injective _ ( fun c₁ c₂ => not_imp_not.mp ( hmore c₁ c₂ ) )

end FermiParadox