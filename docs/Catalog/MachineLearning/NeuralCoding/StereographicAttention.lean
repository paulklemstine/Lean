/-
# Stereographic attention on the unit sphere

This file studies the Cauchy weight obtained after placing queries and keys on a
unit sphere.  It reuses `conformalFactor`, the catalog's stereographic conformal
factor.  The main finding is an obstruction to the proposed sparsity claim:
chordal distance on a unit sphere is at most two, so every Cauchy weight is at
least `1/5`.  Consequently no fixed threshold at or below `1/5` can discard even
one key, randomly sampled or otherwise.
-/
import MachineLearning.NeuralCoding.InverseStereographicNeuralField

open Real Finset

noncomputable section

namespace StereographicAttention

variable {E : Type*} [SeminormedAddCommGroup E]

/-- The Cauchy attention weight, expressed using the catalog's stereographic
conformal factor.  The division by two changes `2 / (1 + r²)` into
`1 / (1 + r²)`. -/
def cauchyWeight (q k : E) : ℝ := conformalFactor (dist q k ^ 2) / 2

/-- The catalog-based definition is exactly the usual Cauchy kernel. -/
theorem cauchyWeight_eq (q k : E) :
    cauchyWeight q k = 1 / (1 + dist q k ^ 2) := by
  simp [cauchyWeight, conformalFactor]
  ring

/-- Cauchy weights are strictly positive. -/
theorem cauchyWeight_pos (q k : E) : 0 < cauchyWeight q k := by
  rw [cauchyWeight_eq]
  positivity

/-- Two points of norm one have chordal distance at most two. -/
theorem unitSphere_dist_le_two {q k : E} (hq : ‖q‖ = 1) (hk : ‖k‖ = 1) :
    dist q k ≤ 2 := by
  calc
    dist q k ≤ ‖q‖ + ‖k‖ := dist_le_norm_add_norm q k
    _ = 2 := by rw [hq, hk]; norm_num

/-- **Uniform lower bound.** Every Cauchy weight between unit-sphere points is
at least `1/5`.  This deterministic statement also applies almost surely under
any probability distribution supported on the unit sphere. -/
theorem unitSphere_cauchyWeight_lower {q k : E} (hq : ‖q‖ = 1) (hk : ‖k‖ = 1) :
    (1 : ℝ) / 5 ≤ cauchyWeight q k := by
  rw [cauchyWeight_eq]
  have hd : dist q k ≤ 2 := unitSphere_dist_le_two hq hk
  have hd0 : 0 ≤ dist q k := dist_nonneg
  have hden : 1 + dist q k ^ 2 ≤ (5 : ℝ) := by nlinarith
  exact one_div_le_one_div_of_le (by positivity) hden

/-- Keys whose Cauchy weight is below a threshold. -/
def belowThreshold (q : E) (keys : Finset E) (τ : ℝ) : Finset E :=
  keys.filter (fun k => cauchyWeight q k < τ)

/-- At any threshold at most `1/5`, a unit-sphere query has no below-threshold
keys in a finite unit-sphere key set. -/
theorem belowThreshold_eq_empty (q : E) (keys : Finset E) (τ : ℝ)
    (hq : ‖q‖ = 1) (hkeys : ∀ k ∈ keys, ‖k‖ = 1) (hτ : τ ≤ (1 : ℝ) / 5) :
    belowThreshold q keys τ = ∅ := by
  apply Finset.filter_eq_empty_iff.mpr
  intro k hk
  exact not_lt_of_ge (hτ.trans (unitSphere_cauchyWeight_lower hq (hkeys k hk)))

/-- Equivalently, all keys remain active at thresholds at most `1/5`.
Thus the active count is exactly `N`, rather than `O(√N)`. -/
theorem active_count_eq_card (q : E) (keys : Finset E) (τ : ℝ)
    (hq : ‖q‖ = 1) (hkeys : ∀ k ∈ keys, ‖k‖ = 1) (hτ : τ ≤ (1 : ℝ) / 5) :
    (keys.filter (fun k => τ ≤ cauchyWeight q k)).card = keys.card := by
  congr 1
  exact Finset.filter_true_of_mem fun k hk =>
    hτ.trans (unitSphere_cauchyWeight_lower hq (hkeys k hk))

/-- For more than one key, the exact active count is strictly larger than the
natural-number square root of the key count.  This directly refutes a literal
`≤ √N` sparsity bound for fixed threshold `τ ≤ 1/5`. -/
theorem active_count_gt_sqrt (q : E) (keys : Finset E) (τ : ℝ)
    (hq : ‖q‖ = 1) (hkeys : ∀ k ∈ keys, ‖k‖ = 1) (hτ : τ ≤ (1 : ℝ) / 5)
    (hcard : 1 < keys.card) :
    Nat.sqrt keys.card < (keys.filter (fun k => τ ≤ cauchyWeight q k)).card := by
  rw [active_count_eq_card q keys τ hq hkeys hτ]
  exact Nat.sqrt_lt_self hcard

end StereographicAttention