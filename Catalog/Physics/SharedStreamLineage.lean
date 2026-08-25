/-
# One seed is one dataset: a whole lineage of nested runs is worth its longest leg

## Provenance (round-75 #3, exp 569b, paper 220)

The disposition recorded for this round is a sentence about *evidence*, not about code:

> every dataset from seed `20260824` is ONE seed's evidence.

`exp569` (`150k` samples per modulus) and `exp569b` (`600k`) consume the same chunk seeds
`SEED + 1000 + c` as a deterministic prefix, so the shorter run's draws sit inside the longer
run's draws.  A lab that keeps extending a run and pooling the extensions produces a *chain*
of legs `S₁ ⊆ S₂ ⊆ ⋯ ⊆ S_n` from a single stream.

This file proves that no amount of such pooling can beat the last leg.

## Main results

* `Design.nested_trueVar_of_weight` — for a nested pair the honest variance of the weighted
  pool is exactly `σ²(w²/|S| + (1 - w²)/|T|)`: the cross term cancels the second-order gain.
* `Design.nested_optimal_weight_is_zero` — the variance is minimised at `w = 0`, i.e. by
  *discarding the prefix leg*, strictly so whenever the prefix is proper.
* `Design.chain_pool_var_ge` — **the lineage theorem.**  For any chain of legs from one stream
  and any convex weighting, the honest variance of the pool is at least `σ²/|S_last|`.  A
  lineage of `n` nested "replications" carries exactly the information of its longest run.
* `Design.disjoint_pool_var` and `Design.fresh_stream_strictly_better` — the contrast: two
  *disjoint* legs (a genuinely fresh master seed) pool to `σ²/(|S| + |T|)`, strictly below the
  chain floor.  The fresh-seed run is the only move that lowers the floor.
* `Design.fresh_seed_halves_variance` — an equal-size independent replication halves the
  variance (error bars `÷√2`), the exact gain that re-running a prefix cannot produce.
-/
import Physics.PoolingIndependenceAudit

namespace Catalog.Physics.PoolingAudit

open Finset RealInnerProductSpace

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

namespace Design

variable (D : Design E)

/-- Honest variance of a nested pool at an arbitrary weight: `σ²(w²/|S| + (1 - w²)/|T|)`.
The `2w(1-w)` cross term is *not* a correction of order `w(1-w)`; it exactly upgrades
`(1-w)²` to `1 - w²`. -/
theorem nested_trueVar_of_weight {w : ℝ} {S T : Finset ℕ} (hST : S ⊆ T) (hS : S.Nonempty)
    (hT : T.Nonempty) :
    D.trueVar w S T =
      D.sigma ^ 2 * (w ^ 2 / (S.card : ℝ) + (1 - w ^ 2) / (T.card : ℝ)) := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  rw [D.trueVar_eq_naiveVar_add hS hT, naiveVar, Finset.inter_eq_left.2 hST]
  field_simp
  ring

/-- **Discard the prefix.**  For a nested pair the honest variance is strictly decreasing in
`|w|`: the weight `w = 0` — using only the long leg — is optimal, and any positive weight on
the prefix strictly hurts. -/
theorem nested_optimal_weight_is_zero {w : ℝ} {S T : Finset ℕ} (hST : S ⊆ T) (hS : S.Nonempty)
    (hlt : S.card < T.card) (hw : w ≠ 0) :
    D.trueVar 0 S T < D.trueVar w S T := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  have hT : T.Nonempty := Finset.card_pos.1 (lt_of_le_of_lt (Nat.zero_le _) hlt)
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  have hcast : (S.card : ℝ) < (T.card : ℝ) := by exact_mod_cast hlt
  have hσ : 0 < D.sigma ^ 2 := by have := D.sigma_pos; positivity
  rw [D.nested_trueVar_of_weight hST hS hT, D.nested_trueVar_of_weight hST hS hT]
  have hw2 : 0 < w ^ 2 := by positivity
  have hstep : (0 : ℝ) < w ^ 2 / (S.card : ℝ) - w ^ 2 / (T.card : ℝ) := by
    rw [sub_pos, div_lt_div_iff₀ hcT hcS]
    nlinarith
  have hgain := mul_pos hσ hstep
  have e0 : (0 : ℝ) ^ 2 / (S.card : ℝ) + (1 - (0 : ℝ) ^ 2) / (T.card : ℝ)
      = 1 / (T.card : ℝ) := by norm_num
  have e1 : w ^ 2 / (S.card : ℝ) + (1 - w ^ 2) / (T.card : ℝ)
      = 1 / (T.card : ℝ) + (w ^ 2 / (S.card : ℝ) - w ^ 2 / (T.card : ℝ)) := by ring
  rw [e0, e1, mul_add]
  linarith

/-! ### The lineage theorem -/

/-- Any two legs of a chain drawn from one stream have covariance at least `σ²/|S_n|`, where
`S_n` is a leg containing both. -/
theorem cov_mean_chain_ge {S : ℕ → Finset ℕ} (hne : ∀ i, (S i).Nonempty)
    (hmono : ∀ i j, i ≤ j → S i ⊆ S j) {i j n : ℕ} (hi : i ≤ n) (hj : j ≤ n) :
    D.sigma ^ 2 / ((S n).card : ℝ) ≤ ⟪D.mean (S i), D.mean (S j)⟫ := by
  have hσ : (0 : ℝ) < D.sigma ^ 2 := by have := D.sigma_pos; positivity
  have key : ∀ p q : ℕ, p ≤ q → q ≤ n →
      D.sigma ^ 2 / ((S n).card : ℝ) ≤ ⟪D.mean (S p), D.mean (S q)⟫ := by
    intro p q hpq hqn
    have hcq : (0 : ℝ) < ((S q).card : ℝ) := by
      exact_mod_cast Finset.card_pos.2 (hne q)
    have hcard : ((S q).card : ℝ) ≤ ((S n).card : ℝ) := by
      exact_mod_cast Finset.card_le_card (hmono q n hqn)
    rw [D.cov_mean_of_subset (hmono p q hpq) (hne p)]
    exact div_le_div_of_nonneg_left hσ.le hcq hcard
  rcases le_total i j with h | h
  · exact key i j h hj
  · rw [real_inner_comm]
    exact key j i h hi

/-- **The lineage theorem.**  Let `S 0 ⊆ S 1 ⊆ ⋯` be legs cut from a single stream — a run and
its extensions — and pool them with any nonnegative weights summing to `1`.  The honest
variance of the pool is at least `σ²/|S n|`, the variance of the longest leg alone.  Pooling a
seed's own lineage never produces information the last run does not already have. -/
theorem chain_pool_var_ge {S : ℕ → Finset ℕ} {w : ℕ → ℝ} {n : ℕ}
    (hne : ∀ i, (S i).Nonempty) (hmono : ∀ i j, i ≤ j → S i ⊆ S j)
    (hw : ∀ i ∈ Finset.range (n + 1), 0 ≤ w i)
    (hsum : ∑ i ∈ Finset.range (n + 1), w i = 1) :
    D.sigma ^ 2 / ((S n).card : ℝ)
      ≤ ⟪∑ i ∈ Finset.range (n + 1), w i • D.mean (S i),
          ∑ j ∈ Finset.range (n + 1), w j • D.mean (S j)⟫ := by
  have hexp : ⟪∑ i ∈ Finset.range (n + 1), w i • D.mean (S i),
      ∑ j ∈ Finset.range (n + 1), w j • D.mean (S j)⟫
      = ∑ i ∈ Finset.range (n + 1), ∑ j ∈ Finset.range (n + 1),
          w i * w j * ⟪D.mean (S i), D.mean (S j)⟫ := by
    rw [sum_inner]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [real_inner_smul_left, inner_sum, Finset.mul_sum]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [real_inner_smul_right]
    ring
  rw [hexp]
  have hbound : ∀ i ∈ Finset.range (n + 1), ∀ j ∈ Finset.range (n + 1),
      w i * w j * (D.sigma ^ 2 / ((S n).card : ℝ))
        ≤ w i * w j * ⟪D.mean (S i), D.mean (S j)⟫ := by
    intro i hi j hj
    have hi' : i ≤ n := Nat.lt_succ_iff.1 (Finset.mem_range.1 hi)
    have hj' : j ≤ n := Nat.lt_succ_iff.1 (Finset.mem_range.1 hj)
    exact mul_le_mul_of_nonneg_left (D.cov_mean_chain_ge hne hmono hi' hj')
      (mul_nonneg (hw i hi) (hw j hj))
  have hlow : ∑ i ∈ Finset.range (n + 1), ∑ j ∈ Finset.range (n + 1),
      w i * w j * (D.sigma ^ 2 / ((S n).card : ℝ))
      = D.sigma ^ 2 / ((S n).card : ℝ) := by
    have hrow : ∀ i, ∑ j ∈ Finset.range (n + 1), w i * w j * (D.sigma ^ 2 / ((S n).card : ℝ))
        = w i * (D.sigma ^ 2 / ((S n).card : ℝ)) := by
      intro i
      have : ∑ j ∈ Finset.range (n + 1), w i * w j * (D.sigma ^ 2 / ((S n).card : ℝ))
          = (w i * (D.sigma ^ 2 / ((S n).card : ℝ))) * ∑ j ∈ Finset.range (n + 1), w j := by
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun j _ => by ring
      rw [this, hsum, mul_one]
    rw [Finset.sum_congr rfl (fun i _ => hrow i), ← Finset.sum_mul, hsum, one_mul]
  calc D.sigma ^ 2 / ((S n).card : ℝ)
      = ∑ i ∈ Finset.range (n + 1), ∑ j ∈ Finset.range (n + 1),
          w i * w j * (D.sigma ^ 2 / ((S n).card : ℝ)) := hlow.symm
    _ ≤ ∑ i ∈ Finset.range (n + 1), ∑ j ∈ Finset.range (n + 1),
          w i * w j * ⟪D.mean (S i), D.mean (S j)⟫ :=
        Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => hbound i hi j hj

/-! ### What a genuinely fresh seed buys -/

/-- Disjoint legs — the fresh-stream replication — pool by inverse variance to the honest
`σ²/(|S| + |T|)`. -/
theorem disjoint_pool_var {S T : Finset ℕ} (hdisj : Disjoint S T) (hS : S.Nonempty)
    (hT : T.Nonempty) :
    D.trueVar (ivw S T) S T = D.sigma ^ 2 / ((S.card : ℝ) + (T.card : ℝ)) := by
  rw [D.trueVar_eq_naiveVar_add hS hT, D.naiveVar_ivw hS hT,
    Finset.disjoint_iff_inter_eq_empty.1 hdisj]
  simp

/-- **Only a fresh stream lowers the floor.**  A disjoint replication beats the chain floor of
the whole lineage: its pooled variance is strictly below the variance of the longest nested
leg. -/
theorem fresh_stream_strictly_better {S T : Finset ℕ} (hdisj : Disjoint S T) (hS : S.Nonempty)
    (hT : T.Nonempty) :
    D.trueVar (ivw S T) S T < D.sigma ^ 2 / (T.card : ℝ) := by
  have hcS : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hS
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  have hσ : (0 : ℝ) < D.sigma ^ 2 := by have := D.sigma_pos; positivity
  rw [D.disjoint_pool_var hdisj hS hT, div_lt_div_iff₀ (by linarith) hcT]
  nlinarith

/-- An equal-size independent replication — the decisive `seed 20260825` leg — halves the
variance, shrinking the honest interval by `√2`.  No re-run inside the old stream can do
this. -/
theorem fresh_seed_halves_variance {S T : Finset ℕ} (hdisj : Disjoint S T) (hS : S.Nonempty)
    (hT : T.Nonempty) (hcard : S.card = T.card) :
    D.trueVar (ivw S T) S T = (1 / 2) * (D.sigma ^ 2 / (T.card : ℝ)) := by
  have hcT : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hT
  have hcast : (S.card : ℝ) = (T.card : ℝ) := by exact_mod_cast hcard
  rw [D.disjoint_pool_var hdisj hS hT, hcast]
  field_simp
  ring

end Design

end Catalog.Physics.PoolingAudit