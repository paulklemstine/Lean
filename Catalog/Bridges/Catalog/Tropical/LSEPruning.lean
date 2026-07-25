/-
# Finite-Temperature Pruning Law for Log-Sum-Exp Aggregation

This file formalizes a sharp finite-temperature stability principle for
log-sum-exp (LSE) aggregation under head pruning. The core result:
when coordinates are redundant in the tropical sense (dominated by the
maximum of retained coordinates), finite-temperature smoothing cannot
amplify their removal by more than an entropic term.

## Main results

* `lse_prune_redundant_set_bound` — removing a set of dominated heads
  changes LSE by at most `τ * log (|R| + 1)`.
* `lse_prune_refined_gap_bound` — the refined free-energy defect formula.
* `lse_prune_gap_with_margin` — exponential improvement under uniform gap.

## Cross-domain significance

- **Statistical mechanics**: LSE is free energy; pruning deletes microstates.
- **Information theory**: difference of log-partitions as coding redundancy.
- **Tropical geometry**: certified dequantization estimate (τ → 0 limit).
- **Neural network pruning**: certified head removal under softmax aggregation.

Keywords: certified pruning, attention head redundancy, log-sum-exp stability,
tropicalization error, free energy perturbation, entropy-compression tradeoff,
softmax robustness, idempotent analysis, KL / Gibbs distributions,
low-temperature asymptotics
-/

import Mathlib

open Finset Real BigOperators

noncomputable section

/-! ## Helper lemmas about sums of exponentials -/

/-- Sum of exponentials over a nonempty finset is positive. -/
lemma sum_exp_pos_of_nonempty {ι : Type*} (τ : ℝ) (x : ι → ℝ)
    (S : Finset ι) (hS : S.Nonempty) :
    0 < ∑ i ∈ S, Real.exp (x i / τ) :=
  Finset.sum_pos (fun i _ => Real.exp_pos _) hS

/-
The sum of exponentials over a set dominates the exponential of the supremum.
This captures the idea that the partition function is at least as large as
the Boltzmann weight of the maximum-energy state.
-/
lemma sum_exp_ge_exp_sup {ι : Type*} (τ : ℝ) (hτ : 0 < τ) (x : ι → ℝ)
    (K : Finset ι) (hK : K.Nonempty) :
    Real.exp (Finset.sup' K hK (fun i => x i) / τ) ≤ ∑ i ∈ K, Real.exp (x i / τ) := by
  -- By definition of supremum, there exists an element $k \in K$ such that $x k = \sup_{i \in K} x i$.
  obtain ⟨k, hk⟩ : ∃ k ∈ K, x k = Finset.sup' K hK (fun i => x i) := by
    exact ( Finset.exists_max_image K x hK ) |> fun ⟨ k, hk₁, hk₂ ⟩ => ⟨ k, hk₁, le_antisymm ( Finset.le_sup' ( fun i => x i ) hk₁ ) ( Finset.sup'_le _ _ fun i hi => hk₂ i hi ) ⟩;
  exact Finset.single_le_sum ( fun i _ => Real.exp_nonneg ( x i / τ ) ) hk.1 |> le_trans ( by rw [ ← hk.2 ] )

/-
Monotonicity of exp(·/τ) when τ > 0.
-/
lemma exp_div_le_exp_div {τ a b : ℝ} (hτ : 0 < τ) (hab : a ≤ b) :
    Real.exp (a / τ) ≤ Real.exp (b / τ) := by
  gcongr

/-
Sum of removed exponentials is bounded by card times the top exponent.
-/
lemma sum_exp_removed_le_card_mul {ι : Type*} [DecidableEq ι]
    (τ : ℝ) (hτ : 0 < τ) (x : ι → ℝ)
    (K R : Finset ι) (hK : K.Nonempty)
    (hdom : ∀ j ∈ R, x j ≤ Finset.sup' K hK (fun i => x i)) :
    ∑ j ∈ R, Real.exp (x j / τ) ≤
      R.card * Real.exp (Finset.sup' K hK (fun i => x i) / τ) := by
  exact le_trans ( Finset.sum_le_sum fun i hi => Real.exp_le_exp.mpr ( div_le_div_of_nonneg_right ( hdom i hi ) hτ.le ) ) ( by simp +decide [ mul_comm ] )

/-
The full sum is at most (|R| + 1) times the kept sum.
-/
lemma sum_exp_all_le_mul_keep {ι : Type*} [DecidableEq ι]
    (τ : ℝ) (hτ : 0 < τ) (x : ι → ℝ)
    (K R : Finset ι) (hK : K.Nonempty) (hdisj : Disjoint K R)
    (hdom : ∀ j ∈ R, x j ≤ Finset.sup' K hK (fun i => x i)) :
    ∑ i ∈ (K ∪ R), Real.exp (x i / τ) ≤
      (↑R.card + 1) * ∑ i ∈ K, Real.exp (x i / τ) := by
  -- Split K ∪ R sum using Finset.sum_union hdisj.
  have h_split : ∑ i ∈ K ∪ R, Real.exp (x i / τ) = ∑ i ∈ K, Real.exp (x i / τ) + ∑ i ∈ R, Real.exp (x i / τ) := by
    exact Finset.sum_union hdisj;
  -- By sum_exp_removed_le_card_mul, ∑R ≤ |R| * exp(s/τ).
  have h_sum_r : ∑ j ∈ R, Real.exp (x j / τ) ≤ (R.card : ℝ) * Real.exp ((Finset.sup' K hK (fun i => x i)) / τ) := by
    convert sum_exp_removed_le_card_mul τ hτ x K R hK hdom;
  nlinarith [ sum_exp_ge_exp_sup τ hτ x K hK, Real.exp_pos ( ( Finset.sup' K hK fun i => x i ) / τ ) ]

/-
Subset monotonicity of sums of exponentials.
-/
lemma sum_exp_le_sum_exp_union {ι : Type*} [DecidableEq ι] (x : ι → ℝ) (τ : ℝ)
    (K R : Finset ι) (hdisj : Disjoint K R) :
    ∑ i ∈ K, Real.exp (x i / τ) ≤ ∑ i ∈ (K ∪ R), Real.exp (x i / τ) := by
  exact Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_union_left ) fun _ _ _ => Real.exp_nonneg _

/-
Log-transfer: from a ≤ c * b with positivity, deduce τ * log a - τ * log b ≤ τ * log c.
-/
lemma tau_log_le_of_le_mul {a b c τ : ℝ} (hτ : 0 < τ) (ha : 0 < a)
    (hb : 0 < b) (hc : 0 < c) (h : a ≤ c * b) :
    τ * Real.log a - τ * Real.log b ≤ τ * Real.log c := by
  nlinarith [ Real.log_le_log ( by positivity ) h, Real.log_mul hc.ne' hb.ne' ]

/-
Non-negativity of log ratio when a ≤ b.
-/
lemma tau_log_nonneg_of_le {a b τ : ℝ} (hτ : 0 < τ) (ha : 0 < a)
    (hab : a ≤ b) :
    0 ≤ τ * Real.log b - τ * Real.log a := by
  exact sub_nonneg_of_le ( mul_le_mul_of_nonneg_left ( Real.log_le_log ha hab ) hτ.le )

/-! ## Main theorems -/

/-
**Redundant set pruning bound.** Removing a set of dominated heads
changes the log-sum-exp by at most `τ * log (|R| + 1)`.

This is the central certified pruning theorem: if every removed head `j ∈ R`
has score dominated by the maximum of the kept set `K`, then the
finite-temperature aggregate changes by a bounded entropic cost.
-/
theorem lse_prune_redundant_set_bound
    {n : ℕ} (τ : ℝ) (hτ : 0 < τ) (x : Fin n → ℝ)
    (K : Finset (Fin n)) (hK : K.Nonempty)
    (R : Finset (Fin n)) (hdisj : Disjoint K R) (hall : K ∪ R = Finset.univ)
    (hdom : ∀ j ∈ R, x j ≤ Finset.sup' K hK (fun i => x i)) :
    let lse_all := τ * Real.log (∑ i : Fin n, Real.exp (x i / τ))
    let lse_keep := τ * Real.log (∑ i ∈ K, Real.exp (x i / τ))
    0 ≤ lse_all - lse_keep ∧
    lse_all - lse_keep ≤ τ * Real.log (↑R.card + 1) := by
  constructor;
  · exact sub_nonneg_of_le ( mul_le_mul_of_nonneg_left ( Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) hK ) ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ _ ) fun _ _ _ => Real.exp_nonneg _ ) ) hτ.le );
  · convert tau_log_le_of_le_mul hτ _ _ _ _ using 1;
    · exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ⟨ ⟨ 0, Nat.pos_of_ne_zero ( by aesop_cat ) ⟩, Finset.mem_univ _ ⟩;
    · exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) hK;
    · positivity;
    · convert sum_exp_all_le_mul_keep τ hτ x K R hK hdisj hdom using 1;
      rw [ hall ]

/-
**Refined free-energy defect bound.** The pruning gap is controlled by
the exact thermodynamic defect formula involving individual excess
Boltzmann weights. This is the strongest form of the pruning bound.
-/
theorem lse_prune_refined_gap_bound
    {n : ℕ} (τ : ℝ) (hτ : 0 < τ) (x : Fin n → ℝ)
    (K : Finset (Fin n)) (hK : K.Nonempty)
    (R : Finset (Fin n)) (hdisj : Disjoint K R) (hall : K ∪ R = Finset.univ) :
    let s := Finset.sup' K hK (fun i => x i)
    let lse_all := τ * Real.log (∑ i : Fin n, Real.exp (x i / τ))
    let lse_keep := τ * Real.log (∑ i ∈ K, Real.exp (x i / τ))
    lse_all - lse_keep ≤ τ * Real.log (1 + ∑ j ∈ R, Real.exp ((x j - s) / τ)) := by
  simp_all +decide [ ← mul_sub, ← Finset.sum_div _ _ _, mul_div, Real.exp_sub ];
  nontriviality;
  rw [ ← Real.log_mul, ← Real.log_exp ( ∑ i ∈ K, Real.exp ( x i / τ ) ) ];
  · refine' Real.log_le_log _ _;
    · exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ⟨ Classical.choose hK, Finset.mem_univ _ ⟩;
    · rw [ ← Finset.sum_add_sum_compl ( K ), show ( Kᶜ : Finset ( Fin n ) ) = R from ?_ ];
      · norm_num [ add_mul, sub_div, Real.exp_sub ];
        rw [ Finset.sum_mul _ _ _ ];
        gcongr;
        rw [ div_mul_eq_mul_div, le_div_iff₀ ( Real.exp_pos _ ) ];
        exact mul_le_mul_of_nonneg_left ( by simpa using sum_exp_ge_exp_sup τ hτ x K hK ) ( Real.exp_nonneg _ );
      · rw [ Finset.compl_eq_univ_sdiff, ← hall, Finset.union_sdiff_cancel_left hdisj ];
  · exact ne_of_gt ( add_pos_of_pos_of_nonneg zero_lt_one ( Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ ) );
  · exact ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) hK

/-
**Margin-refined pruning bound.** When removed heads have a gap δ below
the retained maximum, the pruning cost decays exponentially with δ/τ.
This captures the key insight that deeply dominated heads are virtually
free to prune even at moderate temperature.
-/
theorem lse_prune_gap_with_margin
    {n : ℕ} (τ δ : ℝ) (hτ : 0 < τ) (_hδ : 0 ≤ δ)
    (x : Fin n → ℝ) (K R : Finset (Fin n)) (hK : K.Nonempty)
    (hdisj : Disjoint K R) (_hall : K ∪ R = Finset.univ)
    (hdom : ∀ j ∈ R, x j ≤ Finset.sup' K hK (fun i => x i) - δ) :
    let lse_all := τ * Real.log (∑ i ∈ (K ∪ R), Real.exp (x i / τ))
    let lse_keep := τ * Real.log (∑ i ∈ K, Real.exp (x i / τ))
    lse_all - lse_keep ≤ τ * Real.log (1 + ↑R.card * Real.exp (-δ / τ)) := by
  have h_sum_R_le : ∑ j ∈ R, Real.exp (x j / τ) ≤ R.card * Real.exp ((K.sup' hK (fun i => x i) - δ) / τ) := by
    exact le_trans ( Finset.sum_le_sum fun i hi => Real.exp_le_exp.mpr ( div_le_div_of_nonneg_right ( hdom i hi ) hτ.le ) ) ( by simp +decide [ mul_div_cancel₀ _ hτ.ne' ] );
  have h_sum_K_ge : ∑ i ∈ K, Real.exp (x i / τ) ≥ Real.exp ((K.sup' hK (fun i => x i)) / τ) := by
    exact sum_exp_ge_exp_sup τ hτ x K hK;
  have h_sum_union : ∑ i ∈ K ∪ R, Real.exp (x i / τ) = ∑ i ∈ K, Real.exp (x i / τ) + ∑ j ∈ R, Real.exp (x j / τ) := by
    rw [ Finset.sum_union hdisj ];
  have h_log_union : Real.log (∑ i ∈ K ∪ R, Real.exp (x i / τ)) ≤ Real.log (∑ i ∈ K, Real.exp (x i / τ)) + Real.log (1 + R.card * Real.exp (-δ / τ)) := by
    rw [ h_sum_union, ← Real.log_mul ( ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) hK ) ( ne_of_gt <| add_pos_of_pos_of_nonneg zero_lt_one <| mul_nonneg ( Nat.cast_nonneg _ ) <| Real.exp_nonneg _ ) ];
    refine' Real.log_le_log ( add_pos_of_pos_of_nonneg ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) hK ) ( Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ ) ) _;
    rw [ show ( ( K.sup' hK fun i => x i ) - δ ) / τ = ( K.sup' hK fun i => x i ) / τ + ( -δ / τ ) by ring, Real.exp_add ] at *;
    nlinarith [ Real.exp_pos ( ( K.sup' hK fun i => x i ) / τ ), Real.exp_pos ( -δ / τ ), mul_le_mul_of_nonneg_right h_sum_K_ge ( Real.exp_nonneg ( -δ / τ ) ) ];
  nlinarith

end